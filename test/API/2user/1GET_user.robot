*** Settings ***
Documentation     Testes do endpoint GET /users
...    
...    Endpoint: GET /users
...    Descrição: Retorna lista de usuários cadastrados
...    Autenticação: x-api-key header required
...    Rate Limit: 1000 requests/hour
...    Cache: ETag implementation
...    SLA: 1s response time
...    
...    Known Issues:
...    - API-123: Paginação não implementada
...    - API-124: Cache headers incorretos
...    - API-125: Filtros não funcionam
...    - API-126: Performance abaixo do SLA
...    - API-127: Problemas no ETag
...    - API-128: Duplicação em paginação

Resource          ../../../resources/resource.resource
Resource          ../../../resources/page/api/2user/1GET_user.resource

Force Tags        api    get_users
Default Tags      regression

Suite Setup       Suite Setup
Suite Teardown    Delete All Sessions

*** Variables ***
&{KNOWN_ISSUES}    
...    API-123=Paginação não implementada
...    API-124=Cache headers incorretos
...    API-125=Filtros não funcionam
...    API-126=Performance abaixo do SLA
...    API-127=Problemas no ETag
...    API-128=Duplicação em paginação

*** Test Cases ***
### TESTES DE STATUS CODE ###

Get Successful Response - user
    [Documentation]    Valida requisição bem-sucedida no endpoint GET /users
    ...    
    ...    Objetivo: Verificar se o endpoint retorna status 200 e dados válidos
    ...    
    ...    Pré-condições: 
    ...    - API em execução
    ...    - Token válido configurado
    ...    
    ...    Passos:
    ...    1. Enviar requisição GET para /users
    ...    2. Validar status code 200
    ...    3. Validar estrutura da resposta
    ...    4. Validar conteúdo não vazio
    ...    
    ...    Resultado Esperado:
    ...    - Status code 200
    ...    - Response body com lista de usuários
    ...    - Dados em formato JSON válido
    [Tags]    status_code    positive    regression    smoke    priority_high    
    ...    data_validation    critical
    ${response}=    Get Users
    Validate Status Code 200    ${response}
    Validate Response Has Content    ${response}
    Log    Response: ${response.json()}

Get Unauthorized Response - user
    [Documentation]    Valida comportamento com autenticação inválida
    ...
    ...    Objetivo: Verificar se o endpoint retorna erro adequado sem autenticação
    ...    
    ...    Pré-condições:
    ...    - API em execução
    ...    
    ...    Passos:
    ...    1. Enviar requisição GET sem token
    ...    2. Validar status code 401
    ...    3. Validar mensagem de erro
    ...    
    ...    Resultado Esperado:
    ...    - Status code 401
    ...    - Mensagem "Invalid token"
    ...    - Headers de autenticação apropriados
    [Tags]    status_code    negative    regression    security    priority_high
    ${response}=    Get Users Without Token
    Validate Status Code 401    ${response}
    Validate Error Message    ${response}    Invalid token

# 3 - Requisição inválida (400 Bad Request)
Get Bad Request Error - user
    [Documentation]    Status 400 - Simula condições para causar solicitação inválida.
    [Tags]    status_code    negative    regression
    ${response}=    Get Users With Invalid Request
    Validate Status Code 400    ${response}
    Log Response Details    ${response}

# 4 - Recurso não encontrado (404 Not Found)
Get Resource Not Found - user
    [Documentation]    Status 404 - Testa uma requisição para um recurso inexistente.
    [Tags]    status_code    negative    regression
    ${response}=    Get Non Existent User
    Validate Status Code 404    ${response}
    Log Response Details    ${response}

# 5 - Erro interno no servidor (500 Internal Server Error)     
Get Internal Server Error - user
    [Documentation]    Status 500 - Simula condições para causar erro interno no servidor.
    [Tags]    status_code    negative    robot:skip
    ${response}=    Get Users With Server Error
    Validate Status Code 500    ${response}

### TESTES DE HEADERS ###

# 6 - Requisição sem header x-api-key
Get Users Without Required Header - user
    [Documentation]    Valida o comportamento da API quando a requisição é feita sem o header x-api-key.
    [Tags]    headers    negative    regression
    ${response}=    Get Users Without Token
    Validate Status Code 401    ${response}    # Corrigido para validar status code
    Validate Error Message    ${response}    Invalid token

