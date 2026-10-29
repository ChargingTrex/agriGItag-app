*** Settings ***
Documentation       Stack health: the B00 acceptance line "docker compose up -> /healthz {db,redis,s3: ok}".
...                 Serves: plan §7.1 B00, gate G0. Run by: CI job robot-smoke, Verifiers.
Resource            ../resources/common.resource
Test Tags           api    smoke


*** Test Cases ***
Healthz Reports Db Redis And S3 Ok
    [Documentation]    GET /v1/healthz returns 200 with db, redis and s3 all "ok".
    [Tags]    WP-B00    FR-33
    Stack Is Healthy
