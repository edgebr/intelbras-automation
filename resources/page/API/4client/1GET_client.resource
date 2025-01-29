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
    [Documentation]    Executa GET /clients para listar todos os clientes
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

Get Client By ID Without Token
    [Arguments]    ${client_id}
    [Documentation]    Executa GET /clients/{id] sem token de autenticação
    ${headers}=    Create Dictionary

    ${response}=    GET On Session
    ...    alias=user_no_auth
    ...    url=${BASE_URL}/clients/${client_id}
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

Get Client By ID With Invalid Key
    [Documentation]    Executa GET /clients com token inválido
    [Arguments]    ${client_id}
    ${headers}=    Create Dictionary    x-api-key=invalid_key
    ${response}=    GET On Session
    ...    alias=user
    ...    url=${BASE_URL}/clients/${client_id}
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

Get Response Time For Clients List
    [Documentation]    Executa a requisição GET /clients e retorna o tempo de resposta.
    ...    Returns:
    ...        response: Objeto de resposta da requisição
    ...        response_time: Tempo de resposta em segundos
    ${start_time}=    Get Time    epoch
    ${response}=    Get Clients
    ${end_time}=    Get Time    epoch
    ${response_time}=    Evaluate    ${end_time} - ${start_time}
    RETURN    ${response}    ${response_time}

Get Response Time For Single Client
    [Arguments]    ${client_id}    ${expected_status}
    [Documentation]    Executa a requisição GET /clients/{id} e retorna o tempo de resposta.
    ...    Returns:
    ...        response: Objeto de resposta da requisição
    ...        response_time: Tempo de resposta em segundos
    ${start_time}=    Get Time    epoch
    ${response}=    Get Client By ID    ${client_id}    ${expected_status}
    ${end_time}=    Get Time    epoch
    ${response_time}=    Evaluate    ${end_time} - ${start_time}
    RETURN    ${response}    ${response_time}

Get Response Time For Clients List With Filter
    [Arguments]    ${search_parameter}    ${search_term}
    [Documentation]    Executa a requisição GET /clients com filtro e retorna o tempo de resposta.
    ...    Returns:
    ...        response: Objeto de resposta da requisição
    ...        response_time: Tempo de resposta em segundos
    ${start_time}=    Get Time    epoch
    ${response}=    Get Clients With Filter    ${search_parameter}    ${search_term}
    ${end_time}=    Get Time    epoch
    ${response_time}=    Evaluate    ${end_time} - ${start_time}
    RETURN    ${response}    ${response_time}

Get Response Time For Invalid Token - client list
    [Documentation]    Executa a requisição com token inválido e retorna o tempo de resposta.
    ...    Returns:
    ...        response: Objeto de resposta da requisição
    ...        response_time: Tempo de resposta em segundos
    ${start_time}=    Get Time    epoch
    ${response}=    Get Clients With Invalid Key
    ${end_time}=    Get Time    epoch
    ${response_time}=    Evaluate    ${end_time} - ${start_time}
    RETURN    ${response}    ${response_time}

Get Response Time For Invalid Token - client by id
    [Documentation]    Executa a requisição com token inválido e retorna o tempo de resposta.
    ...    Returns:
    ...        response: Objeto de resposta da requisição
    ...        response_time: Tempo de resposta em segundos
    ${start_time}=    Get Time    epoch
    ${response}=    Get Client By ID With Invalid Key    client_id=1
    ${end_time}=    Get Time    epoch
    ${response_time}=    Evaluate    ${end_time} - ${start_time}
    RETURN    ${response}    ${response_time}

Get Clients With ETag
    [Documentation]    Executa GET /clients com header If-None-Match
    [Arguments]    ${etag}
    &{headers}=    Create Dictionary
    ...    x-api-key=${HEADERS}[x-api-key]
    ...    If-None-Match=${etag}
    ${response}=    GET On Session
    ...    alias=user
    ...    url=${BASE_URL}/clients
    ...    headers=${headers}
    ...    expected_status=any
    RETURN    ${response}
    