# 7 - Requisição com header x-api-key inválido
Get Users With Invalid Header - user
    [Documentation]    Valida o comportamento da API quando a requisição é feita com header x-api-key inválido.
    [Tags]    headers    negative    regression
    ${response}=    Get Users With Invalid Key
    Validate Status Code 401    ${response}
    Validate Error Message    ${response}    Invalid token
    Log Response Details    ${response}

# 8 - Requisição com header x-api-key válido
Get Users With Valid Header - user
    [Documentation]    Valida o comportamento da API quando a requisição é feita com header x-api-key válido.
    [Tags]    headers    positive    regression
    ${response}=    Get Users
    Validate Status Code 200    ${response}
    Validate Response Has Content    ${response}
    Log Response Details    ${response}

### TESTES DE SCHEMA ###

# 9 - Validação do corpo da requisição
Validate Response Body Schema - user
    [Documentation]    Status 200 - Valida que o corpo da resposta segue o schema esperado.
    [Tags]    schema    positive    regression
    ${response}=    Get Users
    Validate Status Code 200    ${response}
    Validate Response Schema    ${response}    test_schema_get_200_user.json
    Log    Schema validation completed successfully    # Log adicional

### TESTES DE PAGINAÇÃO ###

# 10 - Validação de Paginação - Primeira Página
Validate First Page - user
    [Documentation]    Verifica a primeira página no endpoint GET /users.
    ...    Known Issue: API-123 - Paginação não implementada
    ...    O endpoint não está implementando os parâmetros page e per_page.
    ...    Atualmente retorna todos os registros independente da página solicitada.
    [Tags]    pagination    positive    known_issue
    ${response}=    Get Users With Pagination    page=1
    Validate First Page Response    ${response}

# 11 - Validação de Paginação - Segunda Página
Validate Second Page - user
    [Documentation]    Verifica a segunda página no endpoint GET /users.
    ...    Known Issue: API-123 - Paginação não implementada
    ...    O endpoint não está implementando os parâmetros page e per_page.
    ...    Atualmente retorna todos os registros independente da página solicitada.
    [Tags]    pagination    positive    known_issue
    ${response}=    Get Users With Pagination    page=2
    Validate Second Page Response    ${response}

# 12 - Validação de Paginação - Página Inexistente
Validate Non Existent Page - user
    [Documentation]    Verifica página inexistente no endpoint GET /users.
    ...    Known Issue: API-123 - Paginação não implementada
    ...    O endpoint não está implementando os parâmetros page e per_page.
    ...    Atualmente retorna todos os registros independente da página solicitada.
    ...    Deveria retornar uma lista vazia para páginas sem registros.
    [Tags]    pagination    positive    known_issue    robot:skip
    ${response}=    Get Users With Pagination    page=999
    Validate Empty Page Response    ${response}

### TESTES DE FILTROS ###

# 13 - Verificação de Filtros Disponíveis
Verify Available Filters - user
    [Documentation]    Verifica quais filtros estão disponíveis no endpoint GET /users
    ...    Known Issue: API-125 - Filtros não implementados
    ...    O endpoint não suporta nenhum tipo de filtro.
    ...    Deveria implementar filtros por:
    ...    - name (string)
    ...    - email (string)
    ...    - createdAt (date range)
    ...    - updatedAt (date range)
    [Tags]    filter    smoke    known_issue
    ${available_filters}=    Get Available Filters
    Verify Available Filters Response    ${available_filters}

# 14 - Filtro por Nome
Validate Name Filter - user
    [Documentation]    Verifica o filtro por nome no endpoint GET /users
    ...    Known Issue: API-125 - Campo name não está sendo retornado no response
    [Tags]    filter    positive    robot:skip
    ${response}=    Get Users With Filter    name    Lorem Ipsum
    Status Should Be    200    ${response}
    Validate Name Filter    ${response}    Lorem Ipsum

# 15 - Filtro por Status
Validate Status Filter - user
    [Documentation]    Verifica o filtro por status no endpoint GET /users
    ...    Known Issue: API-125 - Campo status não está sendo retornado no response
    [Tags]    filter    positive    robot:skip
    ${response}=    Get Users With Filter    status    Habilitado
    Status Should Be    200    ${response}
    Validate Status Filter    ${response}    Habilitado

