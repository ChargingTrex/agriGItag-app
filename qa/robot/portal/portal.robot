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
Suite Teardown      Portal Suite Teardown
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

Stage Tiles Match Seed Counts
    [Documentation]    Runs before this suite adds any lot. Every stage tile shows the server's counts for the
    ...    FPO (GET /v1/dashboard/fpo/{id}); when the FPO holds only the seed's three lots (a fresh seed, this
    ...    suite run first) every stage also reads "3 done · 0 in progress · 0 not started".
    [Tags]    WP-P06    FR-13
    Portal As Admin
    Go To    ${PORTAL_BASE}/
    ${shown}=    Stage Tile Counts
    ${me}=    Call API    GET    /me    ${ADMIN}    200
    ${fpo}=    Set Variable    ${me.json()}[memberships][0][fpo_id]
    ${board}=    Call API    GET    /dashboard/fpo/${fpo}    ${ADMIN}    200
    ${server}=    Evaluate    [f'{t["done"]} done · {t["in_progress"]} in progress · {t["not_started"]} not started' for t in $board.json()["stages"]]
    Lists Should Be Equal    ${shown}    ${server}
    Portal Database
    ${lots}=    Query    SELECT count(*) FROM lots WHERE fpo_id = '${fpo}'
    IF    ${lots}[0][0] == 3
        Lists Should Be Equal    ${shown}    ${{ ["3 done · 0 in progress · 0 not started"] * 7 }}
    ELSE
        Log    The FPO has ${lots}[0][0] lots (not a fresh seed): the literal seed counts were not checked.    WARN
    END

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
    [Tags]    WP-P05    FR-12
    Portal As Admin
    Batch X Is Published
    Go To    ${PORTAL_BASE}/batches/${BATCH_X}[id]
    ${file}=    Download From Button    Download labels
    Should Be Equal    ${file}[suggestedFilename]    labels-${BATCH_X}[code].pdf
    ${head}=    Evaluate    pathlib.Path($file["saveAs"]).read_bytes()[:5]
    Should Be Equal    ${head}    ${{ b"%PDF-" }}

CSV Export Has A Unit On Every Quantity
    [Tags]    WP-P05    FR-58
    Portal As Admin
    Batch X Is Published
    Go To    ${PORTAL_BASE}/batches/${BATCH_X}[id]
    ${lots}=    Download From Button    Download lots CSV
    ${audit}=    Download From Button    Download audit CSV
    Open Screen    Labels & exports
    ${farmers}=    Download From Button    Download farmers CSV
    FOR    ${file}    IN    ${lots}    ${audit}    ${farmers}
        ${found}=    Unitless Quantity Columns    ${file}[saveAs]    counts=${{ ["plots", "lots", "lots_complete", "version_no"] }}
        Log    ${file}[suggestedFilename]: ${found}
        Should Be Empty    ${found}[unitless]    msg=${file}[suggestedFilename]: quantity columns without a unit
        Should Not Be Empty    ${found}[quantities]    msg=${file}[suggestedFilename]: no quantity column found
        ${header}=    Evaluate    pathlib.Path($file["saveAs"]).read_text("utf-8-sig").splitlines()[0]
        Should Not Contain    ${header.lower()}    phone
    END

