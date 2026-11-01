"""Verifier live check (B04): enqueue notifications.send on the compose broker (run inside the api container).

The worker container consumes and delivers it; rows are then read with psql. Arg: recipient user id.
"""
import sys

from agritrace.worker import app

uid = sys.argv[1]
for key, lang, payload in [("harvest_reminder", "ta", {"plot_name": "Verifier plot"}), ("no_such_template", "en", {})]:
    r = app.send_task("notifications.send", kwargs={"user_id": uid, "template_key": key, "channel": "console", "lang": lang, "payload": payload})
    print("enqueued", key, r.id)
