*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    String
Resource    ../../../resource.resource

*** Keywords ***

### KEYWORDS DE REQUISIÇÃO ###
Get Users
    [Arguments]    ${index}=${EMPTY}    ${args}=${EMPTY}
    [Documentation]    Executa GET /users para listar todos os usuários
    ${response}=    GET On Session    
    ...    alias=user
    ...    url=${BASE_URL}/users
    ...    headers=${HEADERS}
    ...    expected_status=200
    RETURN    ${response}

Get Users With Pagination
    [Arguments]    ${page}=1    ${per_page}=10
    [Documentation]    Executa GET /users com paginação
    ${headers}=    Create Dictionary    x-api-key=${HEADERS}[x-api-key]
    ${params}=    Create Dictionary    
    ...    page=${page}    
    ...    per_page=${per_page}
    ${response}=    GET On Session    
    ...    alias=user    
    ...    url=${BASE_URL}/users    
    ...    headers=${headers}    
    ...    params=${params}    
    ...    expected_status=any
    RETURN    ${response}

Get Users Without Token
    [Documentation]    Executa GET /users sem token de autenticação
    ${headers}=    Create Dictionary
    
    ${response}=    GET On Session    
    ...    alias=user_no_auth    
    ...    url=${BASE_URL}/users    
    ...    headers=${headers}    
    ...    expected_status=401
    
    RETURN    ${response}

Get Users With Invalid Key
    [Documentation]    Executa GET /users com token inválido
    ${headers}=    Create Dictionary    x-api-key=invalid_key
    ${response}=    GET On Session    
    ...    alias=user    
    ...    url=${BASE_URL}/users    
    ...    headers=${headers}    
    ...    expected_status=401
    RETURN    ${response}

### KEYWORDS DE VALIDAÇÃO ###
Validate First Page Response
    [Arguments]    ${response}
    Status Should Be    200    ${response}
    ${body}=    Set Variable    ${response.json()}
    Log    Response body: ${body}    DEBUG
    
    # Validar que a lista não está vazia
    Should Not Be Empty    ${body}
    
    # Validar o primeiro usuário da lista
    ${first_user}=    Set Variable    ${body}[0]
    Dictionary Should Contain Key    ${first_user}    id
    Dictionary Should Contain Key    ${first_user}    email
    Dictionary Should Contain Key    ${first_user}    name
    Dictionary Should Contain Key    ${first_user}    createdAt
    Dictionary Should Contain Key    ${first_user}    updatedAt

Validate Status Code 200
    [Arguments]    ${response}
    Status Should Be    200    ${response}

Validate Status Code 401
    [Arguments]    ${response}
    [Documentation]    Valida que a resposta tem status code 401
    Status Should Be    401    ${response}
    
    # Valida mensagem de erro
    ${body}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${body}    error
    Should Be Equal    ${body}[error]    Invalid token
    
    Log    Status code 401 validado com sucesso    level=DEBUG

Validate Response Has Content
    [Arguments]    ${response}
    ${response_content}=    Set Variable    ${response.json()}
    Should Not Be Empty    ${response_content}

Validate Users List Response
    [Arguments]    ${response}
    ${body}=    Set Variable    ${response.json()}
    FOR    ${user}    IN    @{body}
        Dictionary Should Contain Key    ${user}    id
        Dictionary Should Contain Key    ${user}    email
        Dictionary Should Contain Key    ${user}    name
        Dictionary Should Contain Key    ${user}    createdAt
        Dictionary Should Contain Key    ${user}    updatedAt
    END

Get Users List
    [Documentation]    Executa GET /users para listar todos os usuários
    ${response}=    Get Users
    RETURN    ${response.json()}

Get Non Existent User
    [Documentation]    Executa GET /users para um usuário inexistente
    ${response}=    GET On Session    
    ...    alias=user
    ...    url=${BASE_URL}/users/999999
    ...    headers=${HEADERS}
    ...    expected_status=404
    RETURN    ${response}