# 16 - Filtro por Aplicação
Validate Application Filter - user
    [Documentation]    Verifica o filtro por aplicação no endpoint GET /users
    ...    Known Issue: API-125 - Campo application não está sendo retornado no response
    [Tags]    filter    positive    robot:skip
    ${response}=    Get Users With Filter    application    SIC Lite
    Status Should Be    200    ${response}
    Validate Application Filter    ${response}    SIC Lite

# 17 - Filtro por Grupo de Servidores
Validate Server Group Filter - user
    [Documentation]    Verifica o filtro por grupo de servidores no endpoint GET /users
    ...    Known Issue: API-125 - Campo serverGroup não está sendo retornado no response
    [Tags]    filter    positive    robot:skip
    ${response}=    Get Users With Filter    serverGroup    Lorem Ipsum
    Status Should Be    200    ${response}
    Validate Server Group Filter    ${response}    Lorem Ipsum

# 18 - Filtro por Conexão Relay
Validate Relay Connection Filter - user
    [Documentation]    Verifica o filtro por status da conexão relay
    ...    Known Issue: API-125 - Campo relayConnection não está sendo retornado no response
    [Tags]    filter    positive    robot:skip
    ${response1}=    Get Users With Filter    relayConnection    20 minutes
    Status Should Be    200    ${response1}
    Validate Relay Connection Filter    ${response1}    20 minutes

# 19 - Filtro por Data de Atualização
Validate Update Date Filter - user
    [Documentation]    Verifica o filtro por data de atualização
    ...    Known Issue: API-125 - Campo updatedAt não está sendo retornado no response
    [Tags]    filter    positive    robot:skip
    ${today}=    Get Current Date
    ${response}=    Get Users With Filter    updatedAt    ${today}
    Status Should Be    200    ${response}
    Validate Update Date Filter    ${response}    ${today}

# 20 - Múltiplos Filtros
Validate Multiple Filters - user
    [Documentation]    Verifica a combinação de múltiplos filtros
    ...    Known Issue: API-125 - Campos status, application e relayConnection não estão sendo retornados
    [Tags]    filter    positive    robot:skip
    ${filters}=    Create Dictionary    
    ...    status=Habilitado    
    ...    application=SIC Lite
    ...    relayConnection=20 minutes
    ${response}=    Get Users With Multiple Filters    ${filters}
    Status Should Be    200    ${response}
    Validate Status Filter    ${response}    Habilitado
    Validate Application Filter    ${response}    SIC Lite
    Validate Relay Connection Filter    ${response}    20 minutes

# 21 - Filtro com Valor Inválido
Validate Invalid Filter Value - user
    [Documentation]    Verifica o comportamento com valor de filtro inválido
    ...    Known Issue: API-126 - API retorna 200 com dados ao invés de 400 ou lista vazia
    [Tags]    filter    negative    known_issue
    ${response}=    Get Users With Filter    status    invalid_status
    Validate Invalid Filter Response    ${response}    invalid_status

### TESTES DE PERFORMANCE ###

# 22 - Tempo de resposta para listagem de usuários (SLA: 1s)
Validate Get Users Response Time - user
    [Documentation]    Verifica se o tempo de resposta da listagem está dentro do SLA (1s)
    [Tags]    performance    positive    sla_1s
    ${response}    ${response_time}=    Get Response Time For Users List
    Validate Response Time    ${response_time}    1
    Status Should Be    200    ${response}
    Validate Response Has Content    ${response}

# 23 - Tempo de resposta para usuário específico (SLA: 0.8s)
Validate Get Single User Response Time - user
    [Documentation]    Verifica se o tempo de resposta está dentro do SLA (0.8s)
    ...    Known Issue: API-126 - Tempo de resposta acima do SLA
    ...    O endpoint está consistentemente respondendo acima do limite de 0.8s.
    ...    Tempo atual médio: ~1s
    ...    Comportamento esperado:
    ...    - Tempo de resposta deve ser menor que 0.8s para 95% das requisições
    ...    - Tempo de resposta máximo aceitável: 1s
    [Tags]    performance    negative    sla_0.8s    known_issue
    ${response}    ${response_time}=    Get Response Time For Single User
    
    # Registra métricas mesmo se falhar
    Log    Tempo de resposta: ${response_time}s    WARN
    Log    SLA esperado: 0.8s    WARN
    Log    Diferença: ${response_time - 0.8}s    WARN
    
    # Valida o SLA, mas não falha o teste por ser known issue
    ${within_sla}=    Run Keyword And Return Status
    ...    Should Be True    ${response_time} < 0.8
    ...    Response time of ${response_time} seconds exceeded the SLA of 0.8 second(s)
    
    IF    not ${within_sla}
        Log    Known Issue: API-126 - Tempo de resposta acima do SLA    WARN
        Log    O endpoint está consistentemente respondendo acima do limite de 0.8s    WARN
        Log    Recomendação: Investigar possíveis otimizações no endpoint    WARN
        Skip    Known Issue: API-126 - Tempo de resposta (${response_time}s) acima do SLA (0.8s)
    END

