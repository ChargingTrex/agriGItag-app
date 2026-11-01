*** Settings ***
Documentation       Events, sync push, evidence (plan §7.1 B06) and reference bundle + sync pull (B07), live.
...                 Serves: FR-4, FR-6, FR-24, FR-25, FR-26, FR-47, FR-61; gate G2; BM-06, BM-15 (benchmarks stay
...                 in docs/agents/qa/B06/bench).
...                 Live procedures: docs/agents/qa/B06.md (live_b06.py: pushes as a QA farmer, an object written
...                 around the presigned URL, the worker's verify_photo and rules), B07.md (live_b07.py: ETags per
...                 part, standards part = DB rules, pull drain + one flag inserted + wait past PULL_SETTLE 30 s).
...                 The pull line uses its own farmer, created in the suite setup, so no other line's writes reach it.
Resource            ../resources/common.resource
Suite Setup         Sync Suite Setup
Suite Teardown      Disconnect From Database
Test Tags           api


*** Test Cases ***
Same Client Id Pushed Twice Stores One Row
    [Tags]    WP-B06    FR-4
    ${e}=    Harvest Entry
    ${first}=    Push    ${FARMER}    ${e}
    ${second}=    Push    ${FARMER}    ${e}
    Should Be Equal    ${first}[0][status]    accepted
    Should Be Equal    ${second}[0][status]    duplicate
    Should Be Equal    ${first}[0][server_id]    ${second}[0][server_id]
    Check Row Count    SELECT 1 FROM event_versions WHERE id = '${e}[client_id]'    ==    1

Foreign Owned Client Id Returns Client Id Conflict
    [Tags]    WP-B06    FR-24
    ${e}=    Harvest Entry
    Push    ${FARMER}    ${e}
    ${r}=    Push    ${OFFICER}    ${e}
    Should Be Equal    ${r}[0][status]    rejected
    Should Be Equal    ${r}[0][error][code]    client_id_conflict

Push Of 51 Entries Returns 422
    [Tags]    WP-B06    FR-4
    @{entries}=    Create List
    FOR    ${i}    IN RANGE    51
        ${e}=    Harvest Entry
        Append To List    ${entries}    ${e}
    END
    ${r}=    Push    ${FARMER}    @{entries}    expect=422
    Should Be Equal    ${r}[error][code]    validation_error

Mixed Batch Accepts 1 And 3 And Rejects 2
    [Tags]    WP-B06    FR-4
    # Entry 2 names the second plot on the first plot's lot: not the lot's plot.
    ${bad}=    Event    ${LOT}    ${PLOT2}    harvest    ${TODAY}    ${{ {"quantity": {"value": 195, "unit": "kg"}} }}
    ${e1}=    Harvest Entry
    ${e3}=    Harvest Entry
    ${r}=    Push    ${FARMER}    ${e1}    ${bad}    ${e3}
    ${got}=    Evaluate    [(x["status"], (x.get("error") or {}).get("code")) for x in $r]
    Should Be Equal    ${got}    ${{ [("accepted", None), ("rejected", "validation_error"), ("accepted", None)] }}
    Check Row Count    SELECT 1 FROM event_versions WHERE id = '${bad}[client_id]'    ==    0

