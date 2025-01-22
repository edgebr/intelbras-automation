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
...    - API-126: Performance abaixo do SLA
...    - API-127: Problemas no ETag
...    - API-128: Duplicação em paginação
...    - API-129: Rate Limiting não implementado
...    - API-130: Endpoint vulnerável a SQL Injection
...    - API-131: Headers de proteção XSS não implementados
...    - API-132: Dados sensíveis expostos sem mascaramento

Resource          ../../../resources/resource.resource
Resource          ../../../resources/page/api/2user/1GET_user.resource

Force Tags        api    get_users
Default Tags      regression

Suite Setup       resource.Suite Setup
Suite Teardown    Delete All Sessions

*** Variables ***
&{KNOWN_ISSUES}    
...    API-123=Paginação não implementada
...    API-124=Cache headers incorretos
...    API-126=Performance abaixo do SLA
...    API-127=Problemas no ETag
...    API-128=Duplicação em paginação
...    API-129=Headers de Rate Limiting não implementados
...    API-130=Endpoint vulnerável a SQL Injection
...    API-131=Headers de proteção XSS não implementados
...    API-132=Dados sensíveis expostos sem mascaramento

*** Test Cases ***
### TESTES DE STATUS CODE ###

# GET-1 - Requisição bem-sucedida (200 OK)
Get Successful Response - user
    [Documentation]    Validar resposta bem-sucedida do endpoint GET /users
    ...    
    ...    ID: GET-1
    ...    
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /users
    ...    Então devo receber status code 200
    ...    E devo receber uma lista de usuários
    ...    E os dados devem estar em formato JSON válido
    [Tags]    status_code    positive    regression    smoke    priority_high    data_validation    critical    GET-1
    ${response}=    Get Users
    Validate Status Code 200    ${response}
    Validate Response Has Content    ${response}
    Log    Response: ${response.json()}

# GET-2 - Requisição sem autenticação (401 Unauthorized)
Get Unauthorized Response - user
    [Documentation]    Validar comportamento da API quando requisição é feita sem token
    ...    
    ...    ID: GET-2
    ...    
    ...    Dado que não envio token de autenticação
    ...    Quando faço uma requisição GET para /users
    ...    Então devo receber status code 401
    ...    E devo receber a mensagem "Invalid token"
    [Tags]    api    get_users    negative    priority_high    regression    security    status_code    GET-2
    ${response}=    Get Users Without Token
    Validate Status Code 401    ${response}
    Validate Error Message    ${response}    Invalid token

# GET-3 - Requisição inválida (400 Bad Request)
Get Bad Request Error - user
    [Documentation]    Validar comportamento da API com requisição inválida
    ...    
    ...    ID: GET-3
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /users com parâmetros inválidos
    ...    Então devo receber status code 400
    ...    E devo receber uma mensagem de erro apropriada
    [Tags]    status_code    negative    regression    GET-3
    ${response}=    Get Users With Invalid Request
    Validate Status Code 400    ${response}
    Log Response Details    ${response}

# GET-4 - Recurso não encontrado (404 Not Found)
Get Resource Not Found - user
    [Documentation]    Validar comportamento da API ao buscar recurso inexistente
    ...    
    ...    ID: GET-4
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para um usuário que não existe
    ...    Então devo receber status code 404
    ...    E devo receber uma mensagem indicando que o recurso não foi encontrado
    [Tags]    status_code    negative    regression    GET-4
    ${response}=    Get Non Existent User
    Validate Status Code 404    ${response}
    Log Response Details    ${response}

# GET-5 - Erro interno no servidor (500 Internal Server Error)     
Get Internal Server Error - user
    [Documentation]    Validar comportamento da API em caso de erro interno
    ...    
    ...    ID: GET-5
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição que causa erro interno no servidor
    ...    Então devo receber status code 500
    ...    E devo receber uma mensagem de erro interno do servidor
    [Tags]    status_code    negative    robot:skip    GET-5
    ${response}=    Get Users With Server Error
    Validate Status Code 500    ${response}

### TESTES DE HEADERS ###

