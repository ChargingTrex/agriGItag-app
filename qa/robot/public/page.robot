*** Settings ***
Documentation       Public batch page: render, privacy lint, backend-down serve, Lighthouse thresholds
...                 (plan §7.4 W01-W03, §7.5 Q03). Serves: FR-5, FR-15, FR-16, FR-17, FR-19, FR-41, FR-58,
...                 FR-61, FR-63; gate G4; BM-03, BM-09. Run by: Q03 Verifier.
...                 Placeholders are tagged not-ready and skip until their WP merges.
Resource            ../resources/common.resource
Test Tags           public


*** Test Cases ***
Privacy Lint Passes The Clean Fixture And Catches The Dirty One
    [Documentation]    Real smoke test, no stack needed: infra/scripts/privacy-lint.py on qa/fixtures/privacy.
    [Tags]    WP-Q00    FR-16    BM-09    smoke
    ${lint}=    Set Variable    ${REPO_ROOT}/infra/scripts/privacy-lint.py
    ${clean}=    Run Process    ${{sys.executable}}    ${lint}    ${REPO_ROOT}/qa/fixtures/privacy/clean
    Should Be Equal As Integers    ${clean.rc}    0    msg=${clean.stdout}
    ${dirty}=    Run Process    ${{sys.executable}}    ${lint}    ${REPO_ROOT}/qa/fixtures/privacy/dirty
    Should Be Equal As Integers    ${dirty.rc}    1    msg=${dirty.stdout}

Fixture Renders Valid HTML
    [Tags]    WP-W01    FR-16    not-ready
    Not Ready    W01

Crop Name Is Bilingual
    [Tags]    WP-W01    FR-5    not-ready
    Not Ready    W01

Every Quantity Carries A Unit
    [Tags]    WP-W01    FR-58    not-ready
    Not Ready    W01

Events Are In Date Order
    [Tags]    WP-W01    FR-63    not-ready
    Not Ready    W01

No Temp Uploads Or Non Evidence Paths
    [Tags]    WP-W01    FR-61    not-ready
    Not Ready    W01

Injected Phone Number Fails Privacy Lint
    [Tags]    WP-W02    FR-16    BM-09    not-ready
    Not Ready    W02

Lighthouse Slow 3G Performance Is At Least 90 With LCP At Most 2 s
    [Tags]    WP-W02    FR-19    BM-03    not-ready
    Not Ready    W02

First View Transfers Under 500 KB With Zero HTML Errors
    [Tags]    WP-W02    FR-19    BM-03    not-ready
    Not Ready    W02

OG Tags Pass The Privacy Lint
    [Tags]    WP-W03    FR-41    not-ready
    Not Ready    W03

Tamil Renders With The System Font
    [Tags]    WP-W03    FR-5    not-ready
    Not Ready    W03

Page Is Served From MinIO With The Backend Down
    [Tags]    WP-Q03    FR-15    not-ready
    Not Ready    Q03

Old Page Version Is Retrievable
    [Tags]    WP-Q03    FR-17    not-ready
    Not Ready    Q03
