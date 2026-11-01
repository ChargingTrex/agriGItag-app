"""Verifier live check of the B15 push kinds `farmer` and `assist_session` (D-031, D-032) on the compose stack.

Purpose: the G5 condition (rulings 2026-10-31 §4): offline onboarding push [farmer, assist_session, consent, plot]
-> 4 x accepted, replay -> 4 x duplicate, online timeout then sync -> one farmer; plus the role, ended-session,
unknown-session and config-feature lines, all as the seeded field officer +919000000002 against the real API.
New farmers use phones +919000000151..153. Prints every call and SQL read; adds ids to $QA_WORLD.
Caller: the Verifier, once.
"""

import os
import sys
from datetime import UTC, datetime

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "B09", "logs"))
from qa_live import (ADMIN, OFFICER, QA_FARMER_PHONE, check, client, load, push, save, section, show, sql,  # noqa: E402
                     statuses, uuid7)

W = load()
LAT, LON = 9.5598, 78.1335
officer_id = sql(f"select id from users where phone='{OFFICER}'")


def farmer_e(fid, phone, name="QA Onboard Farmer"):
    """A `farmer` entry."""
    return {"client_id": str(fid), "kind": "farmer", "data": {"name": name, "phone": phone, "lang": "ta"}}


def session_e(sid, fid):
    """An `assist_session` entry."""
    return {"client_id": str(sid), "kind": "assist_session",
            "data": {"farmer_id": str(fid), "started_at": datetime.now(UTC).isoformat(), "started_gps": None}}


def consent_e(fid, sid=None):
    """A `consent` entry (data_collection)."""
    return {"client_id": str(uuid7()), "kind": "consent", "assist_session_id": sid and str(sid),
            "data": {"farmer_id": str(fid), "consent_type": "data_collection", "consent_version": "v1-ta",
                     "given_at": datetime.now(UTC).isoformat()}}


def plot_e(fid, sid=None, lat=LAT):
    """A `plot` entry (1.5 acre, live GPS)."""
    return {"client_id": str(uuid7()), "kind": "plot", "assist_session_id": sid and str(sid),
            "data": {"farmer_id": str(fid), "pin": {"lat": lat, "lon": LON, "accuracy_m": 5}, "pin_method": "live_gps",
                     "device_time": datetime.now(UTC).isoformat(), "declared_area": {"value": 1.5, "unit": "acre"}}}


def audit(entity: str, eid) -> str:
    """The create audit row's (actor, assist_session_id, on_behalf_of_farmer_id)."""
    return sql(f"select actor_user_id, coalesce(assist_session_id::text,'-'), coalesce(on_behalf_of_farmer_id::text,'-') "
               f"from audit_log where entity_type='{entity}' and entity_id='{eid}' and action='create'")