# GET-6 - Requisição sem header x-api-key
Get Users Without Required Header - user
    [Documentation]    Validar comportamento da API quando a requisição é feita sem o header x-api-key
    ...    
    ...    ID: GET-6
    ...
    ...    Dado que não envio o header x-api-key
    ...    Quando faço uma requisição GET para /users
    ...    Então devo receber status code 401
    ...    E devo receber a mensagem "Invalid token"
    [Tags]    headers    negative    regression    GET-6
    ${response}=    Get Users Without Token
    Validate Status Code 401    ${response}
    Validate Error Message    ${response}    Invalid token

# GET-7 - Requisição com header x-api-key inválido
Get Users With Invalid Header - user
    [Documentation]    Validar comportamento da API quando requisição é feita com token inválido
    ...    
    ...    ID: GET-7
    ...
    ...    Dado que envio um token de autenticação inválido
    ...    Quando faço uma requisição GET para /users
    ...    Então devo receber status code 401
    ...    E devo receber a mensagem "Invalid token"
    ...    E os detalhes da resposta devem ser registrados
    [Tags]    headers    negative    regression    GET-7
    ${response}=    Get Users With Invalid Key
    Validate Status Code 401    ${response}
    Validate Error Message    ${response}    Invalid token
    Log Response Details    ${response}

# GET-8 - Requisição com header x-api-key válido
Get Users With Valid Header - user
    [Documentation]    Validar comportamento da API quando a requisição é feita com header x-api-key válido
    ...    
    ...    ID: GET-8
    ...
    ...    Dado que envio um token de autenticação válido
    ...    Quando faço uma requisição GET para /users
    ...    Então devo receber status code 200
    ...    E devo receber uma lista de usuários
    [Tags]    headers    positive    regression    GET-8
    ${response}=    Get Users
    Validate Status Code 200    ${response}
    Validate Response Has Content    ${response}
    Log Response Details    ${response}

### TESTES DE SCHEMA ###

# GET-9 - Validação do corpo da requisição
Validate Response Body Schema - user
    [Documentation]    Validar que o corpo da resposta segue o schema esperado
    ...    
    ...    ID: GET-9
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /users
    ...    Então devo receber status code 200
    ...    E o corpo da resposta deve seguir o schema esperado
    [Tags]    schema    positive    regression    GET-9
    ${response}=    Get Users
    Validate Status Code 200    ${response}
    Validate Response Schema    ${response}    test_schema_get_200_user.json
    Log    Schema validation completed successfully

### TESTES DE PAGINAÇÃO ###

# GET-10 - Validação de Paginação - Primeira Página
Validate First Page - user
    [Documentation]    Validar a primeira página no endpoint GET /users
    ...    
    ...    ID: GET-10
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /users com paginação na primeira página
    ...    Então devo receber status code 200
    ...    E devo receber a primeira página de resultados
    [Tags]    pagination    positive    known_issue    GET-10
    ${response}=    Get Users With Pagination    page=1
    Validate First Page Response    ${response}

# GET-11 - Validação de Paginação - Segunda Página
Validate Second Page - user
    [Documentation]    Validar a segunda página no endpoint GET /users
    ...    
    ...    ID: GET-11
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /users com paginação na segunda página
    ...    Então devo receber status code 200
    ...    E devo receber a segunda página de resultados
    [Tags]    pagination    positive    known_issue    GET-11
    ${response}=    Get Users With Pagination    page=2
    Validate Second Page Response    ${response}

# GET-12 - Validação de Paginação - Página Inexistente
Validate Non Existent Page - user
    [Documentation]    Validar comportamento ao solicitar uma página inexistente
    ...    
    ...    ID: GET-12
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /users com paginação em uma página inexistente
    ...    Então devo receber status code 200
    ...    E devo receber uma lista vazia
    [Tags]    pagination    positive    known_issue    robot:skip    GET-12
    ${response}=    Get Users With Pagination    page=999
    Validate Empty Page Response    ${response}

### TESTES DE FILTROS ###

