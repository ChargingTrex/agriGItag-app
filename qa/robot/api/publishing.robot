*** Settings ***
Documentation       Publishing the static batch page (plan §7.1 B10) and reporting + stubs (B11).
...                 Serves: FR-12, FR-15, FR-16, FR-17, FR-20, FR-21, FR-33, FR-41, FR-63; gates G2/G4; BM-09.
...                 Placeholders are tagged not-ready and skip until their WP merges.
Resource            ../resources/common.resource
Test Tags           api


*** Test Cases ***
Published Objects Exist With Matching Generation
    [Tags]    WP-B10    FR-17    not-ready
    Not Ready    B10

Page HTML Has No Phone Survey Number Or Temp Uploads
    [Tags]    WP-B10    FR-16    not-ready
    Not Ready    B10

Revoked Name Consent Shows Farmer 2
    [Tags]    WP-B10    FR-41    not-ready
    Not Ready    B10

Correction Creates A New Build And Keeps Old Versions
    [Tags]    WP-B10    FR-17    not-ready
    Not Ready    B10

QR Decodes To The Public Batch URL
    [Tags]    WP-B10    FR-12    not-ready
    Not Ready    B10

Events Are Listed In Ascending Date Order
    [Tags]    WP-B10    FR-63    not-ready
    Not Ready    B10

Completeness Equals Lots With All Mandatory Events Over Lots
    [Tags]    WP-B11    FR-20    not-ready
    Not Ready    B11

100 Scans Per Minute Returns 429
    [Tags]    WP-B11    FR-15    not-ready
    Not Ready    B11

Audit CSV Has A Row Per Version With Entered By And Assist Session
    [Tags]    WP-B11    FR-21    not-ready
    Not Ready    B11

Partner API Returns 501 Not Implemented Pilot
    [Tags]    WP-B11    FR-33    not-ready
    Not Ready    B11
