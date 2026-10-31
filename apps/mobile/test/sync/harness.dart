// Test harness for the sync engine: a fake B06/B07 server behind a dio adapter (push with client-id idempotency,
// presigned PUT, photo confirm, pull, bundles, healthz), a fake clock, fixed jitter and photo files on disk.
// Requirement: WP-M02 tests (fake dio adapter + in-memory Drift + fake clock/connectivity); backend-design.md §3
//   (the protocol the fake answers).
// Callers: test/sync/*_test.dart.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:agritrace/core/db/database.dart';
import 'package:agritrace/core/sync/sync_context.dart';
import 'package:agritrace/core/sync/sync_service.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../db/db_fixtures.dart';

export '../db/db_fixtures.dart';

/// One request the fake server saw: method, path (or full URL for storage), query, decoded body and headers.
typedef Seen = ({String method, String path, Map<String, String> query, Object? body, Map<String, dynamic> headers});

/// Answers a request instead of the fake server's default; return null to fall through to the default.
typedef Intercept = FutureOr<ResponseBody?> Function(Seen request);

/// A fake API + storage server implementing the sync protocol of backend-design.md §3.
class FakeServer implements HttpClientAdapter {
  /// Creates the server; [clock] supplies `server_time`.
  FakeServer(this.clock);

  /// Server clock for `server_time` (defaults to the test clock: no skew).
  DateTime Function() clock;

  /// Every request, in order.
  final requests = <Seen>[];

  /// Stored entries by client id (the server's rows).
  final entries = <String, Map<String, Object?>>{};

  /// Stored objects by photo client id.
  final objects = <String, Uint8List>{};

  /// When true every request fails like airplane mode (connection error).
  bool offline = false;

  /// Optional per-test answer.
  Intercept? intercept;

  /// Changes served by `GET /v1/sync/pull`, page by page; each page is `(changes, next_cursor, has_more)`.
  final pullPages = <(List<Map<String, Object?>>, String, bool)>[];

  /// Reference parts served by `GET /v1/sync/reference`: name → (version, etag, body).
  final reference = <String, (int, String, Object?)>{};

  /// Requests with [method] whose path contains [path].
  List<Seen> seen(String method, String path) =>
      requests.where((r) => r.method == method && r.path.contains(path)).toList();

  /// Entry client ids sent across all pushes, in order.
  List<String> get pushedIds => [
    for (final r in seen('POST', '/v1/sync/push'))
      for (final e in ((r.body! as Map)['entries'] as List).cast<Map<String, Object?>>()) e['client_id']! as String,
  ];

  /// Serves one request. Returns the fake response; throws a connection-error [DioException] when [offline].
  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    final bytes = requestStream == null ? null : Uint8List.fromList(await requestStream.expand((b) => b).toList());
    final isJson = o.method != 'PUT' && bytes != null && bytes.isNotEmpty;
    final path = o.uri.host == 's3.test' ? o.uri.toString() : o.uri.path;
    final request = (
      method: o.method,
      path: path,
      query: o.uri.queryParameters,
      body: isJson ? jsonDecode(utf8.decode(bytes)) : bytes,
      headers: o.headers,
    );
    requests.add(request);
    if (offline) throw DioException.connectionError(requestOptions: o, reason: 'airplane mode');
    final custom = await intercept?.call(request);
    if (custom != null) return custom;
    return _default(o, request, bytes);
  }

  /// The default protocol behaviour. Returns the response; throws nothing.
  ResponseBody _default(RequestOptions o, Seen r, Uint8List? bytes) {
    final now = clock();
    switch ((r.method, o.uri.path)) {
      case ('HEAD', '/v1/healthz'):
        return ResponseBody.fromString('', 200);
      case ('POST', '/v1/sync/push'):
        final results = [
          for (final e in ((r.body! as Map)['entries'] as List).cast<Map<String, Object?>>()) _push(e, now),
        ];
        return json({'server_time': now.toIso8601String(), 'results': results});
      case ('PUT', _):
        final id = o.uri.pathSegments.last.split('.').first;
        objects[id] = bytes!;
        return ResponseBody.fromString('', 200);
      case ('POST', '/v1/sync/photos/confirm'):
        return json([
          for (final p in ((r.body! as Map)['photos'] as List).cast<Map<String, Object?>>())
            {'client_id': p['client_id'], 'status': objects.containsKey(p['client_id']) ? 'received' : 'missing'},
        ]);
      case ('GET', '/v1/sync/pull'):
        if (pullPages.isEmpty) return json({'changes': [], 'next_cursor': null, 'has_more': false});
        final (changes, cursor, more) = pullPages.removeAt(0);
        return json({'changes': changes, 'next_cursor': cursor, 'has_more': more});
      case ('GET', '/v1/sync/reference'):
        // B07: a part is returned when its version differs from the phone's or the phone did not list it.
        final since = {
          for (final item in (o.uri.queryParameters['since'] ?? '').split(',').where((i) => i.isNotEmpty))
            item.split(':').first: int.parse(item.split(':').last),
        };
        final changed = {
          for (final MapEntry(key: name, value: (version, etag, body)) in reference.entries)
            if (since[name] != version) name: {'version': version, 'etag': etag, 'body': body},
        };
        return changed.isEmpty ? ResponseBody.fromString('', 304) : json({'parts': changed});
    }
    return json({
      'error': {'code': 'not_found'},
    }, status: 404);
  }

  /// Stores one pushed entry (idempotent by client id) and answers like B06: accepted / duplicate with upload URLs
  /// for photos not yet in storage. Returns the result map; throws nothing.
  Map<String, Object?> _push(Map<String, Object?> e, DateTime now) {
    final id = e['client_id']! as String;
    final duplicate = entries.containsKey(id);
    entries.putIfAbsent(id, () => e);
    final photos = (((entries[id]!['data'] as Map)['photos'] as List?) ?? const []).cast<Map<String, Object?>>();
    return {
      'client_id': id,
      'status': duplicate ? 'duplicate' : 'accepted',
      'server_id': id,
      'photo_uploads': [
        for (final p in photos.where((p) => !objects.containsKey(p['client_id'])))
          {
            'photo_client_id': p['client_id'],
            'method': 'PUT',
            'url': 'https://s3.test/evidence/fpo-1/${p['client_id']}.jpg',
            'headers': <String, String>{},
            'expires_at': now.add(const Duration(minutes: 15)).toIso8601String(),
          },
      ],
    };
  }

  /// Does nothing (no resources). Throws nothing.
  @override
  void close({bool force = false}) {}
}

