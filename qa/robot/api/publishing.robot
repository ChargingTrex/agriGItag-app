*** Settings ***
Documentation       Publishing the static batch page (plan §7.1 B10) and reporting + stubs (B11), live.
...                 Serves: FR-12, FR-15, FR-16, FR-17, FR-20, FR-21, FR-33, FR-41, FR-63; gates G2/G4; BM-09
...                 (the privacy-lint benchmark itself stays in docs/agents/qa/B10/bench).
...                 Live procedures: docs/agents/qa/B10.md (live_b10.py: objects in public-pages/batches/<code>/,
...                 leak search, QR decode, rebuild after a correction keeps old S3 versions) and B11.md
...                 (live_b11.py). The suite setup publishes batch X: lots of 100 / 200 / 20 kg of the run's QA
...                 farmer, the first with five events pushed out of date order, then waits for the worker's build.
...                 S3 versions and the QR decoder are reached through ${COMPOSE} (LocalStack, api image).
Resource            ../resources/common.resource
Suite Setup         Publishing Suite Setup
Suite Teardown      Disconnect From Database
Test Tags           api


*** Test Cases ***
Published Objects Exist With Matching Generation
    [Tags]    WP-B10    FR-17
    ${data}=    Page Object    data.json
    ${html}=    Page Object    index.html
    Page Object    qr.png
    ${gen}=    Query    SELECT generation FROM page_builds WHERE batch_id = '${X}[id]' AND status = 'built' ORDER BY build_no DESC LIMIT 1
    Should Be Equal As Strings    ${data.json()}[footer][generation]    ${gen}[0][0]
    ${proxy}=    Call API    GET    /public/batches/${X}[code]    expect=200
    Should Be Equal    ${proxy.content}    ${html.content}

Page HTML Has No Phone Survey Number Or Temp Uploads
    [Tags]    WP-B10    FR-16
    ${w}=    QA World
    ${phones}=    Query    SELECT phone FROM users
    ${leaks}=    Evaluate    [$w["farmer"]["phone"], $w["farmer"]["phone"][-10:], "QA-SURVEY", "77/3B", "Survey", "temp_uploads", "626129"] + [p for (p,) in $phones] + [p[-10:] for (p,) in $phones]
    FOR    ${name}    IN    index.html    data.json
        ${r}=    Page Object    ${name}
        ${hits}=    Evaluate    [x for x in $leaks if x in $r.text]
        Should Be Empty    ${hits}    msg=${name} leaks ${hits}
    END

Revoked Name Consent Shows Farmer 2
    [Tags]    WP-B10    FR-41
    ${name}=    Evaluate    "QA Robot Kannan " + uuid.uuid4().hex[:6]
    ${farmer}=    New Farmer    ${name}
    ${session}=    Start Assist    ${farmer}[id]
    ${consent}=    New Consent    ${farmer}[id]    public_name    ${session}
    Call API    POST    /consents/${consent}[id]/revoke    ${OFFICER}    expect=200    headers=${{ {"X-Assist-Session": $session} }}
    ${plot}=    New Plot    farmer_id=${farmer}[id]
    ${a}=    Received Lot    100    ${plot}
    ${b}=    Received Lot    200    ${plot}
    ${batch}=    Publish Batch    ${{ [$a, $b] }}
    ${html}=    Page Object    index.html    ${batch}[code]
    Should Contain    ${html.text}    Farmer 2
    Should Not Contain    ${html.text}    ${name}
    ${data}=    Page Object    data.json    ${batch}[code]
    ${names}=    Evaluate    [lot["farmer_name"] for lot in $data.json()["lots"]]
    Should Be Equal    ${names}    ${{ [None, None] }}