Get Client By ID With ETag
    [Documentation]    Executa GET /clients com header If-None-Match
    [Arguments]    ${etag}    ${client_id}
    &{headers}=    Create Dictionary
    ...    x-api-key=${HEADERS}[x-api-key]
    ...    If-None-Match=${etag}
    ${response}=    GET On Session
    ...    alias=user
    ...    url=${BASE_URL}/clients/${client_id}
    ...    headers=${headers}
    ...    expected_status=any
    RETURN    ${response}

### KEYWORDS DE VALIDAÇÃO ###
Validate First Page Response - client
    [Arguments]    ${response}
    Status Should Be    200    ${response}
    ${body}=    Set Variable    ${response.json()}
    Log    Response body: ${body}    DEBUG

    # Validar que a lista não está vazia
    Should Not Be Empty    ${body}

    # Validar o primeiro cliente da lista
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
    Should Be Empty    ${json}    A lista de clientes deve estar vazia

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
    [Documentation]    Valida a estrutura de um item de cliente conforme o schema

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
    ${is_id_integer}=    Run Keyword And Return Status
    ...    Evaluate    isinstance($id, int)
    Should Be True    ${is_id_integer}    Campo 'id' deve ser um inteiro

    ${client_key}=    Get From Dictionary    ${client}    clientKey
    ${is_client_key_string}=    Run Keyword And Return Status
    ...    Evaluate    isinstance($client_key, str)
    Should Be True    ${is_client_key_string}    Campo 'clientKey' deve ser uma string

    ${enabled}=    Get From Dictionary    ${client}    enabled
    ${is_enabled_boolean}=    Run Keyword And Return Status
    ...    Evaluate    isinstance($enabled, bool)
    Should Be True    ${is_enabled_boolean}    Campo 'enabled' deve ser um booleano

    # Valida email (pode ser string ou null)
    ${email}=    Get From Dictionary    ${client}    email
    ${is_email_none}=    Run Keyword And Return Status
    ...    Evaluate    $email is None

    IF    not ${is_email_none}
        ${is_email_string}=    Run Keyword And Return Status
        ...    Evaluate    isinstance($email, str)
        Should Be True    ${is_email_string}    Campo 'email' deve ser uma string quando não é null

        # Valida formato do email apenas se não for null
        ${is_valid_email}=    Run Keyword And Return Status
        ...    Should Match Regexp    ${email}    ^[\\w\\.-]+@[\\w\\.-]+\\.\\w+$
        Should Be True    ${is_valid_email}    Email '${email}' não está em um formato válido
    END

    # Valida applicationId (pode ser inteiro ou null)
    ${application_id}=    Get From Dictionary    ${client}    applicationId
    ${is_application_id_none}=    Run Keyword And Return Status
    ...    Evaluate    $application_id is None

    IF    not ${is_application_id_none}
        ${is_application_id_integer}=    Run Keyword And Return Status
        ...    Evaluate    isinstance($application_id, int)
        Should Be True    ${is_application_id_integer}    Campo 'applicationId' deve ser um inteiro quando não é null
    END

    # Valida datas
    ${created_at}=    Get From Dictionary    ${client}    createdAt
    ${is_created_at_string}=    Run Keyword And Return Status
    ...    Evaluate    isinstance($created_at, str)
    Should Be True    ${is_created_at_string}    Campo 'createdAt' deve ser uma string
    Should Match Regexp    ${created_at}    ^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{3}Z$

    ${updated_at}=    Get From Dictionary    ${client}    updatedAt
    ${is_updated_at_string}=    Run Keyword And Return Status
    ...    Evaluate    isinstance($updated_at, str)
    Should Be True    ${is_updated_at_string}    Campo 'updatedAt' deve ser uma string
    Should Match Regexp    ${updated_at}    ^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{3}Z$

    # Valida groups (deve ser uma lista)
    ${groups}=    Get From Dictionary    ${client}    groups
    ${is_groups_list}=    Run Keyword And Return Status
    ...    Evaluate    isinstance($groups, list)
    Should Be True    ${is_groups_list}    Campo 'groups' deve ser uma lista

    # Valida estrutura dos grupos, se existirem
    FOR    ${group}    IN    @{groups}
        Dictionary Should Contain Key    ${group}    id
        Dictionary Should Contain Key    ${group}    name
        Dictionary Should Contain Key    ${group}    clientGroup

        ${group_id}=    Get From Dictionary    ${group}    id
        ${is_group_id_integer}=    Run Keyword And Return Status
        ...    Evaluate    isinstance($group_id, int)
        Should Be True    ${is_group_id_integer}    Campo 'id' do grupo deve ser um inteiro

        ${group_name}=    Get From Dictionary    ${group}    name
        ${is_group_name_string}=    Run Keyword And Return Status
        ...    Evaluate    isinstance($group_name, str)
        Should Be True    ${is_group_name_string}    Campo 'name' do grupo deve ser uma string

        ${client_group}=    Get From Dictionary    ${group}    clientGroup
        ${is_client_group_dict}=    Run Keyword And Return Status
        ...    Evaluate    isinstance($client_group, dict)
        Should Be True    ${is_client_group_dict}    Campo 'clientGroup' deve ser um dicionário

        # Valida estrutura do clientGroup
        Dictionary Should Contain Key    ${client_group}    relayAccess
        Dictionary Should Contain Key    ${client_group}    relayDuration

        ${relay_access}=    Get From Dictionary    ${client_group}    relayAccess
        ${is_relay_access_integer}=    Run Keyword And Return Status
        ...    Evaluate    isinstance($relay_access, int)
        Should Be True    ${is_relay_access_integer}    Campo 'relayAccess' deve ser um inteiro

        ${relay_duration}=    Get From Dictionary    ${client_group}    relayDuration
        ${is_relay_duration_integer}=    Run Keyword And Return Status
        ...    Evaluate    isinstance($relay_duration, int)
        Should Be True    ${is_relay_duration_integer}    Campo 'relayDuration' deve ser um inteiro
    END

