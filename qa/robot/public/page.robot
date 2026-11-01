*** Settings ***
Documentation       Public batch page: render, privacy lint, HTML validity, size budgets, Lighthouse thresholds,
...                 backend-down serve (plan §7.4 W01-W03, §7.5 Q03). Serves: FR-5, FR-15, FR-16, FR-17, FR-19,
...                 FR-41, FR-58, FR-61, FR-63; gate G4; BM-03, BM-09, BM-16. Run by: W02 and Q03 Verifiers.
...                 Needs uv (builds fixtures/batch_sample.json into apps/public-page/out/site) and, for the
...                 html-validate and Lighthouse tests, `npm ci` in apps/public-page. Lighthouse tests are tagged
...                 needs-chrome and skip when lhci finds no Chrome (set CHROME_PATH). The W03 Tamil font test
...                 needs `rfbrowser init` (Browser library). The two Q03 tests (WP Q07 round 2) need the live
...                 stack: API_BASE, PUBLIC_BASE_URL and COMPOSE (they stop and restart its api and worker).
...                 Placeholders are tagged not-ready and skip until their WP merges.
Resource            ../resources/common.resource
Test Tags           public


*** Variables ***
${PAGE_APP}         ${REPO_ROOT}/apps/public-page
${SITE}             ${PAGE_APP}/out/site
${CANARIES}         ${PAGE_APP}/fixtures/canaries.json


*** Test Cases ***
Privacy Lint Passes The Clean Fixture And Catches The Dirty One
    [Documentation]    Real smoke test, no stack needed: infra/scripts/privacy-lint.py on qa/fixtures/privacy.
    [Tags]    WP-Q00    FR-16    BM-09    smoke
    ${lint}=    Set Variable    ${REPO_ROOT}/infra/scripts/privacy-lint.py
    ${clean}=    Run Process    ${{sys.executable}}    ${lint}    ${REPO_ROOT}/qa/fixtures/privacy/clean
    Should Be Equal As Integers    ${clean.rc}    0    msg=${clean.stdout}
    ${dirty}=    Run Process    ${{sys.executable}}    ${lint}    ${REPO_ROOT}/qa/fixtures/privacy/dirty
    Should Be Equal As Integers    ${dirty.rc}    1    msg=${dirty.stdout}

Fixture Renders Valid HTML
    [Documentation]    html-validate (.htmlvalidate.mjs: standard + a11y presets) reports 0 errors on the build.
    [Tags]    WP-W01    WP-W02    FR-16
    [Setup]    Public Page Fixture Is Built
    ${run}=    Run Page Tool    npx    --no-install    html-validate    out/site/index.html
    Should Be Equal As Integers    ${run.rc}    0    msg=${run.stdout}

Crop Name Is Bilingual
    [Documentation]    The heading shows the fixture's Tamil crop name, then the English one.
    [Tags]    WP-W01    FR-5
    [Setup]    Public Page Fixture Is Built
    ${record}=    Evaluate    json.loads(pathlib.Path($PAGE_APP, "fixtures", "batch_sample.json").read_text("utf-8"))
    ...    modules=json,pathlib
    ${html}=    Get File    ${SITE}/index.html
    Should Contain    ${html}
    ...    <h1><span lang="ta">${record}[product_name_local]</span> / <span lang="en">${record}[product_name_en]</span></h1>

Every Quantity Carries A Unit
    [Documentation]    Every <data class="q"> reads "<number> <unit>", e.g. "1,20,000 kg" or "31.25 %".
    [Tags]    WP-W01    FR-58
    [Setup]    Public Page Fixture Is Built
    ${facts}=    Read Public Page    ${SITE}/index.html
    Should Not Be Empty    ${facts}[quantities]
    FOR    ${quantity}    IN    @{facts}[quantities]
        Should Match Regexp    ${quantity}    ^-?[0-9][0-9,]*(\\.[0-9]+)? \\S+$
    END

Events Are In Date Order
    [Documentation]    In every timeline (each lot, processing) event start dates ascend.
    [Tags]    WP-W01    FR-63
    [Setup]    Public Page Fixture Is Built
    ${facts}=    Read Public Page    ${SITE}/index.html
    Should Not Be Empty    ${facts}[timelines]
    FOR    ${dates}    IN    @{facts}[timelines]
        ${ascending}=    Evaluate    sorted($dates)
        Lists Should Be Equal    ${dates}    ${ascending}
    END