Upload With 2 Bad Rows Previews 2 Red Rows With Codes
    [Tags]    WP-P08    FR-8
    Portal As Admin
    ${v}=    QA Villages
    ${tag}=    Set Variable    ${v}[tag]
    ${template}=    Call API    GET    /imports/farmers/template.csv    ${ADMIN}    200
    ${header}=    Evaluate    $template.text.splitlines()[0]
    ${p1}=    New Phone
    ${p2}=    New Phone
    ${p3}=    New Phone
    ${r1}=    Create Dictionary    name=QA Alpha ${tag}    phone=${p1}    village_lgd_code=${v}[alpha]
    ${r2}=    Create Dictionary    name=${EMPTY}    phone=${p2}    village_lgd_code=${v}[alpha]
    ${r3}=    Create Dictionary    name=QA Beta ${tag}    phone=${p3}    village_lgd_code=${v}[beta]
    ${r4}=    Create Dictionary    name=QA BadPhone ${tag}    phone=12345    village_lgd_code=${v}[beta]
    @{rows}=    Create List    ${r1}    ${r2}    ${r3}    ${r4}
    ${csv}=    Template CSV    ${header}    @{rows}
    Create File    ${OUTPUT DIR}/qa-farmers-2-bad.csv    ${csv}
    Go To    ${PORTAL_BASE}/uploads
    Click    role=tab[name="Farmers"]
    Upload File By Selector    internal:label=/^CSV file/    ${OUTPUT DIR}/qa-farmers-2-bad.csv
    ${rejected}=    Set Variable    role=table[name="Rows of qa-farmers-2-bad.csv"] >> tr:has-text("Rejected")
    Get Element Count    ${rejected}    ==    2
    ${registry}=    Get File    ${REPO_ROOT}/docs/api/error-codes.md
    ${texts}=    Get Elements    ${rejected}
    FOR    ${row}    IN    @{texts}
        ${text}=    Get Text    ${row}
        ${code}=    Evaluate    re.search(r"Rejected\\s+([a-z_]+)", $text).group(1)
        Should Contain    ${registry}    | `${code}` |    msg=${code} is not in docs/api/error-codes.md
        Get Style    ${row}    background-color    ==    rgba(211, 47, 47, 0.1)
    END
    Set Suite Variable    ${FARMERS_CSV_TAG}    ${tag}

Confirm Creates Only The Valid Rows
    [Tags]    WP-P08    FR-8
    Portal As Admin
    Variable Should Exist    ${FARMERS_CSV_TAG}    msg=Run "Upload With 2 Bad Rows Previews 2 Red Rows With Codes" first.
    ${before}=    Query    SELECT count(*) FROM farmers
    Click    role=button[name="Import 2 rows"]
    Wait For Elements State    text=/^2 rows imported\\./    visible
    ${after}=    Query    SELECT count(*) FROM farmers
    Should Be Equal As Integers    ${after}[0][0]    ${{ $before[0][0] + 2 }}
    ${made}=    Query    SELECT name, status FROM farmers WHERE name LIKE 'QA % ${FARMERS_CSV_TAG}' ORDER BY name
    ${expected}=    Evaluate    [("QA Alpha " + $FARMERS_CSV_TAG, "pending"), ("QA Beta " + $FARMERS_CSV_TAG, "pending")]
    Lists Should Be Equal    ${{ [tuple(r) for r in $made] }}    ${expected}

Template Matches Config Fields
    [Tags]    WP-P08    FR-23
    Portal As Admin
    Go To    ${PORTAL_BASE}/uploads
    Click    role=tab[name="Farmers"]
    ${cells}=    Get Elements    role=table[name=/template columns/] >> code
    ${shown}=    Create List
    FOR    ${cell}    IN    @{cells}
        ${text}=    Get Text    ${cell}
        Append To List    ${shown}    ${text.strip()}
    END
    ${template}=    Call API    GET    /imports/farmers/template.csv    ${ADMIN}    200
    ${header}=    Evaluate    [h.strip() for h in $template.text.splitlines()[0].split(",")]
    ${fields}=    Call API    GET    /config/fields    ${ADMIN}    200
    # The API's rule (registry/imports.py): enabled farmer fields of a CSV type, plus village_lgd_code.
    ${csv_types}=    Create List    text    number    integer    boolean    date    phone    choice
    ${expected}=    Evaluate    [f["name"] for f in $fields.json()["farmer"] if f["enabled"] and f["type"] in $csv_types] + ["village_lgd_code"]
    Lists Should Be Equal    ${shown}    ${header}
    Lists Should Be Equal    ${header}    ${expected}

