*** Settings ***
Resource     ../../../resource.resource

*** Keywords ***
### KEYWORDS DE REQUISIÇÃO ###
Get Users
    ${response}=    GET    ${BASE_URL}/users    headers=${HEADERS}
    RETURN    ${response}

Get Users Without Token
    ${response}=    GET    ${BASE_URL}/users    expected_status=401
    ${error_msg}=    Set Variable    ${response.json()}[error]
    RETURN    ${error_msg}

Get Users With Invalid Key
    &{headers}=    Create Dictionary    
    ...    x-api-key=chave_invalida_123
    ${response}=    GET    ${BASE_URL}/users    
    ...    headers=${headers}    
    ...    expected_status=401
    ${error_msg}=    Set Variable    ${response.json()}[error]
    RETURN    ${error_msg}

Get Non Existent User
    ${response}=    GET    ${BASE_URL}/users/999999    headers=${HEADERS}    expected_status=404
    ${error_response}=    Set Variable    ${response.json()}
    RETURN    ${error_response}

Get Users With Invalid Request
    [Documentation]    Envia uma requisição POST com JSON inválido para gerar erro 400
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

### KEYWORDS DE VALIDAÇÃO ###
Validate Status Code 200
    [Arguments]    ${response}
    Status Should Be    200    ${response}

Validate Status Code 401
    [Arguments]    ${response}
    Should Be Equal    ${response}    Invalid token

Validate Status Code 404
    [Arguments]    ${response}
    Should Be Equal    ${response}[error]    Not Found
    Should Be Equal    ${response}[message]    Cannot GET /users/999999
    Should Be Equal    ${response}[statusCode]    ${404}

Validate Status Code 400
    [Arguments]    ${response}
    Should Be Equal    ${response}[error]    Bad Request
    Should Be Equal    ${response}[message]    Expected property name or '}' in JSON at position 1
    Should Be Equal    ${response}[statusCode]    ${400}

### KEYWORDS DE PERFORMANCE ###
Get Response Time For Users List
    [Documentation]    Executa a requisição GET /users e retorna o tempo de resposta.
    ...    Returns:
    ...        response: Objeto de resposta da requisição
    ...        response_time: Tempo de resposta em segundos
    ${start_time}=    Get Time    epoch
    ${response}=    Get Users
    ${end_time}=    Get Time    epoch
    ${response_time}=    Evaluate    ${end_time} - ${start_time}
    RETURN    ${response}    ${response_time}

Get Response Time For Single User
    [Documentation]    Executa a requisição GET /users/{id} e retorna o tempo de resposta.
    ...    Returns:
    ...        response: Objeto de resposta da requisição
    ...        response_time: Tempo de resposta em segundos
    ${start_time}=    Get Time    epoch
    ${response}=    Get Non Existent User
    ${end_time}=    Get Time    epoch
    ${response_time}=    Evaluate    ${end_time} - ${start_time}
    RETURN    ${response}    ${response_time}

Get Response Time For Invalid Token
    [Documentation]    Executa a requisição com token inválido e retorna o tempo de resposta.
    ...    Returns:
    ...        response: Objeto de resposta da requisição
    ...        response_time: Tempo de resposta em segundos
    ${start_time}=    Get Time    epoch
    ${response}=    Get Users With Invalid Key
    ${end_time}=    Get Time    epoch
    ${response_time}=    Evaluate    ${end_time} - ${start_time}
    RETURN    ${response}    ${response_time}

### KEYWORDS DE UTILIDADE ###
Validate Response Time
    [Arguments]    ${response_time}    ${sla_limit}=1
    [Documentation]    Valida se o tempo de resposta está dentro do limite do SLA.
    ...    Args:
    ...        response_time: Tempo de resposta em segundos
    ...        sla_limit: Limite máximo aceitável em segundos (default: 1)
    Should Be True    ${response_time} < ${sla_limit}
    ...    Response time of ${response_time} seconds exceeded the SLA of ${sla_limit} second(s)

Validate Response Has Content
    [Arguments]    ${response}
    Should Not Be Empty    ${response.content}    Response body should not be empty

Validate Response Schema
    [Arguments]    ${response}    ${schema_file}
    ${json_schema}=    Get File    ${EXECDIR}/resources/json/${schema_file}
    ${schema}=    Evaluate    json.loads('''${json_schema}''')    json
    ${response_json}=    Set Variable    ${response.json()}
    ${is_valid}=    Evaluate    jsonschema.validate(${response_json}, ${schema})    modules=jsonschema
    Should Be Equal    ${is_valid}    ${None}

