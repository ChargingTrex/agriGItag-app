Drift offline store (M01, D-014): `database.dart` (AppDatabase, migrations), `tables/` (mobile-design.md §2 plus the
append-only triggers in `append_only.drift`), `daos/` (one DAO per job). Generated `*.g.dart` files are committed;
regenerate with `tool/schema_dump.sh`. See apps/mobile/README.md "Offline store".
