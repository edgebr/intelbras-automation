*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    JSONLibrary
Resource    ../../../resource.resource

*** Variables ***
${DEVICE_ENDPOINT}    ${BASE_URL}/devices
${SCHEMA_DIR}    ${CURDIR}/../../../json
${SCHEMA_PATH}    ${CURDIR}/../../../json/GET_DEVICES/test_schema_get_200_device.json

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
    ${invalid_id}=    Set Variable    0
    ${response}=    GET On Session    
    ...    alias=device    
    ...    url=${DEVICE_ENDPOINT}/${invalid_id}    
    ...    headers=${HEADERS}    
    ...    expected_status=404
    RETURN    ${response}

Validate Device Status Code 404
    [Arguments]    ${response}
    [Documentation]    Valida que o código de status é 404 e a mensagem de erro
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal As Strings    ${status_code}    404
    
    ${response_json}=    Set Variable    ${response.json()}
    Should Be Equal    ${response_json}[error]    Device not found

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
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal As Strings    ${status_code}    500
    
    ${response_json}=    Set Variable    ${response.json()}
    Should Be Equal    ${response_json}[error]    Internal Server Error
    Should Be Equal    ${response_json}[message]    An unexpected error occurred
    Should Be Equal    ${response_json}[statusCode]    ${500}

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

Get Devices Without Api Key
    [Documentation]    Executa GET /devices sem o header x-api-key
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${response}=    GET On Session    
    ...    alias=device_no_auth    # Mudando para usar a sessão sem autenticação
    ...    url=${DEVICE_ENDPOINT}    
    ...    headers=${headers}    
    ...    expected_status=401
    RETURN    ${response}

Validate Device Status Code 401
    [Arguments]    ${response}
    [Documentation]    Valida que o código de status é 401 e as mensagens de erro
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal As Strings    ${status_code}    401
    
    ${response_json}=    Set Variable    ${response.json()}
    Log    Response Status Code: ${status_code}    # Log do status code
    Log    Response Body: ${response_json}    # Log do corpo completo
    Log    Response Type: ${response_json.__class__.__name__}    # Log do tipo da resposta
    Log    Response Keys: ${response_json.keys()}    # Log das chaves disponíveis
    
    # Validação específica para resposta 401 sem x-api-key
    Dictionary Should Contain Key    ${response_json}    error
    Should Be Equal    ${response_json}[error]    Invalid token

Get Devices With Invalid Api Key
    [Documentation]    Executa GET /devices com um x-api-key inválido
    ${invalid_headers}=    Create Dictionary    
    ...    Content-Type=application/json
    ...    x-api-key=invalid_key_123
    ${response}=    GET On Session    
    ...    alias=device_no_auth    # Usando a sessão sem autenticação
    ...    url=${DEVICE_ENDPOINT}    
    ...    headers=${invalid_headers}    
    ...    expected_status=401
    RETURN    ${response}

Get Devices With Valid Api Key
    [Documentation]    Executa GET /devices com um x-api-key válido
    ${valid_headers}=    Create Dictionary    
    ...    Content-Type=application/json
    ...    x-api-key=${HEADERS}[x-api-key]
    ${response}=    GET On Session    
    ...    alias=device_no_auth    # Usando a sessão sem autenticação
    ...    url=${DEVICE_ENDPOINT}    
    ...    headers=${valid_headers}    
    ...    expected_status=200
    RETURN    ${response}

Validate Device Schema
    [Arguments]    ${response}
    [Documentation]    Valida se o corpo da resposta segue o schema definido
    ${response_json}=    Set Variable    ${response.json()}
    ${json_schema}=    Load JSON From File    ${SCHEMA_PATH}
    
    # Verifica tipo da resposta e ajusta se necessário
    ${is_list}=    Evaluate    isinstance($response_json, list)
    ${response_to_validate}=    Run Keyword If    ${is_list}    Set Variable    ${response_json}
    ...    ELSE    Create List    ${response_json}
    
    # Valida campos obrigatórios e schema
    TRY
        FOR    ${device}    IN    @{response_to_validate}
            # Valida campos obrigatórios
            Dictionary Should Contain Key    ${device}    id
            Dictionary Should Contain Key    ${device}    serialId
            Dictionary Should Contain Key    ${device}    name
            Dictionary Should Contain Key    ${device}    blacklisted
            Dictionary Should Contain Key    ${device}    productCode
        END
        
        # Valida schema completo
        ${schema_is_valid}=    Evaluate    jsonschema.validate(instance=${response_to_validate}, schema=${json_schema})    modules=jsonschema
    EXCEPT    AS    ${error}
        FAIL    Schema validation failed: ${error}
    END

Get Device With Invalid Id
    [Arguments]    ${id}
    [Documentation]    Executa GET /devices com ID inválido (contendo espaço)
    ${response}=    GET On Session    
    ...    alias=device    
    ...    url=${DEVICE_ENDPOINT}/${id}    
    ...    headers=${HEADERS}    
    ...    expected_status=500
    RETURN    ${response}

Validate Device List
    [Arguments]    ${response}
    [Documentation]    Valida a lista de dispositivos retornada
    ${response_json}=    Set Variable    ${response.json()}
    
    # Valida que a resposta é uma lista não vazia
    Should Be True    isinstance($response_json, list)    Response should be a list
    Should Not Be Empty    ${response_json}    Device list should not be empty
    
    # Log informações úteis
    ${list_size}=    Get Length    ${response_json}
    Log    Total Devices: ${list_size}
    Log    First Device: ${response_json}[0]

### KEYWORDS DE PAGINAÇÃO ###

Get Devices With Pagination
    [Arguments]    ${page}    ${size}
    [Documentation]    Executa GET /devices com parâmetros de paginação
    ...    Issue: EDGE-001 - Endpoint não suporta paginação
    ${params}=    Create Dictionary    
    ...    page=${page}    
    ...    size=${size}
    ${response}=    GET On Session    
    ...    alias=device    
    ...    url=${DEVICE_ENDPOINT}    
    ...    headers=${HEADERS}    
    ...    params=${params}    
    ...    expected_status=any
    RETURN    ${response}

Validate Pagination Info
    [Arguments]    ${response}    ${expected_page}    ${expected_size}
    [Documentation]    Valida as informações de paginação na resposta
    ...    Issue: EDGE-001 - Endpoint não suporta paginação
    ${response_json}=    Set Variable    ${response.json()}
    
    # Valida estrutura da paginação
    Dictionary Should Contain Key    ${response_json}    content
    Dictionary Should Contain Key    ${response_json}    pageable
    Dictionary Should Contain Key    ${response_json}    totalElements
    Dictionary Should Contain Key    ${response_json}    totalPages
    Dictionary Should Contain Key    ${response_json}    number
    Dictionary Should Contain Key    ${response_json}    size
    Dictionary Should Contain Key    ${response_json}    first
    Dictionary Should Contain Key    ${response_json}    last
    
    # Valida valores específicos da página
    Should Be Equal As Integers    ${response_json}[number]    ${expected_page}
    Should Be Equal As Integers    ${response_json}[size]    ${expected_size}
    
    # Valida conteúdo
    ${content}=    Set Variable    ${response_json}[content]
    Length Should Be    ${content}    ${expected_size}
    
    # Log informações úteis
    Log    Total Elements: ${response_json}[totalElements]
    Log    Total Pages: ${response_json}[totalPages]
    Log    Current Page: ${response_json}[number]
    Log    Page Size: ${response_json}[size]