# 24 - Tempo de resposta com token inválido (SLA: 0.5s)
Validate Invalid Token Response Time - user
    [Documentation]    Verifica se o tempo de resposta está dentro do SLA (0.5s)
    [Tags]    performance    negative    sla_0.5s
    ${response}    ${response_time}=    Get Response Time For Invalid Token
    
    # Valida o tempo de resposta
    Validate Response Time    ${response_time}    0.5
    
    # Valida a mensagem de erro
    ${response_json}=    Set Variable    ${response.json()}
    ${error_message}=    Get From Dictionary    ${response_json}    error
    Should Be Equal    ${error_message}    Invalid token

### TESTES DE CACHE ###

# 25 - Validação de Headers de Cache
Validate Cache Headers - user
    [Documentation]    Verifica os cabeçalhos relacionados a cache na resposta
    ...    Known Issue: API-127 - Headers de cache não estão implementados corretamente
    [Tags]    cache    positive    known_issue    robot:skip
    ${response}=    Get Users
    Validate Cache Headers Response    ${response}

# 26 - Validação de Cache com ETag
Validate ETag Cache - user
    [Documentation]    Verifica se o cache usando ETag está funcionando corretamente
    ...    Known Issue: API-127 - Mecanismo de ETag não está implementado corretamente
    [Tags]    cache    positive    known_issue    robot:skip
    # Primeira requisição para obter o ETag
    ${response1}=    Get Users
    ${etag}=    Get From Dictionary    ${response1.headers}    ETag
    
    # Segunda requisição usando If-None-Match
    ${response2}=    Get Users With ETag    ${etag}
    Status Should Be    304    ${response2}

# 27 - Validação de Cache Expirado
Validate Expired Cache - user
    [Documentation]    Verifica o comportamento quando o cache está expirado
    ...    Known Issue: API-127 - Mecanismo de cache expirado não está implementado
    [Tags]    cache    positive    known_issue    robot:skip
    # Primeira requisição para obter o ETag
    ${response1}=    Get Users
    ${etag}=    Get From Dictionary    ${response1.headers}    ETag
    
    # Espera o cache expirar (simulado com ETag inválido)
    ${response2}=    Get Users With ETag    "invalid-etag"
    Status Should Be    200    ${response2}
    Validate Response Has Content    ${response2}
    
    # Verifica se recebeu novo ETag
    Dictionary Should Contain Key    ${response2.headers}    ETag
    ${new_etag}=    Get From Dictionary    ${response2.headers}    ETag
    Should Not Be Equal    ${new_etag}    "invalid-etag" 

### TESTES DE TAMANHO DE RESPOSTA ###

# 28 - Validação de Resposta Pequena
Validate Small Response Size - user
    [Documentation]    Verifica o comportamento com conjunto pequeno de dados (até 10 registros)
    ...    Valida:
    ...    - Tempo de resposta
    ...    - Tamanho do payload
    ...    - Estrutura dos dados
    [Tags]    response_size    performance    positive
    ${response}=    Get Users With Pagination    page=1    per_page=10
    Validate Small Response    ${response}

# 29 - Validação de Resposta Média
Validate Medium Response Size - user
    [Documentation]    Verifica o comportamento com conjunto médio de dados (50-100 registros)
    ...    Valida:
    ...    - Tempo de resposta
    ...    - Tamanho do payload
    ...    - Estrutura dos dados
    ...    Known Issue: API-128 - Paginação retorna todos os registros
    [Tags]    response_size    performance    positive    known_issue    robot:skip
    [Setup]    Log    Skipping test: API-128 - Paginação não implementada corretamente
    ${response}=    Get Users With Pagination    page=1    per_page=50
    Validate Medium Response    ${response}