Village Filter Updates Tiles And Table
    [Tags]    WP-P06    FR-13
    Portal As Admin
    ${v}=    QA Villages
    ${alpha}=    New Farmer    QA Village Farmer ${v}[tag]    village_id=${v}[alpha_id]
    ${plot}=    New Plot    farmer_id=${alpha}[id]
    New Lot    ${plot}
    Go To    ${PORTAL_BASE}/
    ${before}=    Stage Tile Counts
    Select Options By    role=combobox[name="District"]    value    Virudhunagar
    Select Options By    role=combobox[name="Block"]    value    QA Block One ${v}[tag]
    Select Options By    role=combobox[name="Village"]    label    QA Village Alpha ${v}[tag]
    ${want}=    Evaluate    ["0 done · 0 in progress · 1 not started"] * 7
    Wait Until Keyword Succeeds    30s    2s    Stage Tile Counts Should Be    ${want}
    ${table}=    Set Variable    role=table[name="Farmers"]
    Get Text    ${table}    contains    QA Village Farmer ${v}[tag]
    # Farmers outside the village (the seed's, the QA world's) are filtered out.
    Get Text    ${table}    not contains    muthu murugan
    Get Text    ${table}    not contains    QA Robot Farmer
    Should Not Be Equal    ${before}    ${want}

Column Toggle Persists
    [Tags]    WP-P06    FR-13
    Portal As Admin
    Go To    ${PORTAL_BASE}/
    ${box}=    Set Variable    role=checkbox[name="Village"]
    ${header}=    Set Variable    role=table[name="Farmers"] >> role=columnheader[name="Village"]
    Wait For Elements State    role=table[name="Farmers"]    visible
    Check Checkbox    ${box}
    Get Element Count    ${header}    ==    1
    Uncheck Checkbox    ${box}
    Get Element Count    ${header}    ==    0
    Reload
    Wait For Elements State    role=table[name="Farmers"]    visible
    Get Checkbox State    ${box}    ==    unchecked
    Get Element Count    ${header}    ==    0
    ${stored}=    Evaluate JavaScript    ${None}
    ...    Object.keys(localStorage).filter((k) => k.startsWith('agritrace.dashboard.columns')).map((k) => localStorage.getItem(k))
    Should Not Be Empty    ${stored}
    Should Not Contain    ${stored}[0]    "village"
    [Teardown]    Check Checkbox    ${box}

Audit Search Shows The Seeded Correction With Actor And Reason
    [Documentation]    P06 line 5 (also the Q02 re-check the Verifier could not finish): the field officer corrects
    ...    a harvest with a reason; the admin's audit search for that version shows the officer and the reason.
    [Tags]    WP-P06    FR-25
    Portal As Admin
    ${w}=    QA World
    ${lot}=    New Lot
    ${on}=    Days Ago    30
    ${harvest}=    Event    ${lot}    ${w}[plot]    harvest    ${on}    ${{ {"quantity": {"value": 50, "unit": "kg"}, "bags": 10} }}
    Push    ${OFFICER}    ${harvest}
    ${data}=    Copy Dictionary    ${harvest}[data]
    Set To Dictionary    ${data}    version_no=${2}    change_kind=correct    reason_code=wrong_quantity
    ...    reason_text=QA Robot: scale re-read    payload=${{ {"quantity": {"value": 48, "unit": "kg"}, "bags": 10} }}
    Call API    POST    /events/${data}[event_id]/versions    ${OFFICER}    expect=200    json=${{ {"client_id": str(uuid.uuid4()), "data": $data} }}
    ${officer}=    Call API    GET    /me    ${OFFICER}    200
    ${rows}=    Call API    GET    /audit-log    ${ADMIN}    200    params=${{ {"entity_type": "event_versions", "limit": 100} }}
    ${row}=    Evaluate    [r for r in $rows.json()["items"] if r["action"] == "event.correct" and r["diff"].get("event_id") == $data["event_id"]][0]
    Open Screen    Audit log
    Select Options By    internal:label="Entity type"s    value    ${row}[entity_type]
    Fill Text    internal:label="Entity id"s    ${row}[entity_id]
    Click    role=button[name=/^Search/]
    ${table}=    Set Variable    role=table[name="Audit log"]
    Get Text    ${table}    contains    event.correct
    Get Text    ${table}    contains    ${officer.json()}[user][id]
    Get Text    ${table}    contains    wrong_quantity
    Get Text    ${table}    contains    QA Robot: scale re-read
    Get Text    ${table}    not contains    Reason: not in the audit log yet