Wrong Photo Checksum Returns Checksum Mismatch And A Flag
    [Tags]    WP-B06    FR-61
    ${photo}=    Evaluate    str(uuid.uuid4())
    ${promised}=    Evaluate    hashlib.sha256(b"promised").hexdigest()
    ${e}=    Event    ${LOT}    ${PLOT}    harvest    ${TODAY}    ${{ {"quantity": {"value": 195, "unit": "kg"}} }}
    Set To Dictionary    ${e}[data]    photos=${{ [{"client_id": $photo, "sha256": $promised, "size_bytes": 8}] }}
    ${r}=    Push    ${FARMER}    ${e}
    Should Be Equal    ${r}[0][status]    accepted
    ${key}=    Query    SELECT object_key FROM evidence_photos WHERE id = '${photo}'
    # Written around the presigned URL, as a tampering client would.
    S3 Put    evidence    ${key}[0][0]    tampered
    Call API    POST    /sync/photos/confirm    ${FARMER}    expect=200    json=${{ {"photos": [{"client_id": $photo}]} }}
    Check Row Count    SELECT 1 FROM evidence_photos WHERE id = '${photo}' AND status = 'checksum_mismatch'    ==    1
    ...    retry_timeout=120s    retry_pause=3s
    Check Row Count    SELECT 1 FROM flags WHERE rule_code = 'photo_checksum_mismatch' AND (subject_id IN ('${photo}', '${e}[data][event_id]') OR details::text LIKE '%${photo}%')
    ...    >=    1    retry_timeout=120s    retry_pause=3s

Undo After 24 h Returns 409
    [Tags]    WP-B06    FR-6
    ${e}=    Event    ${LOT}    ${PLOT}    harvest    ${TODAY}    ${{ {"quantity": {"value": 195, "unit": "kg"}} }}    clock_shift_hours=-25
    Push    ${FARMER}    ${e}
    ${r}=    Call API    POST    /events/${e}[data][event_id]/undo    ${FARMER}    expect=409
    ...    json=${{ {"client_id": str(uuid.uuid4()), "version_no": 2} }}
    Error Code Should Be    ${r}    undo_window_closed

Farmer Correction Returns 403
    [Tags]    WP-B06    FR-25
    ${e}=    Harvest Entry
    Push    ${FARMER}    ${e}
    ${data}=    Evaluate    {**$e["data"], "version_no": 2, "change_kind": "correct", "reason_code": "wrong_quantity", "payload": {"quantity": {"value": 185, "unit": "kg"}}}
    ${r}=    Call API    POST    /events/${e}[data][event_id]/versions    ${FARMER}    expect=403
    ...    json=${{ {"client_id": str(uuid.uuid4()), "data": $data} }}
    Error Code Should Be    ${r}    forbidden

Device Clock 3 Days Ahead Is Stored With A Clock Skew Flag
    [Tags]    WP-B06    FR-26
    ${e}=    Event    ${LOT}    ${PLOT}    harvest    ${TODAY}    ${{ {"quantity": {"value": 195, "unit": "kg"}} }}    clock_shift_hours=72
    ${r}=    Push    ${FARMER}    ${e}
    Should Be Equal    ${r}[0][status]    accepted
    Check Row Count    SELECT 1 FROM event_versions WHERE id = '${e}[client_id]' AND device_time - server_received_at > interval '71 hours'    ==    1
    Check Row Count    SELECT 1 FROM flags WHERE rule_code = 'clock_skew' AND subject_id IN ('${e}[data][event_id]', '${e}[client_id]')
    ...    ==    1    retry_timeout=120s    retry_pause=3s

Matching If-None-Match On The Bundle Returns 304
    [Tags]    WP-B07    FR-4
    ${manifest}=    Call API    GET    /sync/bundle    ${FARMER}    expect=200
    ${parts}=    Set Variable    ${manifest.json()}[parts]
    Should Not Be Empty    ${parts}
    FOR    ${part}    IN    @{parts}
        ${first}=    Call API    GET    /sync/bundle/${part}    ${FARMER}    expect=200
        Should Be Equal    ${first.headers}[etag]    ${parts}[${part}][etag]
        ${again}=    Call API    GET    /sync/bundle/${part}    ${FARMER}    expect=304    headers=${{ {"If-None-Match": $parts[$part]["etag"]} }}
        Should Be Empty    ${again.content}
        Call API    GET    /sync/bundle/${part}    ${FARMER}    expect=200    headers=${{ {"If-None-Match": '"stale"'} }}
    END

