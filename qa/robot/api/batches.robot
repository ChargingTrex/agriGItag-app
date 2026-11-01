*** Settings ***
Documentation       Lots, intake, batches and gates (plan §7.1 B09), live.
...                 Serves: FR-11, FR-15, FR-17, FR-29, FR-37, FR-43, FR-49, FR-60; gate G2.
...                 Live procedure: docs/agents/qa/B09.md (B09/logs/live_b09.py, live_b09_part2.py, qa_live.py):
...                 lots of the run's QA farmer, moisture by the QA meter, events pushed by the field officer,
...                 intake and batch by the FPO admin. The seeded batch FGP8T4033HM7 is only read.
Resource            ../resources/common.resource
Suite Setup         Connect To AgriTrace Database
Suite Teardown      Disconnect From Database
Test Tags           api


*** Test Cases ***
Lot Ready At 11.5 Percent Returns 409 And At 10.9 Percent Becomes Ready
    [Tags]    WP-B09    FR-43
    ${lot}=    New Lot
    Record Moisture    ${lot}    11.5
    ${r}=    Call API    POST    /lots/${lot}/ready    ${ADMIN}
    Gate Reasons Should Be    ${r}    moisture_gate_failed
    Record Moisture    ${lot}    10.9
    ${r}=    Call API    POST    /lots/${lot}/ready    ${ADMIN}    expect=200
    Should Be Equal    ${r.json()}[status]    ready_for_sale
    Should Not Be Equal    ${r.json()}[ready_at]    ${None}

Intake 100 kg Versus Packed 69 kg Raises Quantity Mismatch
    [Tags]    WP-B09    FR-11
    ${w}=    QA World
    ${lot}=    New Lot
    ${on}=    Days Ago    5
    ${packing}=    Event    ${lot}    ${w}[plot]    packing    ${on}    ${{ {"quantity": {"value": 69, "unit": "kg"}, "bags": 2} }}
    Push    ${OFFICER}    ${packing}
    Record Moisture    ${lot}    10.0
    Call API    POST    /lots/${lot}/ready    ${ADMIN}    expect=200
    ${intake}=    Receive    ${lot}    100
    Should Be Equal    ${intake}[reconciliation][in_order]    ${False}
    ${codes}=    Evaluate    {f["rule_code"] for f in $intake["flags"]}
    Should Contain    ${codes}    quantity_mismatch
    ${after}=    Call API    GET    /lots/${lot}    ${ADMIN}    expect=200
    Should Be Equal    ${after.json()}[status]    received

Lots 100 200 20 kg Give Shares 31.250 62.500 6.250
    [Tags]    WP-B09    FR-37
    ${a}=    Received Lot    100
    ${b}=    Received Lot    200
    ${c}=    Received Lot    20
    ${batch}=    New Batch    ${{ [$a, $b, $c] }}
    ${pct}=    Evaluate    {s["lot_id"]: s["share_pct"] for s in $batch["shares"]}
    Should Be Equal    ${{ [$pct[$a], $pct[$b], $pct[$c]] }}    ${{ ["31.250", "62.500", "6.250"] }}
    Should Be Equal As Numbers    ${batch}[total_received][value]    320
    Should Be Equal    ${batch}[total_received][unit]    kg
    # The seeded reference batch has the same shares.
    ${rows}=    Query    SELECT s.share_pct::text FROM batch_shares s JOIN batches b ON b.id = s.batch_id WHERE b.code = 'FGP8T4033HM7' ORDER BY s.share_pct
    Should Be Equal    ${{ [r[0] for r in $rows] }}    ${{ ["6.250", "31.250", "62.500"] }}