No Temp Uploads Or Non Evidence Paths
    [Documentation]    No temporary path anywhere; every photo URL (img, source, photo link) is in evidence/.
    [Tags]    WP-W01    FR-61
    [Setup]    Public Page Fixture Is Built
    ${html}=    Get File    ${SITE}/index.html
    Should Not Contain    ${html}    temp_uploads
    Should Not Contain    ${html}    /tmp/
    ${facts}=    Read Public Page    ${SITE}/index.html
    Should Not Be Empty    ${facts}[photo_urls]
    FOR    ${url}    IN    @{facts}[photo_urls]
        Should Match Regexp    ${url}    ^https?://[^/\\s]+/(\\S*/)?evidence/\\S+$
    END

Built Fixture Passes Privacy Lint With Canaries
    [Documentation]    tools/check_output.sh (privacy-lint.py + every canary in fixtures/canaries.json) finds 0 hits.
    [Tags]    WP-W02    FR-16    BM-09
    [Setup]    Public Page Fixture Is Built
    ${run}=    Run Page Tool    bash    tools/check_output.sh    out/site
    Should Be Equal As Integers    ${run.rc}    0    msg=${run.stdout}
    Should Contain    ${run.stdout}    0 hit(s) in 2 file(s) scanned

Injected Phone Number Fails Privacy Lint
    [Documentation]    A copy of the build with the phone canary printed into it fails, and the log never
    ...    repeats the number (W02 acceptance "injected phone fails CI").
    [Tags]    WP-W02    FR-16    BM-09
    [Setup]    Public Page Fixture Is Built
    ${phone}=    Evaluate
    ...    next(c["value"] for c in json.loads(pathlib.Path($CANARIES).read_text("utf-8"))["canaries"] if c["kind"] == "phone")
    ...    modules=json,pathlib
    ${copy}=    Set Variable    ${OUTPUT DIR}/injected-phone
    Remove Directory    ${copy}    recursive=True
    Copy Directory    ${SITE}    ${copy}
    ${html}=    Get File    ${copy}/index.html
    Create File    ${copy}/index.html    ${{ $html.replace("</main>", "<p>" + $phone + "</p></main>") }}
    ${run}=    Run Page Tool    bash    tools/check_output.sh    ${copy}
    Should Be Equal As Integers    ${run.rc}    1    msg=${run.stdout}
    Should Contain    ${run.stdout}    : phone: <redacted>
    Should Contain    ${run.stdout}    : canary: <redacted>
    Should Not Contain    ${run.stdout}    ${phone}

Initial HTML CSS And JS Are Under 100 KB
    [Documentation]    `python -m agritrace_page check`: inline CSS < 12 KB, JS < 4 KB, index.html < 100 KB raw
    ...    (plan §13 E1). The first view loads only index.html (photos sit in closed <details>), so this
    ...    also bounds BM-03's 500 KB first-view transfer without a browser.
    [Tags]    WP-W02    FR-19    BM-03    BM-16
    [Setup]    Public Page Fixture Is Built
    ${run}=    Run Page Tool    uv    run    python    -m    agritrace_page    check    out/site
    Should Be Equal As Integers    ${run.rc}    0    msg=${run.stdout}
    Should Not Contain    ${run.stdout}    OVER BUDGET

Lighthouse 3G Performance Is At Least 90 With LCP At Most 2 s
    [Documentation]    lighthouserc.3g.yml: performance >= 0.90, total-byte-weight <= 500000 B, LCP <= 2000 ms
    ...    (median of 3 simulated runs). Reports in apps/public-page/out/lhci/3g/.
    [Tags]    WP-W02    FR-19    BM-03    needs-chrome
    [Setup]    Public Page Fixture Is Built
    Chrome Is Available For Lighthouse
    ${run}=    Run Page Tool    npx    --no-install    lhci    autorun    --config=lighthouserc.3g.yml
    Should Be Equal As Integers    ${run.rc}    0    msg=${run.stdout}

