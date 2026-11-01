*** Settings ***
Documentation       Registry and PostGIS geo (plan §7.1 B03) plus config-driven fields, masters and imports (B13).
...                 Serves: FR-8, FR-23, FR-24, FR-25, FR-27, FR-28, FR-31, FR-32, FR-70; gate G2.
...                 Live procedures: docs/agents/qa/B03.md (live_geo.py near-edge point), B13.md (live_b13.py,
...                 one-off api containers with a scratch config). Plots go to the run's QA farmer; the B13
...                 config lines start throw-away api containers through ${COMPOSE} (needs docker).
Resource            ../resources/common.resource
Library             String
Suite Setup         Connect To AgriTrace Database
Suite Teardown      Disconnect From Database
Test Tags           api


*** Variables ***
${REF_LAT}          9.559806
${REF_LON}          78.133521
${MADURAI_LAT}      9.9252
${MADURAI_LON}      78.1198
${TENANT}           tenants/VIRUDHAI_SCFC_VINOBA_BHAVA_FPO.yaml
# Host port of the one-off api container started with the flag switched on (B13 line 2).
${FLAG_ON_PORT}     %{FLAG_ON_PORT=8098}


*** Test Cases ***
Point 9.559806 78.133521 Is Inside The Fixture GI Region
    [Tags]    WP-B03    FR-28
    ${plot}=    New Plot    ${REF_LAT}    ${REF_LON}
    Should Be Equal    ${plot}[region_check][status]    inside
    Should Be Equal    ${plot}[location_status]    confirmed
    Should Be Equal As Numbers    ${plot}[region_check][buffer_m]    150

Point 100 m Outside With 150 m Buffer Is Near Edge
    [Tags]    WP-B03    FR-32
    # The point 100 m beyond the seeded outline's nearest edge, on the way to Madurai (B03 live_geo.py).
    ${row}=    Query    WITH r AS (SELECT geom::geometry g FROM gi_region_versions ORDER BY version_no DESC LIMIT 1), m AS (SELECT ST_SetSRID(ST_MakePoint(${MADURAI_LON}, ${MADURAI_LAT}), 4326) p), c AS (SELECT ST_ClosestPoint(ST_Boundary(r.g), m.p) cp, m.p FROM r, m) SELECT ST_Y(q::geometry), ST_X(q::geometry) FROM (SELECT ST_Project(cp::geography, 100, ST_Azimuth(cp, p)) q FROM c) z
    ${plot}=    New Plot    ${row}[0][0]    ${row}[0][1]
    Should Be Equal    ${plot}[region_check][status]    near_edge
    Should Be True    95 < ${plot}[region_check][distance_m] < 105
    Should Be Equal    ${plot}[location_status]    near_edge

Madurai Point Is Outside
    [Tags]    WP-B03    FR-28
    ${plot}=    New Plot    ${MADURAI_LAT}    ${MADURAI_LON}
    Should Be Equal    ${plot}[region_check][status]    outside
    Should Be Equal    ${plot}[location_status]    outside

Map Pin Plot Needs Review
    [Tags]    WP-B03    FR-70
    ${plot}=    New Plot    ${REF_LAT}    ${REF_LON}    pin_method=map_pin
    Should Be Equal    ${plot}[location_status]    needs_review
    Should Be Equal    ${plot}[location_method_label]    Map pin

Plot Correction Without Reason Returns 422
    [Tags]    WP-B03    FR-25
    ${plot}=    New Plot
    ${r}=    Call API    POST    /plots/${plot}[id]/correct    ${ADMIN}    expect=422    json=${{ {"farming_type": "irrigated"} }}
    Error Code Should Be    ${r}    reason_required
    ${r}=    Call API    POST    /plots/${plot}[id]/correct    ${ADMIN}    expect=200
    ...    json=${{ {"farming_type": "irrigated", "reason_code": "land_record_checked"} }}
    Should Be Equal As Integers    ${r.json()}[revision_no]    2

Cross FPO Plot Read Returns 404
    [Tags]    WP-B03    FR-24
    ${w}=    QA World
    ${other}=    Second FPO Admin
    Call API    GET    /plots/${w}[plot][id]    ${other}    expect=404
    Call API    GET    /farmers/${w}[farmer][id]    ${other}    expect=404
    Call API    GET    /plots/${w}[plot][id]    ${ADMIN}    expect=200