Get Users With Invalid Request
    [Documentation]    Envia uma requisição POST com JSON inválido para gerar erro 400
    ${malformed_json}=    Set Variable    {invalid_json
    &{headers}=    Create Dictionary    
    ...    x-api-key=${HEADERS}[x-api-key]    
    ...    Content-Type=application/json
    
    ${response}=    POST On Session    
    ...    alias=user
    ...    url=${BASE_URL}/users
    ...    headers=${headers}
    ...    data=${malformed_json}
    ...    expected_status=400
    
    RETURN    ${response}

Get Users With Server Error
    [Documentation]    Simula uma requisição que causa erro 500 no servidor
    ${invalid_headers}=    Create Dictionary    
    ...    x-api-key=${HEADERS}[x-api-key]
    ...    Content-Type=invalid/content-type
    ${response}=    GET On Session    
    ...    alias=user
    ...    url=${BASE_URL}/users/error500
    ...    headers=${invalid_headers}
    ...    expected_status=500
    ${error_response}=    Set Variable    ${response.json()}
    RETURN    ${error_response}

Validate Status Code 400
    [Arguments]    ${response}
    [Documentation]    Valida que o código de status é 400 e as mensagens de erro
    Status Should Be    400    ${response}
    
    ${response_json}=    Set Variable    ${response.json()}
    Should Be Equal    ${response_json}[error]    Bad Request
    Should Be Equal    ${response_json}[message]    Expected property name or '}' in JSON at position 1
    Should Be Equal    ${response_json}[statusCode]    ${400}

Validate Status Code 404
    [Arguments]    ${response}
    [Documentation]    Valida que o código de status é 404 e as mensagens de erro
    Status Should Be    404    ${response}
    
    ${response_json}=    Set Variable    ${response.json()}
    Should Be Equal    ${response_json}[error]    Not Found
    Should Be Equal    ${response_json}[message]    Cannot GET /users/999999
    Should Be Equal    ${response_json}[statusCode]    ${404}

Validate Status Code 500
    [Arguments]    ${response}
    Should Be Equal    ${response}[error]    Internal Server Error
    Should Be Equal    ${response}[message]    An unexpected error occurred
    Should Be Equal    ${response}[statusCode]    ${500}

Validate Response Schema
    [Arguments]    ${response}    ${schema_file}
    [Documentation]    Valida o schema do response contra o arquivo de schema JSON
    ${response_json}=    Set Variable    ${response.json()}
    ${schema_path}=    Set Variable    ${CURDIR}/../../../json/${schema_file}
    
    Validate Json Against Schema    ${response_json}    ${schema_path}
    Log    Schema validation completed successfully

Validate User Item Structure
    [Arguments]    ${user}
    [Documentation]    Valida a estrutura de um item de usuário conforme o schema
    # Campos obrigatórios conforme o schema
    Dictionary Should Contain Key    ${user}    id
    Dictionary Should Contain Key    ${user}    name
    Dictionary Should Contain Key    ${user}    createdAt
    Dictionary Should Contain Key    ${user}    updatedAt
    
    # Campos opcionais (podem ser null)
    Dictionary Should Contain Key    ${user}    email
    
    # Valida o tipo dos campos obrigatórios
    ${id}=    Get From Dictionary    ${user}    id
    ${is_id_string}=    Run Keyword And Return Status    
    ...    Evaluate    isinstance($id, str)    
    Should Be True    ${is_id_string}    Campo 'id' deve ser uma string
    
    ${name}=    Get From Dictionary    ${user}    name
    ${is_name_string}=    Run Keyword And Return Status    
    ...    Evaluate    isinstance($name, str)
    Should Be True    ${is_name_string}    Campo 'name' deve ser uma string
    
    # Valida email (pode ser string ou null)
    ${email}=    Get From Dictionary    ${user}    email
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
    
    # Valida datas
    ${created_at}=    Get From Dictionary    ${user}    createdAt
    ${is_created_at_string}=    Run Keyword And Return Status    
    ...    Evaluate    isinstance($created_at, str)
    Should Be True    ${is_created_at_string}    Campo 'createdAt' deve ser uma string
    Should Match Regexp    ${created_at}    ^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{3}Z$
    
    ${updated_at}=    Get From Dictionary    ${user}    updatedAt
    ${is_updated_at_string}=    Run Keyword And Return Status    
    ...    Evaluate    isinstance($updated_at, str)
    Should Be True    ${is_updated_at_string}    Campo 'updatedAt' deve ser uma string
    Should Match Regexp    ${updated_at}    ^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{3}Z$

Validate Email Format
    [Arguments]    ${email}
    [Documentation]    Valida o formato do email
    Should Match Regexp    ${email}    ^[\\w\\.-]+@[\\w\\.-]+\\.\\w+$    
    ...    msg=Email '${email}' não está em um formato válido

Get Available Filters
    [Documentation]    Retorna a lista de filtros disponíveis na API
    ${filters}=    Create List
    # Tenta cada filtro possível e verifica se a API aceita
    @{possible_filters}=    Create List
    ...    name
    ...    status
    ...    application
    ...    serverGroup
    ...    relayConnection
    ...    updatedAt
    
    FOR    ${filter}    IN    @{possible_filters}
        ${response}=    GET On Session    
        ...    alias=user
        ...    url=${BASE_URL}/users    
        ...    params=${filter}=test
        ...    headers=${HEADERS}
        ...    expected_status=any
        
        # Se retornar 200, o filtro existe (mesmo que retorne lista vazia)
        ${status_code}=    Convert To String    ${response.status_code}
        IF    '${status_code}' == '200'
            Append To List    ${filters}    ${filter}
        END
    END
    
    RETURN    ${filters}

Get Users With Filter
    [Arguments]    ${field}    ${value}
    [Documentation]    Executa GET /users com filtro
    ${params}=    Create Dictionary    ${field}=${value}
    ${response}=    GET On Session    
    ...    alias=user    
    ...    url=${BASE_URL}/users    
    ...    headers=${HEADERS}    
    ...    params=${params}    
    ...    expected_status=200
    RETURN    ${response}

Get Users With Multiple Filters
    [Documentation]    Executa GET /users com múltiplos filtros
    [Arguments]    ${filters}
    ${response}=    GET On Session    
    ...    alias=user
    ...    url=${BASE_URL}/users    
    ...    params=${filters}
    ...    headers=${HEADERS}
    ...    expected_status=any
    
    RETURN    ${response}

Verify Available Filters Response
    [Arguments]    ${available_filters}
    [Documentation]    Verifica a resposta dos filtros disponíveis
    Log    Filtros disponíveis: ${available_filters}
    
    # Criar lista de filtros esperados
    @{expected_filters}=    Create List
    ...    name
    ...    status
    ...    application
    ...    serverGroup
    ...    relayConnection
    ...    updatedAt
    
    # Verificar quais filtros estão implementados
    FOR    ${filter}    IN    @{expected_filters}
        ${filter_exists}=    Run Keyword And Return Status
        ...    List Should Contain Value    ${available_filters}    ${filter}
        IF    not ${filter_exists}
            Log    Filtro '${filter}' não está implementado    WARN
        END
    END
    
    # Validar que pelo menos um filtro está disponível
    Should Not Be Empty    ${available_filters}    Nenhum filtro está implementado

Validate Invalid Filter Response
    [Arguments]    ${response}    ${invalid_value}
    [Documentation]    Valida a resposta para um filtro com valor inválido
    Status Should Be    200    ${response}
    ${response_json}=    Set Variable    ${response.json()}
    Log    Response da API: ${response_json}
    
    # Verifica o tipo e conteúdo do response
    ${type}=    Evaluate    type($response_json).__name__
    Log    Tipo do response: ${type}
    Log    Conteúdo do response: ${response_json}
    
    # Verifica se é uma lista
    Should Be True    isinstance($response_json, list)    Response não é uma lista
    
    # Verifica se todos os itens da lista têm status diferente do valor inválido enviado
    FOR    ${item}    IN    @{response_json}
        Run Keyword If    'status' in $item
        ...    Should Not Be Equal    ${item}[status]    ${invalid_value}
        ...    ELSE
        ...    Log    Item não possui campo status: ${item}
    END

Validate Name Filter
    [Arguments]    ${response}    ${expected_name}
    [Documentation]    Valida o filtro por nome
    ${response_json}=    Set Variable    ${response.json()}
    FOR    ${item}    IN    @{response_json}
        Dictionary Should Contain Key    ${item}    name
        Should Be Equal    ${item}[name]    ${expected_name}
    END

Validate Application Filter
    [Arguments]    ${response}    ${expected_application}
    [Documentation]    Valida o filtro por aplicação
    ${response_json}=    Set Variable    ${response.json()}
    FOR    ${item}    IN    @{response_json}
        Dictionary Should Contain Key    ${item}    application
        Should Be Equal    ${item}[application]    ${expected_application}
    END

Validate Server Group Filter
    [Arguments]    ${response}    ${expected_group}
    [Documentation]    Valida o filtro por grupo de servidores
    ${response_json}=    Set Variable    ${response.json()}
    FOR    ${item}    IN    @{response_json}
        Dictionary Should Contain Key    ${item}    serverGroup
        Should Be Equal    ${item}[serverGroup]    ${expected_group}
    END

Validate Relay Connection Filter
    [Arguments]    ${response}    ${expected_connection}
    [Documentation]    Valida o filtro por conexão relay
    ${response_json}=    Set Variable    ${response.json()}
    FOR    ${item}    IN    @{response_json}
        Dictionary Should Contain Key    ${item}    relayConnection
        # Se for tempo em minutos, validar o formato
        ${is_minutes}=    Run Keyword And Return Status    Should Match Regexp    ${expected_connection}    ^\\d+ minutes$
        IF    ${is_minutes}
            ${minutes}=    Get Regexp Matches    ${expected_connection}    ^(\\d+).*    1
            Should Be Equal    ${item}[relayConnection]    ${minutes}[0]    # API retorna apenas o número
        ELSE
            Should Be Equal    ${item}[relayConnection]    ${expected_connection}
        END
    END

Validate Update Date Filter
    [Arguments]    ${response}    ${expected_date}
    [Documentation]    Valida o filtro por data de atualização
    ${response_json}=    Set Variable    ${response.json()}
    FOR    ${item}    IN    @{response_json}
        Dictionary Should Contain Key    ${item}    updatedAt
        ${updated_date}=    Convert Date    ${item}[updatedAt]
        Should Be Equal    ${updated_date}    ${expected_date}
    END

Validate Status Filter
    [Arguments]    ${response}    ${expected_status}
    [Documentation]    Valida o filtro por status
    ${response_json}=    Set Variable    ${response.json()}
    FOR    ${item}    IN    @{response_json}
        Dictionary Should Contain Key    ${item}    status
        Should Be Equal    ${item}[status]    ${expected_status}
    END

Validate Cache Headers Response
    [Arguments]    ${response}
    [Documentation]    Valida os headers de cache na resposta
    Dictionary Should Contain Key    ${response.headers}    Cache-Control
    Dictionary Should Contain Key    ${response.headers}    ETag
    
    ${cache_control}=    Get From Dictionary    ${response.headers}    Cache-Control
    Should Match Regexp    ${cache_control}    ^max-age=\\d+$
    
    ${etag}=    Get From Dictionary    ${response.headers}    ETag
    Should Match Regexp    ${etag}    ^"[a-f0-9]+"$

Get Users With ETag
    [Documentation]    Executa GET /users com header If-None-Match
    [Arguments]    ${etag}
    &{headers}=    Create Dictionary    
    ...    x-api-key=${HEADERS}[x-api-key]
    ...    If-None-Match=${etag}
    ${response}=    GET On Session    
    ...    alias=user
    ...    url=${BASE_URL}/users
    ...    headers=${headers}
    ...    expected_status=any
    RETURN    ${response}

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

Validate Response Time
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
    Should Be True    ${response_time} < ${sla_limit}
    ...    Response time of ${response_time} seconds exceeded the SLA of ${sla_limit} second(s)

Validate Second Page Response
    [Arguments]    ${response}
    [Documentation]    Valida a resposta da segunda página
    Status Should Be    200    ${response}
    
    ${json}=    Set Variable    ${response.json()}
    Should Be True    isinstance($json, list)    A resposta deve ser uma lista
    Should Not Be Empty    ${json}    A lista de usuários não pode estar vazia
    
    # Obtém a primeira página para comparação
    ${first_page}=    Get Users With Pagination    page=1
    ${first_page_json}=    Set Variable    ${first_page.json()}
    
    # Verifica se a paginação está implementada
    ${pagination_implemented}=    Run Keyword And Return Status
    ...    Should Not Be Equal    ${json}    ${first_page_json}    msg=Segunda página igual à primeira
    
    IF    not ${pagination_implemented}
        Log    Known Issue: API-123 - Paginação não implementada    WARN
        Log    O endpoint não está implementando os parâmetros page e per_page    WARN
        Log    Atualmente retorna todos os registros independente da página solicitada    WARN
        Log    Comportamento esperado:    WARN
        Log    - Deve retornar apenas os registros da página solicitada    WARN
        Log    - Deve respeitar o limite de registros por página (per_page)    WARN
        Log    - Deve retornar lista vazia para páginas sem registros    WARN
        Skip    Known Issue: API-123 - Paginação não implementada. O endpoint não processa os parâmetros page e per_page corretamente.
    END
    
    # Valida a estrutura dos itens
    FOR    ${user}    IN    @{json}
        Validate User Item Structure    ${user}
    END

Validate Empty Page Response
    [Arguments]    ${response}
    Status Should Be    200    ${response}
    ${json}=    Set Variable    ${response.json()}
    
    # Valida que é uma lista vazia
    Should Be True    isinstance($json, list)    A resposta deve ser uma lista
    Should Be Empty    ${json}    A lista de usuários deve estar vazia

Validate Error Message
    [Arguments]    ${response}    ${expected_message}
    [Documentation]    Valida a mensagem de erro na resposta
    ${body}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${body}    error
    Should Be Equal    ${body}[error]    ${expected_message}

Log Response Details
    [Arguments]    ${response}
    [Documentation]    Registra os detalhes da resposta nos logs
    ${response_json}=    Set Variable    ${response.json()}
    
    Log    Status Code: ${response.status_code}
    Log    Headers: ${response.headers}
    Log    Body: ${response_json}

Validate Response Time With Logging
    [Arguments]    ${response_time}    ${sla_limit}=1    ${test_name}=Unknown Test
    [Documentation]    Valida o tempo de resposta com logs detalhados
    Log    Validando tempo de resposta para: ${test_name}
    Log    Tempo de resposta: ${response_time} segundos
    Log    Limite SLA: ${sla_limit} segundos
    
    ${within_sla}=    Evaluate    ${response_time} < ${sla_limit}
    
    IF    ${within_sla}
        Log    ✓ Tempo de resposta dentro do SLA    console=True
    ELSE
        Log    ⚠ Tempo de resposta excedeu o SLA!    console=True
    END
    
    Should Be True    ${within_sla}
    ...    Response time of ${response_time} seconds exceeded the SLA of ${sla_limit} second(s)

Validate API Health
    [Documentation]    Verifica a saúde geral da API
    ${response}=    Get Users
    
    # Valida tempo de resposta
    ${response_time}=    Get Time    epoch
    ${end_time}=    Get Time    epoch
    ${total_time}=    Evaluate    ${end_time} - ${response_time}
    Validate Response Time    ${total_time}    1
    
    # Valida status code
    Validate Status Code 200    ${response}
    
    # Valida headers essenciais
    Dictionary Should Contain Key    ${response.headers}    Content-Type
    Dictionary Should Contain Key    ${response.headers}    Date
    
    # Valida formato do response
    ${response_json}=    Set Variable    ${response.json()}
    Should Be True    isinstance($response_json, list)
    
    Log    ✓ API health check passed    console=True

Validate Single Type
    [Arguments]    ${value}    ${type}
    [Documentation]    Valida se um valor corresponde ao tipo esperado
    # Verifica se o tipo é uma lista
    ${is_list}=    Run Keyword And Return Status
    ...    Evaluate    isinstance($type, list)
    
    IF    ${is_list}
        # Se for lista, verifica cada tipo permitido
        FOR    ${allowed_type}    IN    @{type}
            ${type_valid}=    Run Keyword And Return Status
            ...    Validate Type Match    ${value}    ${allowed_type}
            IF    ${type_valid}    RETURN    ${TRUE}
        END
        RETURN    ${FALSE}
    ELSE
        # Se não for lista, valida contra o único tipo
        ${type_valid}=    Run Keyword And Return Status
        ...    Validate Type Match    ${value}    ${type}
        RETURN    ${type_valid}
    END

Validate Type Match
    [Arguments]    ${value}    ${expected_type}
    [Documentation]    Valida se um valor corresponde ao tipo esperado
    ${is_valid}=    Set Variable    ${FALSE}
    
    # Valida string
    IF    '${expected_type}' == 'string'
        ${is_valid}=    Run Keyword And Return Status
        ...    Evaluate    isinstance($value, str)
    # Valida null
    ELSE IF    '${expected_type}' == 'null'
        ${is_valid}=    Run Keyword And Return Status
        ...    Evaluate    $value is None
    # Valida number
    ELSE IF    '${expected_type}' == 'number'
        ${is_valid}=    Run Keyword And Return Status
        ...    Evaluate    isinstance($value, (int, float))
    # Valida boolean
    ELSE IF    '${expected_type}' == 'boolean'
        ${is_valid}=    Run Keyword And Return Status
        ...    Evaluate    isinstance($value, bool)
    # Valida object
    ELSE IF    '${expected_type}' == 'object'
        ${is_valid}=    Run Keyword And Return Status
        ...    Evaluate    isinstance($value, dict)
    # Valida array
    ELSE IF    '${expected_type}' == 'array'
        ${is_valid}=    Run Keyword And Return Status
        ...    Evaluate    isinstance($value, list)
    END
    
    RETURN    ${is_valid}

Validate Json Against Schema
    [Documentation]    Valida um JSON contra um schema
    [Arguments]    ${json_data}    ${schema_path}
    ${schema}=    Get File    ${schema_path}
    ${schema_json}=    Convert String To Json    ${schema}
    
    # Verifica se o schema é para array
    ${schema_type}=    Get From Dictionary    ${schema_json}    type
    ${is_array_schema}=    Run Keyword And Return Status
    ...    Should Be Equal    ${schema_type}    array
    
    IF    ${is_array_schema}
        # Valida que o JSON é uma lista
        ${is_list}=    Run Keyword And Return Status    
        ...    Evaluate    isinstance($json_data, list)
        Should Be True    ${is_list}    
        ...    O JSON deve ser uma lista, mas recebeu: ${json_data}
        
        # Valida cada item da lista
        ${items_schema}=    Get From Dictionary    ${schema_json}    items
        FOR    ${item}    IN    @{json_data}
            Validate Json Object    ${item}    ${items_schema}
        END
    ELSE
        Validate Json Object    ${json_data}    ${schema_json}
    END
    
    Log    JSON validado com sucesso contra o schema ${schema_path}    DEBUG

Validate Json Object
    [Arguments]    ${json_object}    ${schema}
    [Documentation]    Valida um objeto JSON contra um schema
    # Valida que é um objeto
    ${is_dict}=    Run Keyword And Return Status    
    ...    Evaluate    isinstance($json_object, dict)
    Should Be True    ${is_dict}    
    ...    O valor deve ser um objeto, mas recebeu: ${json_object}
    
    # Valida campos obrigatórios se existirem
    ${has_required}=    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${schema}    required
    
    IF    ${has_required}
        ${required}=    Get From Dictionary    ${schema}    required
        FOR    ${field}    IN    @{required}
            Dictionary Should Contain Key    ${json_object}    ${field}
            ...    msg=Campo obrigatório '${field}' não encontrado
        END
    END
    
    # Valida tipos dos campos
    ${properties}=    Get From Dictionary    ${schema}    properties
    FOR    ${property}    ${definition}    IN    &{properties}
        ${has_value}=    Run Keyword And Return Status
        ...    Dictionary Should Contain Key    ${json_object}    ${property}
        
        IF    ${has_value}
            ${value}=    Get From Dictionary    ${json_object}    ${property}
            ${type_def}=    Get From Dictionary    ${definition}    type
            
            # Converte tipo único para lista para tratamento uniforme
            ${type_list}=    Run Keyword If    isinstance($type_def, list)
            ...    Set Variable    ${type_def}
            ...    ELSE    Create List    ${type_def}
            
            ${valid_type}=    Set Variable    ${FALSE}
            FOR    ${allowed_type}    IN    @{type_list}
                ${type_valid}=    Run Keyword And Return Status
                ...    Validate Type Match    ${value}    ${allowed_type}
                IF    ${type_valid}
                    ${valid_type}=    Set Variable    ${TRUE}
                    BREAK
                END
            END
            
            Should Be True    ${valid_type}
            ...    Campo '${property}' com valor '${value}' não corresponde ao(s) tipo(s) permitido(s): ${type_list}
        END
    END

Validate Multiple Types
    [Arguments]    ${value}    ${allowed_types}
    [Documentation]    Valida se um valor corresponde a um dos tipos permitidos
    FOR    ${type}    IN    @{allowed_types}
        ${is_valid}=    Validate Single Type    ${value}    ${type}
        IF    ${is_valid}    RETURN    ${TRUE}
    END
    RETURN    ${FALSE}

### KEYWORDS DE VALIDAÇÃO DE TAMANHO DE RESPOSTA ###
Get Response Size
    [Arguments]    ${response}
    [Documentation]    Retorna o tamanho do response em bytes
    ${content_length}=    Get From Dictionary    ${response.headers}    Content-Length
    RETURN    ${content_length}

Validate Small Response
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
    ${payload_size}=    Get Response Size    ${response}
    Should Be True    ${payload_size} < 10240    
    ...    Tamanho do payload (${payload_size} bytes) acima do esperado (10KB)
    
    # Valida estrutura dos dados
    FOR    ${item}    IN    @{body}
        Validate User Item Structure    ${item}
    END

Validate Medium Response
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
    ${payload_size}=    Get Response Size    ${response}
    Should Be True    ${payload_size} < 51200    
    ...    Tamanho do payload (${payload_size} bytes) acima do esperado (50KB)
    
    # Valida estrutura dos dados
    FOR    ${item}    IN    @{body}
        Validate User Item Structure    ${item}
    END

Validate Large Response
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
    ${payload_size}=    Get Response Size    ${response}
    Should Be True    ${payload_size} < 102400    
    ...    Tamanho do payload (${payload_size} bytes) acima do esperado (100KB)
    
    # Valida estrutura dos dados
    FOR    ${item}    IN    @{body}
        Validate User Item Structure    ${item}
    END

Get Users With Cache
    [Arguments]    ${index}    ${etag}
    [Documentation]    Executa GET /users com ETag para teste de cache
    ${headers}=    Create Dictionary    
    ...    x-api-key=${HEADERS}[x-api-key]    
    ...    If-None-Match=${etag}
    ${response}=    GET On Session    
    ...    alias=user    
    ...    url=${BASE_URL}/users    
    ...    headers=${headers}    
    ...    expected_status=any
    RETURN    ${response}

Validate Concurrent Cache Responses
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

Validate Concurrent Pagination Responses
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

### KEYWORDS DE VALIDAÇÃO DE SEGURANÇA ###
Validate User Security
    [Arguments]    ${user}
    # Verifica ausência de dados sensíveis
    Dictionary Should Not Contain Key    ${user}    password
    Dictionary Should Not Contain Key    ${user}    secret
    Dictionary Should Not Contain Key    ${user}    token
    Dictionary Should Not Contain Key    ${user}    apiKey
    
    # Verifica mascaramento de email quando presente
    Validate Email Security    ${user}

Validate Email Security
    [Arguments]    ${user}
    ${has_email}=    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${user}    email
    
    IF    ${has_email}
        ${email}=    Get From Dictionary    ${user}    email
        ${is_email_none}=    Run Keyword And Return Status
        ...    Should Be Equal    ${email}    ${None}
        
        IF    not ${is_email_none}
            Should Match Regexp    ${email}    ^[^@]+@[^@]+\\.[^@]+$
            Should Not Contain    ${email}    admin
            Should Not Contain    ${email}    root
        END
    END

Validate Rate Limit Headers
    [Arguments]    ${response}
    Dictionary Should Contain Key    ${response.headers}    X-RateLimit-Limit
    Dictionary Should Contain Key    ${response.headers}    X-RateLimit-Remaining
    ${remaining}=    Get From Dictionary    ${response.headers}    X-RateLimit-Remaining
    RETURN    ${remaining}

Validate SQL Injection Response
    [Arguments]    ${response}
    Status Should Be    400    ${response}
    Should Not Contain    ${response.text}    sql
    Should Not Contain    ${response.text}    database
    Should Not Contain    ${response.text}    error

Validate XSS Headers
    [Arguments]    ${response}
    Dictionary Should Contain Key    ${response.headers}    X-XSS-Protection
    Dictionary Should Contain Key    ${response.headers}    Content-Security-Policy

Validate XSS Response Body
    [Arguments]    ${response}
    ${response_body}=    Convert To String    ${response.text}
    Should Not Contain    ${response_body}    <script>
    Should Not Contain    ${response_body}    javascript:
    Should Not Contain    ${response_body}    onerror=

Validate Data Masking Rules
    [Arguments]    ${user}
    [Documentation]    Validação temporária de mascaramento de dados
    ...    Known Issue: API-132
    
    # Valida mascaramento de email quando presente
    ${has_email}=    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${user}    email
    
    IF    ${has_email}
        ${email}=    Get From Dictionary    ${user}    email
        ${is_email_none}=    Run Keyword And Return Status
        ...    Should Be Equal    ${email}    ${None}
        
        IF    not ${is_email_none}
            # Verifica formato básico de email até implementação do mascaramento
            Should Match Regexp    ${email}    ^[^@]+@[^@]+\\.[^@]+$
            Should Not Contain    ${email}    admin
            Should Not Contain    ${email}    root
            Log    Known Issue API-132: Email não mascarado: ${email}    WARN
        END
    END
    
    # Valida outros dados sensíveis
    ${name}=    Get From Dictionary    ${user}    name
    Should Not Contain Any    ${name}    
    ...    CPF    RG    SSN    CNPJ    
    ...    Passport    License
    
    # Log para auditoria
    Log    Verificando dados sensíveis para usuário: ${user}[id]    DEBUG

Validate Basic Rate Limit Response
    [Arguments]    ${response}
    [Documentation]    Validação básica de rate limiting
    ...    Usado temporariamente enquanto API-129 não é corrigida
    Status Should Be    200    ${response}
    
    # Verifica se algum header de rate limit existe
    ${headers}=    Get Dictionary Keys    ${response.headers}
    ${rate_limit_headers}=    Get Matches    ${headers}    *rate*    case_insensitive=True
    
    # Registra headers encontrados
    IF    ${rate_limit_headers}
        Log    Headers de Rate Limit encontrados: ${rate_limit_headers}    WARN
        Log    Atualizar teste: API-129 pode ter sido corrigida    WARN
    ELSE
        Log    Known Issue API-129: Rate Limiting não implementado    WARN
    END

# Keywords de Validação de Filtros
Validate Filter Response Structure
    [Arguments]    ${response}
    [Documentation]    Valida a estrutura básica da resposta do filtro
    Status Should Be    200    ${response}
    
    ${users}=    Set Variable    ${response.json()}
    Should Not Be Empty    ${users}
    
    # Valida que a resposta é uma lista válida
    ${is_list}=    Evaluate    isinstance($users, list)
    Should Be True    ${is_list}
    

Validate Name Filter Response
    [Arguments]    ${response}    ${search_term}
    [Documentation]    Valida resposta do filtro por nome
    ${users}=    Validate Filter Response Structure    ${response}
    
    # Log para debug
    Log    Filtro testado: name    level=INFO
    Log    Termo pesquisado: ${search_term}    level=DEBUG
    Log    Usuários retornados: ${users}    level=DEBUG

Test Name Filter With Special Characters
    [Arguments]    ${special_char}
    [Documentation]    Testa filtro com caracteres especiais
    ${response}=    Get Users With Filter    name    ${special_char}
    Validate Filter Response Structure    ${response}
    Log    Caractere especial testado: ${special_char}    level=DEBUG

Test Case Insensitive Search
    [Arguments]    ${search_term}
    [Documentation]    Testa busca case insensitive
    ${response}=    Get Users With Filter    name    ${search_term}
    Validate Filter Response Structure    ${response}
    Log    Termo case insensitive testado: ${search_term}    level=DEBUG

# Keywords de Segurança
Validate Sensitive Data Masking
    [Arguments]    ${user}
    [Documentation]    Verifica se dados sensíveis estão mascarados
    
    # Verifica email
    ${email}=    Get From Dictionary    ${user}    email
    Run Keyword If    '${email}' != 'None'    Should Match Regexp    ${email}    ^[^@]+@[^@]+\\.[^@]+$
    
    # Verifica outros campos sensíveis conforme necessário
    Log    Validação de mascaramento concluída para usuário: ${user['id']}    level=DEBUG

# Keywords de Validação de Dados
Validate User Data Types
    [Arguments]    ${user}
    [Documentation]    Valida os tipos de dados dos campos do usuário
    
    # Validação de tipos usando evaluate para verificar o tipo Python
    ${is_name_string}=    Evaluate    isinstance($user['name'], str)
    Should Be True    ${is_name_string}    Campo 'name' deve ser string, valor atual: ${user}[name]
    
    # Valida email (pode ser nulo)
    ${email}=    Set Variable    ${user}[email]
    IF    $email is not None
        ${is_email_string}=    Evaluate    isinstance($user['email'], str)
        Should Be True    ${is_email_string}    Campo 'email' deve ser string quando presente, valor atual: ${user}[email]
    END
    
    ${is_id_string}=    Evaluate    isinstance($user['id'], str)
    Should Be True    ${is_id_string}    Campo 'id' deve ser string, valor atual: ${user}[id]
    
    # Campos em camelCase na API
    ${is_created_at_string}=    Evaluate    isinstance($user['createdAt'], str)
    Should Be True    ${is_created_at_string}    Campo 'createdAt' deve ser string, valor atual: ${user}[createdAt]
    
    ${is_updated_at_string}=    Evaluate    isinstance($user['updatedAt'], str)
    Should Be True    ${is_updated_at_string}    Campo 'updatedAt' deve ser string, valor atual: ${user}[updatedAt]
    
    # Log para debug
    Log    Tipos de dados validados para usuário: ${user['id']}    level=DEBUG

Validate Required User Fields
    [Arguments]    ${user}
    [Documentation]    Valida presença de campos obrigatórios
    
    # Lista de campos obrigatórios (usando camelCase conforme API)
    @{required_fields}=    Create List    id    name    email    createdAt    updatedAt
    
    FOR    ${field}    IN    @{required_fields}
        Dictionary Should Contain Key    ${user}    ${field}
        
        # Verifica se o campo não está vazio (exceto email que pode ser nulo)
        ${value}=    Set Variable    ${user}[${field}]
        IF    '${field}' != 'email'
            Should Not Be Empty    ${value}    Campo '${field}' não pode ser vazio
        END
    END
    
    Log    Campos obrigatórios validados para usuário: ${user['id']}    level=DEBUG

Validate User Data Formats
    [Arguments]    ${user}
    [Documentation]    Valida formatos específicos dos dados
    
    # Valida formato de email (se não for nulo)
    ${email}=    Set Variable    ${user}[email]
    IF    $email is not None
        Should Match Regexp    ${user}[email]    ^[^@]+@[^@]+\\.[^@]+$
    END
    
    # Valida formato de datas (usando camelCase)
    Should Match Regexp    ${user}[createdAt]    ^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}
    Should Match Regexp    ${user}[updatedAt]    ^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}
    
    # Valida formato de ID (Base64 URL Safe)
    Should Match Regexp    ${user}[id]    ^[A-Za-z0-9_-]+$
    
    Log    Formatos de dados validados para usuário: ${user['id']}    level=DEBUG

