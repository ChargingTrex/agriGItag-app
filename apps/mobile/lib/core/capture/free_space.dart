// Free storage on the phone and the "Phone is full" purge: below 100 MB free, the files of photos the server has
// confirmed are deleted (never a photo still waiting to upload) and the farmer is asked to send the rest.
// Requirement: PLAN §7.2 M13 ("storage < 100 MB → prompt + purge confirmed photos"); mobile-design.md §3 ("Phone is
//   full" purge); UserFlows §When things go wrong (phone full); Arch §Offline-first "Photos made light".
// Callers: features/farmer_home/farmer_home_screen.dart (lowStorageAtStartProvider, once per app start),
//   features/event_log/camera_step.dart (purgeIfLow after each photo); test/features/low_storage_test.dart.

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../db/providers.dart';

/// Below this many free bytes (100 MiB) the phone counts as full (PLAN §7.2 M13).
const lowStorageBytes = 100 * 1024 * 1024;

/// Answered by android/app/src/main/kotlin/.../MainActivity.kt (`freeBytes`: StatFs of the app's files folder).
// DECISION D-053: free space from a three-line StatFs channel in MainActivity.kt, not a disk-space plugin.
//   ADV: no dependency (or LIBRARIES.md row) for one platform call.
//   COMPROMISE: iOS has no handler yet, so the check is skipped there (TODO.md); the pilot phones are Android.
const _storageChannel = MethodChannel('in.agritrace/storage');

/// Reads the free bytes of the app's storage. The function returns null when the platform cannot tell (no handler:
/// iOS until its TODO, tests), so the check is skipped rather than guessed; it throws nothing. Tests override it.
final freeBytesProvider = Provider<Future<int?> Function()>(
  (ref) => () async {
    try {
      return await _storageChannel.invokeMethod<int>('freeBytes');
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  },
);

/// The phone-full check: when [freeBytes] reports less than [lowStorageBytes], deletes the files of every photo the
/// server has confirmed (MediaDao.purgeConfirmed, [now] recorded as `purgedAt`).
///
/// [db] is the offline store. Returns true when the phone is full (the caller then shows the "Phone is full. Send
/// your entries now?" sheet), false when there is room or the free space is unknown. Throws [FileSystemException]
/// when a file cannot be deleted. Side effect: deletes files on disk.
Future<bool> purgeIfLow({
  required Future<int?> Function() freeBytes,
  required AppDatabase db,
  required DateTime now,
}) async {
  final free = await freeBytes();
  if (free == null || free >= lowStorageBytes) return false;
  await db.mediaDao.purgeConfirmed(now: now);
  return true;
}

/// [purgeIfLow] once per app start, run by the first farmer home that watches it (assist mode included); true when
/// the phone was full. Errors stay in the AsyncValue (the check is a convenience, never a blocker).
final lowStorageAtStartProvider = FutureProvider<bool>(
  (ref) => purgeIfLow(
    freeBytes: ref.read(freeBytesProvider),
    db: ref.read(appDatabaseProvider),
    now: DateTime.now().toUtc(),
  ),
);