Name Opt Out Is Reflected In The Preview
    [Tags]    WP-P06    FR-41
    Portal As Admin
    Batch X Is Published
    ${w}=    QA World
    ${session}=    Start Assist    ${w}[farmer][id]
    New Consent    ${w}[farmer][id]    public_name    ${session}
    Set FPO Farmer Names    true
    Go To    ${PORTAL_BASE}/batches/${BATCH_X}[id]
    Rebuild And Wait
    # The preview iframe keeps its URL across builds and the page is served with max-age=60, so it can show the
    # previous build for up to 60 s (Q07-2): reload the batch page until the new build shows.
    Wait Until Keyword Succeeds    100s    5s    Preview Should Show    contains    ${w}[farmer][name]
    Set FPO Farmer Names    false
    Rebuild And Wait
    Wait Until Keyword Succeeds    100s    5s    Preview Should Show    not contains    ${w}[farmer][name]
    Preview Should Show    contains    Farmer 1
    Open Screen    Settings
    Get Checkbox State    internal:label="Hide farmer names on public pages (opt-out)"s    ==    checked
    [Teardown]    Set FPO Farmer Names    ${FPO_NAMES_BEFORE}

Full Chain Login To Labels Is Green Under 10 Minutes Twice
    [Documentation]    P07's Playwright chain (e2e/chain.spec.ts, two serial runs) in mock mode: both pass and each
    ...    takes under 10 minutes. Playwright starts `npm run dev:mock` on :5174 itself.
    [Tags]    WP-P07    FR-13
    ${report}=    Run Playwright Spec    e2e/chain.spec.ts
    Should Be Equal As Integers    ${report}[stats][expected]    2    msg=${report}[stats]
    Should Be Equal As Integers    ${report}[stats][unexpected]    0    msg=${report}[stats]
    ${durations}=    Evaluate    [r["duration"] for s in $report["suites"] for t in s["specs"] for x in t["tests"] for r in x["results"]]
    FOR    ${ms}    IN    @{durations}
        Should Be True    ${ms} < 600000    msg=a chain run took ${ms} ms
    END

No Serious Axe Violations
    [Documentation]    P07's axe check (e2e/axe.spec.ts) over every routed screen in mock mode passes: no serious
    ...    or critical violation.
    [Tags]    WP-P07    FR-13
    ${report}=    Run Playwright Spec    e2e/axe.spec.ts
    Should Be Equal As Integers    ${report}[stats][expected]    1    msg=${report}[stats]
    Should Be Equal As Integers    ${report}[stats][unexpected]    0    msg=${report}[stats]


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

Portal Database
    [Documentation]    Connect to the stack's database once per run (the P06/P08 fixture switches have no API) and
    ...    remember the FPO's farmer-name setting so the teardown can restore it.
    ...    Fails: the database is unreachable. Side effects: sets ${PORTAL_DB} and ${FPO_NAMES_BEFORE}.
    ${known}=    Get Variable Value    ${PORTAL_DB}    ${False}
    IF    ${known}    RETURN
    Connect To AgriTrace Database
    ${names}=    Query    SELECT f.public_show_farmer_names FROM fpos f JOIN memberships m ON m.fpo_id = f.id JOIN users u ON u.id = m.user_id WHERE u.phone = '${ADMIN}'
    Set Suite Variable    ${FPO_NAMES_BEFORE}    ${{ str($names[0][0]).lower() }}
    Set Suite Variable    ${PORTAL_DB}    ${True}