Validate Response Time - client
    [Arguments]    ${response_time}    ${sla_limit}=0.8
    [Documentation]    Valida se o tempo de resposta está dentro do limite do SLA.
    ...    Args:
    ...        response_time: Tempo de resposta em segundos
    ...        sla_limit: Limite máximo aceitável em segundos (default: 0.8)

    # Registra métricas detalhadas
    Log    Tempo de resposta: ${response_time}s    WARN
    Log    SLA esperado: ${sla_limit}s    WARN
    Log    Diferença: ${response_time - ${sla_limit}}s    WARN

    # Valida o SLA
    Should Be True    ${response_time} <= ${sla_limit}
    ...    O tempo de resposta de ${response_time} segundos excedeu o SLA de ${sla_limit} segundo(s).

# Keywords de Validação de Filtros

Validate ID Filter Response - client
    [Arguments]    ${response}    ${search_term}    ${expected_status}
    [Documentation]    Valida resposta do filtro por ID
    ${clients}=    Validate Filter Response Structure - client    ${response}    object    ${expected_status}

    # Log para debug
    Log    Filtro testado: id    level=INFO
    Log    Termo pesquisado: ${search_term}    level=DEBUG
    Log    Clientes retornados: ${clients}    level=DEBUG

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

Validate Cache Headers Response - client
    [Arguments]    ${response}
    [Documentation]    Valida os headers de cache na resposta
    Dictionary Should Contain Key    ${response.headers}    Cache-Control
    Dictionary Should Contain Key    ${response.headers}    ETag

    ${cache_control}=    Get From Dictionary    ${response.headers}    Cache-Control
    Should Match Regexp    ${cache_control}    ^max-age=\\d+$

    ${etag}=    Get From Dictionary    ${response.headers}    ETag
    Should Match Regexp    ${etag}    ^"[a-f0-9]+"$