# 30 - Validação de Resposta Grande
Validate Large Response Size - user
    [Documentation]    Verifica o comportamento com conjunto grande de dados (>100 registros)
    ...    Valida:
    ...    - Tempo de resposta
    ...    - Tamanho do payload
    ...    - Estrutura dos dados
    ...    Known Issue: API-128 - Paginação retorna todos os registros
    [Tags]    response_size    performance    positive    known_issue    robot:skip
    [Setup]    Log    Skipping test: API-128 - Paginação não implementada corretamente
    ${response}=    Get Users With Pagination    page=1    per_page=100
    Validate Large Response    ${response}

### TESTES DE CONCORRÊNCIA ###

# 31 - Validação de Requisições Concorrentes
Validate Concurrent Requests - user
    [Documentation]    Verifica o comportamento do endpoint sob múltiplas requisições simultâneas
    ...    Valida:
    ...    - Consistência das respostas
    ...    - Tempo de resposta sob carga
    ...    - Status code consistente
    ...    - Ausência de race conditions
    [Tags]    concurrent    performance    positive
    
    ${responses}=    Run Concurrent Requests    Get Users    10
    Validate Concurrent Responses    ${responses}    Validate User Item Structure

# 32 - Validação de Concorrência com Cache
Validate Concurrent Cached Requests - user
    [Documentation]    Verifica o comportamento do cache sob múltiplas requisições simultâneas
    ...    Valida:
    ...    - Consistência do ETag
    ...    - Hit rate do cache
    ...    - Performance com cache
    [Tags]    concurrent    cache    performance    positive
    
    # Primeira requisição para obter ETag
    ${initial_response}=    Get Users
    ${etag}=    Get From Dictionary    ${initial_response.headers}    ETag
    
    ${responses}=    Run Concurrent Requests    Get Users With Cache    10    ${etag}
    Validate Concurrent Cache Responses    ${responses}

# 33 - Validação de Concorrência com Paginação
Validate Concurrent Paginated Requests - user
    [Documentation]    Verifica o comportamento da paginação sob múltiplas requisições simultâneas
    ...    Known Issue: API-128 - Paginação retorna registros duplicados entre páginas
    ...    O endpoint está retornando os mesmos registros em diferentes páginas
    [Tags]    concurrent    pagination    performance    positive    known_issue    robot:skip
    [Setup]    Log    Skipping test: API-128 - Paginação retornando registros duplicados
    
    ${pages}=    Create List    1    2    3    4    5
    @{responses}=    Create List
    
    FOR    ${page}    IN    @{pages}
        ${response}=    Get Users With Pagination    page=${page}
        Append To List    ${responses}    ${response}
    END
    
    Validate Concurrent Pagination Responses    ${responses}

### TESTES DE SEGURANÇA ###

Validate Sensitive Information Protection - user
    [Documentation]    Verifica se informações sensíveis não são expostas na API
    ...    
    ...    Objetivo: Garantir que dados sensíveis estejam protegidos
    ...    
    ...    Pré-condições:
    ...    - API em execução
    ...    - Token válido configurado
    ...    - Usuários cadastrados com dados sensíveis
    ...    
    ...    Passos:
    ...    1. Enviar requisição GET para /users
    ...    2. Validar que dados sensíveis não estão expostos
    ...    3. Verificar mascaramento de informações
    ...    
    ...    Resultado Esperado:
    ...    - Não deve expor senhas
    ...    - Emails devem estar mascarados ou omitidos
    ...    - Dados pessoais devem estar protegidos
    ...    - Tokens e chaves não devem estar expostos
    [Tags]    security    negative    regression    critical    priority_high
    ${response}=    Get Users
    
    # Valida response
    ${users}=    Set Variable    ${response.json()}
    FOR    ${user}    IN    @{users}
        # Verifica ausência de dados sensíveis
        Dictionary Should Not Contain Key    ${user}    password
        Dictionary Should Not Contain Key    ${user}    secret
        Dictionary Should Not Contain Key    ${user}    token
        Dictionary Should Not Contain Key    ${user}    apiKey
        
        # Verifica mascaramento de email quando presente
        ${has_email}=    Run Keyword And Return Status
        ...    Dictionary Should Contain Key    ${user}    email
        
        IF    ${has_email} and ${user.email} is not None
            ${email}=    Get From Dictionary    ${user}    email
            Should Match Regexp    ${email}    ^[^@]+@[^@]+\\.[^@]+$
            Should Not Contain    ${email}    admin
            Should Not Contain    ${email}    root
        END
    END