Lighthouse Normal 4G Transfers Under 100 KB With LCP At Most 2.5 s
    [Documentation]    lighthouserc.4g.yml (qa/robot/profiles.yaml normal_4g): total-byte-weight <= 102400 B,
    ...    LCP <= 2500 ms (median of 3 simulated runs). Reports in apps/public-page/out/lhci/4g/.
    [Tags]    WP-W02    FR-19    BM-16    needs-chrome
    [Setup]    Public Page Fixture Is Built
    Chrome Is Available For Lighthouse
    ${run}=    Run Page Tool    npx    --no-install    lhci    autorun    --config=lighthouserc.4g.yml
    Should Be Equal As Integers    ${run.rc}    0    msg=${run.stdout}

OG Tags Pass The Privacy Lint
    [Documentation]    The share tags (og:*, description, title) carry no farmer name, lot code or personal data:
    ...    they are written alone into a file that tools/check_output.sh (privacy-lint + every canary) scans.
    [Tags]    WP-W03    FR-41
    [Setup]    Public Page Fixture Is Built
    ${html}=    Get File    ${SITE}/index.html
    @{tags}=    Evaluate    re.findall(r"<meta [^>]*>|<title>[^<]*</title>", $html)    modules=re
    ${og}=    Evaluate    sorted(set(re.findall(r'property="(og:[a-z:]+)"', " ".join($tags))))    modules=re
    Should Contain    ${og}    og:title
    Should Contain    ${og}    og:description
    Should Contain    ${og}    og:type
    ${record}=    Evaluate    json.loads(pathlib.Path($PAGE_APP, "fixtures", "batch_sample.json").read_text("utf-8"))
    ...    modules=json,pathlib
    ${head}=    Catenate    SEPARATOR=\n    @{tags}
    # Opted-out lots have no farmer_name in the record; only the values present can leak.
    ${private}=    Evaluate    [v for lot in $record["lots"] for v in (lot.get("farmer_name"), lot.get("lot_code")) if v]
    Should Not Be Empty    ${private}
    FOR    ${value}    IN    @{private}
        Should Not Contain    ${head}    ${value}
    END
    ${dir}=    Set Variable    ${OUTPUT DIR}/og-tags
    Remove Directory    ${dir}    recursive=True
    Create File    ${dir}/head.html    <!doctype html><html><head>${head}</head><body></body></html>
    ${run}=    Run Page Tool    bash    tools/check_output.sh    ${dir}
    Should Be Equal As Integers    ${run.rc}    0    msg=${run.stdout}
    Should Contain    ${run.stdout}    0 hit(s) in 1 file(s) scanned

Tamil Renders With The System Font
    [Documentation]    At a 390 px phone width the page loads no web font (document.fonts is empty, no @font-face,
    ...    no stylesheet link), the body font stack names system fonts with Noto Sans Tamil, and the Tamil
    ...    heading is drawn (non-zero width).
    [Tags]    WP-W03    FR-5
    [Setup]    Public Page Fixture Is Built
    Import Library    Browser    auto_closing_level=TEST
    New Browser    chromium    headless=True
    New Context    viewport={'width': 390, 'height': 844}
    New Page    file://${SITE}/index.html
    ${facts}=    Evaluate JavaScript    ${None}
    ...    (() => ({fonts: document.fonts.size,
    ...    faces: [...document.styleSheets].flatMap((s) => [...s.cssRules]).filter((r) => r instanceof CSSFontFaceRule).length,
    ...    links: document.querySelectorAll('link[rel="stylesheet"]').length,
    ...    family: getComputedStyle(document.body).fontFamily,
    ...    tamil: document.querySelectorAll('[lang="ta"]').length,
    ...    width: document.querySelector('h1 [lang="ta"]').getBoundingClientRect().width}))()
    Log    ${facts}
    Should Be Equal As Integers    ${facts}[fonts]    0
    Should Be Equal As Integers    ${facts}[faces]    0
    Should Be Equal As Integers    ${facts}[links]    0
    Should Contain    ${facts}[family]    system-ui
    Should Contain    ${facts}[family]    Noto Sans Tamil
    Should Be True    ${facts}[tamil] > 0
    Should Be True    ${facts}[width] > 0
    [Teardown]    Close Browser