Correction Creates A New Build And Keeps Old Versions
    [Tags]    WP-B10    FR-17
    ${before}=    S3 Versions    public-pages    batches/${X}[code]/data.json
    ${data}=    Evaluate    {k: v for k, v in $HARVEST["data"].items() if k != "gps"}
    Set To Dictionary    ${data}    version_no=${2}    change_kind=correct    reason_code=entered_by_mistake
    ...    payload=${{ {"quantity": {"value": 112, "unit": "kg"}, "bags": 5} }}
    Call API    POST    /events/${data}[event_id]/versions    ${OFFICER}    expect=200    json=${{ {"client_id": str(uuid.uuid4()), "data": $data} }}
    ${r}=    Call API    POST    /batches/${X}[id]/rebuild    ${ADMIN}    expect=202
    ${build}=    Wait For Build    ${X}[id]    ${r.json()}[build_no]
    Should Be Equal    ${build}[status]    built
    ${after}=    S3 Versions    public-pages    batches/${X}[code]/data.json
    Length Should Be    ${after}    ${{ len($before) + 1 }}
    @{gens}=    Create List
    FOR    ${v}    IN    @{after}
        ${body}=    S3 Get    public-pages    batches/${X}[code]/data.json    ${v}[VersionId]
        Append To List    ${gens}    ${{ json.loads($body)["footer"]["generation"] }}
    END
    Should Be True    ${gens}[0] > ${gens}[1]    msg=newest first: ${gens}
    ${html}=    S3 Versions    public-pages    batches/${X}[code]/index.html
    Length Should Be    ${html}    ${{ len($after) }}

QR Decodes To The Public Batch URL
    [Tags]    WP-B10    FR-12
    ${want}=    Set Variable    ${PUBLIC_BASE}/b/${X}[code]
    ${s3}=    Page Object    qr.png
    ${api}=    Call API    GET    /batches/${X}[id]/qr.png    ${ADMIN}    expect=200
    FOR    ${png}    IN    ${s3.content}    ${api.content}
        ${texts}=    Decode QR    ${png}
        Should Be Equal    ${texts}    ${{ [$want] }}
    END

Events Are Listed In Ascending Date Order
    [Tags]    WP-B10    FR-63
    ${data}=    Page Object    data.json
    FOR    ${lot}    IN    @{data.json()}[lots]
        ${dates}=    Evaluate    [e["date"] for e in $lot["events"]]
        Should Be Equal    ${dates}    ${{ sorted($dates) }}
    END
    ${c}=    Evaluate    max(len(lot["events"]) for lot in $data.json()["lots"])
    Should Be True    ${c} >= 5    msg=lot C's five events (pushed out of order) are on the page

Completeness Equals Lots With All Mandatory Events Over Lots
    [Tags]    WP-B11    FR-20
    ${w}=    QA World
    ${d}=    Call API    GET    /dashboard/fpo/${w}[fpo]    ${ADMIN}    expect=200
    # Same test as reporting.service (D-037): every type in the crop's event_schema.mandatory has a live event.
    ${count}=    Query    SELECT count(*) FILTER (WHERE NOT EXISTS (SELECT 1 FROM jsonb_array_elements_text(c.event_schema->'mandatory') m(t) WHERE NOT EXISTS (SELECT 1 FROM events e WHERE e.lot_id = l.id AND e.event_type = m.t AND e.status NOT IN ('undone', 'superseded')))), count(*) FROM lots l JOIN crops c ON c.id = l.crop_id WHERE l.fpo_id = '${w}[fpo]'
    Should Be Equal As Integers    ${d.json()}[completeness][complete_lots]    ${count}[0][0]
    Should Be Equal As Integers    ${d.json()}[completeness][lots]    ${count}[0][1]

100 Scans Per Minute Returns 429
    [Tags]    WP-B11    FR-15
    # Start early in a minute so 105 scans fall in one window (B11 live_b11.py).
    ${sec}=    Evaluate    datetime.datetime.now().second
    IF    ${sec} > 40    Sleep    ${{ 61 - $sec }}s
    @{codes}=    Create List
    FOR    ${i}    IN RANGE    105
        ${r}=    Call API    POST    /public/scans    params=${{ {"batch_code": $X["code"]} }}
        Append To List    ${codes}    ${r.status_code}
    END
    Should Be Equal    ${codes}[:100]    ${{ [204] * 100 }}
    Should Be Equal    ${codes}[100:]    ${{ [429] * 5 }}
    Error Code Should Be    ${r}    rate_limited

