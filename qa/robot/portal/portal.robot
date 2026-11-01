*** Settings ***
Documentation       FPO admin portal acceptance (plan §7.3 P01-P08) and the P07 chain.
...                 Serves: FR-8, FR-9, FR-12, FR-13, FR-14, FR-15, FR-23, FR-25, FR-29, FR-37, FR-41, FR-46,
...                 FR-49, FR-58, FR-70; gate G4; WP Q07 (P01-P04 lines real). Run by: Q02 Verifier, gate G4.
...                 Needs `rfbrowser init` once and the portal served in live mode (`npm run dev`, no VITE_MSW)
...                 against the stack under test; see qa/robot/README.md.
...                 Every test drives the UI as the seeded FPO admin, signed in once per run through the login
...                 form. Data the line needs (farmers, plots, packed lots, QC grading) is made over the API
...                 with the agritrace_keywords fixtures; API reads only back up what the screen showed
...                 (the stored status, the audit row, the QR content). Ready lots is opened with a full page load, because the
...                 portal caches lots and hold flags for 30 s and each test makes its lots just before.
...                 Placeholders are tagged not-ready and skip until their WP merges.
Resource            ../resources/common.resource
# SUITE: the admin page signed in by the first test stays open for the others (one OTP per run).
Library             Browser    timeout=20s    auto_closing_level=SUITE
Suite Teardown      Close Browser    ALL
Test Tags           portal


*** Variables ***
${NOT_GI}           Outside the GI region. It can only go into a non-GI batch.


*** Test Cases ***
Portal Loads In A Headless Browser
    [Tags]    WP-P00    FR-14    smoke
    New Browser    chromium    headless=True
    New Page    ${PORTAL_BASE}
    Get Title    !=    ${EMPTY}
    [Teardown]    Close Browser

Approving A Member Makes It Active Without Reload
    [Tags]    WP-P01    FR-8
    Portal As Admin
    ${f}=    New Farmer    QA Robot Pending ${{uuid.uuid4().hex[:6]}}    approve=${False}
    Open Screen    Members
    Evaluate JavaScript    ${None}    window.__qaNoReload = 'still-here'
    ${pending}=    Set Variable    role=table[name="Waiting for approval"] >> tr:has-text("${f}[name]")
    Wait For Elements State    ${pending}    visible
    Click    role=button[name="Approve ${f}[name]"]
    Wait For Elements State    ${pending}    detached
    Get Text    role=table[name="All members"] >> tr:has-text("${f}[name]")    contains    Active
    # A marker set on window before the click survives only if the page was not reloaded.
    ${marker}=    Evaluate JavaScript    ${None}    window.__qaNoReload
    Should Be Equal    ${marker}    still-here
    ${farmer}=    Call API    GET    /farmers/${f}[id]    ${ADMIN}    200
    Should Be Equal    ${farmer.json()}[status]    active

Phone Is Masked Except An Audited Reveal
    [Tags]    WP-P01    FR-25
    Portal As Admin
    ${f}=    New Farmer    QA Robot Reveal ${{uuid.uuid4().hex[:6]}}
    ${farmer}=    Call API    GET    /farmers/${f}[id]    ${ADMIN}    200
    ${masked}=    Set Variable    ${farmer.json()}[phone_masked]
    Should Match Regexp    ${masked}    ^X+${f}[phone][-4:]$
    Go To    ${PORTAL_BASE}/members/${f}[id]
    Wait For Elements State    role=heading[name="${f}[name]"]    visible
    Get Text    main    contains    Mobile: ${masked}
    Get Text    main    not contains    ${f}[phone][-10:]
    ${before}=    Phone Reveals    ${f}[id]
    Should Be Equal As Integers    ${before}    0
    Click    role=button[name="Reveal number"]
    Get Text    main    contains    Mobile: ${f}[phone]
    Get Element Count    role=button[name="Reveal number"]    ==    0
    ${after}=    Phone Reveals    ${f}[id]
    Should Be Equal As Integers    ${after}    1

