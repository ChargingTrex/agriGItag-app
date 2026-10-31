// Riverpod provider for the app's one Drift database.
// Requirement: mobile-design.md §1 (core/db), D-013 (Riverpod providers, overridable in tests), D-014.
// Callers: SessionNotifier (lib/core/router/session.dart), the settings placeholder (outbox count); M02 sync and the
//   feature screens from M07 on. Tests override it with `AppDatabase(NativeDatabase.memory())`.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database.dart';

/// The app's database, opened once (`AppDatabase.open()`, lazily on first query) and closed when the scope ends.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
});