# GET-13 - Verificação do Filtro por Nome
Verify Name Filter - user
    [Documentation]    Validar o filtro por nome no endpoint GET /users
    ...    
    ...    ID: GET-13
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /users com filtro de nome
    ...    Então devo receber status code 200
    ...    E os resultados devem corresponder ao filtro aplicado
    [Tags]    filter    smoke    regression    GET-13
    ${response}=    Get Users With Filter    name    test
    Validate Name Filter Response    ${response}    test

# GET-14 - Validação de Caracteres Especiais no Filtro
Validate Special Characters In Name Filter - user
    [Documentation]    Validar comportamento do filtro com caracteres especiais
    ...    
    ...    ID: GET-14
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /users com filtro de nome contendo caracteres especiais
    ...    Então devo receber status code 200
    ...    E os resultados devem ser adequadamente filtrados
    [Tags]    filter    negative    regression    GET-14
    @{special_chars}=    Create List    @    #    $    %    &    *
    
    FOR    ${char}    IN    @{special_chars}
        Test Name Filter With Special Characters    ${char}
    END

# GET-15 - Pesquisa Case Insensitive
Validate Case Insensitive Search - user
    [Documentation]    Validar se a pesquisa é case insensitive
    ...    
    ...    ID: GET-15
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /users com filtro de nome em diferentes cases
    ...    Então devo receber status code 200
    ...    E os resultados devem ser os mesmos independentemente do case
    [Tags]    filter    positive    regression    GET-15
    @{variations}=    Create List    usuário    Usuário    USUÁRIO
    
    FOR    ${term}    IN    @{variations}
        Test Case Insensitive Search    ${term}
    END

# GET-16 - Pesquisa Sem Resultados
Validate Empty Search Results - user
    [Documentation]    Validar comportamento quando não há resultados para o filtro
    ...    
    ...    ID: GET-16
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /users com filtro de nome que não retorna resultados
    ...    Então devo receber status code 200
    ...    E a lista de resultados deve estar vazia
    [Tags]    filter    negative    regression    GET-16
    ${response}=    Get Users With Filter    name    usuário_inexistente_xyz
    Validate Filter Response Structure    ${response}

### TESTES DE PERFORMANCE ###

# GET-22 - Tempo de resposta para listagem de usuários (SLA: 1s)
Validate Get Users Response Time - user
    [Documentation]    Validar se o tempo de resposta da listagem está dentro do SLA (1s)
    ...    
    ...    ID: GET-22
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /users
    ...    Então o tempo de resposta deve ser menor que 1 segundo
    [Tags]    performance    positive    sla_1s    GET-22
    ${response}    ${response_time}=    Get Response Time For Users List
    Validate Response Time    ${response_time}    1
    Status Should Be    200    ${response}
    Validate Response Has Content    ${response}

# GET-23 - Tempo de resposta para usuário específico (SLA: 0.8s)
Validate Get Single User Response Time - user
    [Documentation]    Validar se o tempo de resposta para um usuário específico está dentro do SLA (0.8s)
    ...    
    ...    ID: GET-23
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para um usuário específico
    ...    Então o tempo de resposta deve ser menor que 0.8 segundos
    [Tags]    performance    negative    sla_0.8s    known_issue    GET-23
    ${response}    ${response_time}=    Get Response Time For Single User
    
    Log    Tempo de resposta: ${response_time}s    WARN
    Log    SLA esperado: 0.8s    WARN
    Log    Diferença: ${response_time - 0.8}s    WARN
    
    ${within_sla}=    Run Keyword And Return Status
    ...    Should Be True    ${response_time} < 0.8
    ...    Response time of ${response_time} seconds exceeded the SLA of 0.8 second(s)
    
    IF    not ${within_sla}
        Log    Known Issue: API-126 - Tempo de resposta acima do SLA    WARN
    END