Ineligible Lot With GI Requested Gives GI Verified False With Reasons
    [Tags]    WP-B09    FR-29
    ${plot}=    New Plot
    ${lot}=    New Lot    ${plot}
    ${on}=    Days Ago    20
    # 2,000 kg on 1 acre is past the +30 % hold margin over the 1,000 kg/acre ceiling.
    ${harvest}=    Event    ${lot}    ${plot}    harvest    ${on}    ${{ {"quantity": {"value": 2000, "unit": "kg"}, "bags": 80} }}
    Push    ${OFFICER}    ${harvest}
    Wait For Flag    ${lot}    yield_over_ceiling
    Record Moisture    ${lot}    10.0
    Call API    POST    /lots/${lot}/ready    ${ADMIN}    expect=200
    Receive    ${lot}    50
    ${batch}=    New Batch    ${{ [$lot] }}    gi=${True}
    Should Be Equal    ${batch}[gi_verified]    ${False}
    ${reasons}=    Evaluate    {(x["lot_id"], x["reason"], x["detail"]) for x in $batch["gi_block_reasons"]}
    ${pairs}=    Evaluate    {t[:2] for t in $reasons}
    Should Contain    ${pairs}    ${{ ($lot, "lot_on_hold") }}
    Should Contain    ${reasons}    ${{ (None, "hold_flag", "yield_over_ceiling") }}

Approve On Declared Above Computed Returns 409
    [Tags]    WP-B09    FR-49
    ${batch}=    Graded Batch    Special    100
    ${r}=    Call API    POST    /batches/${batch}/grading/approve    ${ADMIN}    json=${{ {"graded": {"value": 90, "unit": "kg"}} }}
    Gate Reasons Should Be    ${r}    declared_above_computed

Packing 25 kg On 20 kg Graded Returns 409
    [Tags]    WP-B09    FR-60
    ${batch}=    Graded Batch
    Call API    POST    /batches/${batch}/grading/approve    ${ADMIN}    expect=200    json=${{ {"graded": {"value": 20, "unit": "kg"}} }}
    ${over}=    Packing    25
    ${r}=    Call API    POST    /batches/${batch}/final-packing    ${ADMIN}    json=${over}
    Gate Reasons Should Be    ${r}    packed_above_graded
    ${pack}=    Packing    20
    ${r}=    Call API    POST    /batches/${batch}/final-packing    ${ADMIN}    expect=200    json=${pack}
    Should Be Equal    ${r.json()}[status]    packed

Publish Before Approval Returns 409 Listing Reasons
    [Tags]    WP-B09    FR-15
    ${batch}=    Graded Batch
    ${r}=    Call API    POST    /batches/${batch}/publish    ${ADMIN}
    Gate Reasons Should Be    ${r}    grading_not_approved    final_packing_missing

Publish After Gates Returns 202 And A Page Build Row
    [Tags]    WP-B09    FR-17
    ${batch}=    Graded Batch
    Call API    POST    /batches/${batch}/grading/approve    ${ADMIN}    expect=200    json=${{ {"graded": {"value": 20, "unit": "kg"}} }}
    ${pack}=    Packing    20
    Call API    POST    /batches/${batch}/final-packing    ${ADMIN}    expect=200    json=${pack}
    ${r}=    Call API    POST    /batches/${batch}/publish    ${ADMIN}    expect=202
    Should Be Equal As Integers    ${r.json()}[build_no]    1
    Should Be Equal    ${r.json()}[status]    queued
    Check Row Count    SELECT 1 FROM page_builds WHERE batch_id = '${batch}' AND build_no = 1 AND trigger = 'publish'    ==    1
    ${r}=    Call API    POST    /batches/${batch}/publish    ${ADMIN}
    Gate Reasons Should Be    ${r}    already_published


*** Keywords ***
Record Moisture
    [Documentation]    Record a drying-end instrument moisture reading of ${value} % on a lot (201).
    [Arguments]    ${lot}    ${value}
    ${body}=    Moisture    ${value}    lot_id=${lot}
    Call API    POST    /quality-readings    ${ADMIN}    expect=201    json=${body}

Graded Batch
    [Documentation]    A one-lot batch of ${kg} kg graded with declared ${declared} on a 10.5 % grading reading
    ...    (computed Standard). Returns: the batch id.
    [Arguments]    ${declared}=Standard    ${kg}=20
    ${lot}=    Received Lot    ${kg}
    ${batch}=    New Batch    ${{ [$lot] }}
    ${reading}=    Moisture    10.5    grading    batch_id=${batch}[id]
    Call API    POST    /batches/${batch}[id]/grading    ${ADMIN}    expect=201    json=${{ {"declared_grade": $declared, "readings": [$reading]} }}
    RETURN    ${batch}[id]