Reviewing A Held Lot Makes It Tickable In Create Batch
    [Tags]    WP-P02    FR-70
    Portal As Admin
    ${held}=    Held Lot
    Go To    ${PORTAL_BASE}/ready-lots
    Get Attribute    role=checkbox[name=/^Lot ${held}[lot][code]: /]    aria-label    contains    Yield above the ceiling
    Get Element States    role=checkbox[name=/^Lot ${held}[lot][code]: /]    contains    disabled
    Go To    ${PORTAL_BASE}/flags/${held}[flag][id]
    Wait For Elements State    role=heading[name="Resolve this flag"]    visible
    Select Options By    internal:label=/^Outcome/    value    looks_fine
    Select Options By    internal:label=/^Reason/    index    1
    Fill Text    internal:label=/^Note/    QA Robot: field visit confirmed the yield
    Click    role=button[name="Save review"]
    Wait For Elements State    text=/^Cleared on/    visible
    # The worker re-derives gi_eligible after the review: wait for it on the server, then load the screen once.
    # Not a reload loop: a reload during the portal's session-restore refresh signs the device out (Q07-1).
    Wait Until Keyword Succeeds    90s    3s    Lot Should Be GI Eligible    ${held}[lot][id]
    Go To    ${PORTAL_BASE}/ready-lots
    Get Element States    role=checkbox[name="Tick lot ${held}[lot][code]"]    contains    enabled
    Check Checkbox    role=checkbox[name="Tick lot ${held}[lot][code]"]
    Get Checkbox State    role=checkbox[name="Tick lot ${held}[lot][code]"]    ==    checked
    Uncheck Checkbox    role=checkbox[name="Tick lot ${held}[lot][code]"]

Required Review Fields Block Submit
    [Tags]    WP-P02    FR-70
    Portal As Admin
    ${held}=    Held Lot
    Go To    ${PORTAL_BASE}/flags/${held}[flag][id]
    Wait For Elements State    role=heading[name="Resolve this flag"]    visible
    Click    role=button[name="Save review"]
    Wait For Elements State    text="Choose a reason."    visible
    ${flag}=    Call API    GET    /flags/${held}[flag][id]    ${ADMIN}    200
    Should Be Equal    ${flag.json()}[status]    open

Lots 100 200 20 kg Show Shares 31.25 62.5 6.25
    [Tags]    WP-P03    FR-37
    Portal As Admin
    ${lots}=    Share Lots
    Go To    ${PORTAL_BASE}/ready-lots
    FOR    ${lot}    IN    @{lots}
        Check Checkbox    role=checkbox[name="Tick lot ${lot}[code]"]
    END
    FOR    ${lot}    ${want}    IN ZIP    ${lots}    ${{[31.25, 62.5, 6.25]}}
        ${share}=    Get Text    role=table[name="Ready lots"] >> tr:has-text("${lot}[code]") >> td >> nth=-1
        Should Be Equal As Numbers    ${share.rstrip(' %')}    ${want}
    END
    Get Text    text=/lots? ticked, total/    contains    320 kg

Out Of GI Lot Is Greyed With A Tooltip
    [Tags]    WP-P03    FR-29
    Portal As Admin
    ${plot}=    New Plot    13.0827    80.2707
    ${lot}=    Packed Lot    30    ${plot}
    Wait For Flag    ${plot}[id]    plot_outside_gi_region
    Go To    ${PORTAL_BASE}/ready-lots
    ${box}=    Set Variable    role=checkbox[name=/^Lot ${lot}[code]: /]
    Get Element States    ${box}    contains    disabled
    Get Attribute    ${box}    aria-label    ==    Lot ${lot}[code]: ${NOT_GI}
    # A disabled input fires no hover events: the tooltip sits on the span around the checkbox.
    Hover    ${box} >> xpath=ancestor::span[1]/..
    Get Text    role=tooltip    ==    ${NOT_GI}
    Get Style    tr:has-text("${lot}[code]") >> td >> nth=1    color    ==    rgba(0, 0, 0, 0.6)

Create Batch Returns An Id And A QR
    [Tags]    WP-P03    FR-12
    Portal As Admin
    ${lots}=    Share Lots
    Go To    ${PORTAL_BASE}/ready-lots
    FOR    ${lot}    IN    @{lots}
        Check Checkbox    role=checkbox[name="Tick lot ${lot}[code]"]
    END
    ${batch}=    Create Batch In The UI
    Get Text    p:has-text("Batch ID:")    contains    Batch ID: ${batch}[code]
    # The page shows the QR once published (happy path below); the QR itself already encodes /b/<code>.
    ${png}=    Call API    GET    /batches/${batch}[id]/qr.png    ${ADMIN}    200
    ${texts}=    Decode QR    ${png.content}
    Should Be Equal    ${texts}    ${{[$PUBLIC_BASE + "/b/" + $batch["code"]]}}
    Set Suite Variable    ${BATCH_X}    ${batch}

Batch Over Threshold Needs A Second Sign Off
    [Tags]    WP-P03    FR-9
    Portal As Admin
    ${plot}=    New Plot    declared_area=${{ {"value": "5", "unit": "acre"} }}
    ${lot}=    Packed Lot    1100    ${plot}
    Go To    ${PORTAL_BASE}/ready-lots
    Check Checkbox    role=checkbox[name="Tick lot ${lot}[code]"]
    Create Batch In The UI
    Wait For Elements State    text=/Waiting for a second admin/    visible
    Get Element States    role=button[name=/^Sign off(:|$)/]    contains    disabled
    Get Attribute    role=button[name=/^Sign off(:|$)/]    aria-label    contains    a different FPO admin must give the second sign-off

