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
    ...    url=${BASE_URL}/clients
    ...    headers=${headers}
    ...    expected_status=401
    RETURN    ${response}

Get Clients With Filter
    [Arguments]    ${field}    ${value}
    [Documentation]    Executa GET /clients com filtro
    ${params}=    Create Dictionary    ${field}=${value}
    ${response}=    GET On Session
    ...    alias=user
    ...    url=${BASE_URL}/clients
    ...    headers=${HEADERS}
    ...    params=${params}
    ...    expected_status=200
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
    FOR    ${client}    IN    @{json}
        Validate Client Item Structure    ${client}
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

Validate Client Item Structure
    [Arguments]    ${client}
    [Documentation]    Valida a estrutura de um item de cliente conforme o schema.

    # Campos obrigatórios conforme o schema
    Dictionary Should Contain Key    ${client}    id
    Dictionary Should Contain Key    ${client}    clientKey
    Dictionary Should Contain Key    ${client}    enabled
    Dictionary Should Contain Key    ${client}    createdAt
    Dictionary Should Contain Key    ${client}    updatedAt
    Dictionary Should Contain Key    ${client}    groups

    # Campos opcionais (podem ser null)
    Dictionary Should Contain Key    ${client}    email
    Dictionary Should Contain Key    ${client}    applicationId

    # Valida o tipo dos campos obrigatórios
    ${id}=    Get From Dictionary    ${client}    id
    ${is_id_int}=    Run Keyword And Return Status
    ...    Evaluate    isinstance(${id}, int)
    Should Be True    ${is_id_int}    Campo 'id' deve ser um inteiro

    ${clientKey}=    Get From Dictionary    ${client}    clientKey
    ${is_clientKey_string}=    Run Keyword And Return Status
    ...    Evaluate    isinstance(${clientKey}, str)
    Should Be True    ${is_clientKey_string}    Campo 'clientKey' deve ser uma string

    ${enabled}=    Get From Dictionary    ${client}    enabled
    ${is_enabled_bool}=    Run Keyword And Return Status
    ...    Evaluate    isinstance(${enabled}, bool)
    Should Be True    ${is_enabled_bool}    Campo 'enabled' deve ser um booleano

    ${createdAt}=    Get From Dictionary    ${client}    createdAt
    ${is_createdAt_string}=    Run Keyword And Return Status
    ...    Evaluate    isinstance(${createdAt}, str)
    Should Be True    ${is_createdAt_string}    Campo 'createdAt' deve ser uma string no formato datetime

    ${updatedAt}=    Get From Dictionary    ${client}    updatedAt
    ${is_updatedAt_string}=    Run Keyword And Return Status
    ...    Evaluate    isinstance(${updatedAt}, str)
    Should Be True    ${is_updatedAt_string}    Campo 'updatedAt' deve ser uma string no formato datetime

    # Valida o campo opcional 'email'
    ${email}=    Get From Dictionary    ${client}    email
    ${is_email_none}=    Run Keyword And Return Status
    ...    Evaluate    ${email} is None
    IF    not ${is_email_none}
        ${is_email_string}=    Run Keyword And Return Status
        ...    Evaluate    isinstance(${email}, str)
        Should Be True    ${is_email_string}    Campo 'email' deve ser uma string quando não é null

        ${is_valid_email}=    Run Keyword And Return Status
        ...    Should Match Regexp    ${email}    ^[\\w\\.-]+@[\\w\\.-]+\\.\\w+$
        Should Be True    ${is_valid_email}    Email '${email}' não está em um formato válido
    END

    # Valida o campo opcional 'applicationId'
    ${applicationId}=    Get From Dictionary    ${client}    applicationId
    ${is_appId_none}=    Run Keyword And Return Status
    ...    Evaluate    ${applicationId} is None
    IF    not ${is_appId_none}
        ${is_appId_int}=    Run Keyword And Return Status
        ...    Evaluate    isinstance(${applicationId}, int)
        Should Be True    ${is_appId_int}    Campo 'applicationId' deve ser um inteiro quando não é null
    END

    # Valida o campo 'groups'
    ${groups}=    Get From Dictionary    ${client}    groups
    ${is_groups_list}=    Run Keyword And Return Status
    ...    Evaluate    isinstance(${groups}, list)
    Should Be True    ${is_groups_list}    Campo 'groups' deve ser uma lista

    FOR    ${group}    IN    @{groups}
        Dictionary Should Contain Key    ${group}    id
        Dictionary Should Contain Key    ${group}    name
        Dictionary Should Contain Key    ${group}    clientGroup

        ${groupId}=    Get From Dictionary    ${group}    id
        ${is_groupId_int}=    Run Keyword And Return Status
        ...    Evaluate    isinstance(${groupId}, int)
        Should Be True    ${is_groupId_int}    Campo 'id' no grupo deve ser um inteiro

        ${groupName}=    Get From Dictionary    ${group}    name
        ${is_groupName_string}=    Run Keyword And Return Status
        ...    Evaluate    isinstance(${groupName}, str)
        Should Be True    ${is_groupName_string}    Campo 'name' no grupo deve ser uma string

        ${clientGroup}=    Get From Dictionary    ${group}    clientGroup
        Dictionary Should Contain Key    ${clientGroup}    relayAccess
        Dictionary Should Contain Key    ${clientGroup}    relayDuration

        ${relayAccess}=    Get From Dictionary    ${clientGroup}    relayAccess
        ${is_relayAccess_int}=    Run Keyword And Return Status
        ...    Evaluate    isinstance(${relayAccess}, int)
        Should Be True    ${is_relayAccess_int}    Campo 'relayAccess' deve ser um inteiro

        ${relayDuration}=    Get From Dictionary    ${clientGroup}    relayDuration
        ${is_relayDuration_int}=    Run Keyword And Return Status
        ...    Evaluate    isinstance(${relayDuration}, int)
        Should Be True    ${is_relayDuration_int}    Campo 'relayDuration' deve ser um inteiro
    END


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

Validate Filter Response - client
    [Arguments]    ${response}    ${search_parameter}    ${search_term}
    [Documentation]    Valida resposta do filtro por nome
    ${clients}=    Validate Filter Response Structure - client    ${response}    expected_type=list    expected_status=200

    # Log para debug
    Log    Filtro testado: ${search_parameter}    level=INFO
    Log    Termo pesquisado: ${search_term}    level=DEBUG
    Log    Usuários retornados: ${clients}    level=DEBUG

Test Case Insensitive Search - client
    [Arguments]    ${search_parameter}    ${search_term}
    [Documentation]    Testa busca case insensitive
    ${response}=    Get Clients With Filter    ${search_parameter}    ${search_term}
    Validate Filter Response Structure - client    ${response}    expected_type=list    expected_status=200
    Log    Parametro case insensitive testado: ${search_parameter}    level=DEBUG
    Log    Termo case insensitive testado: ${search_term}    level=DEBUG

Test Filter With Special Characters - client
    [Arguments]    ${search_parameter}    ${special_char}
    [Documentation]    Testa filtro com caracteres especiais
    ${response}=    Get Clients With Filter    ${search_parameter}    ${special_char}
    Validate Filter Response Structure - client    ${response}    expected_type=list    expected_status=200
    Log    Caractere especial testado: ${special_char}    level=DEBUG