*** Settings ***
Documentation       Quality readings and the grade engine (plan §7.1 B05), through the live API.
...                 Serves: FR-42, FR-46, FR-48, FR-49, FR-50; gate G2; BM-08 (the full 65-case table stays a unit run).
...                 Live procedure: docs/agents/qa/B05.md, B09/logs/live_b09_part2.py (inline grading readings).
...                 Seeded profile (bundle part `standards`): Special ≤ 10.0 %, Standard ≤ 11.0 %, moisture
...                 sources instrument/lab only, a visual reading capped at Standard, trail tolerance 0.5 %.
...                 Each grade line grades its own fresh one-lot batch with exactly the inline reading.
Resource            ../resources/common.resource
Test Tags           api


*** Test Cases ***
Moisture 9.8 Percent Grades Special
    [Tags]    WP-B05    FR-48
    ${grade}=    Grade A Fresh Batch    9.8
    Should Be Equal    ${grade}[computed_grade]    Special

Moisture 10.5 Percent Grades Standard
    [Tags]    WP-B05    FR-48
    ${grade}=    Grade A Fresh Batch    10.5
    Should Be Equal    ${grade}[computed_grade]    Standard

Moisture 11.4 Percent Is Below Grade
    [Tags]    WP-B05    FR-48
    # Lot dried to 10.9 % so 11.4 % at grading stays inside the 0.5 % trail tolerance.
    ${grade}=    Grade A Fresh Batch    11.4    lot_reading=10.9
    Should Be Equal    ${grade}[computed_grade]    Below grade

Visual 9.8 Percent Is Capped At Standard
    [Tags]    WP-B05    FR-48
    # Through the API a visual moisture reading never reaches the engine: the profile allows instrument and
    # lab only and caps visual at Standard (B05-r1 F5 ruling; engine cap proven by the BM-08 unit table).
    ${rules}=    Active Profile Rules
    ${m}=    Evaluate    next(p for p in $rules["parameters"] if p["code"] == "moisture")
    Should Be Equal    ${m}[max_grade_for_source][visual]    Standard
    ${lot}=    New Lot
    ${visual}=    Moisture    9.8    lot_id=${lot}    source=visual    instrument_id=${None}
    ${r}=    Call API    POST    /quality-readings    ${ADMIN}    expect=422    json=${visual}
    Error Code Should Be    ${r}    source_not_allowed

Missing Required Reading Is Incomplete
    [Tags]    WP-B05    FR-46
    ${batch}=    Fresh Batch
    ${r}=    Call API    POST    /batches/${batch}[id]/grading    ${ADMIN}    expect=201    json=${{ {"declared_grade": "Standard", "reading_ids": []} }}
    Should Be Equal    ${r.json()}[status]    incomplete
    Should Be Equal    ${r.json()}[computed_grade]    ${None}

Moisture Minus 1 Returns 422
    [Tags]    WP-B05    FR-50
    ${lot}=    New Lot
    ${reading}=    Moisture    -1    lot_id=${lot}
    ${r}=    Call API    POST    /quality-readings    ${ADMIN}    expect=422    json=${reading}
    Error Code Should Be    ${r}    implausible_value
    ${listed}=    Call API    GET    /lots/${lot}/readings    ${ADMIN}    expect=200
    Should Be Empty    ${listed.json()}[items]

Expired Instrument Returns 422
    [Tags]    WP-B05    FR-42
    ${lot}=    New Lot
    ${expired}=    New Instrument    -30
    ${reading}=    Moisture    10.0    lot_id=${lot}    instrument_id=${expired}
    ${r}=    Call API    POST    /quality-readings    ${ADMIN}    expect=422    json=${reading}
    Error Code Should Be    ${r}    instrument_calibration_expired
    ${reading}=    Moisture    10.0    lot_id=${lot}
    ${r}=    Call API    POST    /quality-readings    ${ADMIN}    expect=201    json=${reading}
    Should Not Be Equal    ${r.json()}[calibration_due_on_at_time]    ${None}

Grading 12.0 After Intake 10.0 Needs A Reason And Raises A Flag
    [Tags]    WP-B05    FR-50
    ${batch}=    Fresh Batch
    ${intake}=    Moisture    10.0    intake    lot_id=${batch}[shares][0][lot_id]
    Call API    POST    /quality-readings    ${ADMIN}    expect=201    json=${intake}
    ${reading}=    Moisture    12.0    grading    batch_id=${batch}[id]
    ${r}=    Call API    POST    /quality-readings    ${ADMIN}    expect=422    json=${reading}
    Error Code Should Be    ${r}    moisture_trail_violation
    Set To Dictionary    ${reading}    reason_code=rain_exposure
    ${r}=    Call API    POST    /quality-readings    ${ADMIN}    expect=201    json=${reading}
    Should Be Equal    ${r.json()}[reason_code]    rain_exposure
    ${flag}=    Wait For Flag    ${reading}[client_id]    moisture_trail_override
    Should Be Equal    ${flag}[subject_type]    reading

Declared Special Versus Computed Standard Raises Declared Above Computed
    [Tags]    WP-B05    FR-49
    ${grade}=    Grade A Fresh Batch    10.5    declared=Special
    Should Be Equal    ${grade}[computed_grade]    Standard
    Should Be Equal    ${grade}[declared_grade]    Special
    Should Be Equal    ${grade}[status]    declared_above_computed


*** Keywords ***
Fresh Batch
    [Documentation]    A one-lot, 100 kg batch whose lot was dried to ${lot_reading} % (B09 receive path).
    ...    Args: ${lot_reading} the lot's drying-end moisture %. Returns: the batch body.
    [Arguments]    ${lot_reading}=10.0
    ${lot}=    Received Lot    100    reading=${lot_reading}
    ${batch}=    New Batch    ${{ [$lot] }}
    RETURN    ${batch}

Grade A Fresh Batch
    [Documentation]    Grade a fresh batch on one inline instrument moisture reading only (`reading_ids: []`).
    ...    Args: ${value} grading moisture %; ${declared} declared grade; ${lot_reading} the lot's moisture.
    ...    Returns: the GradeOut body (201).
    [Arguments]    ${value}    ${declared}=Standard    ${lot_reading}=10.0
    ${batch}=    Fresh Batch    ${lot_reading}
    ${reading}=    Moisture    ${value}    grading    batch_id=${batch}[id]
    ${r}=    Call API    POST    /batches/${batch}[id]/grading    ${ADMIN}    expect=201
    ...    json=${{ {"declared_grade": $declared, "reading_ids": [], "readings": [$reading]} }}
    RETURN    ${r.json()}

Active Profile Rules
    [Documentation]    The QA crop's active Standards Profile rules, as the sync bundle part `standards` serves them.
    ...    Returns: the rules dictionary (grades, parameters, trail_rules, ...).
    ${w}=    QA World
    ${r}=    Call API    GET    /sync/bundle/standards    ${ADMIN}    expect=200
    RETURN    ${r.json()}[profiles][${w}[crop]]