FPO Admin Uploading GI Region Returns 403
    [Tags]    WP-B03    FR-31
    ${w}=    QA World
    ${region}=    Call API    GET    /gi-tags/${w}[gi_tag]/region    ${ADMIN}    expect=200
    ${v}=    Set Variable    ${region.json()}[version]
    ${body}=    Create Dictionary    geometry=${{ {"type": "MultiPolygon", "coordinates": [$region.json()["geometry"]["coordinates"]]} }}
    ...    tolerance_buffer_m=150    taluks=${v}[taluks]    source_ref=QA Robot upload attempt    licence=${v}[licence]
    ...    confidence=fixture    attribution=QA    share_alike=${False}
    ${r}=    Call API    POST    /gi-tags/${w}[gi_tag]/region-versions    ${ADMIN}    expect=403    json=${body}
    Error Code Should Be    ${r}    forbidden

Disabling Soil Type In A Tenant File Hides The Field For That FPO Only
    [Tags]    WP-B13    FR-23
    ${demo}=    Plot Field Names    ${ADMIN}
    List Should Not Contain Value    ${demo}    soil_type
    ${other}=    Second FPO Admin
    ${other_fields}=    Plot Field Names    ${other}
    List Should Contain Value    ${other_fields}    soil_type

ID Document Upload Endpoint Follows The Feature Flag
    [Tags]    WP-B13    FR-23
    ${w}=    QA World
    ${doc}=    Create Dictionary    doc_type=aadhaar    content_type=image/jpeg    sha256=${{ "0" * 64 }}
    ${features}=    Call API    GET    /config/features    ${ADMIN}    expect=200
    Should Be Equal    ${features.json()}[id_document_capture]    ${False}
    ${r}=    Call API    POST    /farmers/${w}[farmer][id]/id-documents    ${ADMIN}    expect=404    json=${doc}
    Error Code Should Be    ${r}    feature_disabled
    # The same image with the tenant file switching the flag on: the route is exposed (validation runs).
    ${cfg}=    Scratch Config    on    features:\n    features:\n${SPACE}${SPACE}id_document_capture: true\n
    ${run}=    Compose    run    -d    --rm    --no-deps    -p    ${FLAG_ON_PORT}:8000    -v    ${cfg}:/app/config:ro    api
    Should Be Equal As Integers    ${run}[rc]    0    msg=${run}[out]
    ${name}=    Evaluate    $run["stdout"].strip().splitlines()[-1]
    TRY
        ${on}=    Set Variable    http://localhost:${FLAG_ON_PORT}/v1
        Wait Until Keyword Succeeds    90s    3s    GET    ${on}/healthz    expected_status=200
        ${h}=    Login As    ${ADMIN}
        ${f}=    GET    ${on}/config/features    headers=${h}    expected_status=200
        Should Be Equal    ${f.json()}[id_document_capture]    ${True}
        ${r}=    POST    ${on}/farmers/${w}[farmer][id]/id-documents    json=${doc}    headers=${h}    expected_status=422
        Error Code Should Be    ${r}    validation_error
    FINALLY
        Run Process    docker    rm    -f    ${name}
    END

Farmer CSV With 2 Bad Rows Accepts The Rest Without Partial Writes
    [Tags]    WP-B13    FR-8
    ${tag}=    Evaluate    uuid.uuid4().hex[:6]
    ${p1}=    New Phone
    ${p3}=    New Phone
    ${p5}=    New Phone
    ${p2}=    New Phone
    ${csv}=    Catenate    SEPARATOR=\n    name,name_local,phone,lang,gi_authorised_user_no,no_smartphone,village_lgd_code
    ...    QA CSV ${tag} One,,${p1},ta,,false,    ,,${p2},ta,,false,
    ...    QA CSV ${tag} Three,,${p3},en,,false,    QA CSV ${tag} Four,,12345,ta,,false,    QA CSV ${tag} Five,,${p5},ta,,true,
    FOR    ${dry}    ${written}    IN    true    0    false    3
        ${r}=    Call API    POST    /imports/farmers    ${ADMIN}    expect=200    params=${{ {"dry_run": $dry} }}
        ...    files=${{ {"file": ("farmers.csv", $csv.encode() + b"\n", "text/csv")} }}
        Should Be Equal As Integers    ${r.json()}[accepted]    3
        ${rejected}=    Evaluate    [(x["row"], x["code"]) for x in $r.json()["rejected"]]
        Should Be Equal    ${rejected}    ${{ [(3, "field_required"), (5, "import_row_invalid")] }}
        Check Row Count    SELECT 1 FROM farmers WHERE name LIKE 'QA CSV ${tag} %'    ==    ${written}
    END
    Check Row Count    SELECT 1 FROM farmers WHERE name = 'QA CSV ${tag} Four'    ==    0