Portal Suite Teardown
    [Documentation]    Close the browsers; when the run touched the database, give the admin back a plain (not
    ...    super-admin) account and the FPO its farmer-name setting, then disconnect.
    ...    Side effects: UPDATE users / fpos (only fields this suite changed).
    Close Browser    ALL
    ${db}=    Get Variable Value    ${PORTAL_DB}    ${False}
    IF    ${db}
        Execute Sql String    UPDATE users SET is_super_admin = false WHERE phone = '${ADMIN}'
        Set FPO Farmer Names    ${FPO_NAMES_BEFORE}
        Disconnect From Database
    END

Set FPO Farmer Names
    [Documentation]    Set the admin's FPO `public_show_farmer_names` in the database (no API route changes it; the
    ...    Settings switch is read-only). Args: ${value} true | false. Side effects: UPDATE fpos.
    [Arguments]    ${value}
    Portal Database
    Execute Sql String    UPDATE fpos SET public_show_farmer_names = ${value} WHERE id IN (SELECT m.fpo_id FROM memberships m JOIN users u ON u.id = m.user_id WHERE u.phone = '${ADMIN}')

QA Villages
    [Documentation]    Two villages with random LGD codes in blocks "QA Block One/Two <tag>" of Virudhunagar, imported
    ...    through the Villages tab once per run (P08 setup, P06 village filter). The import is super-admin only, so
    ...    the admin gets that flag in the database first (as the WEB Verifier did; the teardown removes it) and a
    ...    full page load picks it up in a refreshed token.
    ...    Returns: {"tag", "alpha", "beta" (LGD codes), "alpha_id" (village id)}.
    ...    Side effects: UPDATE users; two villages rows; sets ${VILLAGES}.
    ${known}=    Get Variable Value    ${VILLAGES}
    IF    $known is not None    RETURN    ${known}
    Portal Database
    ${tag}=    Evaluate    uuid.uuid4().hex[:4]
    ${alpha}=    Evaluate    str(random.randrange(900000, 989998))
    ${beta}=    Evaluate    str(int($alpha) + 1)
    Execute Sql String    UPDATE users SET is_super_admin = true WHERE phone = '${ADMIN}'
    ${csv}=    Catenate    SEPARATOR=\r\n    lgd_code,name_en,name_local,block,taluk,district,state,pincode
    ...    ${alpha},QA Village Alpha ${tag},,QA Block One ${tag},QA Taluk,Virudhunagar,Tamil Nadu,626001
    ...    ${beta},QA Village Beta ${tag},,QA Block Two ${tag},QA Taluk,Virudhunagar,Tamil Nadu,626002    ${EMPTY}
    Create File    ${OUTPUT DIR}/qa-villages.csv    ${csv}
    Go To    ${PORTAL_BASE}/uploads
    Click    role=tab[name="Villages"]
    Upload File By Selector    internal:label=/^CSV file/    ${OUTPUT DIR}/qa-villages.csv
    Click    role=button[name=/^Import \\d+ rows?$/]
    Wait For Elements State    text=/rows? imported\\./    visible
    ${id}=    Query    SELECT id FROM villages WHERE lgd_code = '${alpha}'
    ${villages}=    Create Dictionary    tag=${tag}    alpha=${alpha}    beta=${beta}    alpha_id=${{ str($id[0][0]) }}
    Set Suite Variable    ${VILLAGES}    ${villages}
    RETURN    ${villages}

Batch X Is Published
    [Documentation]    Assert the 320 kg batch of the P03/P04 tests exists and is published (P05/P06 use it).
    ...    Fails: those tests did not run first or did not publish it.
    # shortcut: P05/P06 reuse batch X from P03 create + P04 happy path; run the suite whole (as G4 does).
    Variable Should Exist    ${BATCH_X}    msg=Run the P03 create and P04 happy-path tests first: they publish batch X.
    ${batch}=    Call API    GET    /batches/${BATCH_X}[id]    ${ADMIN}    200
    Should Be Equal    ${batch.json()}[status]    published

