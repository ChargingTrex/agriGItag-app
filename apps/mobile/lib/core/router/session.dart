// Session state: who is signed in (role), which language the app shows, and the sign-in, restore, refresh and
//   sign-out flows that change it.
// Requirement: FR1 (phone + OTP sign-in), UserFlows §Log in once (stay signed in, no passwords), §When things go
//   wrong "Phone lost or changed" (sign in again on the new phone), §Who uses what (shared family phones),
//   §Design rules "Language first"; D-024 contract (docs/api/conventions.md "Authentication"); mobile-design.md §2.
// Callers: app_router.dart (redirect), app.dart (locale), bootstrap.dart (restore), api_client.dart (tokens,
//   refresh), features/auth screens (OTP/PIN), placeholder screens (language, sign-out), tests.

import 'dart:async';
import 'dart:convert';

import 'package:agritrace_api/agritrace_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../api/api_client.dart';
import '../db/providers.dart';

/// The three roles the mobile app serves. Wire names match the API roles.
enum Role {
  /// A farmer: sees only farmer screens.
  farmer('farmer'),

  /// An FPO field officer: officer screens plus assist mode for a farmer.
  fieldOfficer('field_officer'),

  /// A quality-check / grading officer at the processing unit.
  qc('qc_officer');

  const Role(this.wireName);

  /// Name used by the API (`SessionOut.roles`).
  final String wireName;
}

/// Tamil, the default language for the pilot FPOs (D-016).
const tamil = Locale('ta');

/// English, the second bundled language.
const english = Locale('en');

/// Immutable snapshot of the session.
@immutable
class Session {
  /// Creates a session. [role] is null while nobody is signed in; [locale] is the UI language; [sessionEnded] is
  /// true after the server ended the session (refresh token reused or revoked), so the sign-in screen explains why.
  const Session({this.role, this.locale = tamil, this.sessionEnded = false});

  /// Signed-in role, or null when signed out.
  final Role? role;

  /// Language the UI renders in.
  final Locale locale;

  /// Whether the last sign-out was forced by the server rather than chosen by the user.
  final bool sessionEnded;
}

/// A sign-in failure the screens turn into one sentence: the API error `code` (`otp_invalid`, `pin_locked`, ...),
/// `network` when no answer came, `portal_only` for accounts without a mobile role, `unknown` otherwise.
class AuthFailure implements Exception {
  /// Creates a failure with [code] and the error envelope's [details].
  const AuthFailure(this.code, [this.details = const {}]);

  /// Reads the failure out of any [error] thrown by a sign-in call.
  ///
  /// A [DioException] with the API error envelope gives its code and details; one without a response is
  /// `network`; an [AuthFailure] is returned as is; anything else is `unknown`. Throws nothing.
  factory AuthFailure.from(Object error) {
    if (error is AuthFailure) return error;
    if (error is! DioException) return const AuthFailure('unknown');
    final data = error.response?.data;
    if (data is Map && data['error'] is Map) {
      final body = data['error'] as Map;
      final details = body['details'];
      return AuthFailure('${body['code']}', details is Map ? details.cast<String, Object?>() : const {});
    }
    return error.response == null ? const AuthFailure('network') : const AuthFailure('unknown');
  }

  /// API error code or one of the client codes above.
  final String code;

  /// The envelope's `details` (e.g. `attempts_left`, `locked_until`, `retry_after_s`).
  final Map<String, Object?> details;

  /// Debug text; throws nothing.
  @override
  String toString() => 'AuthFailure($code, $details)';
}

/// The platform keystore (Keychain on iOS, Keystore-backed storage on Android). Tests use
/// `FlutterSecureStorage.setMockInitialValues`.
final secureStorageProvider = Provider<FlutterSecureStorage>(
  // Readable after the first unlock (background sync, M02) and never synced to another phone through iCloud.
  (ref) =>
      const FlutterSecureStorage(iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device)),
);

/// Secure-storage keys.
const _kAccess = 'access_token', _kRefresh = 'refresh_token', _kExpires = 'access_expires_at', _kDevice = 'device_id';

/// Holds the [Session] and the tokens behind it.
///
/// DECISION D-013: Riverpod Notifier for session state, read by go_router's redirect.
///   ADV: one provider drives routing, locale and the API client's tokens; tests override or drive it directly.
///   COMPROMISE: plain Notifier without riverpod_annotation codegen; tokens are private fields mirrored to secure
///   storage rather than state, so token rotation never rebuilds the UI.
class SessionNotifier extends Notifier<Session> {
  String? _access, _refresh;
  DateTime? _expiresAt;
  String? _deviceId;
  Future<String?>? _refreshing;

  /// Initial state: signed out, Tamil (until [restore] reads the stored session). Returns the [Session].
  @override
  Session build() => const Session();

  /// The current access token, or null when signed out. Read by the API client on every request.
  String? get accessToken => _access;

  FlutterSecureStorage get _storage => ref.read(secureStorageProvider);

