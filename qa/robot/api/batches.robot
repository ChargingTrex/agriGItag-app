*** Settings ***
Documentation       Lots, intake, batches and gates (plan §7.1 B09).
...                 Serves: FR-11, FR-15, FR-17, FR-29, FR-37, FR-43, FR-49, FR-60; gate G2.
...                 Placeholders are tagged not-ready and skip until B09 merges.
Resource            ../resources/common.resource
Test Tags           api


*** Test Cases ***
Stack Answers Before Batch Tests
    [Tags]    WP-B00    FR-33    smoke
    Stack Is Healthy

Lot Ready At 11.5 Percent Returns 409 And At 10.9 Percent Becomes Ready
    [Tags]    WP-B09    FR-43    not-ready
    Not Ready    B09

Intake 100 kg Versus Packed 69 kg Raises Quantity Mismatch
    [Tags]    WP-B09    FR-11    not-ready
    Not Ready    B09

Lots 100 200 20 kg Give Shares 31.250 62.500 6.250
    [Tags]    WP-B09    FR-37    not-ready
    Not Ready    B09

Ineligible Lot With GI Requested Gives GI Verified False With Reasons
    [Tags]    WP-B09    FR-29    not-ready
    Not Ready    B09

Approve On Declared Above Computed Returns 409
    [Tags]    WP-B09    FR-49    not-ready
    Not Ready    B09

Packing 25 kg On 20 kg Graded Returns 409
    [Tags]    WP-B09    FR-60    not-ready
    Not Ready    B09

Publish Before Approval Returns 409 Listing Reasons
    [Tags]    WP-B09    FR-15    not-ready
    Not Ready    B09

Publish After Gates Returns 202 And A Page Build Row
    [Tags]    WP-B09    FR-17    not-ready
    Not Ready    B09
