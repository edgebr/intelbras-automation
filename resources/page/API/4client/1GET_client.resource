*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    String
Library    JSONLibrary
Resource    ../../../resource.resource

*** Variables ***


*** Keywords ***
### KEYWORDS DE REQUISIÇÃO ###
Get Clients
    [Arguments]    ${index}=${EMPTY}    ${args}=${EMPTY}
    [Documentation]    Executa GET /clients para listar todos os usuários
    ${response}=    GET On Session
    ...    alias=user
    ...    url=${BASE_URL}/clients
    ...    headers=${HEADERS}
    ...    expected_status=200
    RETURN    ${response}

Get Client By ID
    [Arguments]    ${client_id}
    [Documentation]    Executa GET /clients/{id} para buscar os detalhes de um cliente com ID específico
    ${response}=    GET On Session
    ...    alias=user
    ...    url=${BASE_URL}/clients/${client_id}
    ...    headers=${HEADERS}
    ...    expected_status=200
    RETURN    ${response}

Get Clients Without Token
    [Documentation]    Executa GET /clients sem token de autenticação
    ${headers}=    Create Dictionary

    ${response}=    GET On Session
    ...    alias=user_no_auth
    ...    url=${BASE_URL}/clients
    ...    headers=${headers}
    ...    expected_status=401

    RETURN    ${response}

Get Clients With Invalid Request
    [Documentation]    Envia uma requisição GET com id inválido para gerar erro 400
    ${invalid_id}=    Set Variable    invalid_id
    &{headers}=    Create Dictionary
    ...    x-api-key=${HEADERS}[x-api-key]
    ...    Content-Type=application/json

    ${response}=    GET On Session
    ...    alias=user
    ...    url=${BASE_URL}/clients/${invalid_id}
    ...    headers=${headers}
    ...    expected_status=400

    RETURN    ${response}

Get Non Existent Client
    [Documentation]    Executa GET /clients para um cliente inexistente
    ${response}=    GET On Session
    ...    alias=user
    ...    url=${BASE_URL}/clients/0
    ...    headers=${HEADERS}
    ...    expected_status=404
    RETURN    ${response}

Get Clients With Server Error
    [Documentation]    Simula uma requisição que causa erro 500 no servidor
    &{headers}=    Create Dictionary
    ...    x-api-key=${HEADERS}[x-api-key]
    ...    Content-Type=application/json
    ${response}=    GET On Session
    ...    alias=user
    ...    url=${BASE_URL}/clients/9999999999
    ...    headers=${headers}
    ...    expected_status=500
    ${error_response}=    Set Variable    ${response.json()}
    RETURN    ${error_response}

Get Clients With Invalid Key
    [Documentation]    Executa GET /clients com token inválido
    ${headers}=    Create Dictionary    x-api-key=invalid_key
    ${response}=    GET On Session
    ...    alias=user
    ...    url=${BASE_URL}/users
    ...    headers=${headers}
    ...    expected_status=401
    RETURN    ${response}

### KEYWORDS DE VALIDAÇÃO ###
Validate Status Code 200 - client
    [Arguments]    ${response}
    Status Should Be    200    ${response}

Validate Status Code 401 - client
    [Arguments]    ${response}
    [Documentation]    Valida que a resposta tem status code 401
    Status Should Be    401    ${response}

    # Valida mensagem de erro
    ${body}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${body}    error
    Should Be Equal    ${body}[error]    Invalid token

    Log    Status code 401 validado com sucesso    level=DEBUG

Validate Status Code 400 - client
    [Arguments]    ${response}
    [Documentation]    Valida que o código de status é 400 e as mensagens de erro
    Status Should Be    400    ${response}

    ${response_json}=    Set Variable    ${response.json()}
    Should Be Equal    ${response_json}[error]    id must be an integer

Validate Status Code 404 - client
    [Arguments]    ${response}
    [Documentation]    Valida que o código de status é 404 e as mensagens de erro
    Status Should Be    404    ${response}

    ${response_json}=    Set Variable    ${response.json()}
    Should Be Equal    ${response_json}[error]    Client not found

Validate Status Code 500 - client
    [Arguments]    ${response}
    Should Be Equal    ${response}[message]    Internal server error
    Should Be Equal    ${response}[statusCode]    ${500}

Validate Response Has Content - client
    [Arguments]    ${response}
    ${response_content}=    Set Variable    ${response.json()}
    Should Not Be Empty    ${response_content}

Validate Error Message - client
    [Arguments]    ${response}    ${expected_message}
    [Documentation]    Valida a mensagem de erro na resposta
    ${body}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${body}    error
    Should Be Equal    ${body}[error]    ${expected_message}

Log Response Details - client
    [Arguments]    ${response}
    [Documentation]    Registra os detalhes da resposta nos logs
    ${response_json}=    Set Variable    ${response.json()}

    Log    Status Code: ${response.status_code}
    Log    Headers: ${response.headers}
    Log    Body: ${response_json}

Validate Json Against Schema
    [Arguments]    ${json_data}    ${schema_path}
    [Documentation]    Valida um JSON contra um schema
    ...    Args:
    ...        json_data: Dados JSON a serem validados
    ...        schema_path: Caminho para o arquivo de schema JSON
    
    # Carrega o schema do arquivo
    ${schema}=    Load JSON From File    ${schema_path}
    
    # Valida o JSON contra o schema
    Validate JSON By Schema    ${json_data}    ${schema}
    
    # Log para debug
    Log    JSON validado com sucesso contra o schema: ${schema_path}    DEBUG

Validate Response Schema - client
    [Arguments]    ${response}    ${schema_file}
    [Documentation]    Valida o schema do response contra o arquivo de schema JSON
    ${response_json}=    Set Variable    ${response.json()}
    
    # Ajusta o caminho do schema para usar o diretório correto
    ${schema_path}=    Set Variable    ${CURDIR}/../../../../json/${schema_file}
    
    # Valida o schema
    Validate Json Against Schema    ${response_json}    ${schema_path}
    Log    Schema validation completed successfully