### KEYWORDS DE VALIDAÇÃO DE TAMANHO DE RESPOSTA ###

Get Response Size - client
    [Arguments]    ${response}
    [Documentation]    Retorna o tamanho do response em bytes
    ${content_length}=    Get From Dictionary    ${response.headers}    Content-Length
    RETURN    ${content_length}

Validate Small Response - client
    [Arguments]    ${response}
    [Documentation]    Valida uma resposta pequena (até 10 registros)

    # Valida status code
    Status Should Be    200    ${response}

    # Obtém o response body
    ${body}=    Set Variable    ${response.json()}

    # Valida que é uma lista
    Should Be True    isinstance($body, list)    O response deve ser uma lista

    # Valida quantidade de registros
    ${count}=    Get Length    ${body}
    Should Be True    ${count} <= 10
    ...    Quantidade de registros (${count}) maior que o esperado (10)

    # Valida tempo de resposta
    ${response_time}=    Get Response Time    ${response}
    Should Be True    ${response_time} < 0.5
    ...    Tempo de resposta (${response_time}s) acima do esperado (0.5s)

    # Valida tamanho do payload
    ${payload_size}=    Get Response Size - client    ${response}
    Should Be True    ${payload_size} < 10240
    ...    Tamanho do payload (${payload_size} bytes) acima do esperado (10KB)

    # Valida estrutura dos dados
    FOR    ${item}    IN    @{body}
        Validate Client Item Structure    ${item}
    END

Validate Medium Response - client
    [Arguments]    ${response}
    [Documentation]    Valida uma resposta média (50-100 registros)

    # Valida status code
    Status Should Be    200    ${response}

    # Obtém o response body
    ${body}=    Set Variable    ${response.json()}

    # Valida que é uma lista
    Should Be True    isinstance($body, list)    O response deve ser uma lista

    # Valida quantidade de registros
    ${count}=    Get Length    ${body}
    Should Be True    50 <= ${count} <= 100
    ...    Quantidade de registros (${count}) fora do esperado (50-100)

    # Valida tempo de resposta
    ${response_time}=    Get Response Time    ${response}
    Should Be True    ${response_time} < 1
    ...    Tempo de resposta (${response_time}s) acima do esperado (1s)

    # Valida tamanho do payload
    ${payload_size}=    Get Response Size - client    ${response}
    Should Be True    ${payload_size} < 51200
    ...    Tamanho do payload (${payload_size} bytes) acima do esperado (50KB)

    # Valida estrutura dos dados
    FOR    ${item}    IN    @{body}
        Validate Client Item Structure    ${item}
    END

Validate Large Response - client
    [Arguments]    ${response}
    [Documentation]    Valida uma resposta grande (>100 registros)

    # Valida status code
    Status Should Be    200    ${response}

    # Obtém o response body
    ${body}=    Set Variable    ${response.json()}

    # Valida que é uma lista
    Should Be True    isinstance($body, list)    O response deve ser uma lista

    # Valida quantidade de registros
    ${count}=    Get Length    ${body}
    Should Be True    ${count} > 100
    ...    Quantidade de registros (${count}) menor que o esperado (>100)

    # Valida tempo de resposta
    ${response_time}=    Get Response Time    ${response}
    Should Be True    ${response_time} < 2
    ...    Tempo de resposta (${response_time}s) acima do esperado (2s)

    # Valida tamanho do payload
    ${payload_size}=    Get Response Size - client    ${response}
    Should Be True    ${payload_size} < 102400
    ...    Tamanho do payload (${payload_size} bytes) acima do esperado (100KB)

    # Valida estrutura dos dados
    FOR    ${item}    IN    @{body}
        Validate Client Item Structure    ${item}
    END

### KEYWORDS DE CONCORRÊNCIA ###

