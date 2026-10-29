*** Settings ***
Documentation       Offline/online matrix: 9 farmer actions x 5 network states (plan §7.5 Q01, gate G3).
...                 Each cell sets the emulator network (qa/scripts/network.sh), shells to
...                 `flutter test integration_test --machine` and asserts on Parse Flutter Results.
...                 Serves: FR-4. Run by: Q01 Verifier on the Go AVD (qa/avd/go_profile.ini).
...                 The 9 actions are fixed by Q01; one placeholder per network state until M02/M07 merge.
Resource            ../resources/common.resource
Test Tags           mobile    offline-matrix


*** Test Cases ***
Flutter Machine Output Is Parsed
    [Documentation]    Real smoke test, no emulator needed: the parser counts a recorded --machine log.
    [Tags]    WP-Q00    FR-4    smoke
    ${result}=    Parse Flutter Results    ${REPO_ROOT}/qa/fixtures/flutter/sample_machine.jsonl
    Should Be Equal As Integers    ${result}[passed]    1
    Should Be Equal As Integers    ${result}[failed]    1
    Should Be Equal As Integers    ${result}[skipped]    1
    Should Contain    ${result}[failures]    harvest reaches server after network returns

Matrix On Offline
    [Tags]    WP-M02    WP-Q01    FR-4    not-ready
    Not Ready    M02

Matrix On Edge
    [Tags]    WP-M02    WP-Q01    FR-4    not-ready
    Not Ready    M02

Matrix On Weak 4G
    [Tags]    WP-M02    WP-Q01    FR-4    not-ready
    Not Ready    M02

Matrix On Normal 4G
    [Tags]    WP-M02    WP-Q01    FR-4    not-ready
    Not Ready    M02

Matrix On Reconnect After Offline
    [Tags]    WP-M02    WP-Q01    FR-4    not-ready
    Not Ready    M02