Page Is Served From Object Storage With The Backend Down
    [Documentation]    Live stack: publish a batch, stop api and worker, and the page, QR and data still load from
    ...    LocalStack S3 (D-007); the teardown starts them again and waits for healthz.
    [Tags]    WP-Q03    FR-15
    ${lot}=    Received Lot    20
    ${batch}=    Publish Batch    ${{ [$lot] }}
    ${stop}=    Compose    stop    api    worker
    Should Be Equal As Integers    ${stop}[rc]    0    msg=${stop}[out]
    ${down}=    Run Keyword And Return Status    GET    ${API_BASE}/healthz    timeout=5
    Should Not Be True    ${down}    msg=the API still answers with api stopped
    FOR    ${name}    ${type}    IN    index.html    text/html    qr.png    image/png    data.json    application/json
        ${r}=    GET    ${PUBLIC_BASE}/batches/${batch}[code]/${name}    expected_status=200
        Should Start With    ${r.headers}[content-type]    ${type}
    END
    [Teardown]    Start Api And Worker

Old Page Version Is Retrievable
    [Documentation]    Live stack: a rebuild writes a new version of the page; the older one is still served
    ...    anonymously with ?versionId= (S3 versioning, FR-17).
    [Tags]    WP-Q03    FR-17
    ${lot}=    Received Lot    20
    ${batch}=    Publish Batch    ${{ [$lot] }}
    ${r}=    Call API    POST    /batches/${batch}[id]/rebuild    ${ADMIN}    expect=202
    ${build}=    Wait For Build    ${batch}[id]    ${r.json()}[build_no]
    Should Be Equal    ${build}[status]    built    msg=${build}
    ${versions}=    S3 Versions    public-pages    batches/${batch}[code]/index.html
    Length Should Be    ${versions}    2
    ${old}=    Evaluate    [v["VersionId"] for v in $versions if not v["IsLatest"]][0]
    ${page}=    GET    ${PUBLIC_BASE}/batches/${batch}[code]/index.html    params=versionId=${old}    expected_status=200
    Should Start With    ${page.headers}[content-type]    text/html
    Should Contain    ${page.text}    ${batch}[code]


*** Keywords ***
Start Api And Worker
    [Documentation]    Start the stack's api and worker again (after the backend-down line) and wait until healthz
    ...    reports db, redis and s3 ok. Fails: not healthy within 180 s.
    Compose    start    api    worker
    Wait Until Keyword Succeeds    180s    5s    Stack Is Healthy

Public Page Fixture Is Built
    [Documentation]    Build fixtures/batch_sample.json into apps/public-page/out/site once per Robot run,
    ...    with the W01 CLI under uv. Fails: uv is missing or the build exits non-zero (the output is shown).
    ...    Side effects: overwrites out/site/index.html and data.json (git-ignored); sets ${PAGE_BUILT}.
    ${built}=    Get Variable Value    ${PAGE_BUILT}    ${False}
    IF    ${built}    RETURN
    ${run}=    Run Page Tool    uv    run    python    -m    agritrace_page    build
    ...    fixtures/batch_sample.json    out/site
    Should Be Equal As Integers    ${run.rc}    0    msg=${run.stdout}
    Set Global Variable    ${PAGE_BUILT}    ${True}

Run Page Tool
    [Documentation]    Run a command in apps/public-page, stderr merged into stdout.
    ...    Args: @{command} the program and its arguments (an `=` inside an argument stays literal).
    ...    Returns: the Process result (rc, stdout). Fails: only if the program cannot be started.
    [Arguments]    @{command}
    ${run}=    Run Process    @{command}    cwd=${PAGE_APP}    stderr=STDOUT
    RETURN    ${run}

Chrome Is Available For Lighthouse
    [Documentation]    Skip the current test unless `lhci healthcheck --fatal` finds Chrome (CHROME_PATH or an
    ...    installed Chrome) and the npm tools are installed. Side effects: none beyond lhci's own check.
    ${health}=    Run Page Tool    npx    --no-install    lhci    healthcheck    --fatal    --config=lighthouserc.3g.yml
    Skip If    ${health.rc} != 0    lhci found no Chrome or no npm tools (npm ci; set CHROME_PATH): ${health.stdout}
