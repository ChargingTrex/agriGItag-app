*** Settings ***
Documentation       Seeded reference batch FGP8T4033HM7 end to end (plan §7.1 B12, PRD §12.2).
...                 Serves: FR-11, FR-13, FR-15, FR-30, FR-33, FR-47; gate G5; BM-05. Run by: Q04/Q05 Verifiers.
...                 The live-stack form of apps/api/tests/e2e/test_reference_batch.py (WP Q07 round 2): the same
...                 seed, flag set, refused gates and fixes, over the API of the stack under test. The gate lines
...                 change the seeded batch, so the "before fixes" lines need a fresh seed: on a stack where the
...                 batch is already published they skip with that reason. "Dart And TS Clients Compile" needs
...                 node_modules in apps/portal, Java 11+ and dart on PATH.
Resource            ../resources/common.resource
Suite Setup         Reference Suite Setup
Suite Teardown      Disconnect From Database
Test Tags           e2e


*** Variables ***
${REF_CODE}         FGP8T4033HM7
@{SEED_TABLES}      fpos    farmers    plots    lots    batches    batch_shares    events    event_versions    flags
...                 inputs_master    quality_readings    lot_intakes    audit_log


*** Test Cases ***
Demo Seed Is Idempotent
    [Tags]    WP-B12    FR-13
    ${before}=    Table Counts
    ${run}=    Compose    exec    -T    api    python    -m    agritrace.seed.demo
    Should Be Equal As Integers    ${run}[rc]    0    msg=${run}[out]
    Should Contain    ${run}[out]    already present
    ${after}=    Table Counts
    Dictionaries Should Be Equal    ${after}    ${before}

Reference Batch Raises Exactly The Expected Flag Set
    [Tags]    WP-B12    FR-11    BM-05
    Reference Batch Is Unfixed
    ${seed}=    Seed Constants
    ${rows}=    Query    SELECT rule_code, count(*) FROM flags WHERE status = 'open' AND (subject_id = '${REF}[id]' OR subject_id IN (SELECT lot_id FROM batch_shares WHERE batch_id = '${REF}[id]')) GROUP BY rule_code
    ${flags}=    Evaluate    {code: n for code, n in $rows}
    Dictionaries Should Be Equal    ${flags}    ${seed}[expected]
    FOR    ${code}    IN    @{seed}[absent]
        Dictionary Should Not Contain Key    ${flags}    ${code}
    END

Grade A Returns 422 Unknown Grade For Profile
    [Tags]    WP-B12    FR-47
    ${r}=    Call API    POST    /batches/${REF}[id]/grading    ${QC}    expect=422    json=${{ {"declared_grade": "A"} }}
    Error Code Should Be    ${r}    unknown_grade_for_profile

Approve And Publish Return 409 Before Fixes
    [Tags]    WP-B12    FR-15
    Reference Batch Is Unfixed
    ${approve}=    Call API    POST    /batches/${REF}[id]/grading/approve    ${ADMIN}    json=${{ {"graded": {"value": 20, "unit": "kg"}} }}
    ${reasons}=    Gate Reason Codes    ${approve}
    Should Contain    ${reasons}    not_graded
    ${publish}=    Call API    POST    /batches/${REF}[id]/publish    ${ADMIN}
    ${reasons}=    Gate Reason Codes    ${publish}
    Should Contain    ${reasons}    grading_not_approved
    Should Contain    ${reasons}    final_packing_missing

After Fixes Publish Succeeds With GI Verified And Shares 31.25 62.5 6.25
    [Tags]    WP-B12    FR-30
    Reference Batch Is Unfixed
    Fix Reference Batch    ${REF}[id]
    ${r}=    Call API    POST    /batches/${REF}[id]/publish    ${ADMIN}    expect=202
    ${build}=    Wait For Build    ${REF}[id]    ${r.json()}[build_no]
    Should Be Equal    ${build}[status]    built    msg=${build}
    ${out}=    Call API    GET    /batches/${REF}[id]    ${ADMIN}    200
    ${b}=    Set Variable    ${out.json()}
    Should Be Equal    ${b}[status]    published
    Should Be True    ${b}[gi_verified]
    Should Be Empty    ${b}[gi_block_reasons]
    ${shares}=    Evaluate    sorted(s["share_pct"] for s in $b["shares"])
    Lists Should Be Equal    ${shares}    ${{ ["31.250", "6.250", "62.500"] }}
    ${units}=    Evaluate    {s["contributed"]["unit"] for s in $b["shares"]} | {$b[k]["unit"] for k in ("total_received", "graded", "packed")}
    Should Be Equal    ${units}    ${{ {"kg"} }}
    ${data}=    GET    ${PUBLIC_BASE}/batches/${REF_CODE}/data.json    expected_status=200
    ${page}=    Set Variable    ${data.json()}
    Should Be True    ${page}[gi_verified]
    ${page_shares}=    Evaluate    sorted(lot["share_pct"] for lot in $page["lots"])
    Lists Should Be Equal    ${page_shares}    ${{ [6.25, 31.25, 62.5] }}
    ${unitless}=    Unitless Quantities    ${page}
    Should Be Empty    ${unitless}    msg=a quantity on the page has no unit (FR-58)

