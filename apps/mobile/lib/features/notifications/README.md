Push and local reminders, deep links (M12, FR7, D-046).
- `reminders.dart`: one local notification per open task in the Tasks table (due time, ta/en, "Time to log: Harvest",
  "Field 2", payload `/log/<event>?lot=<id>`), rescheduled on every Tasks / session / switch change; tap and
  cold-start launch open the event on top of the farmer home; one-time permission rationale; Settings switch state.
- `push.dart`: `PushProvider` seam with the console provider (no Firebase yet); registration behind the
  `push_notifications` flag of the `fields` bundle.
