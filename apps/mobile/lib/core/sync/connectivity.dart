// Network awareness for the sync engine: the current network type (connectivity_plus) and real reachability of the
// API (`HEAD /v1/healthz` within 3 s), because a phone can be "on Wi-Fi" with no route to the server.
// Requirement: PLAN §13 A1 (reachability before a run; a connectivity change only triggers the probe), B5 (Wi-Fi-only
//   photos need the network type), F1 (network type per metric); mobile-design.md §3; Arch §Offline-first "When it
//   syncs".
// Callers: sync_service.dart (defaults for its network inputs, probe before automatic runs); tests use fakes.

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

/// How long the reachability probe may take (PLAN §13 A1).
const probeTimeout = Duration(seconds: 3);

/// The phone's current network type: `wifi`, `mobile`, `ethernet`, `none` or `other`.
///
/// shortcut: connectivity_plus cannot tell 2G/3G/LTE apart, so metrics say `mobile`; add a telephony plugin if the
/// sync-health tile needs the generation. Returns the name; throws nothing on supported platforms.
Future<String> currentNetworkType() async => networkTypeOf(await Connectivity().checkConnectivity());

/// Network type names whenever the phone's connectivity changes. Never errors on its own.
Stream<String> networkTypeChanges() => Connectivity().onConnectivityChanged.map(networkTypeOf);

/// The name for [results] (the first match of wifi, mobile, ethernet; `none` when empty or none). Throws nothing.
String networkTypeOf(List<ConnectivityResult> results) => switch (results) {
  _ when results.contains(ConnectivityResult.wifi) => 'wifi',
  _ when results.contains(ConnectivityResult.mobile) => 'mobile',
  _ when results.contains(ConnectivityResult.ethernet) => 'ethernet',
  _ when results.isEmpty || results.contains(ConnectivityResult.none) => 'none',
  _ => 'other',
};

/// True when the API at [api]'s base URL answers anything to `HEAD /v1/healthz` within [probeTimeout].
///
/// Any HTTP status counts (the route may not allow HEAD, or a dependency may be down): it proves a route to the
/// server, which is all a run needs. Returns false on a connection error or timeout; throws nothing.
/// Side effect: one HTTP request.
Future<bool> isReachable(Dio api) async {
  final cancel = CancelToken();
  final timer = Timer(probeTimeout, cancel.cancel);
  try {
    await api.head<void>(
      '/v1/healthz',
      cancelToken: cancel,
      options: Options(validateStatus: (_) => true),
    );
    return true;
  } on DioException {
    return false;
  } finally {
    timer.cancel();
  }
}