Declared Special Computed Standard Disables Approve With Reason
    [Tags]    WP-P04    FR-49
    Portal As Admin
    ${lot}=    Packed Lot    100
    ${batch}=    New Batch    ${{[$lot["id"]]}}    gi=${True}
    ${grading}=    Grade Batch    ${batch}[id]    Special    10.5
    Should Be Equal    ${grading}[computed_grade]    Standard
    Go To    ${PORTAL_BASE}/batches/${batch}[id]
    Get Element States    role=button[name=/^Approve grading/]    contains    disabled
    Get Attribute    role=button[name=/^Approve grading/]    aria-label    contains
    ...    Declared grade Special is above the computed grade Standard

Missing Reading Disables Approve
    [Tags]    WP-P04    FR-46
    Portal As Admin
    ${lot}=    Packed Lot    60
    ${batch}=    New Batch    ${{[$lot["id"]]}}    gi=${True}
    Grade Batch    ${batch}[id]    Standard
    Go To    ${PORTAL_BASE}/batches/${batch}[id]
    Get Text    main    contains    not computed (reading missing)
    Get Element States    role=button[name=/^Approve grading/]    contains    disabled
    Get Attribute    role=button[name=/^Approve grading/]    aria-label    contains
    ...    A required quality reading is missing: moisture.

Happy Path Publishes And Shows The URL
    [Tags]    WP-P04    FR-15
    Portal As Admin
    # shortcut: reuses the 320 kg batch of "Create Batch Returns An Id And A QR"; run with that test (as the
    #   G4 run does). Give this test its own UI-made batch if it must run alone.
    Variable Should Exist    ${BATCH_X}    msg=Run "Create Batch Returns An Id And A QR" first: it creates the batch.
    Grade Batch    ${BATCH_X}[id]    Standard    10.5
    Go To    ${PORTAL_BASE}/batches/${BATCH_X}[id]
    Fill Text    internal:label="Graded quantity (kg)"s    320
    Click    role=button[name="Approve grading"s]
    Wait For Elements State    text=/^Grading approved/    visible
    Fill Text    internal:label="Packed quantity (kg)"s    320
    ${today}=    Days Ago    0
    ${best_before}=    Days Ago    -364
    Fill Text    internal:label="Pack date"s    ${today}
    Fill Text    internal:label="Best before"s    ${best_before}
    Click    role=button[name="Sign off final packing"s]
    Wait For Elements State    text=/^Packed \\d/    visible
    Click    role=button[name="Publish"s]
    ${url}=    Set Variable    ${PUBLIC_BASE}/b/${BATCH_X}[code]
    Wait For Elements State    role=link[name="${url}"s]    visible    timeout=180s
    Wait For Elements State    role=img[name="QR code opening ${url}"s]    visible
    ${batch}=    Call API    GET    /batches/${BATCH_X}[id]    ${ADMIN}    200
    Should Be Equal    ${batch.json()}[status]    published

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


*** Keywords ***
Portal As Admin
    [Documentation]    Bring the signed-in FPO admin's page to the front. The first call of a run opens a headless
    ...    Chromium and signs ${ADMIN} in through the login form (mobile, dev OTP, then the PIN step; a
    ...    fresh seed has no PIN yet, so the form chooses ${OFFICE_PIN}). Later calls reuse that page, so a
    ...    run spends one admin OTP (the API allows 10 per phone per day). Tests call it before their API
    ...    fixtures: the API sign-in (`Login As`) can wait out the one-code-per-60 s limit, the form cannot.
    ...    Fails: a sign-in step is not reached within the Browser timeout, or an earlier test's sign-in
    ...    failed (no retry: each attempt would spend another OTP).
    ...    Side effects: sets the suite variable ${ADMIN_PAGE}; on a fresh seed sets the admin's PIN.
    ${known}=    Get Variable Value    ${ADMIN_PAGE}
    IF    $known == "failed"
        Fail    The portal sign-in failed in an earlier test; see that test.
    ELSE IF    $known is not None
        Switch Page    ${known}    context=ALL    browser=ALL
        RETURN
    END
    Set Suite Variable    ${ADMIN_PAGE}    failed
    New Browser    chromium    headless=True
    New Context    viewport={'width': 1280, 'height': 800}
    ${page}=    New Page    ${PORTAL_BASE}/
    Fill Text    internal:label="Mobile number"s    ${ADMIN}[3:]
    Click    role=button[name="Send code"]
    ${sent}=    Run Keyword And Return Status
    ...    Wait For Elements State    internal:label="SMS code"s    visible    timeout=10s
    IF    not ${sent}
        # One code per phone per 60 s (B02): a run right after another run waits it out once.
        Sleep    61s
        Click    role=button[name="Send code"]
    END
    Fill Text    internal:label="SMS code"s    ${OTP_DEV_CODE}
    Click    role=button[name="Verify code"]
    Wait For Elements State    internal:label=/^(PIN|Choose a 4-digit PIN)$/    visible
    ${first}=    Get Element Count    internal:label="Choose a 4-digit PIN"s
    IF    ${first}
        Fill Text    internal:label="Choose a 4-digit PIN"s    ${OFFICE_PIN}
        Click    role=button[name="Next"]
        Fill Text    internal:label="Type the PIN again"s    ${OFFICE_PIN}
    ELSE
        Fill Text    internal:label="PIN"s    ${OFFICE_PIN}
    END
    # "Sign in", or "Save PIN and sign in" on the first sign-in (a quoted role name matches the whole name).
    Click    role=button[name=/sign in$/i]
    Wait For Elements State    role=navigation[name="Main"]    visible
    Set Suite Variable    ${ADMIN_PAGE}    ${page}[page_id]