# GET-24 - Tempo de resposta com token inválido (SLA: 0.5s)
Validate Invalid Token Response Time - user
    [Documentation]    Validar tempo de resposta com token inválido
    ...    
    ...    ID: GET-24
    ...
    ...    Dado que envio um token de autenticação inválido
    ...    Quando faço uma requisição GET para /users
    ...    Então o tempo de resposta deve ser menor que 0.5 segundos
    ...    E devo receber a mensagem "Invalid token"
    [Tags]    performance    negative    sla_0.5s    GET-24
    ${response}    ${response_time}=    Get Response Time For Invalid Token
    
    # Valida o tempo de resposta
    Validate Response Time    ${response_time}    0.5
    
    # Valida a mensagem de erro
    ${response_json}=    Set Variable    ${response.json()}
    ${error_message}=    Get From Dictionary    ${response_json}    error
    Should Be Equal    ${error_message}    Invalid token

### TESTES DE CACHE ###

# GET-25 - Validação de Headers de Cache
Validate Cache Headers - user
    [Documentation]    Validar headers de cache na resposta
    ...    
    ...    ID: GET-25
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /users
    ...    Então devo receber headers de cache apropriados
    ...    Known Issue: API-127 - Headers de cache não estão implementados corretamente
    [Tags]    cache    positive    known_issue    robot:skip    GET-25
    ${response}=    Get Users
    Validate Cache Headers Response    ${response}

# GET-26 - Validação de Cache com ETag
Validate ETag Cache - user
    [Documentation]    Validar se o cache usando ETag está funcionando corretamente
    ...    
    ...    ID: GET-26
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /users
    ...    Então devo receber um ETag no header
    ...    E ao usar o ETag em uma nova requisição, devo receber status code 304
    ...    Known Issue: API-127 - Mecanismo de ETag não está implementado corretamente
    [Tags]    cache    positive    known_issue    robot:skip    GET-26
    # Primeira requisição para obter o ETag
    ${response1}=    Get Users
    ${etag}=    Get From Dictionary    ${response1.headers}    ETag
    
    # Segunda requisição usando If-None-Match
    ${response2}=    Get Users With ETag    ${etag}
    Status Should Be    304    ${response2}

# GET-27 - Validação de Cache Expirado
Validate Expired Cache - user
    [Documentation]    Validar comportamento quando o cache está expirado
    ...    
    ...    ID: GET-27
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /users
    ...    Então devo receber um ETag no header
    ...    E ao usar um ETag inválido, devo receber status code 200
    ...    E devo receber um novo ETag
    ...    Known Issue: API-127 - Mecanismo de cache expirado não está implementado
    [Tags]    cache    positive    known_issue    robot:skip    GET-27
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

# GET-28 - Validação de Resposta Pequena
Validate Small Response Size - user
    [Documentation]    Validar comportamento com conjunto pequeno de dados (até 10 registros)
    ...    
    ...    ID: GET-28
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /users com paginação de 10 registros por página
    ...    Então devo receber status code 200
    ...    E o tempo de resposta deve ser adequado
    ...    E o tamanho do payload deve ser pequeno
    [Tags]    response_size    performance    positive    GET-28
    ${response}=    Get Users With Pagination    page=1    per_page=10
    Validate Small Response    ${response}

# GET-29 - Validação de Resposta Média
Validate Medium Response Size - user
    [Documentation]    Validar comportamento com conjunto médio de dados (50-100 registros)
    ...    
    ...    ID: GET-29
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /users com paginação de 50 registros por página
    ...    Então devo receber status code 200
    ...    E o tempo de resposta deve ser adequado
    ...    E o tamanho do payload deve ser médio
    ...    Known Issue: API-128 - Paginação retorna todos os registros
    [Tags]    response_size    performance    positive    known_issue    robot:skip    GET-29
    [Setup]    Log    Skipping test: API-128 - Paginação não implementada corretamente
    ${response}=    Get Users With Pagination    page=1    per_page=50
    Validate Medium Response    ${response}

# GET-30 - Validação de Resposta Grande
Validate Large Response Size - user
    [Documentation]    Validar comportamento com conjunto grande de dados (>100 registros)
    ...    
    ...    ID: GET-30
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /users com paginação de 100 registros por página
    ...    Então devo receber status code 200
    ...    E o tempo de resposta deve ser adequado
    ...    E o tamanho do payload deve ser grande
    ...    Known Issue: API-128 - Paginação retorna todos os registros
    [Tags]    response_size    performance    positive    known_issue    robot:skip    GET-30
    [Setup]    Log    Skipping test: API-128 - Paginação não implementada corretamente
    ${response}=    Get Users With Pagination    page=1    per_page=100
    Validate Large Response    ${response}