Dart And TS Clients Compile
    [Tags]    WP-B12    FR-33
    ${ts}=    Run Process    npm    run    gen:check    cwd=${REPO_ROOT}/apps/portal    stderr=STDOUT    timeout=10 min
    Should Be Equal As Integers    ${ts.rc}    0    msg=${ts.stdout}[-2000:]
    ${tsc}=    Run Process    npx    --no-install    tsc    -b    cwd=${REPO_ROOT}/apps/portal    stderr=STDOUT    timeout=10 min
    Should Be Equal As Integers    ${tsc.rc}    0    msg=${tsc.stdout}[-2000:]
    ${gen}=    Run Process    bash    tool/gen_api.sh    cwd=${REPO_ROOT}/apps/mobile    stderr=STDOUT    timeout=20 min
    Should Be Equal As Integers    ${gen.rc}    0    msg=${gen.stdout}[-2000:]
    ${diff}=    Run Process    git    status    --porcelain    --untracked-files\=no    --    apps/mobile/packages/agritrace_api
    ...    cwd=${REPO_ROOT}    stderr=STDOUT
    Should Be Empty    ${diff.stdout}    msg=the regenerated Dart client differs from the committed one
    ${dart}=    Run Process    dart    analyze    --no-fatal-warnings    --no-fatal-infos
    ...    cwd=${REPO_ROOT}/apps/mobile/packages/agritrace_api    stderr=STDOUT    timeout=10 min
    Should Be Equal As Integers    ${dart.rc}    0    msg=${dart.stdout}[-2000:]


*** Keywords ***
Reference Suite Setup
    [Documentation]    Connect to the stack's database and read the seeded reference batch.
    ...    Side effects: sets ${REF} (the BatchOut of FGP8T4033HM7).
    Connect To AgriTrace Database
    ${rows}=    Query    SELECT id FROM batches WHERE code = '${REF_CODE}'
    Should Not Be Empty    ${rows}    msg=${REF_CODE} is not seeded (make seed)
    ${b}=    Call API    GET    /batches/${rows}[0][0]    ${ADMIN}    200
    Set Suite Variable    ${REF}    ${b.json()}

Reference Batch Is Unfixed
    [Documentation]    Skip the current test when the seeded batch has already been fixed and published (a stack
    ...    that is not a fresh seed): its "before fixes" state is gone.
    ${b}=    Call API    GET    /batches/${REF}[id]    ${ADMIN}    200
    Skip If    "${b.json()}[status]" != "created"    ${REF_CODE} is ${b.json()}[status], not as seeded: needs a fresh seed (make seed on an empty DB)

Seed Constants
    [Documentation]    Read the demo seed's expected and absent flag sets from the api image (agritrace.seed.demo).
    ...    Returns: {"expected": {rule_code: count}, "absent": [rule_code, ...]}.
    ${run}=    Compose    exec    -T    api    python    -c
    ...    import json, collections; from agritrace.seed import demo; print(json.dumps({"expected": dict(collections.Counter(demo.EXPECTED_FLAGS)), "absent": list(demo.ABSENT_FLAGS)}))
    Should Be Equal As Integers    ${run}[rc]    0    msg=${run}[out]
    ${seed}=    Evaluate    json.loads($run["stdout"].strip().splitlines()[-1])    modules=json
    RETURN    ${seed}

Table Counts
    [Documentation]    Count the rows of every table the demo seed writes. Returns: {table: count}.
    ${counts}=    Create Dictionary
    FOR    ${table}    IN    @{SEED_TABLES}
        ${n}=    Query    SELECT count(*) FROM ${table}
        Set To Dictionary    ${counts}    ${table}=${n}[0][0]
    END
    RETURN    ${counts}

Gate Reason Codes
    [Documentation]    Read the reason codes of a 409 `gate_not_met` answer.
    ...    Args: ${response} the response. Returns: the `details.reasons[].code` list.
    ...    Fails: another status or error code.
    [Arguments]    ${response}
    Should Be Equal As Integers    ${response.status_code}    409    msg=${response.text}
    Error Code Should Be    ${response}    gate_not_met
    ${codes}=    Evaluate    [r["code"] for r in $response.json()["error"]["details"]["reasons"]]
    RETURN    ${codes}