  /// Restores the session on app open (UserFlows §Log in once).
  ///
  /// A stored Session row plus a stored refresh token means signed in: the role's home opens at once, even offline.
  /// An expired access token is renewed in the background (a `refresh_reused`/401 answer signs out with an
  /// explanation; no signal keeps the session). A row without tokens (keystore wiped) or tokens without a row (iOS
  /// Keychain outlives a reinstall) means signed out, and the leftovers are cleared. Returns once the local state is
  /// known; throws nothing. Side effects: may create the device id, clear storage, start a refresh.
  Future<void> restore() async {
    final row = await ref.read(appDatabaseProvider).sessionDao.read();
    try {
      _deviceId = await _storage.read(key: _kDevice);
      _access = await _storage.read(key: _kAccess);
      _refresh = await _storage.read(key: _kRefresh);
      _expiresAt = DateTime.tryParse(await _storage.read(key: _kExpires) ?? '');
    } on PlatformException {
      // Android can lose the Keystore key (e.g. restored backup): start clean rather than fail to open.
      await _storage.deleteAll();
      _deviceId = _access = _refresh = _expiresAt = null;
    }
    final locale = row == null ? state.locale : Locale(row.locale);
    if (row == null || _refresh == null) {
      await _endLocally(locale: locale);
      return;
    }
    state = Session(role: row.role, locale: locale);
    if (_expiresAt == null || !_expiresAt!.isAfter(DateTime.now())) unawaited(refreshAccessToken());
    // Hook for M02: a fresh install signed in with an existing number pulls the history (UserFlows §Phone lost or
    // changed); M02's pull runs on every app open and after sign-in, so nothing more is needed here.
  }

  /// Asks the API to send a sign-in code to [phone] (E.164, e.g. `+919876543210`).
  ///
  /// Returns when the API answered 204. Throws [DioException] (`rate_limited` with `retry_after_s`,
  /// `validation_error`, network). No local side effects.
  Future<void> requestOtp(String phone) => ref
      .read(apiClientProvider)
      .api
      .getIdentityApi()
      .otpRequestV1AuthOtpRequestPost(otpRequestIn: OtpRequestIn((b) => b.phone = phone));

  /// Trades the SMS [code] for [phone] for a session (farmers) or a PIN step (office roles).
  ///
  /// Returns null when signed in (the router then opens the role's home), or the [PinRequiredOut] for the PIN screen.
  /// Throws [DioException] (`otp_invalid`, `otp_expired`, `otp_locked`, `device_in_use`, network) or [AuthFailure]
  /// `portal_only`. Side effects: on success stores the session (see [openSession]); may create the device id.
  Future<PinRequiredOut?> verifyOtp(String phone, String code) async {
    final deviceId = await _ensureDeviceId();
    final response = await ref
        .read(apiClientProvider)
        .api
        .getIdentityApi()
        .otpVerifyV1AuthOtpVerifyPost(
          otpVerifyIn: OtpVerifyIn(
            (b) => b
              ..phone = phone
              ..code = code
              ..deviceId = deviceId
              ..platform = defaultTargetPlatform == TargetPlatform.iOS
                  ? OtpVerifyInPlatformEnum.ios
                  : OtpVerifyInPlatformEnum.android,
          ),
        );
    final out = response.data!.oneOf.value;
    if (out is PinRequiredOut) return out;
    await openSession(out as SessionOut);
    return null;
  }

  /// Sends the office [pin] with the [pinToken] from OTP verify; when the user had no PIN yet, this sets it.
  ///
  /// Returns when signed in. Throws [DioException] (`pin_invalid` with `attempts_left`, `pin_locked` with
  /// `locked_until`, 401 when the 5-minute pin token expired, network) or [AuthFailure] `portal_only`.
  /// Side effects: stores the session (see [openSession]).
  Future<void> verifyPin(String pinToken, String pin) async {
    final response = await ref
        .read(apiClientProvider)
        .api
        .getIdentityApi()
        .pinVerifyV1AuthPinVerifyPost(pinIn: PinIn((b) => b.pin = pin), headers: {'Authorization': 'Bearer $pinToken'});
    await openSession(response.data!);
  }