Standards Bundle Part Carries The Full Profile Rules Per Active Version
    [Tags]    WP-B07    FR-47
    ${r}=    Call API    GET    /sync/bundle/standards    ${FARMER}    expect=200
    ${rows}=    Query    SELECT sp.crop_id::text, v.rules::text FROM standards_profile_versions v JOIN standards_profiles sp ON sp.id = v.profile_id WHERE v.version_no = (SELECT max(version_no) FROM standards_profile_versions w WHERE w.profile_id = v.profile_id)
    ${db}=    Evaluate    {crop: json.loads(rules) for crop, rules in $rows}
    Should Be Equal    ${r.json()}[profiles]    ${db}
    ${rules}=    Set Variable    ${r.json()}[profiles][${CROP}]
    FOR    ${key}    IN    grades    fail_grade    parameters    lot_gates    trail_rules    lab_certified_requires    yield
        Dictionary Should Contain Key    ${rules}    ${key}
    END

Pull After A New Flag Returns Exactly That Flag
    [Tags]    WP-B07    FR-4
    # Rows younger than PULL_SETTLE (30 s) are held back: let the pull farmer's own setup rows settle first.
    ${age}=    Evaluate    time.time() - $PULL_SINCE
    IF    ${age} < 35    Sleep    ${{ 35 - $age }}s
    ${first}=    Drain Pull    ${PULL_FARMER}[phone]
    ${again}=    Drain Pull    ${PULL_FARMER}[phone]    ${first}[cursor]
    Should Be Empty    ${again}[changes]
    ${flag}=    Evaluate    str(uuid.uuid4())
    Execute Sql String    INSERT INTO flags (id, fpo_id, subject_type, subject_id, rule_code, severity, details, dedupe_key, status, assigned_role, raised_at, created_at, updated_at) SELECT '${flag}', fpo_id, 'lot', id, 'quantity_mismatch', 'warn', '{"qa_robot": true}', 'quantity_mismatch:${PULL_LOT}:qa', 'open', 'field_officer', now(), now(), now() FROM lots WHERE id = '${PULL_LOT}'
    Sleep    35s    reason=PULL_SETTLE is 30 s
    ${second}=    Drain Pull    ${PULL_FARMER}[phone]    ${first}[cursor]
    ${got}=    Evaluate    [(c["entity"], c["op"], c["data"].get("id")) for c in $second["changes"]]
    Should Be Equal    ${got}    ${{ [("flag", "upsert", $flag)] }}


*** Keywords ***
Sync Suite Setup
    [Documentation]    Connect to the DB; the QA farmer gets a second plot and a lot on the main plot; a separate
    ...    pull farmer gets one plot and lot (its clock ${PULL_SINCE} starts now).
    Connect To AgriTrace Database
    ${w}=    QA World
    ${pull}=    New Farmer    QA Robot Pull Farmer
    ${pull_plot}=    New Plot    farmer_id=${pull}[id]
    ${pull_lot}=    New Lot    ${pull_plot}
    Login As    ${pull}[phone]
    Set Suite Variable    ${PULL_SINCE}    ${{ time.time() }}
    Set Suite Variable    ${PULL_FARMER}    ${pull}
    Set Suite Variable    ${PULL_LOT}    ${pull_lot}
    Set Suite Variable    ${FARMER}    ${w}[farmer][phone]
    Set Suite Variable    ${CROP}    ${w}[crop]
    Set Suite Variable    ${PLOT}    ${w}[plot]
    ${plot2}=    New Plot
    Set Suite Variable    ${PLOT2}    ${plot2}
    ${lot}=    New Lot
    Set Suite Variable    ${LOT}    ${lot}
    ${today}=    Days Ago    0
    Set Suite Variable    ${TODAY}    ${today}

Harvest Entry
    [Documentation]    A 195 kg harvest entry on the suite's lot (main QA plot), dated today. Returns: the entry.
    ${e}=    Event    ${LOT}    ${PLOT}    harvest    ${TODAY}    ${{ {"quantity": {"value": 195, "unit": "kg"}, "bags": 13} }}
    RETURN    ${e}
