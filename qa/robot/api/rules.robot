*** Settings ***
Documentation       Rules and flags (plan §7.1 B08) and notifications (B04), on the live API + Celery worker.
...                 Serves: FR-7, FR-14, FR-55, FR-56, FR-68, FR-69, FR-70; gate G2.
...                 Live procedures: docs/agents/qa/B08.md (live_b08.py: entries pushed by the farmer, the worker
...                 runs the rules, re-check through `celery call`), B04.md (live_send.py: `notifications.send`
...                 enqueued from the api container). Every lot sits on its own 1-acre plot of the run's QA farmer
...                 (profile yield ceiling 1,000 kg/acre, warn +20 %, hold +30 %).
Resource            ../resources/common.resource
Suite Setup         Connect To AgriTrace Database
Suite Teardown      Disconnect From Database
Test Tags           api


*** Test Cases ***
Event 600 m Off Plot Raises Event Off Plot Once
    [Tags]    WP-B08    FR-69
    ${plot}=    New Plot
    ${lot}=    New Lot    ${plot}
    # 0.0054° of latitude is about 600 m north of the pin.
    ${today}=    Days Ago    0
    ${e}=    Event    ${lot}    ${plot}    land_preparation    ${today}    lat_shift=0.0054
    Farmer Pushes    ${e}
    ${flag}=    Wait For Flag    ${e}[data][event_id]    event_off_plot
    Should Be Equal    ${flag}[severity]    warn
    ${task}=    Compose    exec    -T    worker    celery    -A    agritrace.worker    call    rules.check_event
    ...    --kwargs    {"event_id": "${e}[data][event_id]"}
    Should Be Equal As Integers    ${task}[rc]    0    msg=${task}[out]
    Wait Until Keyword Succeeds    90s    3s    Worker Finished    ${task}[stdout]
    ${flags}=    Flags Of    ${e}[data][event_id]
    ${off}=    Evaluate    [f for f in $flags if f["rule_code"] == "event_off_plot"]
    Length Should Be    ${off}    1

Inorganic Tag With Only Organic Inputs Raises Practice Tag Contradiction
    [Tags]    WP-B08    FR-56
    ${lot}=    Lot A Declared Inorganic And IPM
    ${flag}=    Wait For Flag    ${lot}[id]    practice_tag_contradiction
    Should Be Equal    ${flag}[severity]    warn

IPM Without A Pest Event Raises A Flag
    [Tags]    WP-B08    FR-56
    ${lot}=    Lot A Declared Inorganic And IPM
    ${flag}=    Wait For Flag    ${lot}[id]    ipm_without_pest_event
    Should Be Equal    ${flag}[severity]    warn

Nursery Before Ploughing Raises No Flag
    [Tags]    WP-B08    FR-55
    ${lot}=    Lot A Declared Inorganic And IPM
    # The lot rules ran (their flag is there), so the event rules of the same push have run too.
    Wait For Flag    ${lot}[id]    practice_tag_contradiction
    FOR    ${event}    IN    ${lot}[nursery]    ${lot}[ploughing]
        ${flags}=    Flags Of    ${event}
        ${order}=    Evaluate    [f for f in $flags if f["rule_code"] == "event_out_of_order"]
        Should Be Empty    ${order}
    END

Sowing Before Nursery Raises A Flag
    [Tags]    WP-B08    FR-55
    ${plot}=    New Plot
    ${lot}=    New Lot    ${plot}
    ${plough}=    Event    ${lot}    ${plot}    land_preparation    2026-07-01
    ${sow}=    Event    ${lot}    ${plot}    sowing    2026-07-05
    ${nursery}=    Event    ${lot}    ${plot}    nursery    2026-07-10
    Farmer Pushes    ${plough}    ${sow}    ${nursery}
    ${flag}=    Wait For Flag    ${sow}[data][event_id]    event_out_of_order
    Should Be Equal    ${flag}[severity]    warn
    FOR    ${other}    IN    ${plough}    ${nursery}
        ${flags}=    Flags Of    ${other}[data][event_id]
        ${order}=    Evaluate    [f for f in $flags if f["rule_code"] == "event_out_of_order"]
        Should Be Empty    ${order}
    END

Yield 1150 1250 1350 kg On 1 Acre Gives None Warn Hold
    [Tags]    WP-B08    FR-68
    ${warn}=    Harvested Lot    1250
    ${hold}=    Harvested Lot    1350
    ${none}=    Harvested Lot    1150
    ${f}=    Wait For Flag    ${warn}    yield_over_ceiling
    Should Be Equal    ${f}[severity]    warn
    ${f}=    Wait For Flag    ${hold}    yield_over_ceiling
    Should Be Equal    ${f}[severity]    hold
    ${lot}=    Call API    GET    /lots/${hold}    ${ADMIN}    expect=200
    Should Be Equal    ${lot.json()}[gi_eligible]    ${False}
    # The 1,150 kg lot was pushed last; give its lot rules a moment after the other two have run.
    Sleep    10s
    ${flags}=    Flags Of    ${none}
    ${y}=    Evaluate    [f for f in $flags if f["rule_code"] == "yield_over_ceiling"]
    Should Be Empty    ${y}
    ${lot}=    Call API    GET    /lots/${none}    ${ADMIN}    expect=200
    Should Be Equal    ${lot.json()}[gi_eligible]    ${True}

Resolving A Flag Without Reason Returns 422
    [Tags]    WP-B08    FR-70
    ${lot}=    Harvested Lot    1250
    ${flag}=    Wait For Flag    ${lot}    yield_over_ceiling
    FOR    ${who}    IN    ${ADMIN}    ${OFFICER}
        ${r}=    Call API    POST    /flags/${flag}[id]/resolve    ${who}    expect=422    json=${{ {"resolution": "looks_fine"} }}
        Error Code Should Be    ${r}    reason_required
    END

