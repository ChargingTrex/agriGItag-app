*** Settings ***
Documentation       4G brief acceptance under simulated network profiles (plan §13, BM-11..BM-15; BM-16 lives in qa/robot/public/page.robot).
...                 Drives the emulator console through qa/scripts/network.sh with profiles from qa/robot/profiles.yaml
...                 (simulator defaults, not field readings). Serves: FR-4, FR-19; gate G3. Run by: Q01 Verifier.
...                 Placeholders are tagged not-ready and skip until M02 / W01 merge.
Resource            ../resources/common.resource
Test Tags           mobile    network


*** Test Cases ***
Profiles Match The 4G Brief And Drive The Emulator Console
    [Documentation]    Real smoke test, no emulator needed: profile numbers match plan §13 and
    ...    network.sh emits the expected console commands (DRY_RUN).
    [Tags]    WP-Q00    FR-4    smoke
    ${profiles}=    Load Network Profiles
    Should Be Equal As Integers    ${profiles}[normal_4g][down_kbps]    10000
    Should Be Equal As Integers    ${profiles}[normal_4g][up_kbps]    5000
    Should Be Equal As Integers    ${profiles}[normal_4g][delay_min_ms]    60
    Should Be Equal As Integers    ${profiles}[weak_4g][down_kbps]    1000
    Should Be Equal As Integers    ${profiles}[weak_4g][up_kbps]    500
    Should Be Equal As Integers    ${profiles}[weak_4g][delay_min_ms]    300
    Should Not Be True    ${profiles}[offline][data]
    Set Environment Variable    DRY_RUN    1
    ${out}=    Set Emulator Network    weak_4g
    Should Contain    ${out}    adb emu network speed 500:1000
    Should Contain    ${out}    adb emu network delay 300:300
    ${out}=    Set Emulator Network    offline
    Should Contain    ${out}    adb emu gsm data off
    [Teardown]    Remove Environment Variable    DRY_RUN

BM-11 Normal 4G Entry Plus One Photo Shows Sent Within 5 s
    [Tags]    WP-M02    WP-Q01    BM-11    FR-4    not-ready
    Not Ready    M02

BM-12 Weak 4G Entry Plus One Photo Shows Sent Within 20 s
    [Tags]    WP-M02    WP-Q01    BM-12    FR-4    not-ready
    Not Ready    M02

BM-13 Airplane Mode Saves Instantly And Sends Automatically On Restore
    [Tags]    WP-M02    WP-Q01    BM-13    FR-4    not-ready
    Not Ready    M02

BM-14 Kill Mid Upload Then Relaunch Leaves One Entry And One Photo
    [Tags]    WP-M02    WP-Q01    BM-14    FR-4    not-ready
    Not Ready    M02

BM-15 Same Push Replayed 5 Times Leaves One Record
    [Tags]    WP-B06    WP-Q01    BM-15    FR-4    not-ready
    Not Ready    B06