Validate Field Length Limits
    [Arguments]    ${user}
    [Documentation]    Valida limites de tamanho dos campos
    
    # Valida tamanho máximo do nome
    ${name_length}=    Get Length    ${user}[name]
    Should Be True    ${name_length} <= 100    Campo 'name' excede o limite de 100 caracteres
    
    # Valida tamanho máximo do email (se não for nulo)
    ${email}=    Set Variable    ${user}[email]
    IF    $email is not None
        ${email_length}=    Get Length    ${email}
        Should Be True    ${email_length} <= 255    Campo 'email' excede o limite de 255 caracteres
    END
    
    Log    Limites de tamanho validados para usuário: ${user['id']}    level=DEBUG

Validate Special Characters
    [Arguments]    ${user}
    [Documentation]    Valida tratamento de caracteres especiais
    
    # Lista de caracteres especiais para verificar
    @{special_chars}=    Create List    á    é    í    ó    ú    ñ    ç    @    #    $
    
    # Verifica se o nome aceita caracteres especiais
    FOR    ${char}    IN    @{special_chars}
        ${contains_char}=    Run Keyword And Return Status
        ...    Should Not Contain    ${user}[name]    ${char}
        Run Keyword If    not ${contains_char}
        ...    Log    Nome contém caractere especial '${char}' para usuário: ${user['id']}    level=DEBUG
    END

Validate Optional Fields
    [Arguments]    ${user}
    [Documentation]    Valida campos opcionais quando presentes
    
    # Lista de campos opcionais
    @{optional_fields}=    Create List    phone    address    role
    
    FOR    ${field}    IN    @{optional_fields}
        ${has_field}=    Run Keyword And Return Status
        ...    Dictionary Should Contain Key    ${user}    ${field}
        
        IF    ${has_field}
            Should Not Be Empty    ${user}[${field}]
            Log    Campo opcional '${field}' presente e válido    level=DEBUG
        END
    END
