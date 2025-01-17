*** Settings ***
Resource     ../../../resource.resource

*** Keywords ***
Get Users
    ${response}=    GET    ${BASE_URL}/users    headers=${HEADERS}
    RETURN    ${response}

Get Users Without Token
    ${response}=    GET    ${BASE_URL}/users    expected_status=401
    ${error_msg}=    Set Variable    ${response.json()}[error]
    RETURN    ${error_msg}

Validate Status Code 200
    [Arguments]    ${response}
    Status Should Be    200    ${response}

Validate Status Code 401
    [Arguments]    ${response}
    Should Be Equal    ${response}    Invalid token

Validate Status Code 403
    [Arguments]    ${response}
    Should Contain    ${response}    HTTPError: 403 Client Error: Forbidden

Validate Response Has Content
    [Arguments]    ${response}
    Should Not Be Empty    ${response.content}    Response body should not be empty

Get Users With Invalid Key
    &{headers}=    Create Dictionary    
    ...    x-api-key=chave_invalida_123
    ${response}=    GET    ${BASE_URL}/users    
    ...    headers=${headers}    
    ...    expected_status=401
    ${error_msg}=    Set Variable    ${response.json()}[error]
    RETURN    ${error_msg}

Get Users With Invalid Permissions
    &{headers}=    Create Dictionary    
    ...    x-api-key=${INVALID_PERMISSION_TOKEN}    
    ${response}=    GET    ${BASE_URL}/users    headers=${headers}    expected_status=403
    RETURN    ${response}

Get Non Existent User
    ${response}=    GET    ${BASE_URL}/users/999999    headers=${HEADERS}    expected_status=404
    ${error_response}=    Set Variable    ${response.json()}
    RETURN    ${error_response}

Validate Status Code 404
    [Arguments]    ${response}
    Should Be Equal    ${response}[error]    Not Found
    Should Be Equal    ${response}[message]    Cannot GET /users/999999
    Should Be Equal    ${response}[statusCode]    ${404}

Get users with invalid request error - Status Code 400
    ${malformed_json}=    Set Variable    {invalid_json
    &{headers}=    Create Dictionary    
    ...    x-api-key=${HEADERS}[x-api-key]    
    ...    Content-Type=application/json
    ${response}=    POST    ${BASE_URL}/users    
    ...    headers=${headers}    
    ...    data=${malformed_json}
    ...    expected_status=400
    ${error_response}=    Set Variable    ${response.json()}
    RETURN    ${error_response}

Get Users With Server Error
    &{headers}=    Create Dictionary    
    ...    x-api-key=${HEADERS}[x-api-key]    
    ...    Content-Type=application/json
    ${unicode_overflow}=    Evaluate    "\\u0001" * 1000 + "\\u0000" * 1000
    ${payload}=    Set Variable    {"name": "${unicode_overflow}", "email": "test@test.com", "password": "test123", "data": {"type": "Buffer", "data": [255, 255, 255, 255]}}
    ${response}=    Run Keyword And Return Status    
    ...    POST    ${BASE_URL}/users    
    ...    headers=${headers}    
    ...    data=${payload}
    ${actual_response}=    Run Keyword And Expect Error    HTTPError: 500*    
    ...    POST    ${BASE_URL}/users    
    ...    headers=${headers}    
    ...    data=${payload}
    RETURN    ${actual_response}

Validate Status Code 400
    [Arguments]    ${response}
    Should Be Equal    ${response}[error]    Bad Request
    Should Be Equal    ${response}[message]    Expected property name or '}' in JSON at position 1
    Should Be Equal    ${response}[statusCode]    ${400}

Validate Status Code 500
    [Arguments]    ${response}
    Should Contain    ${response}    HTTPError: 500 Client Error: Internal Server Error

Validate Response Schema
    [Arguments]    ${response}    ${schema_file}
    ${json_schema}=    Get File    ${EXECDIR}/resources/json/${schema_file}
    ${schema}=    Evaluate    json.loads('''${json_schema}''')    json
    ${response_json}=    Set Variable    ${response.json()}
    ${is_valid}=    Evaluate    jsonschema.validate(${response_json}, ${schema})    modules=jsonschema
    Should Be Equal    ${is_valid}    ${None}

Validate Error Message
    [Arguments]    ${response}    ${expected_status}    ${expected_message}
    Should Contain    ${response}    ${expected_status}
    Should Contain    ${response}    ${expected_message}

Get Error Message From Response
    [Arguments]    ${response}
    ${error_message}=    Set Variable    ${response.json()}[message]
    RETURN    ${error_message}

Get Status Message From Response
    [Arguments]    ${response}
    ${status_message}=    Set Variable    ${response.json()}[status]
    RETURN    ${status_message}

Validate Error Message Format
    [Documentation]    Valida o formato padrão das mensagens de resposta.
    ...    Verifica se contém os campos necessários e se segue o padrão esperado.
    [Arguments]    ${response}
    ${is_json}=    Run Keyword And Return Status    
    ...    Evaluate    isinstance(${response}, object) and hasattr(${response}, 'json')
    
    IF    ${is_json}
        ${response_body}=    Set Variable    ${response.json()}
        Dictionary Should Contain Key    ${response_body}    status
        Dictionary Should Contain Key    ${response_body}    message
    ELSE
        Should Match Regexp    ${response}    .*(?:OK|Bad Request|Unauthorized|Not Found).*
        Should Not Be Empty    ${response}
    END

Validate Response Time
    [Arguments]    ${response_time}    ${sla_limit}=1
    [Documentation]    Valida se o tempo de resposta está dentro do limite do SLA.
    ...    Args:
    ...        response_time: Tempo de resposta em segundos
    ...        sla_limit: Limite máximo aceitável em segundos (default: 1)
    Should Be True    ${response_time} < ${sla_limit}
    ...    Response time of ${response_time} seconds exceeded the SLA of ${sla_limit} second(s)