Open Screen
    [Documentation]    Open a sidebar screen by its label (client-side navigation inside the portal).
    ...    Args: ${label} the navigation label, e.g. "Ready lots".
    ...    Fails: no such link in the Main navigation.
    [Arguments]    ${label}
    Click    role=navigation[name="Main"] >> role=link[name="${label}"]

Create Batch In The UI
    [Documentation]    On Ready lots with lots ticked: pick the first processor, press "Create batch" and wait for
    ...    the batch page.
    ...    Returns: {"id", "code"} of the new batch, read from the URL and the "Batch <code>" heading.
    ...    Fails: the batch page does not open.
    ...    Side effects: creates a batch of the ticked lots as the FPO admin.
    Click    role=combobox[name="Processor"]
    Click    role=option >> nth=0
    Click    role=button[name="Create batch"s]
    ${heading}=    Get Text    role=heading[level=1][name=/^Batch /]
    ${url}=    Get Url
    ${batch}=    Create Dictionary    id=${url.split("/batches/")[1]}    code=${heading.removeprefix("Batch ").strip()}
    RETURN    ${batch}

Share Lots
    [Documentation]    The three packed and received lots of 100, 200 and 20 kg on the QA plot (P03 shares line and
    ...    the batch that P03 create and P04 happy path use), made once per run.
    ...    Returns: the three LotOut bodies, in that order.
    ...    Side effects: first call creates the lots (see `Packed Lot`) and sets the suite variable ${SHARE_LOTS}.
    ${lots}=    Get Variable Value    ${SHARE_LOTS}
    IF    $lots is None
        ${lots}=    Create List
        FOR    ${kg}    IN    100    200    20
            ${lot}=    Packed Lot    ${kg}
            Append To List    ${lots}    ${lot}
        END
        Set Suite Variable    ${SHARE_LOTS}    ${lots}
    END
    RETURN    ${lots}

Held Lot
    [Documentation]    A received lot held by `yield_over_ceiling` (2000 kg harvested on a 1-acre plot), and that
    ...    open hold flag, for the P02 review lines. Each call makes a new one, so the two P02 tests do not
    ...    depend on each other's review.
    ...    Returns: {"lot": LotOut, "flag": FlagOut}.
    ...    Fails: the worker raises no hold within the `Wait For Flag` timeout.
    ...    Side effects: creates a plot, a lot, its events and intake.
    ${plot}=    New Plot
    ${lot}=    Packed Lot    50    ${plot}    harvest_kg=2000
    ${flag}=    Wait For Flag    ${lot}[id]    yield_over_ceiling
    ${held}=    Create Dictionary    lot=${lot}    flag=${flag}
    RETURN    ${held}

Phone Reveals
    [Documentation]    Count a farmer's `farmer.phone_reveal` audit rows (GET /v1/audit-log as the FPO admin).
    ...    Args: ${farmer_id} the farmer.
    ...    Returns: the number of reveal rows.
    ...    Fails: the audit log call does not answer 200.
    [Arguments]    ${farmer_id}
    &{params}=    Create Dictionary    entity_type=farmers    entity_id=${farmer_id}
    ${rows}=    Call API    GET    /audit-log    ${ADMIN}    200    params=${params}
    ${count}=    Evaluate    sum(1 for row in $rows.json()["items"] if row["action"] == "farmer.phone_reveal")
    RETURN    ${count}

Lot Should Be GI Eligible
    [Documentation]    Assert the server marks a lot `gi_eligible` (GET /v1/lots/{id} as the FPO admin).
    ...    Args: ${lot_id} the lot.
    ...    Fails: the lot is still not GI eligible (retry it with Wait Until Keyword Succeeds).
    [Arguments]    ${lot_id}
    ${lot}=    Call API    GET    /lots/${lot_id}    ${ADMIN}    200
    Should Be True    ${lot.json()}[gi_eligible]    msg=lot ${lot_id} is not GI eligible yet
