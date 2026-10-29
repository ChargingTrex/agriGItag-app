*** Settings ***
Documentation       Rules and flags (plan §7.1 B08) and notifications (B04).
...                 Serves: FR-7, FR-14, FR-55, FR-56, FR-68, FR-69, FR-70; gate G2.
...                 Placeholders are tagged not-ready and skip until their WP merges.
Resource            ../resources/common.resource
Test Tags           api


*** Test Cases ***
Stack Answers Before Rules Tests
    [Tags]    WP-B00    FR-33    smoke
    Stack Is Healthy

Event 600 m Off Plot Raises Event Off Plot Once
    [Tags]    WP-B08    FR-69    not-ready
    Not Ready    B08

Inorganic Tag With Only Organic Inputs Raises Practice Tag Contradiction
    [Tags]    WP-B08    FR-56    not-ready
    Not Ready    B08

IPM Without A Pest Event Raises A Flag
    [Tags]    WP-B08    FR-56    not-ready
    Not Ready    B08

Nursery Before Ploughing Raises No Flag
    [Tags]    WP-B08    FR-55    not-ready
    Not Ready    B08

Sowing Before Nursery Raises A Flag
    [Tags]    WP-B08    FR-55    not-ready
    Not Ready    B08

Yield 1150 1250 1350 kg On 1 Acre Gives None Warn Hold
    [Tags]    WP-B08    FR-68    not-ready
    Not Ready    B08

Resolving A Flag Without Reason Returns 422
    [Tags]    WP-B08    FR-70    not-ready
    Not Ready    B08

Officer Resolving A Hold Returns 403
    [Tags]    WP-B08    FR-14    not-ready
    Not Ready    B08

Eager Notification Send Writes A Sent Console Row
    [Tags]    WP-B04    FR-7    not-ready
    Not Ready    B04

Unknown Template Writes A Failed Row Without Raising
    [Tags]    WP-B04    FR-7    not-ready
    Not Ready    B04