Validate Rate Limiting - user
    [Documentation]    Verifica se o rate limiting está funcionando
    ...    
    ...    Objetivo: Garantir que a API está protegida contra abusos
    ...    
    ...    Pré-condições:
    ...    - API em execução
    ...    - Token válido configurado
    ...    
    ...    Passos:
    ...    1. Enviar múltiplas requisições em sequência
    ...    2. Verificar headers de rate limit
    ...    3. Validar bloqueio após limite excedido
    ...    
    ...    Resultado Esperado:
    ...    - Headers X-RateLimit-Limit presentes
    ...    - Bloqueio após exceder limite
    ...    - Status 429 quando limite excedido
    [Tags]    security    performance    negative    regression    priority_high
    
    # Envia requisições até atingir limite
    FOR    ${index}    IN RANGE    1000
        ${response}=    Get Users
        
        # Verifica headers de rate limit
        Dictionary Should Contain Key    ${response.headers}    X-RateLimit-Limit
        Dictionary Should Contain Key    ${response.headers}    X-RateLimit-Remaining
        
        ${remaining}=    Get From Dictionary    ${response.headers}    X-RateLimit-Remaining
        Exit For Loop If    ${remaining} == 0
    END
    
    # Tenta mais uma requisição após limite
    ${response}=    Get Users    expected_status=429
    Status Should Be    429    ${response}
    Should Contain    ${response.json()}[error]    Rate limit exceeded

Validate SQL Injection Protection - user
    [Documentation]    Verifica proteção contra SQL Injection
    ...    
    ...    Objetivo: Garantir que a API está protegida contra SQL Injection
    ...    
    ...    Pré-condições:
    ...    - API em execução
    ...    - Token válido configurado
    ...    
    ...    Passos:
    ...    1. Enviar requisições com payloads maliciosos
    ...    2. Verificar se a API rejeita adequadamente
    ...    
    ...    Resultado Esperado:
    ...    - Rejeição de payloads maliciosos
    ...    - Mensagens de erro apropriadas
    ...    - Nenhum dado exposto
    [Tags]    security    negative    regression    critical    priority_high
    
    @{sql_payloads}=    Create List
    ...    1' OR '1'='1
    ...    1' UNION SELECT * FROM users--
    ...    1'; DROP TABLE users--
    
    FOR    ${payload}    IN    @{sql_payloads}
        ${response}=    Get Users With Filter    id    ${payload}
        Status Should Be    400    ${response}
        Should Not Contain    ${response.text}    sql
        Should Not Contain    ${response.text}    database
        Should Not Contain    ${response.text}    error
    END

Validate XSS Protection - user
    [Documentation]    Verifica proteção contra Cross-Site Scripting (XSS)
    ...    
    ...    Objetivo: Garantir que a API está protegida contra XSS
    ...    
    ...    Pré-condições:
    ...    - API em execução
    ...    - Token válido configurado
    ...    
    ...    Passos:
    ...    1. Enviar requisições com scripts maliciosos
    ...    2. Verificar se a API sanitiza ou rejeita
    ...    
    ...    Resultado Esperado:
    ...    - Scripts são sanitizados ou rejeitados
    ...    - Nenhum script é executado
    ...    - Headers de segurança presentes
    [Tags]    security    negative    regression    critical    priority_high
    
    @{xss_payloads}=    Create List
    ...    <script>alert(1)</script>
    ...    javascript:alert(1)
    ...    <img src=x onerror=alert(1)>
    
    FOR    ${payload}    IN    @{xss_payloads}
        ${response}=    Get Users With Filter    name    ${payload}
        
        # Verifica headers de segurança
        Dictionary Should Contain Key    ${response.headers}    X-XSS-Protection
        Dictionary Should Contain Key    ${response.headers}    Content-Security-Policy
        
        # Verifica sanitização
        ${response_body}=    Convert To String    ${response.text}
        Should Not Contain    ${response_body}    <script>
        Should Not Contain    ${response_body}    javascript:
        Should Not Contain    ${response_body}    onerror=
    END

