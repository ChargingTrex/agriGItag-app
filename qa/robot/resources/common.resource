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
${API_BASE}         %{API_BASE=http://localhost:8000/v1}
${PORTAL_BASE}      %{PORTAL_BASE=http://localhost:5173}
${PUBLIC_BASE}      %{PUBLIC_BASE=http://localhost:9000/public-pages}
${DB_HOST}          %{DB_HOST=localhost}
${DB_PORT}          %{DB_PORT=5432}
${DB_NAME}          %{DB_NAME=agritrace}
${DB_USER}          %{DB_USER=agritrace}
${DB_PASSWORD}      %{DB_PASSWORD=agritrace}
${DEV_OTP_CODE}     %{DEV_OTP_CODE=000000}
${REPO_ROOT}        ${CURDIR}/../../..


*** Keywords ***
Stack Is Healthy
    [Documentation]    GET ${API_BASE}/healthz and assert db, redis and s3 each report "ok" (B00 acceptance).
    ...    Returns: the decoded JSON body.
    ...    Fails: API unreachable, status other than 200, or any dependency not "ok".
    ${resp}=    GET    ${API_BASE}/healthz    expected_status=200    timeout=10
    ${body}=    Set Variable    ${resp.json()}
    # Accept either a flat body or one nested under "checks"; B00 fixes the exact shape.
    ${checks}=    Evaluate    $body.get("checks", $body)
    FOR    ${dependency}    IN    db    redis    s3
        Should Be Equal As Strings    ${checks}[${dependency}]    ok
        ...    msg=healthz reports ${dependency}=${checks}[${dependency}]
    END
    RETURN    ${body}

Login As
    [Documentation]    Placeholder until B02 merges: request an OTP for ${phone}, verify it with the dev
    ...    bypass code ${DEV_OTP_CODE}, and return headers carrying the bearer token.
    ...    Args: ${phone} the user's phone number as seeded.
    ...    Returns: a dictionary {"Authorization": "Bearer <access_token>"} for GET/POST headers=.
    ...    Fails: either call returns a non-2xx status or no access_token comes back.
    ...    Side effects: creates an OTP challenge and a session on the server.
    [Arguments]    ${phone}
    POST    ${API_BASE}/auth/otp/request    json=${{ {"phone": $phone} }}    expected_status=2xx
    ${resp}=    POST    ${API_BASE}/auth/otp/verify
    ...    json=${{ {"phone": $phone, "code": $DEV_OTP_CODE} }}    expected_status=2xx
    ${token}=    Set Variable    ${resp.json()}[access_token]
    RETURN    ${{ {"Authorization": "Bearer " + $token} }}

Error Code Should Be
    [Documentation]    Assert ${response} carries the error envelope with error.code == ${code} (plan §7.1).
    ...    Args: ${response} a RequestsLibrary response; ${code} the snake_case code from docs/api/error-codes.md.
    ...    Fails: the body is not JSON, has no "error" object, or the code differs.
    [Arguments]    ${response}    ${code}
    ${body}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${body}    error
    Should Be Equal As Strings    ${body}[error][code]    ${code}

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