Officer Resolving A Hold Returns 403
    [Tags]    WP-B08    FR-14
    ${lot}=    Harvested Lot    1350
    ${flag}=    Wait For Flag    ${lot}    yield_over_ceiling
    ${body}=    Create Dictionary    resolution=looks_fine    reason_code=land_record_checked
    ${r}=    Call API    POST    /flags/${flag}[id]/resolve    ${OFFICER}    expect=403    json=${body}
    Error Code Should Be    ${r}    resolution_forbidden
    ${after}=    Call API    GET    /flags/${flag}[id]    ${ADMIN}    expect=200
    Should Be Equal    ${after.json()}[status]    open
    ${r}=    Call API    POST    /flags/${flag}[id]/resolve    ${ADMIN}    expect=200    json=${body}
    Wait Until Keyword Succeeds    60s    3s    Lot GI Eligible Should Be    ${lot}    ${True}

Eager Notification Send Writes A Sent Console Row
    [Tags]    WP-B04    FR-7
    ${user}=    Send Notification    harvest_reminder    ta    {"plot_name": "QA Robot plot"}
    Check Row Count    SELECT 1 FROM notifications WHERE user_id = '${user}' AND template_key = 'harvest_reminder' AND channel = 'console' AND status = 'sent' AND provider_ref = 'console' AND sent_at IS NOT NULL
    ...    ==    1    retry_timeout=90s    retry_pause=3s

Unknown Template Writes A Failed Row Without Raising
    [Tags]    WP-B04    FR-7
    ${user}=    Send Notification    no_such_template    en    {}
    Check Row Count    SELECT 1 FROM notifications WHERE user_id = '${user}' AND template_key = 'no_such_template' AND status = 'failed' AND provider_ref = 'error:unknown_template' AND sent_at IS NULL
    ...    ==    1    retry_timeout=90s    retry_pause=3s


*** Keywords ***
Farmer Pushes
    [Documentation]    Push entries as the run's QA farmer and assert every one is accepted.
    ...    Args: @{entries} sync entries (see `Event`).
    [Arguments]    @{entries}
    ${w}=    QA World
    ${res}=    Push    ${w}[farmer][phone]    @{entries}
    FOR    ${r}    IN    @{res}
        Should Be Equal    ${r}[status]    accepted    msg=${r}
    END

Lot A Declared Inorganic And IPM
    [Documentation]    B08 lot A: declared inorganic + IPM; nursery 07-01 before land preparation 07-10, one input of
    ...    the seeded organic "Organic Fertilizer Gold", no pest event. Returns: {id, nursery, ploughing} ids.
    ${plot}=    New Plot
    ${lot}=    New Lot    ${plot}    ${{ ["inorganic", "ipm"] }}
    ${inputs}=    Call API    GET    /inputs    ${ADMIN}    expect=200
    ${organic}=    Evaluate    next(i["id"] for i in $inputs.json() if i["name_en"] == "Organic Fertilizer Gold")
    ${nursery}=    Event    ${lot}    ${plot}    nursery    2026-07-01
    ${plough}=    Event    ${lot}    ${plot}    land_preparation    2026-07-10
    ${input}=    Event    ${lot}    ${plot}    input_application    2026-07-20
    ...    ${{ {"input_id": $organic, "quantity": {"value": 25, "unit": "kg"}} }}
    Farmer Pushes    ${nursery}    ${plough}    ${input}
    RETURN    ${{ {"id": $lot, "nursery": $nursery["data"]["event_id"], "ploughing": $plough["data"]["event_id"]} }}

Harvested Lot
    [Documentation]    A lot on its own 1-acre plot with one harvest of ${kg} kg pushed by the farmer. Returns: the lot id.
    [Arguments]    ${kg}
    ${plot}=    New Plot
    ${lot}=    New Lot    ${plot}
    ${h}=    Event    ${lot}    ${plot}    harvest    2026-10-20    ${{ {"quantity": {"value": int($kg), "unit": "kg"}} }}
    Farmer Pushes    ${h}
    RETURN    ${lot}

Lot GI Eligible Should Be
    [Documentation]    Assert GET /v1/lots/{id} reports gi_eligible == ${expected}.
    [Arguments]    ${lot}    ${expected}
    ${r}=    Call API    GET    /lots/${lot}    ${ADMIN}    expect=200
    Should Be Equal    ${r.json()}[gi_eligible]    ${expected}

Worker Finished
    [Documentation]    Pass once the worker log shows the Celery task ${task_id} succeeded.
    [Arguments]    ${task_id}
    ${logs}=    Compose    logs    --since    10m    worker
    Should Contain    ${logs}[out]    ${task_id.strip()}] succeeded

Send Notification
    [Documentation]    Enqueue `notifications.send` for the run's QA farmer on the stack's broker (from the api
    ...    container, as B04's live check did); the worker delivers it.
    ...    Args: ${template} template key; ${lang} ta|en; ${payload} JSON text. Returns: the recipient user id.
    [Arguments]    ${template}    ${lang}    ${payload}
    ${w}=    QA World
    ${user}=    Set Variable    ${w}[farmer][user_id]
    ${code}=    Catenate    from agritrace.worker import app;
    ...    print(app.send_task("notifications.send", kwargs={"user_id": "${user}", "template_key": "${template}",
    ...    "channel": "console", "lang": "${lang}", "payload": ${payload}}).id)
    ${run}=    Compose    exec    -T    api    python    -c    ${code}
    Should Be Equal As Integers    ${run}[rc]    0    msg=${run}[out]
    RETURN    ${user}