with client(OFFICER) as o, client(ADMIN) as a, client(QA_FARMER_PHONE) as fm:
    section("1 G5: officer push, no header: [farmer F, assist_session S(F), consent(F,S), plot(F,S)] -> 4 x accepted")
    f, s = uuid7(), uuid7()
    phone = "+919000000151"
    entries = (farmer_e(f, phone), session_e(s, f), consent_e(f, s), plot_e(f, s))
    res = push(o, *entries)
    check("4 x accepted", statuses(res) == ["accepted"] * 4)
    row = sql(f"select status, fpo_id from farmers where id='{f}'")
    check("farmers.id == F, status pending", row.startswith("pending|"))
    check("one users row and one memberships row for the phone",
          sql(f"select count(*) from users where phone='{phone}'") == "1" and
          sql(f"select count(*) from memberships m join users u on u.id=m.user_id where u.phone='{phone}'") == "1")
    check("consent witnessed_by_user_id = officer",
          sql(f"select witnessed_by_user_id from consent_records where id='{entries[2]['client_id']}'") == officer_id)
    for ent, e in (("consent_records", entries[2]), ("plots", entries[3])):
        check(f"{ent} audit row carries S and F", audit(ent, e["client_id"]) == f"{officer_id}|{s}|{f}")
    check("farmer's audit row carries neither", audit("farmers", f) == f"{officer_id}|-|-")
    res = push(o, *entries)
    check("replay -> 4 x duplicate", statuses(res) == ["duplicate"] * 4)
    check("still one farmer, user, membership, consent, plot",
          sql(f"select (select count(*) from farmers where id='{f}'), (select count(*) from users where phone='{phone}'),"
              f" (select count(*) from memberships m join users u on u.id=m.user_id where u.phone='{phone}'),"
              f" (select count(*) from consent_records where farmer_id='{f}'), (select count(*) from plots where farmer_id='{f}')")
          == "1|1|1|1|1")
    W.update(b15_farmer=str(f), b15_session=str(s), b15_plot=entries[3]["client_id"])
    save(W)

    section("2 G5: online timeout then sync -> one farmer (POST /v1/farmers client_id G, then kind=farmer G)")
    g, phone_g = uuid7(), "+919000000152"
    r = show(a.post("/farmers", json={"name": "QA Timeout Farmer", "phone": phone_g, "lang": "ta", "client_id": str(g)}))
    check("POST /farmers with client_id G -> 201, id == G", r.status_code == 201 and r.json()["id"] == str(g))
    r = show(a.post("/farmers", json={"name": "QA Timeout Farmer", "phone": phone_g, "lang": "ta", "client_id": str(g)}))
    print("  repeat POST status:", r.status_code)
    check("repeat POST /farmers G -> 200 or 201 with the stored farmer", r.status_code in (200, 201) and r.json()["id"] == str(g))
    res = push(o, farmer_e(g, phone_g, "QA Timeout Farmer"))
    check("kind=farmer G -> duplicate (not farmer_phone_taken)", statuses(res) == ["duplicate"])
    check("one farmer, one user", sql(f"select (select count(*) from farmers where id='{g}'), "
                                      f"(select count(*) from users where phone='{phone_g}')") == "1|1")

    section("3 kind=farmer by a farmer token -> forbidden; taken phone -> farmer_phone_taken and the next plot rejected")
    res = push(fm, farmer_e(uuid7(), "+919000000153"))
    check("farmer token -> rejected forbidden", statuses(res) == ["rejected:forbidden"])
    h = uuid7()
    res = push(o, farmer_e(h, phone, "QA Same Phone"), plot_e(h))
    check("phone of farmer F under a new id -> farmer_phone_taken; its plot -> rejected",
          statuses(res)[0] == "rejected:farmer_phone_taken" and res[1]["status"] == "rejected")
    print("  plot rejection:", res[1].get("error"))

    section("4 unknown session -> assist_session_invalid, next entry still processed; S for F on another farmer -> forbidden")
    res = push(o, consent_e(f, uuid7()), plot_e(f, s))
    check("[consent(F, unknown S), plot(F, S)] -> [rejected assist_session_invalid, accepted]",
          statuses(res) == ["rejected:assist_session_invalid", "accepted"])
    res = push(o, plot_e(W["farmer"], s))
    check("plot for the QA farmer with F's session S -> rejected forbidden", statuses(res) == ["rejected:forbidden"])

    section("5 ended session: per-entry accepted with assist recorded; X-Assist-Session with it -> 403")
    show(o.post("/assist/end", json={"assist_session_id": str(s)}))
    print("  ended_at:", sql(f"select ended_at from assist_sessions where id='{s}'"))
    e = plot_e(f, s, lat=LAT + 0.001)
    res = push(o, e)
    check("entry carrying ended S -> accepted", statuses(res) == ["accepted"])
    check("its audit row carries S and F", audit("plots", e["client_id"]) == f"{officer_id}|{s}|{f}")
    r = show(o.post("/sync/push", json={"device_id": str(uuid7()), "app_version": "1.0.3",
                                        "device_time": datetime.now(UTC).isoformat(), "entries": [plot_e(f)]},
                    headers={"X-Assist-Session": str(s)}))
    check("X-Assist-Session ended S -> 403 assist_session_invalid",
          r.status_code == 403 and r.json()["error"]["code"] == "assist_session_invalid")

    section("6 assist_session with an id used by another officer -> conflict; by a farmer token -> forbidden")
    # The seeded FPO has one field officer; the FPO admin is not a field officer, so "another officer" is not
    # reproducible live without adding a user. The farmer-token case is run; the conflict case is the integration test.
    res = push(fm, session_e(uuid7(), W["farmer"]))
    check("assist_session by a farmer token -> rejected forbidden", statuses(res) == ["rejected:forbidden"])

    section("7 /v1/config/features carries grading_loss_warn_pct")
    r = show(o.get("/config/features"), 3000)
    check("grading_loss_warn_pct present (15)", r.json().get("grading_loss_warn_pct") == 15)

    section("8 D-030 on the seeded reference batch: grading_loss_high open, no batch_quantity_unattributed")
    print(sql("select rule_code, severity, status from flags where subject_id='01900000-0000-7000-8000-0000000b12aa' order by rule_code"))