Download From Button
    [Documentation]    Click a download button and save the file under ${OUTPUT DIR}/downloads.
    ...    Args: ${label} the button's name. Returns: {"saveAs", "suggestedFilename"}.
    ...    Fails: no download starts within the Browser timeout.
    [Arguments]    ${label}
    ${promise}=    Promise To Wait For Download    ${OUTPUT DIR}/downloads/${{ uuid.uuid4().hex }}
    Click    role=button[name="${label}"]
    ${file}=    Wait For    ${promise}
    RETURN    ${file}

Stage Tile Counts
    [Documentation]    Read the dashboard's stage tiles in farm order.
    ...    Returns: one "<n> done · <n> in progress · <n> not started" text per stage.
    ...    Fails: the "Stage progress (lots)" section is not shown.
    ${region}=    Set Variable    role=region[name="Stage progress (lots)"]
    Wait For Elements State    ${region} >> p:has-text(" done · ") >> nth=0    visible
    ${cells}=    Get Elements    ${region} >> p:has-text(" done · ")
    ${texts}=    Create List
    FOR    ${cell}    IN    @{cells}
        ${text}=    Get Text    ${cell}
        Append To List    ${texts}    ${text.strip()}
    END
    RETURN    ${texts}

Stage Tile Counts Should Be
    [Documentation]    Assert the stage tiles read exactly ${expected} (retry it while a filter reloads the tiles).
    ...    Args: ${expected} list of tile texts in farm order. Fails: they differ.
    [Arguments]    ${expected}
    ${shown}=    Stage Tile Counts
    Lists Should Be Equal    ${shown}    ${expected}

Rebuild And Wait
    [Documentation]    On the batch page of batch X press "Rebuild" and wait until the worker has built the new
    ...    page build (GET /v1/batches/{id}/builds). Fails: the build is not `built`.
    ...    Side effects: one page build; the preview reloads with it.
    ${builds}=    Call API    GET    /batches/${BATCH_X}[id]/builds    ${ADMIN}    200
    ${next}=    Evaluate    max(b["build_no"] for b in $builds.json()["items"]) + 1
    Click    role=button[name=/^Rebuild/]
    ${build}=    Wait For Build    ${BATCH_X}[id]    ${next}
    Should Be Equal    ${build}[status]    built    msg=${build}

Preview Should Show
    [Documentation]    Load batch X's page and assert on the text of its public-page preview iframe.
    ...    Args: ${operator} a Browser assertion operator (contains, not contains); ${text} the text.
    ...    Fails: the preview does not match within the Browser timeout.
    [Arguments]    ${operator}    ${text}
    Go To    ${PORTAL_BASE}/batches/${BATCH_X}[id]
    Get Text    iframe[title^="Preview of the public page"] >>> body    ${operator}    ${text}

Run Playwright Spec
    [Documentation]    Run one P07 Playwright spec in mock mode (`npx playwright test <spec>` in apps/portal; it
    ...    starts `npm run dev:mock` on :5174) with the JSON reporter.
    ...    Args: ${spec} e.g. e2e/chain.spec.ts. Returns: the parsed JSON report (stats, suites).
    ...    Fails: Playwright exits non-zero (its output is in the message).
    [Arguments]    ${spec}
    ${json}=    Set Variable    ${OUTPUT DIR}/playwright-${{ $spec.replace("/", "-") }}.json
    ${run}=    Run Process    npx    --no-install    playwright    test    ${spec}    --reporter\=line,json
    ...    cwd=${REPO_ROOT}/apps/portal    env:PLAYWRIGHT_JSON_OUTPUT_NAME=${json}    env:E2E_LIVE=0
    ...    stderr=STDOUT    timeout=25 min
    Log    ${run.stdout}
    Should Be Equal As Integers    ${run.rc}    0    msg=${run.stdout}[-3000:]
    ${report}=    Evaluate    json.loads(pathlib.Path($json).read_text("utf-8"))
    RETURN    ${report}
