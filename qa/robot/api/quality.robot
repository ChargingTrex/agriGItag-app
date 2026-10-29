*** Settings ***
Documentation       Quality readings and the grade engine (plan §7.1 B05).
...                 Serves: FR-42, FR-46, FR-48, FR-49, FR-50; gate G2; BM-08.
...                 Placeholders are tagged not-ready and skip until B05 merges.
Resource            ../resources/common.resource
Test Tags           api


*** Test Cases ***
Stack Answers Before Quality Tests
    [Tags]    WP-B00    FR-33    smoke
    Stack Is Healthy

Moisture 9.8 Percent Grades Special
    [Tags]    WP-B05    FR-48    not-ready
    Not Ready    B05

Moisture 10.5 Percent Grades Standard
    [Tags]    WP-B05    FR-48    not-ready
    Not Ready    B05

Moisture 11.4 Percent Is Below Grade
    [Tags]    WP-B05    FR-48    not-ready
    Not Ready    B05

Visual 9.8 Percent Is Capped At Standard
    [Tags]    WP-B05    FR-48    not-ready
    Not Ready    B05

Missing Required Reading Is Incomplete
    [Tags]    WP-B05    FR-46    not-ready
    Not Ready    B05

Moisture Minus 1 Returns 422
    [Tags]    WP-B05    FR-50    not-ready
    Not Ready    B05

Expired Instrument Returns 422
    [Tags]    WP-B05    FR-42    not-ready
    Not Ready    B05

Grading 12.0 After Intake 10.0 Needs A Reason And Raises A Flag
    [Tags]    WP-B05    FR-50    not-ready
    Not Ready    B05

Declared Special Versus Computed Standard Raises Declared Above Computed
    [Tags]    WP-B05    FR-49    not-ready
    Not Ready    B05