Audit CSV Has A Row Per Version With Entered By And Assist Session
    [Tags]    WP-B11    FR-21
    ${w}=    QA World
    ${lot}=    New Lot
    ${session}=    Evaluate    str(uuid.uuid4())
    ${now}=    Evaluate    datetime.datetime.now(datetime.timezone.utc).isoformat()
    Push    ${OFFICER}    ${{ {"client_id": $session, "kind": "assist_session", "data": {"farmer_id": $w["farmer"]["id"], "started_at": $now, "started_gps": None}} }}
    ${d1}=    Days Ago    100
    ${d2}=    Days Ago    20
    ${assisted}=    Event    ${lot}    ${w}[plot]    land_preparation    ${d1}    assist_session_id=${session}
    ${plain}=    Event    ${lot}    ${w}[plot]    harvest    ${d2}    ${{ {"quantity": {"value": 52, "unit": "kg"}, "bags": 2} }}
    ${res}=    Push    ${OFFICER}    ${assisted}    ${plain}
    Should Be Equal    ${{ [x["status"] for x in $res] }}    ${{ ["accepted", "accepted"] }}
    ${corr}=    Evaluate    {k: v for k, v in $plain["data"].items() if k != "gps"}
    Set To Dictionary    ${corr}    version_no=${2}    change_kind=correct    reason_code=entered_by_mistake
    ...    payload=${{ {"quantity": {"value": 50, "unit": "kg"}, "bags": 2} }}
    Call API    POST    /events/${corr}[event_id]/versions    ${OFFICER}    expect=200    json=${{ {"client_id": str(uuid.uuid4()), "data": $corr} }}
    Received Lot    50    lot_id=${lot}
    ${batch}=    New Batch    ${{ [$lot] }}
    ${r}=    Call API    GET    /batches/${batch}[id]/audit-export.csv    ${ADMIN}    expect=200
    ${rows}=    Evaluate    list(csv.DictReader(io.StringIO($r.text)))
    ${versions}=    Query    SELECT count(*) FROM event_versions v JOIN events e ON e.id = v.event_id JOIN batch_shares s ON s.lot_id = e.lot_id WHERE s.batch_id = '${batch}[id]'
    Length Should Be    ${rows}    ${versions}[0][0]
    Length Should Be    ${rows}    3
    Dictionary Should Contain Key    ${rows}[0]    entered_by
    Dictionary Should Contain Key    ${rows}[0]    assist_session_id
    ${assist}=    Evaluate    [x["assist_session_id"] for x in $rows if x["assist_session_id"]]
    Should Be Equal    ${assist}    ${{ [$session] }}

Partner API Returns 501 Not Implemented Pilot
    [Tags]    WP-B11    FR-33
    FOR    ${method}    ${path}    IN    GET    /partner/batches/${X}[code]    POST    /partner/benefits
    ...    POST    /probes    POST    /probe-readings
        ${body}=    Set Variable If    "${method}" == "POST"    ${{ {} }}    ${None}
        ${r}=    Call API    ${method}    ${path}    ${ADMIN}    expect=501    json=${body}
        Error Code Should Be    ${r}    not_implemented_pilot
    END


*** Keywords ***
Publishing Suite Setup
    [Documentation]    Connect to the DB and publish batch X (lots 100 / 200 / 20 kg; the first lot has five events
    ...    pushed out of date order). Sets ${X} (batch body) and ${HARVEST} (lot C's harvest entry).
    Connect To AgriTrace Database
    ${w}=    QA World
    ${c}=    New Lot
    @{events}=    Create List
    FOR    ${type}    ${days}    IN    packing    40    land_preparation    200    harvest    60    sowing    150    drying    50
        ${on}=    Days Ago    ${days}
        ${payload}=    Set Variable If    "${type}" in ("packing", "harvest")    ${{ {"quantity": {"value": 110, "unit": "kg"}, "bags": 5} }}    ${None}
        ${e}=    Event    ${c}    ${w}[plot]    ${type}    ${on}    ${payload}
        Append To List    ${events}    ${e}
    END
    Push    ${OFFICER}    @{events}
    Set Suite Variable    ${HARVEST}    ${events}[2]
    Received Lot    100    lot_id=${c}
    ${d}=    Received Lot    200
    ${e}=    Received Lot    20
    ${x}=    Publish Batch    ${{ [$c, $d, $e] }}
    Set Suite Variable    ${X}    ${x}

Page Object
    [Documentation]    GET one object of a batch's public page anonymously, as a consumer would (D-007).
    ...    Args: ${name} index.html | data.json | qr.png; ${code} batch code (default batch X).
    ...    Returns: the response (200).
    [Arguments]    ${name}    ${code}=${X}[code]
    ${r}=    GET    ${PUBLIC_BASE}/batches/${code}/${name}    expected_status=200
    RETURN    ${r}
