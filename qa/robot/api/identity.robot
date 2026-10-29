*** Settings ***
Documentation       Identity: OTP login, roles, tenant scope, assist mode, consent, logout (plan §7.1 B02).
...                 Serves: FR-1, FR-14, FR-25, FR-41, FR-59; gate G2. Run by: Verifiers, CI once B02 merges.
...                 Placeholders are tagged not-ready and skip until B02 merges.
Resource            ../resources/common.resource
Test Tags           api


*** Test Cases ***
Stack Answers Before Identity Tests
    [Tags]    WP-B00    FR-33    smoke
    Stack Is Healthy

OTP Request Twice In 60 s Returns 429
    [Tags]    WP-B02    FR-1    not-ready
    Not Ready    B02

Five Wrong OTP Codes Lock The Challenge With 409
    [Tags]    WP-B02    FR-1    not-ready
    Not Ready    B02

Farmer Calling GET Flags Gets 403
    [Tags]    WP-B02    FR-14    not-ready
    Not Ready    B02

Assist Header Sets On Behalf Of Farmer
    [Tags]    WP-B02    FR-59    not-ready
    Not Ready    B02

Consent Writes Audit Row With Officer As Actor
    [Tags]    WP-B02    FR-41    FR-25    not-ready
    Not Ready    B02

Logout Revokes Refresh Token And Refresh Returns 401
    [Tags]    WP-B02    FR-1    not-ready
    Not Ready    B02
