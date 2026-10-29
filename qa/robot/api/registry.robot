*** Settings ***
Documentation       Registry and PostGIS geo (plan §7.1 B03) plus config-driven fields, masters and imports (B13).
...                 Serves: FR-8, FR-23, FR-24, FR-25, FR-27, FR-28, FR-31, FR-32, FR-70; gate G2.
...                 Placeholders are tagged not-ready and skip until their WP merges.
Resource            ../resources/common.resource
Test Tags           api


*** Test Cases ***
Stack Answers Before Registry Tests
    [Tags]    WP-B00    FR-33    smoke
    Stack Is Healthy

Point 9.559806 78.133521 Is Inside The Fixture GI Region
    [Tags]    WP-B03    FR-28    not-ready
    Not Ready    B03

Point 100 m Outside With 150 m Buffer Is Near Edge
    [Tags]    WP-B03    FR-32    not-ready
    Not Ready    B03

Madurai Point Is Outside
    [Tags]    WP-B03    FR-28    not-ready
    Not Ready    B03

Map Pin Plot Needs Review
    [Tags]    WP-B03    FR-70    not-ready
    Not Ready    B03

Plot Correction Without Reason Returns 422
    [Tags]    WP-B03    FR-25    not-ready
    Not Ready    B03

Cross FPO Plot Read Returns 404
    [Tags]    WP-B03    FR-24    not-ready
    Not Ready    B03

FPO Admin Uploading GI Region Returns 403
    [Tags]    WP-B03    FR-31    not-ready
    Not Ready    B03

Disabling Soil Type In A Tenant File Hides The Field For That FPO Only
    [Tags]    WP-B13    FR-23    not-ready
    Not Ready    B13

ID Document Upload Endpoint Follows The Feature Flag
    [Tags]    WP-B13    FR-23    not-ready
    Not Ready    B13

Farmer CSV With 2 Bad Rows Accepts The Rest Without Partial Writes
    [Tags]    WP-B13    FR-8    not-ready
    Not Ready    B13

Virudhunagar Region Build Covers The Reference Point With Provenance
    [Tags]    WP-B13    FR-27    not-ready
    Not Ready    B13

Field YAML Failing Its Schema Stops The App With A Clear Message
    [Tags]    WP-B13    FR-23    not-ready
    Not Ready    B13