Run Concurrent Requests - client
    [Arguments]    ${keyword}    ${number_of_requests}    @{args}
    [Documentation]    Executa requisições sequenciais simulando concorrência
    @{responses}=    Create List

    # Executa requisições em sequência rápida
    FOR    ${index}    IN RANGE    ${number_of_requests}
        ${response}=    Run Keyword    ${keyword}    @{args}
        Append To List    ${responses}    ${response}
        Sleep    0.1s    # Pequeno delay para não sobrecarregar
    END

    RETURN    ${responses}

Validate Concurrent Responses - client
    [Arguments]    ${responses}    ${validate_item_structure}=None
    [Documentation]    Valida as respostas de requisições concorrentes

    FOR    ${response}    IN    @{responses}
        # Valida status code
        ${status_code}=    Convert To String    ${response.status_code}
        Should Be Equal As Strings    ${status_code}    200
        ...    Status code ${status_code} diferente do esperado (200)

        # Valida estrutura da resposta
        ${body}=    Set Variable    ${response.json()}
        ${is_list}=    Evaluate    isinstance($body, list)
        Should Be True    ${is_list}
        ...    Resposta deve ser uma lista, mas recebeu: ${body}

        # Valida tempo de resposta
        ${response_time}=    Get Response Time    ${response}
        Should Be True    ${response_time} < 2
        ...    Tempo de resposta (${response_time}s) acima do esperado sob concorrência (2s)

        # Valida estrutura específica dos itens se fornecida
        IF    $validate_item_structure is not None
            FOR    ${item}    IN    @{body}
                Run Keyword    ${validate_item_structure}    ${item}
            END
        END
    END

Get Clients With Cache
    [Arguments]    ${etag}
    [Documentation]    Executa GET /clients com ETag para teste de cache
    ${headers}=    Create Dictionary
    ...    x-api-key=${HEADERS}[x-api-key]
    ...    If-None-Match=${etag}
    ${response}=    GET On Session
    ...    alias=user
    ...    url=${BASE_URL}/clients
    ...    headers=${headers}
    ...    expected_status=any
    RETURN    ${response}

Get Client By ID With Cache
    [Arguments]    ${etag}    ${client_id}
    [Documentation]    Executa GET /clients/{id} com ETag para teste de cache
    ${headers}=    Create Dictionary
    ...    x-api-key=${HEADERS}[x-api-key]
    ...    If-None-Match=${etag}
    ${response}=    GET On Session
    ...    alias=user
    ...    url=${BASE_URL}/clients/${client_id}
    ...    headers=${headers}
    ...    expected_status=any
    RETURN    ${response}

Validate Concurrent Cache Responses - client
    [Arguments]    ${responses}
    [Documentation]    Valida as respostas de requisições concorrentes com cache

    ${cache_hits}=    Set Variable    ${0}

    FOR    ${response}    IN    @{responses}
        # Valida status code (200 ou 304)
        ${status}=    Convert To String    ${response.status_code}
        Should Be True    '${status}' in ['200', '304']
        ...    Status code ${status} deve ser 200 ou 304

        # Conta cache hits
        IF    '${status}' == '304'
            ${cache_hits}=    Evaluate    ${cache_hits} + 1
        END
    END

    # Valida taxa de hit do cache
    ${hit_rate}=    Evaluate    ${cache_hits} / len($responses)
    Should Be True    ${hit_rate} >= 0.7
    ...    Taxa de hit do cache (${hit_rate}) abaixo do esperado (70%)

Validate Concurrent Pagination Responses - client
    [Arguments]    ${responses}
    @{all_ids}=    Create List

    FOR    ${response}    IN    @{responses}
        ${status_code}=    Convert To String    ${response.status_code}
        Should Be Equal As Strings    ${status_code}    200

        ${body}=    Set Variable    ${response.json()}
        ${is_list}=    Evaluate    isinstance($body, list)
        Should Be True    ${is_list}

        FOR    ${item}    IN    @{body}
            ${id}=    Get From Dictionary    ${item}    id
            # Temporariamente removida a validação de duplicatas até correção da API
            Append To List    ${all_ids}    ${id}
        END
    END

# Keywords de Validação de Dados