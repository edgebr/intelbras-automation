*** Settings ***
Library    RequestsLibrary
Library    Collections
Resource    ../../../resource.resource

*** Variables ***
${DEVICE_ENDPOINT}    ${BASE_URL}/devices

*** Keywords ***
Get Devices
    [Documentation]    Executa GET /devices para listar todos os dispositivos
    ${response}=    GET On Session    
    ...    alias=device    
    ...    url=${DEVICE_ENDPOINT}    
    ...    headers=${HEADERS}    
    ...    expected_status=200
    RETURN    ${response}

Get Devices Without Auth
    [Documentation]    Executa GET /devices sem token de autenticação
    ${response}=    GET On Session    
    ...    alias=device_no_auth    
    ...    url=${DEVICE_ENDPOINT}    
    ...    expected_status=401
    RETURN    ${response}

Get Devices With Invalid Params
    [Documentation]    Executa GET /devices com JSON inválido
    ${invalid_json}=    Set Variable    {invalid_json
    ${headers}=    Create Dictionary    
    ...    Content-Type=application/json    
    ...    x-api-key=${HEADERS}[x-api-key]
    ${response}=    GET On Session    
    ...    alias=device    
    ...    url=${DEVICE_ENDPOINT}    
    ...    headers=${headers}
    ...    data=${invalid_json}    
    ...    expected_status=400
    RETURN    ${response}

Validate Device Status Code 400
    [Arguments]    ${response}
    [Documentation]    Valida que o código de status é 400 e as mensagens de erro
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal As Strings    ${status_code}    400
    
    ${response_json}=    Set Variable    ${response.json()}
    Should Be Equal    ${response_json}[error]    Bad Request
    Should Be Equal    ${response_json}[message]    Expected property name or '}' in JSON at position 1
    Should Be Equal    ${response_json}[statusCode]    ${400}

Get Device Not Found
    [Documentation]    Executa GET /devices com ID inexistente
    ${invalid_id}=    Set Variable    999999
    ${response}=    GET On Session    
    ...    alias=device    
    ...    url=${DEVICE_ENDPOINT}/${invalid_id}    
    ...    headers=${HEADERS}    
    ...    expected_status=404
    RETURN    ${response}

Validate Device Status Code 404
    [Arguments]    ${response}
    [Documentation]    Valida que o código de status é 404 e as mensagens de erro
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal As Strings    ${status_code}    404
    
    ${response_json}=    Set Variable    ${response.json()}
    Should Be Equal    ${response_json}[message]    Cannot GET /devices/999999

Get Device Internal Server Error
    [Documentation]    Simula uma requisição que causa erro 500 no servidor
    ${invalid_headers}=    Create Dictionary    
    ...    x-api-key=${HEADERS}[x-api-key]
    ...    Content-Type=invalid/content-type
    ${response}=    GET On Session    
    ...    alias=device
    ...    url=${BASE_URL}/error500
    ...    headers=${invalid_headers}
    ...    expected_status=500
    ${error_response}=    Set Variable    ${response.json()}
    RETURN    ${error_response}

Validate Device Status Code 500
    [Arguments]    ${response}
    [Documentation]    Valida que o código de status é 500 e as mensagens de erro
    Should Be Equal    ${response}[error]    Internal Server Error
    Should Be Equal    ${response}[message]    An unexpected error occurred
    Should Be Equal    ${response}[statusCode]    ${500}

Get Device By Serial Id
    [Arguments]    ${serialId}
    [Documentation]    Executa GET /devices com filtro por serialId
    ${params}=    Create Dictionary    serialId=${serialId}
    ${response}=    GET On Session    
    ...    alias=device    
    ...    url=${DEVICE_ENDPOINT}    
    ...    headers=${HEADERS}    
    ...    params=${params}    
    ...    expected_status=200
    RETURN    ${response}

Validate Device Status Code 200
    [Arguments]    ${response}
    [Documentation]    Valida que o código de status é 200 e a estrutura da resposta
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal As Strings    ${status_code}    200
    
    ${response_json}=    Set Variable    ${response.json()}
    Should Not Be Empty    ${response_json}

Validate Device Serial Id
    [Arguments]    ${response}    ${serialId}
    [Documentation]    Valida que o dispositivo retornado tem o serialId correto
    ${response_json}=    Set Variable    ${response.json()}
    
    # Se a resposta for uma lista, pega o primeiro item
    ${device}=    Run Keyword If    isinstance($response_json, list)    
    ...    Set Variable    ${response_json}[0]
    ...    ELSE    Set Variable    ${response_json}
    
    Dictionary Should Contain Key    ${device}    serialId
    Should Be Equal As Strings    ${device}[serialId]    ${serialId}

Get And Store Serial Id
    [Documentation]    Executa GET /devices e armazena o serialId do primeiro dispositivo
    ${response}=    Get Devices
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal As Strings    ${status_code}    200
    
    ${response_json}=    Set Variable    ${response.json()}
    ${first_device}=    Set Variable    ${response_json}[0]
    Set Suite Variable    ${STORED_SERIAL_ID}    ${first_device}[serialId]