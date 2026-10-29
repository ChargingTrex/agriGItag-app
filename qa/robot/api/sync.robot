*** Settings ***
Documentation       Events, sync push, evidence (plan §7.1 B06) and reference bundle + sync pull (B07).
...                 Serves: FR-4, FR-6, FR-24, FR-25, FR-26, FR-47, FR-61; gate G2; BM-06, BM-15.
...                 Placeholders are tagged not-ready and skip until their WP merges.
Resource            ../resources/common.resource
Test Tags           api


*** Test Cases ***
Same Client Id Pushed Twice Stores One Row
    [Tags]    WP-B06    FR-4    not-ready
    Not Ready    B06

Foreign Owned Client Id Returns Client Id Conflict
    [Tags]    WP-B06    FR-24    not-ready
    Not Ready    B06

Push Of 51 Entries Returns 422
    [Tags]    WP-B06    FR-4    not-ready
    Not Ready    B06

Mixed Batch Accepts 1 And 3 And Rejects 2
    [Tags]    WP-B06    FR-4    not-ready
    Not Ready    B06

Wrong Photo Checksum Returns Checksum Mismatch And A Flag
    [Tags]    WP-B06    FR-61    not-ready
    Not Ready    B06

Undo After 24 h Returns 409
    [Tags]    WP-B06    FR-6    not-ready
    Not Ready    B06

Farmer Correction Returns 403
    [Tags]    WP-B06    FR-25    not-ready
    Not Ready    B06

Device Clock 3 Days Ahead Is Stored With A Clock Skew Flag
    [Tags]    WP-B06    FR-26    not-ready
    Not Ready    B06

Matching If-None-Match On The Bundle Returns 304
    [Tags]    WP-B07    FR-4    not-ready
    Not Ready    B07

Standards Bundle Part Holds Only Lot Gates Yield Plausible And Limits
    [Tags]    WP-B07    FR-47    not-ready
    Not Ready    B07

Pull After A New Flag Returns Exactly That Flag
    [Tags]    WP-B07    FR-4    not-ready
    Not Ready    B07