Virudhunagar Region Build Covers The Reference Point With Provenance
    [Tags]    WP-B13    FR-27
    # build_virudhunagar.py downloads nothing (its README: a person fetches geoBoundaries); this checks the
    # Verifier's build of geoBoundaries gbOpen IND @ 9469f09 (docs/agents/qa/B13/gi883) with the script itself.
    ${root}=    Normalize Path    ${REPO_ROOT}
    ${gi}=    Set Variable    ${root}/docs/agents/qa/B13/gi883
    FOR    ${v}    IN    0    1
        ${run}=    Compose    run    --rm    --no-deps    -v    ${root}/infra/scripts/gi_boundary:/gi:ro
        ...    -v    ${gi}:/data:ro    api    python    /gi/build_virudhunagar.py    --check-point    ${REF_LAT},${REF_LON}
        ...    --file    /data/gi_region_v${v}.geojson
        Should Be Equal As Integers    ${run}[rc]    0    msg=${run}[out]
        Should Contain    ${run}[out]    is inside
        ${geo}=    Evaluate    json.loads(pathlib.Path($gi, "gi_region_v${v}.geojson").read_text())
        Length Should Be    ${geo}[features]    1
        ${props}=    Set Variable    ${geo}[features][0][properties]
        Should Be Equal    ${geo}[features][0][geometry][type]    MultiPolygon
        Should Contain    ${props}[source_ref]    geoBoundaries
        Should Be Equal    ${props}[licence]    ODbL-1.0
    END

Field YAML Failing Its Schema Stops The App With A Clear Message
    [Tags]    WP-B13    FR-23
    ${cfg}=    Scratch Config    bad    enabled: false    enabled: maybe
    ${run}=    Compose    run    --rm    --no-deps    -v    ${cfg}:/app/config:ro    api
    Should Be Equal As Integers    ${run}[rc]    3    msg=${run}[out]
    Should Contain    ${run}[out]    ConfigInvalid: /app/config/${TENANT}
    Should Contain    ${run}[out]    fields.plot.soil_type.enabled
    Should Contain    ${run}[out]    Application startup failed


*** Keywords ***
Plot Field Names
    [Documentation]    Names of the plot fields GET /v1/config/fields lists for a user's FPO (B13).
    ...    Args: ${phone} the caller. Returns: the list of field names.
    [Arguments]    ${phone}
    ${r}=    Call API    GET    /config/fields    ${phone}    expect=200    params=${{ {"entity": "plot"} }}
    ${names}=    Evaluate    [f["name"] for f in $r.json()["plot"]]
    RETURN    ${names}

Scratch Config
    [Documentation]    Copy apps/api/config to ${OUTPUT DIR}/cfg-<name> and replace text in the demo tenant file.
    ...    Args: ${name} folder suffix; ${old} / ${new} the text to replace (first occurrence).
    ...    Returns: the folder path, to mount at /app/config. Fails: ${old} is not in the tenant file.
    [Arguments]    ${name}    ${old}    ${new}
    ${dir}=    Set Variable    ${OUTPUT DIR}/cfg-${name}
    Remove Directory    ${dir}    recursive=True
    Copy Directory    ${REPO_ROOT}/apps/api/config    ${dir}
    ${text}=    Get File    ${dir}/${TENANT}
    Should Contain    ${text}    ${old}
    ${text}=    Replace String    ${text}    ${old}    ${new}    count=1
    Create File    ${dir}/${TENANT}    ${text}
    RETURN    ${dir}
