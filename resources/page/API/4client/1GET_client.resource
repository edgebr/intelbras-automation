*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    String
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
    [Arguments]    ${client_id}    ${expected_status}
    [Documentation]    Executa GET /clients/{id} para buscar os detalhes de um cliente com ID específico
    ${response}=    GET On Session
    ...    alias=user
    ...    url=${BASE_URL}/clients/${client_id}
    ...    headers=${HEADERS}
    ...    expected_status=${expected_status}
    RETURN    ${response}

Get Clients With Pagination
    [Arguments]    ${page}=1    ${per_page}=10
    [Documentation]    Executa GET /clients com paginação
    ${headers}=    Create Dictionary    x-api-key=${HEADERS}[x-api-key]
    ${params}=    Create Dictionary
    ...    page=${page}
    ...    per_page=${per_page}
    ${response}=    GET On Session
    ...    alias=user
    ...    url=${BASE_URL}/clients
    ...    headers=${headers}
    ...    params=${params}
    ...    expected_status=any
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
Validate First Page Response - client
    [Arguments]    ${response}
    Status Should Be    200    ${response}
    ${body}=    Set Variable    ${response.json()}
    Log    Response body: ${body}    DEBUG

    # Validar que a lista não está vazia
    Should Not Be Empty    ${body}

    # Validar o primeiro usuário da lista
    ${first_client}=    Set Variable    ${body}[0]
    Dictionary Should Contain Key    ${first_client}    id
    Dictionary Should Contain Key    ${first_client}    clientKey
    Dictionary Should Contain Key    ${first_client}    email
    Dictionary Should Contain Key    ${first_client}    enabled
    Dictionary Should Contain Key    ${first_client}    applicationId
    Dictionary Should Contain Key    ${first_client}    createdAt
    Dictionary Should Contain Key    ${first_client}    updatedAt
    Dictionary Should Contain Key    ${first_client}    groups

Validate Second Page Response - client
    [Arguments]    ${response}
    [Documentation]    Valida a resposta da segunda página
    Status Should Be    200    ${response}

    ${json}=    Set Variable    ${response.json()}
    Should Be True    isinstance(${json}, list)    A resposta deve ser uma lista
    Should Not Be Empty    ${json}    A lista de clientes não pode estar vazia

    # Obtém a primeira página para comparação
    ${first_page}=    Get Clients With Pagination    page=1
    ${first_page_json}=    Set Variable    ${first_page.json()}

    # Verifica se a paginação está implementada
    ${pagination_implemented}=    Run Keyword And Return Status
    ...    Should Not Be Equal    ${json}    ${first_page_json}    msg=Segunda página igual à primeira

    IF    not ${pagination_implemented}
        Log    Known Issue: API-123 - Paginação não implementada [CONSYS-196]    WARN
        Log    O endpoint não está implementando os parâmetros page e per_page    WARN
        Log    Atualmente retorna todos os registros independente da página solicitada    WARN
        Log    Comportamento esperado:    WARN
        Log    - Deve retornar apenas os registros da página solicitada    WARN
        Log    - Deve respeitar o limite de registros por página (per_page)    WARN
        Log    - Deve retornar lista vazia para páginas sem registros    WARN
        Skip    Known Issue: API-123 - Paginação não implementada [CONSYS-196]. O endpoint não processa os parâmetros page e per_page corretamente.
    END

    # Valida a estrutura dos itens
    FOR    ${user}    IN    @{json}
        Validate User Item Structure    ${user}
    END

Validate Empty Page Response - client
    [Arguments]    ${response}
    Status Should Be    200    ${response}
    ${json}=    Set Variable    ${response.json()}

    # Valida que é uma lista vazia
    Should Be True    isinstance(${json}, list)    A resposta deve ser uma lista
    Should Be Empty    ${json}    A lista de usuários deve estar vazia

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

Validate Response Schema - client
    [Arguments]    ${response}    ${schema_file}
    [Documentation]    Valida o schema do response contra o arquivo de schema JSON
    ${response_json}=    Set Variable    ${response.json()}
    ${schema_path}=    Set Variable    ${CURDIR}/../../../json/${schema_file}

    Validate Json Against Schema    ${response_json}    ${schema_path}
    Log    Schema validation completed successfully

Validate ID Filter Response - client
    [Arguments]    ${response}    ${search_term}    ${expected_status}
    [Documentation]    Valida resposta do filtro por ID
    ${clients}=    Validate Filter Response Structure - client    ${response}    object    ${expected_status}

    # Log para debug
    Log    Filtro testado: id    level=INFO
    Log    Termo pesquisado: ${search_term}    level=DEBUG
    Log    Usuários retornados: ${clients}    level=DEBUG

# Keywords de Validação de Filtros
Validate Filter Response Structure - client
    [Arguments]    ${response}    ${expected_type}    ${expected_status}
    [Documentation]    Valida a estrutura básica da resposta do filtro
    Status Should Be    ${expected_status}    ${response}

    ${clients}=    Set Variable    ${response.json()}
    Should Not Be Empty    ${clients}

    # Valida que a resposta é do tipo esperado
    ${is_expected_type}=    Evaluate    isinstance(${clients}, ${expected_type})
    Should Be True    ${is_expected_type}

Test ID Filter With Invalid Characters - client
    [Arguments]    ${invalid_char}
    [Documentation]    Testa filtro com caracteres inválidos
    ${response}=    Get Client By ID    client_id=${invalid_char}    expected_status=400
    Validate Filter Response Structure - client    ${response}    expected_type=object    expected_status=400
    Log    Caractere inválido testado: ${invalid_char}    level=DEBUG
    RETURN    ${response}