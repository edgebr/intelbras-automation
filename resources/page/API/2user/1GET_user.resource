*** Settings ***
Resource     ../../../resource.resource

*** Keywords ***
Get Users
    ${response}=    GET    ${BASE_URL}/users    headers=${HEADERS}
    RETURN    ${response}

Get Users Without Token
    ${response}=    Run Keyword And Return Status    GET    ${BASE_URL}/users
    ${actual_response}=    Run Keyword And Expect Error    HTTPError: 401*    GET    ${BASE_URL}/users
    RETURN    ${actual_response}

Validate Status Code 200
    [Arguments]    ${response}
    Status Should Be    200    ${response}

Validate Status Code 401
    [Arguments]    ${response}
    Should Contain    ${response}    HTTPError: 401 Client Error: Unauthorized

Validate Response Has Content
    [Arguments]    ${response}
    Should Not Be Empty    ${response.content}    Response body should not be empty