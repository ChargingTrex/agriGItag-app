*** Settings ***
Documentation       Seeded reference batch FGP8T4033HM7 end to end (plan §7.1 B12, PRD §12.2).
...                 Serves: FR-11, FR-13, FR-15, FR-30, FR-33, FR-47; gate G5; BM-05. Run by: Q04/Q05 Verifiers.
...                 Placeholders are tagged not-ready and skip until B12 merges.
Resource            ../resources/common.resource
Test Tags           e2e


*** Test Cases ***
Demo Seed Is Idempotent
    [Tags]    WP-B12    FR-13    not-ready
    Not Ready    B12

Reference Batch Raises Exactly The Expected Flag Set
    [Tags]    WP-B12    FR-11    BM-05    not-ready
    Not Ready    B12

Grade A Returns 422 Unknown Grade For Profile
    [Tags]    WP-B12    FR-47    not-ready
    Not Ready    B12

Approve And Publish Return 409 Before Fixes
    [Tags]    WP-B12    FR-15    not-ready
    Not Ready    B12

After Fixes Publish Succeeds With GI Verified And Shares 31.25 62.5 6.25
    [Tags]    WP-B12    FR-30    not-ready
    Not Ready    B12

Dart And TS Clients Compile
    [Tags]    WP-B12    FR-33    not-ready
    Not Ready    B12