### TESTES DE CONCORRÊNCIA ###

# GET-31 - Validação de Requisições Concorrentes
Validate Concurrent Requests - user
    [Documentation]    Validar comportamento do endpoint sob múltiplas requisições simultâneas
    ...    
    ...    ID: GET-31
    ...
    ...    Dado que faço múltiplas requisições GET para /users simultaneamente
    ...    Então devo receber respostas consistentes
    ...    E o tempo de resposta deve ser adequado
    ...    E o status code deve ser consistente
    [Tags]    concurrent    performance    positive    GET-31
    ${responses}=    Run Concurrent Requests    Get Users    10
    Validate Concurrent Responses    ${responses}    Validate User Item Structure

# GET-32 - Validação de Concorrência com Cache
Validate Concurrent Cached Requests - user
    [Documentation]    Validar comportamento do cache sob múltiplas requisições simultâneas
    ...
    ...    Dado que faço múltiplas requisições GET para /users com cache simultaneamente
    ...    Então devo receber respostas consistentes
    ...    E o ETag deve ser consistente
    [Tags]    concurrent    cache    performance    positive
    # Primeira requisição para obter ETag
    ${initial_response}=    Get Users
    ${etag}=    Get From Dictionary    ${initial_response.headers}    ETag
    
    ${responses}=    Run Concurrent Requests    Get Users With Cache    10    ${etag}
    Validate Concurrent Cache Responses    ${responses}

# GET-33 - Validação de Concorrência com Paginação
Validate Concurrent Paginated Requests - user
    [Documentation]    Validar comportamento da paginação sob múltiplas requisições simultâneas
    ...
    ...    Dado que faço múltiplas requisições GET para /users com paginação simultaneamente
    ...    Então devo receber respostas consistentes
    ...    E os registros não devem ser duplicados entre páginas
    ...    Known Issue: API-128 - Paginação retorna registros duplicados entre páginas
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

# GET-34 - Validação de Autenticação
Validate Authentication Security - user
    [Documentation]    Validar aspectos de segurança relacionados à autenticação
    ...    
    ...    ID: GET-34
    ...
    ...    Dado que envio um token de autenticação inválido
    ...    Quando faço uma requisição GET para /users
    ...    Então devo receber status code 401
    ...    E devo receber a mensagem "Invalid token"
    [Tags]    security    negative    regression    GET-34
    
    ${response}=    Get Users Without Token
    Validate Status Code 401    ${response}
    Validate Error Message    ${response}    Invalid token
    
    ${response}=    Get Users With Invalid Key
    Validate Status Code 401    ${response}
    Validate Error Message    ${response}    Invalid token

# GET-35 - Validação de Headers de Segurança
Validate Security Headers - user
    [Documentation]    Validar headers de segurança na resposta
    ...    
    ...    ID: GET-35
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /users
    ...    Então devo receber headers de segurança apropriados
    [Tags]    security    negative    regression    known_issue    robot:skip    GET-35
    [Setup]    Log    Skipping test: API-131 - Headers de segurança não implementados
    ${response}=    Get Users
    
    @{security_headers}=    Create List
    ...    X-Content-Type-Options
    ...    X-Frame-Options
    ...    X-XSS-Protection
    ...    Content-Security-Policy
    
    FOR    ${header}    IN    @{security_headers}
        Should Contain    ${response.headers}    ${header}
    END

# GET-36 - Validação de Rate Limiting
Validate Rate Limiting - user
    [Documentation]    Validar se o rate limiting está funcionando
    ...    
    ...    ID: GET-36
    ...
    ...    Dado que faço múltiplas requisições em sequência
    ...    Quando o limite de requisições é atingido
    ...    Então devo receber headers de rate limit apropriados
    [Tags]    security    negative    regression    known_issue    robot:skip    GET-36
    [Setup]    Log    Skipping test: API-129 - Rate Limiting não implementado
    
    FOR    ${i}    IN RANGE    10
        ${response}=    Get Users
        
        Should Contain    ${response.headers}    X-RateLimit-Limit
        Should Contain    ${response.headers}    X-RateLimit-Remaining
        Should Contain    ${response.headers}    X-RateLimit-Reset
    END

