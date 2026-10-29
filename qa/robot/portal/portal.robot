*** Settings ***
Documentation       FPO admin portal acceptance (plan §7.3 P01-P08) and the P07 chain.
...                 Serves: FR-8, FR-9, FR-12, FR-13, FR-14, FR-15, FR-23, FR-25, FR-29, FR-37, FR-41, FR-46,
...                 FR-49, FR-58, FR-70; gate G4. Run by: Q02 Verifier. Needs `rfbrowser init` once.
...                 Placeholders are tagged not-ready and skip until their WP merges.
Resource            ../resources/common.resource
Library             Browser
Test Tags           portal


*** Test Cases ***
Portal Loads In A Headless Browser
    [Tags]    WP-P00    FR-14    smoke
    New Browser    chromium    headless=True
    New Page    ${PORTAL_BASE}
    Get Title    !=    ${EMPTY}
    [Teardown]    Close Browser

Approving A Member Makes It Active Without Reload
    [Tags]    WP-P01    FR-8    not-ready
    Not Ready    P01

Phone Is Masked Except An Audited Reveal
    [Tags]    WP-P01    FR-25    not-ready
    Not Ready    P01

Reviewing A Held Lot Makes It Tickable In Create Batch
    [Tags]    WP-P02    FR-70    not-ready
    Not Ready    P02

Required Review Fields Block Submit
    [Tags]    WP-P02    FR-70    not-ready
    Not Ready    P02

Lots 100 200 20 kg Show Shares 31.25 62.5 6.25
    [Tags]    WP-P03    FR-37    not-ready
    Not Ready    P03

Out Of GI Lot Is Greyed With A Tooltip
    [Tags]    WP-P03    FR-29    not-ready
    Not Ready    P03

Create Batch Returns An Id And A QR
    [Tags]    WP-P03    FR-12    not-ready
    Not Ready    P03

Batch Over Threshold Needs A Second Sign Off
    [Tags]    WP-P03    FR-9    not-ready
    Not Ready    P03

Declared Special Computed Standard Disables Approve With Reason
    [Tags]    WP-P04    FR-49    not-ready
    Not Ready    P04

Missing Reading Disables Approve
    [Tags]    WP-P04    FR-46    not-ready
    Not Ready    P04

Happy Path Publishes And Shows The URL
    [Tags]    WP-P04    FR-15    not-ready
    Not Ready    P04

Labels PDF Is Named Labels Batch Id
    [Tags]    WP-P05    FR-12    not-ready
    Not Ready    P05

CSV Export Has A Unit On Every Quantity
    [Tags]    WP-P05    FR-58    not-ready
    Not Ready    P05

Stage Tiles Match Seed Counts
    [Tags]    WP-P06    FR-13    not-ready
    Not Ready    P06

Village Filter Updates Tiles And Table
    [Tags]    WP-P06    FR-13    not-ready
    Not Ready    P06

Column Toggle Persists
    [Tags]    WP-P06    FR-13    not-ready
    Not Ready    P06

Audit Search Shows The Seeded Correction With Actor And Reason
    [Tags]    WP-P06    FR-25    not-ready
    Not Ready    P06

Name Opt Out Is Reflected In The Preview
    [Tags]    WP-P06    FR-41    not-ready
    Not Ready    P06

Upload With 2 Bad Rows Previews 2 Red Rows With Codes
    [Tags]    WP-P08    FR-8    not-ready
    Not Ready    P08

Confirm Creates Only The Valid Rows
    [Tags]    WP-P08    FR-8    not-ready
    Not Ready    P08

Template Matches Config Fields
    [Tags]    WP-P08    FR-23    not-ready
    Not Ready    P08

Full Chain Login To Labels Is Green Under 10 Minutes Twice
    [Tags]    WP-P07    FR-13    not-ready
    Not Ready    P07

No Serious Axe Violations
    [Tags]    WP-P07    FR-13    not-ready
    Not Ready    P07
