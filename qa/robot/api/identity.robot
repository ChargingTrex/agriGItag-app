*** Settings ***
Documentation       Identity: OTP login, roles, tenant scope, assist mode, consent, logout (plan §7.1 B02).
...                 Serves: FR-1, FR-14, FR-25, FR-41, FR-59; gate G2. Run by: Verifiers, gate runs (Q06).
...                 Live procedure: docs/agents/qa/B02.md (B02/logs/live_identity.sh). Seeded farmers
...                 +919000000013 (OTP limit), +919000000012 (lock), +919000000011 (logout); the 403 and assist
...                 lines use the run's QA farmer and the seeded field officer. Each phone gets at most 10 OTPs a day,
...                 so run on a fresh seed (or wait a day) after about five reruns.
Resource            ../resources/common.resource
Suite Setup         Connect To AgriTrace Database
Suite Teardown      Disconnect From Database
Test Tags           api


*** Variables ***
${F_FLOW}       +919000000013
${F_LOCK}       +919000000012
${F_LOGOUT}     +919000000011


*** Test Cases ***
OTP Request Twice In 60 s Returns 429
    [Tags]    WP-B02    FR-1
    Call API    POST    /auth/otp/request    expect=204    json=${{ {"phone": $F_FLOW} }}
    ${r}=    Call API    POST    /auth/otp/request    expect=429    json=${{ {"phone": $F_FLOW} }}
    Error Code Should Be    ${r}    rate_limited
    Should Be True    ${r.json()}[error][details][retry_after_s] > 0

Five Wrong OTP Codes Lock The Challenge With 409
    [Tags]    WP-B02    FR-1
    Call API    POST    /auth/otp/request    expect=204    json=${{ {"phone": $F_LOCK} }}
    ${wrong}=    Create Dictionary    phone=${F_LOCK}    code=000000    device_id=${{ str(uuid.uuid4()) }}    platform=android
    FOR    ${i}    IN RANGE    4
        ${r}=    Call API    POST    /auth/otp/verify    expect=422    json=${wrong}
        Error Code Should Be    ${r}    otp_invalid
    END
    ${r}=    Call API    POST    /auth/otp/verify    expect=409    json=${wrong}
    Error Code Should Be    ${r}    otp_locked
    Set To Dictionary    ${wrong}    code=${OTP_DEV_CODE}
    ${r}=    Call API    POST    /auth/otp/verify    expect=409    json=${wrong}
    Error Code Should Be    ${r}    otp_locked

Farmer Calling GET Flags Gets 403
    [Tags]    WP-B02    FR-14
    ${w}=    QA World
    ${r}=    Call API    GET    /flags    ${w}[farmer][phone]    expect=403
    Error Code Should Be    ${r}    forbidden

Assist Header Sets On Behalf Of Farmer
    [Tags]    WP-B02    FR-59
    ${w}=    QA World
    ${farmer}=    Set Variable    ${w}[farmer][id]
    ${session}=    Start Assist    ${farmer}
    ${consent}=    New Consent    ${farmer}    public_name    ${session}
    ${rows}=    Audit Rows Of    ${consent}[id]
    Should Be Equal    ${rows}[0][on_behalf_of_farmer_id]    ${farmer}
    Should Be Equal    ${rows}[0][assist_session_id]    ${session}
    Call API    POST    /assist/end    ${OFFICER}    expect=200    json=${{ {"assist_session_id": $session} }}
    ${r}=    New Consent    ${farmer}    public_name    ${session}    expect=403
    Should Be Equal    ${r}[error][code]    assist_session_invalid

Consent Writes Audit Row With Officer As Actor
    [Tags]    WP-B02    FR-41    FR-25
    ${w}=    QA World
    ${officer}=    Call API    GET    /me    ${OFFICER}    expect=200
    ${r}=    New Consent    ${w}[farmer][id]    partner_share    expect=403
    Should Be Equal    ${r}[error][code]    forbidden
    ${session}=    Start Assist    ${w}[farmer][id]
    ${consent}=    New Consent    ${w}[farmer][id]    partner_share    ${session}
    ${rows}=    Audit Rows Of    ${consent}[id]
    Length Should Be    ${rows}    1
    Should Be Equal    ${rows}[0][actor_user_id]    ${officer.json()}[user][id]
    Should Be Equal    ${rows}[0][action]    create
    Should Be Equal    ${rows}[0][on_behalf_of_farmer_id]    ${w}[farmer][id]

Logout Revokes Refresh Token And Refresh Returns 401
    [Tags]    WP-B02    FR-1
    Call API    POST    /auth/otp/request    json=${{ {"phone": $F_LOGOUT} }}
    ${s}=    Call API    POST    /auth/otp/verify    expect=200    json=${{ {"phone": $F_LOGOUT, "code": $OTP_DEV_CODE, "device_id": str(uuid.uuid4()), "platform": "android"} }}
    ${bearer}=    Create Dictionary    Authorization=Bearer ${s.json()}[access_token]
    Call API    POST    /auth/logout    expect=204    headers=${bearer}
    ${r}=    Call API    POST    /auth/refresh    expect=401    json=${{ {"refresh_token": $s.json()["refresh_token"]} }}
    Error Code Should Be    ${r}    unauthorized
    Call API    GET    /me    expect=401    headers=${bearer}


*** Keywords ***
Audit Rows Of
    [Documentation]    The `audit_log` rows about one record, read from the database: GET /v1/audit-log does not
    ...    list consent rows (consent_records has no fpo_id, D-039; docs/agents/qa/issues/Q06-1-consent-audit-not-listed.md).
    ...    Args: ${entity_id} the record id. Returns: rows as dictionaries (actor_user_id, on_behalf_of_farmer_id,
    ...    assist_session_id, action), oldest first.
    [Arguments]    ${entity_id}
    ${rows}=    Query    SELECT actor_user_id::text, on_behalf_of_farmer_id::text, assist_session_id::text, action FROM audit_log WHERE entity_id = '${entity_id}' ORDER BY at    return_dict=True
    RETURN    ${rows}