/// A JSON response with [body], [status] and extra [headers]. Returns it; throws nothing.
ResponseBody json(Object? body, {int status = 200, Map<String, String> headers = const {}}) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
    for (final h in headers.entries) h.key: [h.value],
  },
);

/// Jitter source that always returns the middle of the range, so backoffs are exactly 2, 4, 8 … s.
class MidRandom implements Random {
  /// Returns 0.5.
  @override
  double nextDouble() => 0.5;

  /// Returns 0.
  @override
  int nextInt(int max) => 0;

  /// Returns false.
  @override
  bool nextBool() => false;
}

/// One test world: in-memory database, fake server, fake clock and network, and the engine under test.
class World {
  /// Creates an empty world; call [init] to sign in before use.
  World();

  /// The offline store.
  final db = memoryDb();

  /// Test clock; advance it with [advance].
  DateTime clock = t0;

  /// Network type the engine sees.
  String network = 'mobile';

  /// Whether the reachability probe succeeds.
  bool reachable = true;

  /// Connectivity change events for [SyncService.start].
  final networkChanges = StreamController<Object?>.broadcast();

  /// The fake server.
  late final server = FakeServer(() => clock);

  /// Temp directory for photo files.
  final dir = Directory.systemTemp.createTempSync('m02_sync');

  /// The engine under test.
  late final SyncService sync = newService();

  /// A new engine on the same database and server (a restarted app). Returns it; throws nothing.
  SyncService newService() {
    final api = Dio(BaseOptions(baseUrl: 'https://api.test'))..httpClientAdapter = server;
    return SyncService(
      db: db,
      api: api,
      networkType: () async => network,
      networkChanges: networkChanges.stream,
      reachable: () async => reachable,
      now: () => clock,
      random: MidRandom(),
    );
  }

  /// Signs in [userId] (default `user-1`) with [wifiOnlyPhotos]. Returns when written.
  Future<void> init({String userId = 'user-1', bool wifiOnlyPhotos = false}) =>
      signIn(db, userId, wifiOnlyPhotos: wifiOnlyPhotos);

  /// Moves the clock forward by [d].
  void advance(Duration d) => clock = clock.add(d);

  /// Saves a harvest entry (owner [owner]) with [photos] real JPEG-ish files on disk. Returns the entry id.
  Future<String> save({int photos = 0, String owner = 'user-1'}) async {
    final entry = entryAt(at: clock).copyWith(
      enteredByUserId: Value(owner),
      lat: const Value(9.5598),
      lng: const Value(78.1335),
      accuracyM: const Value(6.2),
    );
    final id = entry.entryId.value;
    final media = <MediaCompanion>[];
    for (var i = 0; i < photos; i++) {
      final file = File('${dir.path}/$id-$i.jpg')..writeAsBytesSync(List.filled(1000 + i, 7));
      File('${file.path}.thumb.jpg').writeAsBytesSync([1]);
      media.add(
        photoOf(
          id,
          path: file.path,
          bytes: file.lengthSync(),
        ).copyWith(sha256: Value(sha256.convert(file.readAsBytesSync()).toString())),
      );
    }
    await db.entriesDao.save(entry, media);
    return id;
  }

  /// A context for calling one phase directly, as `user-1` on the world's network and clock. Returns it.
  SyncContext contextFor() => SyncContext(
    db: db,
    api: sync.api,
    uploads: sync.uploads,
    userId: 'user-1',
    deviceId: '0190f0c4-0000-7000-8000-000000000001',
    appVersion: 'test',
    networkType: network,
    now: () => clock,
    random: MidRandom(),
  );

  /// Writes the photo bytes [save] uses back to [path] (a full-size file the test pretends was not purged).
  void restoreFile(String path) => File(path).writeAsBytesSync(List.filled(1000, 7));

  /// The signed-in user's pending count right now.
  Future<int> pending() => db.outboxDao.pendingCount().first;

  /// The outbox row of [refId].
  Future<OutboxItem> outboxOf(String refId) => (db.select(db.outbox)..where((o) => o.refId.equals(refId))).getSingle();

  /// The entry [id].
  Future<Entry> entry(String id) => (db.select(db.entries)..where((e) => e.entryId.equals(id))).getSingle();

  /// Media rows of entry [id].
  Future<List<MediaFile>> mediaOf(String id) => (db.select(db.media)..where((m) => m.entryId.equals(id))).get();

  /// Closes the database, the engine and the temp directory.
  Future<void> dispose() async {
    await sync.dispose();
    await networkChanges.close();
    await db.close();
    dir.deleteSync(recursive: true);
  }
}