  /// Stores a new server session [out] and signs in with the first mobile role it carries.
  ///
  /// Tokens go to secure storage, everything else to the Session row (D-027). The user id is the access token's
  /// `sub` claim (D-024 lists the claims), so sign-in needs no extra round trip. Accounts with only portal roles
  /// (fpo_admin, viewer, super_admin) are signed out again on the server and get [AuthFailure] `portal_only`.
  /// Returns when stored. Throws [AuthFailure] `portal_only`; [FormatException] for a malformed access token.
  /// Side effects: secure storage, Session row, state (the router redirects to the role's home).
  Future<void> openSession(SessionOut out) async {
    final role = Role.values.where((r) => out.roles.contains(r.wireName)).firstOrNull;
    final claims = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(out.accessToken.split('.')[1]))));
    await _storeTokens(out);
    if (role == null) {
      await signOut();
      throw const AuthFailure('portal_only');
    }
    await ref
        .read(appDatabaseProvider)
        .sessionDao
        .save(
          userId: (claims as Map)['sub'] as String,
          role: role,
          fpoId: out.fpoId,
          deviceId: await _ensureDeviceId(),
          locale: state.locale.languageCode,
        );
    state = Session(role: role, locale: state.locale);
  }

  /// Renews the access token with the stored refresh token. Concurrent callers share one call, because the API
  /// treats two racing refreshes as reuse and signs the phone out (D-024).
  ///
  /// Returns the new access token, or null when signed out or offline. Throws nothing. Side effects: stores the
  /// rotated tokens; on a 401 (`refresh_reused` or unknown token) signs out locally with `sessionEnded`.
  ///
  /// DECISION D-024: client side of the session contract: refresh lazily (on a 401, or on app open when the stored
  /// access token has expired), one call at a time, and sign out only when the server answers 401.
  ///   ADV: no token-expiry timers; offline the farmer keeps working on saved entries (no signal never signs out);
  ///   a stolen-and-reused refresh token signs this phone out on its next call.
  ///   COMPROMISE: the first call after 15 minutes idle pays one extra round trip; a refresh answer lost on the way
  ///   back leaves the phone with a rotated-out token, so its next refresh looks like reuse and signs it out.
  Future<String?> refreshAccessToken() => _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);

  /// One refresh call; see [refreshAccessToken]. Returns the new access token or null; throws nothing.
  Future<String?> _doRefresh() async {
    final token = _refresh;
    if (token == null) return null;
    try {
      final response = await ref
          .read(apiClientProvider)
          .api
          .getIdentityApi()
          .refreshV1AuthRefreshPost(refreshIn: RefreshIn((b) => b.refreshToken = token));
      await _storeTokens(response.data!);
      return _access;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) await _endLocally(sessionEnded: true);
      return null;
    }
  }

  /// Signs out: tells the API (`POST /v1/auth/logout`), then forgets the tokens and the Session row.
  ///
  /// The outbox and every saved entry stay on the phone (they are never deleted unsent). Without signal the API call
  /// fails and the phone signs out anyway; the server still sees this device as signed in, which the next user
  /// clears with [forgetDevice] when sign-in answers `device_in_use`. Returns when signed out; throws nothing.
  /// Side effects: network call, secure storage and Session row cleared, state signed out (router opens /auth).
  Future<void> signOut() async {
    if (_access != null) {
      try {
        await ref.read(apiClientProvider).api.getIdentityApi().logoutV1AuthLogoutPost();
      } on DioException {
        // No signal or already signed out on the server: the local sign-out below is what the user asked for.
      }
    }
    await _endLocally();
  }

  /// Gives this install a new device id, so a sign-in refused with `device_in_use` (the old id is still signed in
  /// for someone else on the server, e.g. after an offline sign-out on a shared phone) can go ahead.
  ///
  /// Returns when stored; throws nothing. Side effect: replaces the stored device id.
  Future<void> forgetDevice() async {
    _deviceId = const Uuid().v4();
    await _storage.write(key: _kDevice, value: _deviceId);
  }

  /// Switches the UI language to [locale]. Side effects: every visible string re-renders; the Session row keeps the
  /// choice when signed in. Throws nothing.
  void setLocale(Locale locale) {
    state = Session(role: state.role, locale: locale, sessionEnded: state.sessionEnded);
    unawaited(ref.read(appDatabaseProvider).sessionDao.setLocale(locale.languageCode));
  }

  /// Returns this install's device id, creating and storing a random UUID on first use. Throws nothing.
  Future<String> _ensureDeviceId() async {
    if (_deviceId == null) await forgetDevice();
    return _deviceId!;
  }

  /// Keeps [out]'s tokens in memory and secure storage. A null refresh token (web only) keeps the old one.
  /// Returns when written; throws nothing.
  Future<void> _storeTokens(SessionOut out) async {
    _access = out.accessToken;
    _refresh = out.refreshToken ?? _refresh;
    _expiresAt = DateTime.now().add(Duration(seconds: out.expiresIn));
    await _storage.write(key: _kAccess, value: _access);
    await _storage.write(key: _kRefresh, value: _refresh);
    await _storage.write(key: _kExpires, value: _expiresAt!.toIso8601String());
  }

  /// Signs out on this phone only: tokens and Session row gone, device id and outbox kept.
  ///
  /// [sessionEnded] tells the sign-in screen the server ended the session; [locale] defaults to the current one.
  /// Returns when cleared; throws nothing.
  Future<void> _endLocally({bool sessionEnded = false, Locale? locale}) async {
    _access = _refresh = _expiresAt = null;
    for (final key in [_kAccess, _kRefresh, _kExpires]) {
      await _storage.delete(key: key);
    }
    await ref.read(appDatabaseProvider).sessionDao.clear();
    state = Session(locale: locale ?? state.locale, sessionEnded: sessionEnded);
  }
}

/// The app-wide session provider.
final sessionProvider = NotifierProvider<SessionNotifier, Session>(SessionNotifier.new);