# GET-37 - Validação de Proteção de Dados
Validate Data Protection - user
    [Documentation]    Validar proteção de dados sensíveis
    ...    
    ...    ID: GET-37
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /users
    ...    Então os dados sensíveis devem estar mascarados
    [Tags]    security    negative    regression    known_issue    GET-37
    ${response}=    Get Users
    Validate Filter Response Structure    ${response}
    
    ${users}=    Set Variable    ${response.json()}
    FOR    ${user}    IN    @{users}
        Run Keyword And Warn On Failure    Validate Sensitive Data Masking    ${user}
    END

### TESTES DE VALIDAÇÃO DE DADOS ###

# GET-38 - Validação de Tipos de Dados
Validate Data Types - user
    [Documentation]    Validar se os tipos de dados dos campos estão corretos
    ...    
    ...    ID: GET-38
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /users
    ...    Então os tipos de dados dos campos devem estar corretos
    [Tags]    data_validation    positive    regression    GET-38
    ${response}=    Get Users
    ${users}=    Set Variable    ${response.json()}
    
    FOR    ${user}    IN    @{users}
        Validate User Data Types    ${user}
    END

# GET-39 - Validação de Campos Obrigatórios
Validate Required Fields - user
    [Documentation]    Validar se todos os campos obrigatórios estão presentes
    ...    
    ...    ID: GET-39
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /users
    ...    Então todos os campos obrigatórios devem estar presentes
    [Tags]    data_validation    positive    regression    GET-39
    ${response}=    Get Users
    ${users}=    Set Variable    ${response.json()}
    
    FOR    ${user}    IN    @{users}
        Validate Required User Fields    ${user}
    END

# GET-40 - Validação de Formatos de Dados
Validate Data Formats - user
    [Documentation]    Validar se os formatos dos dados retornados estão corretos
    ...    
    ...    ID: GET-40
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /users
    ...    Então devo receber status code 200
    ...    E para cada usuário retornado:
    ...    - O ID deve estar no formato UUID
    ...    - O email deve estar em formato válido
    ...    - O nome deve conter apenas caracteres permitidos
    ...    - As datas devem estar no formato ISO 8601
    [Tags]    data_validation    positive    regression    GET-40
    ${response}=    Get Users
    ${users}=    Set Variable    ${response.json()}
    
    FOR    ${user}    IN    @{users}
        Validate User Data Formats    ${user}
    END

# GET-41 - Validação de Valores Limites
Validate Field Length Limits - user
    [Documentation]    Validar limites de tamanho dos campos
    ...    
    ...    ID: GET-41
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /users
    ...    Então os campos devem respeitar os limites de tamanho
    [Tags]    data_validation    negative    regression    GET-41
    ${response}=    Get Users
    ${users}=    Set Variable    ${response.json()}
    
    FOR    ${user}    IN    @{users}
        Validate Field Length Limits    ${user}
    END

# GET-42 - Validação de Caracteres Especiais
Validate Special Characters In Fields - user
    [Documentation]    Validar tratamento de caracteres especiais nos campos
    ...    
    ...    ID: GET-42
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /users
    ...    Então os campos devem tratar adequadamente caracteres especiais
    [Tags]    data_validation    negative    regression    GET-42
    ${response}=    Get Users
    ${users}=    Set Variable    ${response.json()}
    
    FOR    ${user}    IN    @{users}
        Validate Special Characters    ${user}
    END

# GET-43 - Validação de Campos Opcionais
Validate Optional Fields - user
    [Documentation]    Validar campos opcionais quando presentes
    ...    
    ...    ID: GET-43
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /users
    ...    Então os campos opcionais devem estar presentes quando aplicável
    [Tags]    data_validation    positive    regression    GET-43
    ${response}=    Get Users
    ${users}=    Set Variable    ${response.json()}
    
    FOR    ${user}    IN    @{users}
        Validate Optional Fields    ${user}
    END


