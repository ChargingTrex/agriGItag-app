*** Settings ***
Documentation       Shared variables and keywords for every AgriTrace Robot suite.
...                 Serves: plan §9.1 (Robot Framework suites) and §7.5 Q00 (QA harness).
...                 Callers: every suite under qa/robot/ (Resource import).
...                 All endpoints follow plan §7.1 and docs/api/conventions.md: routes under /v1 (D-020),
...                 error envelope {"error": {"code", "message", "details"}}.
Library             RequestsLibrary
Library             Collections
Library             OperatingSystem
Library             Process
Library             DatabaseLibrary
Library             ${CURDIR}/../lib/agritrace_keywords.py


*** Variables ***
# Every value can be overridden from the environment (CI, Verifier shell) without editing suites.
# Names and defaults follow B00's infra/docker-compose.yml and apps/api/.env.example where they exist.
${API_BASE}         %{API_BASE=http://localhost:8000/v1}
${PORTAL_BASE}      %{PORTAL_BASE=http://localhost:5173}
# DECISION D-008: object storage is LocalStack S3 on port 4566 locally (MinIO dropped).
#   ADV: same boto3/S3 API as production; Apache-2.0 image.
#   COMPROMISE: an emulator; production object-lock semantics still need the infra review.
${S3_ENDPOINT}      %{S3_ENDPOINT=http://localhost:4566}
${S3_REGION}        %{S3_REGION=ap-south-1}
${S3_ACCESS_KEY}    %{S3_ACCESS_KEY=test}
${S3_SECRET_KEY}    %{S3_SECRET_KEY=test}
@{S3_BUCKETS}       evidence    public-pages    id-docs
${PUBLIC_BASE}      %{PUBLIC_BASE_URL=http://localhost:4566/public-pages}
${DB_HOST}          %{DB_HOST=localhost}
${DB_PORT}          %{DB_PORT=5432}
${DB_NAME}          %{DB_NAME=agritrace}
${DB_USER}          %{DB_USER=agritrace}
${DB_PASSWORD}      %{DB_PASSWORD=agritrace}
${OTP_DEV_CODE}     %{OTP_DEV_CODE=123456}
# PIN the first office sign-in of a fresh seed sets (B02: pin_set false → the first PIN sent becomes the PIN).
${OFFICE_PIN}       %{OFFICE_PIN=2468}
# Docker compose command line of the stack under test; S3 objects, the worker's Celery calls, the QR decoder
# and one-off api containers (B13 config lines) are reached through it. Default: the repo's compose file.
${COMPOSE}          %{COMPOSE=docker compose -f ${CURDIR}/../../../infra/docker-compose.yml}
# Seeded staff (B12 demo seed, apps/api/agritrace/seed/demo.py).
${ADMIN}            +919000000001
${OFFICER}          +919000000002
${QC}               +919000000003
${REPO_ROOT}        ${CURDIR}/../../..


*** Keywords ***
Stack Is Healthy
    [Documentation]    GET ${API_BASE}/healthz and assert db, redis and s3 each report "ok" (B00 acceptance).
    ...    Returns: the decoded JSON body.
    ...    Fails: API unreachable, status other than 200, or any dependency not "ok".
    ${resp}=    GET    ${API_BASE}/healthz    expected_status=200    timeout=10
    ${body}=    Set Variable    ${resp.json()}
    FOR    ${dependency}    IN    db    redis    s3
        Should Be Equal As Strings    ${body}[${dependency}]    ok
        ...    msg=healthz reports ${dependency}=${body}[${dependency}]
    END
    RETURN    ${body}

Error Code Should Be
    [Documentation]    Assert ${response} carries the error envelope with error.code == ${code} (plan §7.1).
    ...    Args: ${response} a requests response (RequestsLibrary or `Call API`); ${code} the snake_case
    ...    code from docs/api/error-codes.md.
    ...    Fails: the body is not JSON, has no "error" object, or the code differs.
    [Arguments]    ${response}    ${code}
    ${body}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${body}    error
    Should Be Equal As Strings    ${body}[error][code]    ${code}

Gate Reasons Should Be
    [Documentation]    Assert ${response} is 409 `gate_not_met` listing exactly the reason codes given, in order (B09).
    ...    Args: ${response} a requests response; @{codes} the expected `details.reasons[].code` values.
    ...    Fails: another status, another error code, or other reasons.
    [Arguments]    ${response}    @{codes}
    Should Be Equal As Integers    ${response.status_code}    409    msg=${response.text}
    Error Code Should Be    ${response}    gate_not_met
    ${got}=    Evaluate    [r["code"] for r in $response.json()["error"]["details"]["reasons"]]
    Lists Should Be Equal    ${got}    ${codes}

Second FPO Admin
    [Documentation]    Create a second FPO and an FPO admin in it straight in the database (the demo seed has one
    ...    FPO and no super-admin, and no API adds staff), so cross-FPO and per-tenant lines can be called
    ...    over HTTP as that admin. Needs `Connect To AgriTrace Database` first.
    ...    Returns: the new admin's phone (sign in with `Login As`; the first PIN verify sets ${OFFICE_PIN}).
    ...    Side effects: inserts one fpos, one users and one memberships row (FPO code QA_ROBOT_FPO_<hex>,
    ...    which has no tenant file, so it gets the default field config).
    ${fpo}=    Evaluate    str(uuid.uuid4())
    ${user}=    Evaluate    str(uuid.uuid4())
    ${tag}=    Evaluate    uuid.uuid4().hex[:8].upper()
    ${phone}=    New Phone
    Execute Sql String    INSERT INTO fpos (id, code, name, kind, public_show_farmer_names) VALUES ('${fpo}', 'QA_ROBOT_FPO_${tag}', 'QA Robot FPO ${tag}', 'fpo', false)
    Execute Sql String    INSERT INTO users (id, phone, name, lang, is_super_admin, status) VALUES ('${user}', '${phone}', 'QA Robot Admin B', 'en', false, 'active')
    Execute Sql String    INSERT INTO memberships (id, fpo_id, user_id, role) VALUES (gen_random_uuid(), '${fpo}', '${user}', 'fpo_admin')
    RETURN    ${phone}

Publish Batch
    [Documentation]    Batch the received lots (B10, Q03), grade Standard (10.5 %), approve and pack 20 kg, publish, and wait
    ...    for the worker to build the page. Returns: the batch body. Fails: the build is not `built`.
    [Arguments]    ${lots}
    ${batch}=    New Batch    ${lots}
    ${reading}=    Moisture    10.5    grading    batch_id=${batch}[id]
    Call API    POST    /batches/${batch}[id]/grading    ${ADMIN}    expect=201    json=${{ {"declared_grade": "Standard", "readings": [$reading]} }}
    Call API    POST    /batches/${batch}[id]/grading/approve    ${ADMIN}    expect=200    json=${{ {"graded": {"value": 20, "unit": "kg"}} }}
    ${pack}=    Packing    20
    Call API    POST    /batches/${batch}[id]/final-packing    ${ADMIN}    expect=200    json=${pack}
    Call API    POST    /batches/${batch}[id]/publish    ${ADMIN}    expect=202
    ${build}=    Wait For Build    ${batch}[id]    1
    Should Be Equal    ${build}[status]    built    msg=${build}
    RETURN    ${batch}

Connect To AgriTrace Database
    [Documentation]    Open a DatabaseLibrary connection to the stack's Postgres/PostGIS using pg8000.
    ...    Fails: database unreachable or credentials wrong.
    ...    Side effects: one open connection for the suite; close it with Disconnect From Database.
    # DECISION D-018: pg8000 (BSD-3-Clause) instead of psycopg, whose LGPL-3.0 licence is copyleft.
    #   ADV: no copyleft dependency in the QA toolchain; pure Python, no libpq needed on Verifier machines.
    #   COMPROMISE: slower than psycopg; irrelevant for assertion queries.
    Connect To Database    pg8000    ${DB_NAME}    ${DB_USER}    ${DB_PASSWORD}    ${DB_HOST}    ${DB_PORT}

Not Ready
    [Documentation]    Mark a placeholder test as skipped until its work package merges.
    ...    Args: ${wp} the work package that will make the test real (e.g. B02).
    [Arguments]    ${wp}
    Skip    Placeholder: written when ${wp} merges.
