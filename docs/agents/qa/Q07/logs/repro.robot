*** Settings ***
Documentation    Q07-1 repro (scratch): a reload while the portal restores its session signs the web device out.
Library          Browser    timeout=20s    auto_closing_level=SUITE

*** Test Cases ***
Reload During Session Restore
    New Browser    chromium    headless=True
    New Context
    New Page    http://localhost:5183/
    Fill Text    internal:label="Mobile number"s    9000000001
    Click    role=button[name="Send code"]
    Fill Text    internal:label="SMS code"s    123456
    Click    role=button[name="Verify code"]
    Fill Text    internal:label="PIN"s    1234
    Click    role=button[name=/sign in$/i]
    Wait For Elements State    role=navigation[name="Main"]    visible
    FOR    ${i}    IN RANGE    5
        Go To    http://localhost:5183/ready-lots
        Reload
        ${nav}=    Get Element Count    role=navigation[name="Main"]
        Wait For Elements State    role=navigation[name="Main"] >> nth=0    visible    timeout=10s
        Log To Console    round ${i}: signed in
    END
