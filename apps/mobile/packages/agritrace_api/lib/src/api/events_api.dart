//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:agritrace_api/src/api_util.dart';
import 'package:agritrace_api/src/model/bundle_manifest.dart';
import 'package:agritrace_api/src/model/bundle_part.dart';
import 'package:agritrace_api/src/model/correction_in.dart';
import 'package:agritrace_api/src/model/error_envelope.dart';
import 'package:agritrace_api/src/model/page_event_out.dart';
import 'package:agritrace_api/src/model/photo_confirm_out.dart';
import 'package:agritrace_api/src/model/photos_confirm_in.dart';
import 'package:agritrace_api/src/model/pull_out.dart';
import 'package:agritrace_api/src/model/reference_out.dart';
import 'package:agritrace_api/src/model/sync_push_in.dart';
import 'package:agritrace_api/src/model/sync_push_out.dart';
import 'package:agritrace_api/src/model/sync_result.dart';
import 'package:agritrace_api/src/model/undo_in.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';

class EventsApi {
  final Dio _dio;

  final Serializers _serializers;

  const EventsApi(this._dio, this._serializers);

  /// Correct an event
  /// Adds a correction version (field officer or FPO admin only; farmers get 403 &#x60;forbidden&#x60;). The body is a sync &#x60;event_version&#x60; entry: &#x60;data.change_kind&#x60; must be &#x60;correct&#x60;, &#x60;data.version_no&#x60; the current max + 1 (else 409 &#x60;stale_version&#x60;), &#x60;data.reason_code&#x60; is required (422 &#x60;reason_required&#x60;). The earlier version stays stored (append-only, FR25). Resending the same &#x60;client_id&#x60; answers &#x60;duplicate&#x60;.
  ///
  /// Parameters:
  /// * [eventId] - Event id (the client id it was created with).
  /// * [correctionIn]
  /// * [xAssistSession] - Open assist session id (field officer entering data for a farmer).
  /// * [xRequestId] - Client request id, copied to audit rows.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [SyncResult] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<SyncResult>> correctEventV1EventsEventIdVersionsPost({
    required String eventId,
    required CorrectionIn correctionIn,
    String? xAssistSession,
    String? xRequestId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/events/{event_id}/versions'.replaceAll(
        '{' r'event_id' '}',
        encodeQueryParameter(_serializers, eventId, const FullType(String))
            .toString());
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        r'x-assist-session': xAssistSession,
        r'x-request-id': xRequestId,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'AccessToken',
          },
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(CorrectionIn);
      _bodyData = _serializers.serialize(correctionIn, specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    SyncResult? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(SyncResult),
            ) as SyncResult;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<SyncResult>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// List a lot&#39;s events
  /// Every event of the lot with its latest version, ordered by &#x60;occurred_on&#x60;, then &#x60;instance_no&#x60; (FR63). Undone events stay listed with status &#x60;undone&#x60;. A lot has a few dozen events at most, so the whole list is one page (&#x60;has_more&#x60; false).
  ///
  /// Parameters:
  /// * [lotId] - Lot id.
  /// * [xAssistSession] - Open assist session id (field officer entering data for a farmer).
  /// * [xRequestId] - Client request id, copied to audit rows.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PageEventOut] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PageEventOut>> listLotEventsV1LotsLotIdEventsGet({
    required String lotId,
    String? xAssistSession,
    String? xRequestId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/lots/{lot_id}/events'.replaceAll(
        '{' r'lot_id' '}',
        encodeQueryParameter(_serializers, lotId, const FullType(String))
            .toString());
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        r'x-assist-session': xAssistSession,
        r'x-request-id': xRequestId,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'AccessToken',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    PageEventOut? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(PageEventOut),
            ) as PageEventOut;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PageEventOut>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Download one reference-bundle part
  /// The part body in the shape the app parses (docs/api/conventions.md \&quot;Reference bundles\&quot;). Sends a strong &#x60;ETag&#x60;; send it back in &#x60;If-None-Match&#x60; to get 304 without a body. Unknown part → 422.
  ///
  /// Parameters:
  /// * [part_] - Part name, as listed by `GET /v1/sync/bundle`.
  /// * [xAssistSession] - Open assist session id (field officer entering data for a farmer).
  /// * [xRequestId] - Client request id, copied to audit rows.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [BuiltMap<String, JsonObject?>] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<BuiltMap<String, JsonObject?>>>
      syncBundlePartV1SyncBundlePartGet({
    required BundlePart part_,
    String? xAssistSession,
    String? xRequestId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/sync/bundle/{part}'.replaceAll(
        '{' r'part' '}',
        encodeQueryParameter(_serializers, part_, const FullType(BundlePart))
            .toString());
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        r'x-assist-session': xAssistSession,
        r'x-request-id': xRequestId,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'AccessToken',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    BuiltMap<String, JsonObject?>? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(
                  BuiltMap, [FullType(String), FullType(JsonObject)]),
            ) as BuiltMap<String, JsonObject?>;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<BuiltMap<String, JsonObject?>>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Download one reference-bundle part
  /// The part body in the shape the app parses (docs/api/conventions.md \&quot;Reference bundles\&quot;). Sends a strong &#x60;ETag&#x60;; send it back in &#x60;If-None-Match&#x60; to get 304 without a body. Unknown part → 422.
  ///
  /// Parameters:
  /// * [part_] - Part name, as listed by `GET /v1/sync/bundle`.
  /// * [xAssistSession] - Open assist session id (field officer entering data for a farmer).
  /// * [xRequestId] - Client request id, copied to audit rows.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [BuiltMap<String, JsonObject?>] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<BuiltMap<String, JsonObject?>>>
      syncBundlePartV1SyncBundlePartGet_1({
    required BundlePart part_,
    String? xAssistSession,
    String? xRequestId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/sync/bundle/{part}'.replaceAll(
        '{' r'part' '}',
        encodeQueryParameter(_serializers, part_, const FullType(BundlePart))
            .toString());
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        r'x-assist-session': xAssistSession,
        r'x-request-id': xRequestId,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'AccessToken',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    BuiltMap<String, JsonObject?>? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(
                  BuiltMap, [FullType(String), FullType(JsonObject)]),
            ) as BuiltMap<String, JsonObject?>;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<BuiltMap<String, JsonObject?>>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// List reference-bundle parts
  /// Every offline reference part available to you with its &#x60;version&#x60; and strong &#x60;etag&#x60;: &#x60;plots&#x60; (yours, or the FPO&#39;s for officers), &#x60;crops&#x60; (with &#x60;event_schema {mandatory, tracks}&#x60;), &#x60;inputs&#x60; (global + FPO), &#x60;standards&#x60; (full profile rules per crop), &#x60;gi_region&#x60; (simplified outline ≤ 50 KB + buffer; absent while none is in effect), &#x60;farmer_profile&#x60;, &#x60;villages&#x60; (the FPO&#39;s district), &#x60;fields&#x60; (field configuration), &#x60;prompts&#x60;, &#x60;images&#x60; (product-picture URLs) and &#x60;calendar&#x60;. Download a part with &#x60;GET /v1/sync/bundle/{part}&#x60;; later ask &#x60;GET /v1/sync/reference?since&#x3D;&#x60; for changes only.
  ///
  /// Parameters:
  /// * [xAssistSession] - Open assist session id (field officer entering data for a farmer).
  /// * [xRequestId] - Client request id, copied to audit rows.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [BundleManifest] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<BundleManifest>> syncBundleV1SyncBundleGet({
    String? xAssistSession,
    String? xRequestId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/sync/bundle';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        r'x-assist-session': xAssistSession,
        r'x-request-id': xRequestId,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'AccessToken',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    BundleManifest? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(BundleManifest),
            ) as BundleManifest;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<BundleManifest>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// List reference-bundle parts
  /// Every offline reference part available to you with its &#x60;version&#x60; and strong &#x60;etag&#x60;: &#x60;plots&#x60; (yours, or the FPO&#39;s for officers), &#x60;crops&#x60; (with &#x60;event_schema {mandatory, tracks}&#x60;), &#x60;inputs&#x60; (global + FPO), &#x60;standards&#x60; (full profile rules per crop), &#x60;gi_region&#x60; (simplified outline ≤ 50 KB + buffer; absent while none is in effect), &#x60;farmer_profile&#x60;, &#x60;villages&#x60; (the FPO&#39;s district), &#x60;fields&#x60; (field configuration), &#x60;prompts&#x60;, &#x60;images&#x60; (product-picture URLs) and &#x60;calendar&#x60;. Download a part with &#x60;GET /v1/sync/bundle/{part}&#x60;; later ask &#x60;GET /v1/sync/reference?since&#x3D;&#x60; for changes only.
  ///
  /// Parameters:
  /// * [xAssistSession] - Open assist session id (field officer entering data for a farmer).
  /// * [xRequestId] - Client request id, copied to audit rows.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [BundleManifest] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<BundleManifest>> syncBundleV1SyncBundleGet_2({
    String? xAssistSession,
    String? xRequestId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/sync/bundle';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        r'x-assist-session': xAssistSession,
        r'x-request-id': xRequestId,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'AccessToken',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    BundleManifest? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(BundleManifest),
            ) as BundleManifest;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<BundleManifest>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Confirm uploaded photos
  /// Call after each presigned PUT succeeded. For each photo the server checks storage: &#x60;received&#x60; means the object is there (its version id is stored and verification of SHA-256 and EXIF time/GPS is queued), &#x60;missing&#x60; means upload again (ask for fresh URLs by resending the entry) and confirm again. Unknown ids and photos of entries someone else pushed also answer &#x60;missing&#x60;. Bodies over 256 KB → 413 &#x60;payload_too_large&#x60;.
  ///
  /// Parameters:
  /// * [photosConfirmIn]
  /// * [xAssistSession] - Open assist session id (field officer entering data for a farmer).
  /// * [xRequestId] - Client request id, copied to audit rows.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [BuiltList<PhotoConfirmOut>] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<BuiltList<PhotoConfirmOut>>>
      syncPhotosConfirmV1SyncPhotosConfirmPost({
    required PhotosConfirmIn photosConfirmIn,
    String? xAssistSession,
    String? xRequestId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/sync/photos/confirm';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        r'x-assist-session': xAssistSession,
        r'x-request-id': xRequestId,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'AccessToken',
          },
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(PhotosConfirmIn);
      _bodyData = _serializers.serialize(photosConfirmIn, specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    BuiltList<PhotoConfirmOut>? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType:
                  const FullType(BuiltList, [FullType(PhotoConfirmOut)]),
            ) as BuiltList<PhotoConfirmOut>;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<BuiltList<PhotoConfirmOut>>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Confirm uploaded photos
  /// Call after each presigned PUT succeeded. For each photo the server checks storage: &#x60;received&#x60; means the object is there (its version id is stored and verification of SHA-256 and EXIF time/GPS is queued), &#x60;missing&#x60; means upload again (ask for fresh URLs by resending the entry) and confirm again. Unknown ids and photos of entries someone else pushed also answer &#x60;missing&#x60;. Bodies over 256 KB → 413 &#x60;payload_too_large&#x60;.
  ///
  /// Parameters:
  /// * [photosConfirmIn]
  /// * [xAssistSession] - Open assist session id (field officer entering data for a farmer).
  /// * [xRequestId] - Client request id, copied to audit rows.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [BuiltList<PhotoConfirmOut>] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<BuiltList<PhotoConfirmOut>>>
      syncPhotosConfirmV1SyncPhotosConfirmPost_3({
    required PhotosConfirmIn photosConfirmIn,
    String? xAssistSession,
    String? xRequestId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/sync/photos/confirm';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        r'x-assist-session': xAssistSession,
        r'x-request-id': xRequestId,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'AccessToken',
          },
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(PhotosConfirmIn);
      _bodyData = _serializers.serialize(photosConfirmIn, specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    BuiltList<PhotoConfirmOut>? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType:
                  const FullType(BuiltList, [FullType(PhotoConfirmOut)]),
            ) as BuiltList<PhotoConfirmOut>;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<BuiltList<PhotoConfirmOut>>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Pull server-side changes
  /// Changes since &#x60;cursor&#x60;, oldest first: &#x60;flag&#x60;, &#x60;lot&#x60;, &#x60;event&#x60; (current version, e.g. after an officer correction; photo variant URLs are presigned for 1 hour), &#x60;intake&#x60;, &#x60;notification&#x60; (yours) and, on the last page, &#x60;photo_pending&#x60; (photos still not uploaded 24 h after their entry: resend the entry to get fresh upload URLs). Farmers see their own lots, plots and events; other roles the whole FPO. Every change is an &#x60;upsert&#x60; by &#x60;id&#x60;. Store &#x60;next_cursor&#x60; and call again while &#x60;has_more&#x60;. Changes appear about 30 s after they are written. An invalid cursor → 422 &#x60;validation_error&#x60;.
  ///
  /// Parameters:
  /// * [cursor] - `next_cursor` of your previous pull; omit the first time.
  /// * [limit] - Most changes per page.
  /// * [xAssistSession] - Open assist session id (field officer entering data for a farmer).
  /// * [xRequestId] - Client request id, copied to audit rows.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PullOut] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PullOut>> syncPullV1SyncPullGet({
    String? cursor,
    int? limit = 200,
    String? xAssistSession,
    String? xRequestId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/sync/pull';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        r'x-assist-session': xAssistSession,
        r'x-request-id': xRequestId,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'AccessToken',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      if (cursor != null)
        r'cursor':
            encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(int)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    PullOut? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(PullOut),
            ) as PullOut;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PullOut>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Pull server-side changes
  /// Changes since &#x60;cursor&#x60;, oldest first: &#x60;flag&#x60;, &#x60;lot&#x60;, &#x60;event&#x60; (current version, e.g. after an officer correction; photo variant URLs are presigned for 1 hour), &#x60;intake&#x60;, &#x60;notification&#x60; (yours) and, on the last page, &#x60;photo_pending&#x60; (photos still not uploaded 24 h after their entry: resend the entry to get fresh upload URLs). Farmers see their own lots, plots and events; other roles the whole FPO. Every change is an &#x60;upsert&#x60; by &#x60;id&#x60;. Store &#x60;next_cursor&#x60; and call again while &#x60;has_more&#x60;. Changes appear about 30 s after they are written. An invalid cursor → 422 &#x60;validation_error&#x60;.
  ///
  /// Parameters:
  /// * [cursor] - `next_cursor` of your previous pull; omit the first time.
  /// * [limit] - Most changes per page.
  /// * [xAssistSession] - Open assist session id (field officer entering data for a farmer).
  /// * [xRequestId] - Client request id, copied to audit rows.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PullOut] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PullOut>> syncPullV1SyncPullGet_4({
    String? cursor,
    int? limit = 200,
    String? xAssistSession,
    String? xRequestId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/sync/pull';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        r'x-assist-session': xAssistSession,
        r'x-request-id': xRequestId,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'AccessToken',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      if (cursor != null)
        r'cursor':
            encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(int)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    PullOut? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(PullOut),
            ) as PullOut;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PullOut>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Push offline entries
  /// Sends up to 50 entries (and at most 256 KB) captured offline, in capture order. Kinds: &#x60;event_version&#x60; (body &#x60;EventVersionIn&#x60;, the same as &#x60;CorrectionIn.data&#x60;), &#x60;quality_reading&#x60;, &#x60;plot&#x60;, &#x60;consent&#x60;, &#x60;flag_resolution&#x60; (same rules as &#x60;POST /v1/flags/{id}/resolve&#x60;), &#x60;farmer&#x60; (&#x60;FarmerIn&#x60;, field officer or FPO admin, D-031), &#x60;assist_session&#x60; (&#x60;AssistStartIn&#x60;, field officer, D-032) and &#x60;lot_intake&#x60; (&#x60;IntakeIn&#x60; without &#x60;client_id&#x60;, QC officer or FPO admin: receives the lot, D-040); send &#x60;farmer&#x60;, then &#x60;assist_session&#x60;, then the entries that use them, and a lot&#39;s intake reading before its &#x60;lot_intake&#x60;. An entry&#39;s &#x60;assist_session_id&#x60; records assist mode for that entry only (ended sessions accepted): checked against the farmer of a consent, plot, lot event or lot reading, refused on batch readings and batch events, ignored on &#x60;farmer&#x60;, &#x60;flag_resolution&#x60;, &#x60;assist_session&#x60; and &#x60;lot_intake&#x60; (D-042). Each entry is its own transaction and gets its own result: &#x60;accepted&#x60;, &#x60;duplicate&#x60; (same &#x60;client_id&#x60; already stored by you; returns the original &#x60;server_id&#x60; and fresh upload URLs for photos not yet uploaded) or &#x60;rejected&#x60; with an error (&#x60;validation_error&#x60;, &#x60;client_id_conflict&#x60;, &#x60;stale_version&#x60;, &#x60;forbidden&#x60;, &#x60;not_found&#x60;, &#x60;reason_required&#x60;, &#x60;undo_window_closed&#x60;, &#x60;assist_session_invalid&#x60;, &#x60;farmer_phone_taken&#x60;, &#x60;conflict&#x60;, &#x60;field_required&#x60;, &#x60;gate_not_met&#x60;, ...). The response is 200 whenever the envelope parses. Photos are never in the push: each photo gets one presigned PUT (15 minutes, &#x60;Content-Type&#x60; and &#x60;x-amz-checksum-sha256&#x60; must be sent as given), then &#x60;POST /v1/sync/photos/confirm&#x60;. &#x60;metrics[]&#x60; rows are stored for the sync-health dashboard.
  ///
  /// Parameters:
  /// * [syncPushIn]
  /// * [xAssistSession] - Open assist session id (field officer entering data for a farmer).
  /// * [xRequestId] - Client request id, copied to audit rows.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [SyncPushOut] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<SyncPushOut>> syncPushV1SyncPushPost({
    required SyncPushIn syncPushIn,
    String? xAssistSession,
    String? xRequestId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/sync/push';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        r'x-assist-session': xAssistSession,
        r'x-request-id': xRequestId,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'AccessToken',
          },
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(SyncPushIn);
      _bodyData = _serializers.serialize(syncPushIn, specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    SyncPushOut? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(SyncPushOut),
            ) as SyncPushOut;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<SyncPushOut>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Push offline entries
  /// Sends up to 50 entries (and at most 256 KB) captured offline, in capture order. Kinds: &#x60;event_version&#x60; (body &#x60;EventVersionIn&#x60;, the same as &#x60;CorrectionIn.data&#x60;), &#x60;quality_reading&#x60;, &#x60;plot&#x60;, &#x60;consent&#x60;, &#x60;flag_resolution&#x60; (same rules as &#x60;POST /v1/flags/{id}/resolve&#x60;), &#x60;farmer&#x60; (&#x60;FarmerIn&#x60;, field officer or FPO admin, D-031), &#x60;assist_session&#x60; (&#x60;AssistStartIn&#x60;, field officer, D-032) and &#x60;lot_intake&#x60; (&#x60;IntakeIn&#x60; without &#x60;client_id&#x60;, QC officer or FPO admin: receives the lot, D-040); send &#x60;farmer&#x60;, then &#x60;assist_session&#x60;, then the entries that use them, and a lot&#39;s intake reading before its &#x60;lot_intake&#x60;. An entry&#39;s &#x60;assist_session_id&#x60; records assist mode for that entry only (ended sessions accepted): checked against the farmer of a consent, plot, lot event or lot reading, refused on batch readings and batch events, ignored on &#x60;farmer&#x60;, &#x60;flag_resolution&#x60;, &#x60;assist_session&#x60; and &#x60;lot_intake&#x60; (D-042). Each entry is its own transaction and gets its own result: &#x60;accepted&#x60;, &#x60;duplicate&#x60; (same &#x60;client_id&#x60; already stored by you; returns the original &#x60;server_id&#x60; and fresh upload URLs for photos not yet uploaded) or &#x60;rejected&#x60; with an error (&#x60;validation_error&#x60;, &#x60;client_id_conflict&#x60;, &#x60;stale_version&#x60;, &#x60;forbidden&#x60;, &#x60;not_found&#x60;, &#x60;reason_required&#x60;, &#x60;undo_window_closed&#x60;, &#x60;assist_session_invalid&#x60;, &#x60;farmer_phone_taken&#x60;, &#x60;conflict&#x60;, &#x60;field_required&#x60;, &#x60;gate_not_met&#x60;, ...). The response is 200 whenever the envelope parses. Photos are never in the push: each photo gets one presigned PUT (15 minutes, &#x60;Content-Type&#x60; and &#x60;x-amz-checksum-sha256&#x60; must be sent as given), then &#x60;POST /v1/sync/photos/confirm&#x60;. &#x60;metrics[]&#x60; rows are stored for the sync-health dashboard.
  ///
  /// Parameters:
  /// * [syncPushIn]
  /// * [xAssistSession] - Open assist session id (field officer entering data for a farmer).
  /// * [xRequestId] - Client request id, copied to audit rows.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [SyncPushOut] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<SyncPushOut>> syncPushV1SyncPushPost_5({
    required SyncPushIn syncPushIn,
    String? xAssistSession,
    String? xRequestId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/sync/push';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        r'x-assist-session': xAssistSession,
        r'x-request-id': xRequestId,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'AccessToken',
          },
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(SyncPushIn);
      _bodyData = _serializers.serialize(syncPushIn, specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    SyncPushOut? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(SyncPushOut),
            ) as SyncPushOut;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<SyncPushOut>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Changed reference-bundle parts
  /// Delta sync (plan §13 C2). &#x60;since&#x60; lists the part versions you hold as &#x60;&lt;part&gt;:&lt;version&gt;&#x60; joined by commas, e.g. &#x60;plots:41,crops:7,fields:90210&#x60;. Answers the parts whose version differs from yours, each compared on its own, with body, version and etag; parts you do not list are new to you and included. 304 when nothing changed. A malformed &#x60;since&#x60; → 422 &#x60;validation_error&#x60;.
  ///
  /// Parameters:
  /// * [since] - Part versions you hold: `<part>:<version>,...`; omit for all.
  /// * [xAssistSession] - Open assist session id (field officer entering data for a farmer).
  /// * [xRequestId] - Client request id, copied to audit rows.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [ReferenceOut] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<ReferenceOut>> syncReferenceV1SyncReferenceGet({
    String? since,
    String? xAssistSession,
    String? xRequestId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/sync/reference';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        r'x-assist-session': xAssistSession,
        r'x-request-id': xRequestId,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'AccessToken',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      if (since != null)
        r'since':
            encodeQueryParameter(_serializers, since, const FullType(String)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    ReferenceOut? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(ReferenceOut),
            ) as ReferenceOut;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<ReferenceOut>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Changed reference-bundle parts
  /// Delta sync (plan §13 C2). &#x60;since&#x60; lists the part versions you hold as &#x60;&lt;part&gt;:&lt;version&gt;&#x60; joined by commas, e.g. &#x60;plots:41,crops:7,fields:90210&#x60;. Answers the parts whose version differs from yours, each compared on its own, with body, version and etag; parts you do not list are new to you and included. 304 when nothing changed. A malformed &#x60;since&#x60; → 422 &#x60;validation_error&#x60;.
  ///
  /// Parameters:
  /// * [since] - Part versions you hold: `<part>:<version>,...`; omit for all.
  /// * [xAssistSession] - Open assist session id (field officer entering data for a farmer).
  /// * [xRequestId] - Client request id, copied to audit rows.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [ReferenceOut] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<ReferenceOut>> syncReferenceV1SyncReferenceGet_6({
    String? since,
    String? xAssistSession,
    String? xRequestId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/sync/reference';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        r'x-assist-session': xAssistSession,
        r'x-request-id': xRequestId,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'AccessToken',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      if (since != null)
        r'since':
            encodeQueryParameter(_serializers, since, const FullType(String)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    ReferenceOut? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(ReferenceOut),
            ) as ReferenceOut;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<ReferenceOut>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Undo an own entry
  /// A farmer undoes an event they entered, within 24 hours of its capture (device time); later → 409 &#x60;undo_window_closed&#x60; (ask the field officer for a correction). Adds a version with &#x60;change_kind&#x3D;undo&#x60;; the event&#39;s status becomes &#x60;undone&#x60;. &#x60;version_no&#x60; must be the current max + 1.
  ///
  /// Parameters:
  /// * [eventId] - Event id (the client id it was created with).
  /// * [undoIn]
  /// * [xAssistSession] - Open assist session id (field officer entering data for a farmer).
  /// * [xRequestId] - Client request id, copied to audit rows.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [SyncResult] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<SyncResult>> undoEventV1EventsEventIdUndoPost({
    required String eventId,
    required UndoIn undoIn,
    String? xAssistSession,
    String? xRequestId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/events/{event_id}/undo'.replaceAll(
        '{' r'event_id' '}',
        encodeQueryParameter(_serializers, eventId, const FullType(String))
            .toString());
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        r'x-assist-session': xAssistSession,
        r'x-request-id': xRequestId,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'AccessToken',
          },
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(UndoIn);
      _bodyData = _serializers.serialize(undoIn, specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    SyncResult? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(SyncResult),
            ) as SyncResult;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<SyncResult>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }
}
