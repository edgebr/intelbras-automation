*** Settings ***
Documentation     Testes do endpoint GET /clients
...
...    Endpoint: GET /clients
...    Descrição: Retorna lista de clientes cadastrados
...    Autenticação: x-api-key header required
...    Rate Limit: 1000 requests/hour
...    Cache: ETag implementation
...    SLA: 1s response time
...
...    Known Issues:
...    - API-123: Paginação não implementada [CONSYS-196]
...    - API-127: Problemas no ETag [CONSYS-205]
...    - API-129: Rate Limiting não implementado
...    - API-131: Headers de proteção XSS não implementados [CONSYS-206]
...    - API-133: GET /clients/{id} retorna 500 ao enviar ID numérico muito longo [CONSYS-194]
...    - API-134: GET /clients/{id} retorna 500 ao enviar espaço [CONSYS-197]
...    - API-135: Filtros não implementados [CONSYS-204]

Resource          ../../../resources/page/api/4client/1GET_client.resource

Force Tags        api    get_clients
Default Tags      regression

Suite Setup    Suite Setup
Suite Teardown    Delete All Sessions

*** Variables ***
&{KNOWN_ISSUES}
...    API-123=Paginação não implementada [CONSYS-196]
...    API-127=Problemas no ETag [CONSYS-205]
...    API-129=Rate Limiting não implementado
...    API-131=Headers de proteção XSS não implementados [CONSYS-206]
...    API-133=GET /clients/{id} retorna 500 ao enviar ID numérico muito longo [CONSYS-194]
...    API-134=GET /clients/{id} retorna 500 ao enviar espaço [CONSYS-197]
...    API-135=Filtros não implementados [CONSYS-204]


*** Test Cases ***
### TESTES DE STATUS CODE ###

# GET-CLIENT-1 - Requisição bem-sucedida (200 OK)
GET-CLIENT-1 - Get Successful Response - client
    [Documentation]    Validar resposta bem-sucedida do endpoint GET /clients
    ...
    ...    ID: GET-1
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients
    ...    Então devo receber status code 200
    ...    E devo receber uma lista de clientes
    ...    E os dados devem estar em formato JSON válido
    [Tags]    status_code    positive    regression    smoke    priority_high    data_validation    GET-CLIENT-1
    ${response}=    Get Clients
    Validate Status Code 200 - client    ${response}
    Validate Response Has Content - client    ${response}
    Log    Response: ${response.json()}

# GET-CLIENT-2 - Requisição sem autenticação (401 Unauthorized)
GET-CLIENT-2 - Get Unauthorized Response - client
    [Documentation]    Validar comportamento da API quando requisição é feita sem token
    ...
    ...    ID: GET-2
    ...
    ...    Dado que não envio token de autenticação
    ...    Quando faço uma requisição GET para /clients
    ...    Então devo receber status code 401
    ...    E devo receber a mensagem "Invalid token"
    [Tags]    api    get_clients    negative    priority_high    regression    security    status_code    GET-CLIENT-2
    ${response}=    Get Clients Without Token
    Validate Status Code 401 - client    ${response}
    Validate Error Message - client    ${response}    Invalid token

# GET-CLIENT-3 - Requisição inválida (400 Bad Request)
GET-CLIENT-3 - Get Bad Request Error - client
    [Documentation]    Validar comportamento da API com requisição inválida
    ...
    ...    ID: GET-3
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients/{id} com id inválido
    ...    Então devo receber status code 400
    ...    E devo receber uma mensagem de erro apropriada
    [Tags]    status_code    negative    regression    GET-CLIENT-3
    ${response}=    Get Clients With Invalid Request
    Validate Status Code 400 - client    ${response}
    Log Response Details - client    ${response}

# GET-CLIENT-4 - Recurso não encontrado (404 Not Found)
GET-CLIENT-4 - Get Resource Not Found - client
    [Documentation]    Validar comportamento da API ao buscar recurso inexistente
    ...
    ...    ID: GET-4
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para um cliente que não existe
    ...    Então devo receber status code 404
    ...    E devo receber uma mensagem indicando que o cliente não foi encontrado
    [Tags]    status_code    negative    regression    GET-CLIENT-4
    ${response}=    Get Non Existent Client
    Validate Status Code 404 - client    ${response}
    Log Response Details - client    ${response}

# GET-CLIENT-5 - Erro interno no servidor (500 Internal Server Error)
GET-CLIENT-5 - Get Internal Server Error - client
    [Documentation]    Validar comportamento da API em caso de erro interno
    ...
    ...    ID: GET-5
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição para GET /clients/{id} com um ID que excede o limite de caracteres permitido
    ...    Então devo receber status code 500
    ...    E devo receber uma mensagem de erro interno do servidor
    [Tags]    status_code    negative    known_issue    GET-CLIENT-5
    ${response}=    Get Clients With Server Error
    Validate Status Code 500 - client    ${response}
    Log    ${response}
    [Setup]    Log    ${KNOWN_ISSUES}[API-133]

### TESTES DE HEADERS ###

# GET-CLIENT-6 - Requisição sem header x-api-key
GET-CLIENT-6 - Get Clients Without Required Header - client
    [Documentation]    Validar comportamento da API quando a requisição é feita sem o header x-api-key
    ...
    ...    ID: GET-6
    ...
    ...    Dado que não envio o header x-api-key
    ...    Quando faço uma requisição GET para /clients
    ...    Então devo receber status code 401
    ...    E devo receber a mensagem "Invalid token"
    [Tags]    headers    negative    regression    GET-CLIENT-6
    ${response}=    Get Clients Without Token
    Validate Status Code 401 - client    ${response}
    Validate Error Message - client    ${response}    Invalid token
    Log Response Details - client    ${response}

# GET-CLIENT-7 - Requisição com header x-api-key inválido
GET-CLIENT-7 - Get Clients With Invalid Header - client
    [Documentation]    Validar comportamento da API quando requisição é feita com token inválido
    ...
    ...    ID: GET-7
    ...
    ...    Dado que envio um token de autenticação inválido
    ...    Quando faço uma requisição GET para /clients
    ...    Então devo receber status code 401
    ...    E devo receber a mensagem "Invalid token"
    ...    E os detalhes da resposta devem ser registrados
    [Tags]    headers    negative    regression    GET-CLIENT-7
    ${response}=    Get Clients With Invalid Key
    Validate Status Code 401    ${response}
    Validate Error Message    ${response}    Invalid token
    Log Response Details - client    ${response}

# GET-CLIENT-8 - Requisição com header x-api-key válido
GET-CLIENT-8 - Get Clients With Valid Header - client
    [Documentation]    Validar comportamento da API quando a requisição é feita com header x-api-key válido
    ...
    ...    ID: GET-8
    ...
    ...    Dado que envio um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients
    ...    Então devo receber status code 200
    ...    E devo receber uma lista de clientes
    [Tags]    headers    positive    regression    GET-CLIENT-8
    ${response}=    Get Clients
    Validate Status Code 200 - client    ${response}
    Validate Response Has Content - client    ${response}
    Log Response Details - client    ${response}

### TESTES DE SCHEMA ###

# GET-CLIENT-9 - Validação do corpo da requisição GET /clients
GET-CLIENT-9 - Validate Response Body Schema - all clients
    [Documentation]    Validar que o corpo da resposta segue o schema esperado
    ...
    ...    ID: GET-9
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients
    ...    Então devo receber status code 200
    ...    E o corpo da resposta deve seguir o schema esperado
    [Tags]    schema    positive    regression    GET-CLIENT-9
    ${response}=    Get Clients
    Validate Status Code 200 - client    ${response}
    Validate Response Schema    ${response}    test_schema_get_200_client.json
    Log    Schema validation completed successfully

# GET-CLIENT-10 - Validação do corpo da requisição GET /clients/{id}
GET-CLIENT-10 - Validate Response Body Schema - client by id
    [Documentation]    Validar que o corpo da resposta segue o schema esperado
    ...
    ...    ID: GET-10
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients/{id}
    ...    Então devo receber status code 200
    ...    E o corpo da resposta deve seguir o schema esperado
    [Tags]    schema    positive    regression    GET-CLIENT-10
    ${response}=    Get Client By ID    client_id=1    expected_status=200
    Validate Status Code 200 - client    ${response}
    Validate Response Schema    ${response}    test_schema_get_200_client_by_id.json
    Log    Schema validation completed successfully

### TESTES DE PAGINAÇÃO ###

# GET-CLIENT-11 - Validação de Paginação - Primeira Página
GET-CLIENT-11 - Validate First Page - client
    [Documentation]    Validar a primeira página no endpoint GET /clients
    ...
    ...    ID: GET-CLIENT-11
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients com paginação na primeira página
    ...    Então devo receber status code 200
    ...    E devo receber a primeira página de resultados
    [Tags]    pagination    positive    known_issue    GET-CLIENT-11
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-123]
    ${response}=    Get Clients With Pagination    page=1
    Validate First Page Response - client    ${response}

# GET-CLIENT-12 - Validação de Paginação - Segunda Página
GET-CLIENT-12 - Validate Second Page - client
    [Documentation]    Validar a segunda página no endpoint GET /clients
    ...
    ...    ID: GET-CLIENT-12
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients com paginação na segunda página
    ...    Então devo receber status code 200
    ...    E devo receber a segunda página de resultados
    [Tags]    pagination    positive    known_issue    GET-CLIENT-12
    ${response}=    Get Clients With Pagination    page=2
    Validate Second Page Response - client    ${response}

# GET-CLIENT-13 - Validação de Paginação - Página Inexistente
GET-CLIENT-13 - Validate Non Existent Page - client
    [Documentation]    Validar comportamento ao solicitar uma página inexistente
    ...
    ...    ID: GET-CLIENT-13
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients com paginação em uma página inexistente
    ...    Então devo receber status code 200
    ...    E devo receber uma lista vazia
    [Tags]    pagination    positive    known_issue    GET-CLIENT-13
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-123]
    ${response}=    Get Clients With Pagination    page=999999
    Validate Empty Page Response - client    ${response}

### TESTES DE FILTROS ###

# GET-CLIENT-14 - Verificação do Filtro por ID existente
GET-CLIENT-14 - Verify Existing ID Filter - client
    [Documentation]    Validar o filtro por ID existente no endpoint GET /clients/{id}
    ...
    ...    ID: GET-CLIENT-14
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clientes/{id} para filtrar por um ID existente
    ...    Então devo receber status code 200
    ...    E o resultado deve corresponder ao filtro aplicado
    [Tags]    filter    id_filter    positive    smoke    regression    GET-CLIENT-14
    ${response}=    Get Client By ID    client_id=1    expected_status=200
    Validate ID Filter Response - client    ${response}    search_term=1    expected_status=200

# GET-CLIENT-15 - Verificação do Filtro por ID inexistente
GET-CLIENT-15 - Verify Nonexistent ID Filter - client
    [Documentation]    Validar o filtro por ID inexistente no endpoint GET /clients/{id}
    ...
    ...    ID: GET-CLIENT-15
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clientes/{id} para filtrar por um ID inexistente
    ...    Então devo receber status code 404
    ...    E devo receber uma mensagem indicando que o cliente não foi encontrado
    [Tags]    filter    id_filter    negative    smoke    regression    GET-CLIENT-15
    ${response}=    Get Client By ID    client_id=0    expected_status=404
    Validate ID Filter Response - client    ${response}    search_term=0    expected_status=404

# GET-CLIENT-16 - Validação de Caracteres inválidos (não permitidos) no Filtro por ID
GET-CLIENT-16 - Validate Invalid Characters In ID Filter - client
    [Documentation]    Validar comportamento do filtro com caracteres inválidos (não permitidos)
    ...
    ...    ID: GET-CLIENT-16
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clientes/{id} com filtro de ID contendo caracteres inválidos
    ...    Então devo receber status code 400
    ...    E devo receber uma mensagem indicando que o id deve ser um número inteiro
    [Tags]    filter    id_filter    negative    regression    known_issue    GET-CLIENT-16
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-134]
    @{invalid_chars}=    Create List    
    ...    abc        ABC     abc123    ABC123    123.45
    ...    12%2034    true    false     null      %20
    ...    %20%20     @       $         ^         &
    ...    *          (       -         _         =
    ...    +          [       {         |         !
    ...    :          '       ,         <         "
    FOR    ${char}    IN    @{invalid_chars}
        ${response}=    Test ID Filter With Invalid Characters - client    ${char}
        Log    ${response}
        Validate Status Code 400 - client    ${response}
    END

# GET-CLIENT-17 - Verificação do Filtro por Nome
GET-CLIENT-17 - Verify Name Filter - client
    [Documentation]    Validar o filtro por nome no endpoint GET /clients
    ...
    ...    ID: GET-CLIENT-17
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients com filtro de nome
    ...    Então devo receber status code 200
    ...    E os resultados devem corresponder ao filtro aplicado
    [Tags]    filter    name_filter    positive    smoke    regression    known_issue    GET-CLIENT-17
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-135]
    ${response}=    Get Clients With Filter    name    test
    Validate Filter Response - client    ${response}    name    test

# GET-CLIENT-18 - Pesquisa Case Insensitive do Filtro por Nome
GET-CLIENT-18 - Validate Name Filter Case Insensitive Search - client
    [Documentation]    Validar se a pesquisa do filtro por nome é case insensitive
    ...
    ...    ID: GET-CLIENT-18
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients com filtro de nome em diferentes cases
    ...    Então devo receber status code 200
    ...    E os resultados devem ser os mesmos independentemente do case
    [Tags]    filter    name_filter    positive    regression    known_issue    GET-CLIENT-18
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-135]
    @{variations}=    Create List    cliente    Cliente    CLIENTE
    FOR    ${term}    IN    @{variations}
        Test Case Insensitive Search - client    name    ${term}
    END

# GET-CLIENT-19 - Pesquisa por Nome Sem Resultados
GET-CLIENT-19 - Validate Empty Search Results Name Filter - client
    [Documentation]    Validar comportamento quando não há resultados para o filtro por nome
    ...
    ...    ID: GET-CLIENT-19
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients com filtro de nome que não retorna resultados
    ...    Então devo receber status code 200
    ...    E a lista de resultados deve estar vazia
    [Tags]    filter    name_filter    negative    regression    known_issue    GET-CLIENT-19
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-135]
    ${response}=    Get Clients With Filter    name    nome_inexistente_xyz
    Validate Filter Response Structure - client    ${response}    expected_type=list    expected_status=200

# GET-CLIENT-20 - Validação de Caracteres Especiais no Filtro por Nome
GET-CLIENT-20 - Validate Special Characters In Name Filter - client
    [Documentation]    Validar comportamento do filtro por nome com caracteres especiais
    ...
    ...    ID: GET-CLIENT-20
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients com filtro de nome contendo caracteres especiais
    ...    Então devo receber status code 200
    ...    E os resultados devem ser adequadamente filtrados
    [Tags]    filter    name_filter    negative    regression    known_issue    GET-CLIENT-20
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-135]
    @{special_chars}=    Create List    @    \#    $    %    &    *
    FOR    ${char}    IN    @{special_chars}
        Test Filter With Special Characters - client    name    ${char}
    END

# GET-CLIENT-21 - Verificação do Filtro por Aplicação
GET-CLIENT-21 - Verify Application Filter - client
    [Documentation]    Validar o filtro por aplicação no endpoint GET /clients
    ...
    ...    ID: GET-CLIENT-21
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients com filtro de aplicação
    ...    Então devo receber status code 200
    ...    E os resultados devem corresponder ao filtro aplicado
    [Tags]    filter    application_filter    positive    smoke    regression    known_issue    GET-CLIENT-21
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-135]
    ${response}=    Get Clients With Filter    application    test
    Validate Filter Response - client    ${response}    application    test

# GET-CLIENT-22 - Pesquisa Case Insensitive do Filtro por Aplicação
GET-CLIENT-22 - Validate Application Filter Case Insensitive Search - client
    [Documentation]    Validar se a pesquisa do filtro por aplicação é case insensitive
    ...
    ...    ID: GET-CLIENT-22
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients com filtro de aplicação em diferentes cases
    ...    Então devo receber status code 200
    ...    E os resultados devem ser os mesmos independentemente do case
    [Tags]    filter    application_filter    positive    regression    known_issue    GET-CLIENT-22
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-135]
    @{variations}=    Create List    aplicacao    Aplicacao    APLICACAO
    FOR    ${term}    IN    @{variations}
        Test Case Insensitive Search - client    application    ${term}
    END

# GET-CLIENT-23 - Pesquisa por Aplicação Sem Resultados
GET-CLIENT-23 - Validate Empty Search Results Application Filter - client
    [Documentation]    Validar comportamento quando não há resultados para o filtro por aplicação
    ...
    ...    ID: GET-CLIENT-23
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients com filtro de aplicação que não retorna resultados
    ...    Então devo receber status code 200
    ...    E a lista de resultados deve estar vazia
    [Tags]    filter    application_filter    negative    regression    known_issue    GET-CLIENT-23
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-135]
    ${response}=    Get Clients With Filter    application    aplicacao_inexistente_xyz
    Validate Filter Response Structure - client    ${response}    expected_type=list    expected_status=200

# GET-CLIENT-24 - Validação de Caracteres Especiais no Filtro por Aplicação
GET-CLIENT-24 - Validate Special Characters In Application Filter - client
    [Documentation]    Validar comportamento do filtro por aplicação com caracteres especiais
    ...
    ...    ID: GET-CLIENT-24
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients com filtro de aplicação contendo caracteres especiais
    ...    Então devo receber status code 200
    ...    E os resultados devem ser adequadamente filtrados
    [Tags]    filter    application_filter    negative    regression    known_issue    GET-CLIENT-24
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-135]
    @{special_chars}=    Create List    @    \#    $    %    &    *
    FOR    ${char}    IN    @{special_chars}
        Test Filter With Special Characters - client    application    ${char}
    END

# GET-CLIENT-25 - Verificação do Filtro por Grupo
GET-CLIENT-25 - Verify Group Filter - client
    [Documentation]    Validar o filtro por grupo no endpoint GET /clients
    ...
    ...    ID: GET-CLIENT-25
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients com filtro de grupo
    ...    Então devo receber status code 200
    ...    E os resultados devem corresponder ao filtro aplicado
    [Tags]    filter    group_filter    positive    smoke    regression    known_issue    GET-CLIENT-25
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-135]
    ${response}=    Get Clients With Filter    group    test
    Validate Filter Response - client    ${response}    group    test

# GET-CLIENT-26 - Pesquisa Case Insensitive do Filtro por Grupo
GET-CLIENT-26 - Validate Group Filter Case Insensitive Search - client
    [Documentation]    Validar se a pesquisa do filtro por grupo é case insensitive
    ...
    ...    ID: GET-CLIENT-26
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients com filtro de grupo em diferentes cases
    ...    Então devo receber status code 200
    ...    E os resultados devem ser os mesmos independentemente do case
    [Tags]    filter    group_filter    positive    regression    known_issue    GET-CLIENT-26
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-135]
    @{variations}=    Create List    grupo    Grupo    GRUPO
    FOR    ${term}    IN    @{variations}
        Test Case Insensitive Search - client    group    ${term}
    END

# GET-CLIENT-27 - Pesquisa por Grupo Sem Resultados
GET-CLIENT-27 - Validate Empty Search Results Group Filter - client
    [Documentation]    Validar comportamento quando não há resultados para o filtro por grupo
    ...
    ...    ID: GET-CLIENT-27
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients com filtro de grupo que não retorna resultados
    ...    Então devo receber status code 200
    ...    E a lista de resultados deve estar vazia
    [Tags]    filter    group_filter    negative    regression    known_issue    GET-CLIENT-27
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-135]
    ${response}=    Get Clients With Filter    group    grupo_inexistente_xyz
    Validate Filter Response Structure - client    ${response}    expected_type=list    expected_status=200

# GET-CLIENT-28 - Validação de Caracteres Especiais no Filtro por Grupo
GET-CLIENT-28 - Validate Special Characters In Group Filter - client
    [Documentation]    Validar comportamento do filtro por grupo com caracteres especiais
    ...
    ...    ID: GET-CLIENT-28
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients com filtro de grupo contendo caracteres especiais
    ...    Então devo receber status code 200
    ...    E os resultados devem ser adequadamente filtrados
    [Tags]    filter    group_filter    negative    regression    known_issue    GET-CLIENT-28
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-135]
    @{special_chars}=    Create List    @    \#    $    %    &    *
    FOR    ${char}    IN    @{special_chars}
        Test Filter With Special Characters - client    group    ${char}
    END

## TESTES DE PERFORMANCE ###

# GET-CLIENT-29 - Tempo de resposta para listagem de clientes (SLA: 1s)
GET-CLIENT-29 - Validate Get Clients Response Time - client
    [Documentation]    Validar se o tempo de resposta da listagem está dentro do SLA (1s)
    ...
    ...    ID: GET-CLIENT-29
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients
    ...    Então o tempo de resposta deve ser menor ou igual a 1 segundo
    [Tags]    performance    positive    sla_1s    GET-CLIENT-29
    ${response}    ${response_time}=    Get Response Time For Clients List
    Validate Response Time - client    ${response_time}    1
    Status Should Be    200    ${response}
    Validate Response Has Content - client    ${response}

# GET-CLIENT-30 - Tempo de resposta para cliente específico (SLA: 0.8s)
GET-CLIENT-30 - Validate Get Single Client Response Time - client by id
    [Documentation]    Validar se o tempo de resposta para um cliente específico está dentro do SLA (0.8s)
    ...
    ...    ID: GET-CLIENT-30
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para um cliente específico
    ...    Então o tempo de resposta deve ser menor que 0.8 segundos
    [Tags]    performance    positive    sla_0.8s    GET-CLIENT-30
    ${response}    ${response_time}=    Get Response Time For Single Client    client_id=1    expected_status=200
    Validate Response Time - client    ${response_time}    0.8
    Status Should Be    200    ${response}
    Validate Response Has Content - client    ${response}

# GET-CLIENT-31 - Tempo de resposta com token inválido para listagem de clientes (SLA: 0.5s)
GET-CLIENT-31 - Validate Invalid Token Response Time - client
    [Documentation]    Validar tempo de resposta com token inválido para GET /clients (SLA: 0.5s)
    ...
    ...    ID: GET-CLIENT-31
    ...
    ...    Dado que envio um token de autenticação inválido
    ...    Quando faço uma requisição GET para /clients
    ...    Então o tempo de resposta deve ser menor que 0.5 segundos
    ...    E devo receber a mensagem "Invalid token"
    [Tags]    performance    negative    sla_0.5s    GET-CLIENT-31
    ${response}    ${response_time}=    Get Response Time For Invalid Token - client list
    # Valida o tempo de resposta
    Validate Response Time - client    ${response_time}    0.5
    # Valida o status da resposta
    Status Should Be    401    ${response}
    # Valida a mensagem de erro
    ${response_json}=    Set Variable    ${response.json()}
    ${error_message}=    Get From Dictionary    ${response_json}    error
    Should Be Equal    ${error_message}    Invalid token

# GET-CLIENT-32 - Tempo de resposta com token inválido para cliente específico (SLA: 0.5s)
GET-CLIENT-32 - Validate Invalid Token Response Time - client by id
    [Documentation]    Validar tempo de resposta com token inválido para GET /clients/{id} (SLA: 0.5s)
    ...
    ...    ID: GET-CLIENT-32
    ...
    ...    Dado que envio um token de autenticação inválido
    ...    Quando faço uma requisição GET para /clients/{id}
    ...    Então o tempo de resposta deve ser menor que 0.5 segundos
    ...    E devo receber a mensagem "Invalid token"
    [Tags]    performance    negative    sla_0.5s    GET-CLIENT-32
    ${response}    ${response_time}=    Get Response Time For Invalid Token - client by id
    # Valida o tempo de resposta
    Validate Response Time - client    ${response_time}    0.5
    # Valida o status da resposta
    Status Should Be    401    ${response}
    # Valida a mensagem de erro
    ${response_json}=    Set Variable    ${response.json()}
    ${error_message}=    Get From Dictionary    ${response_json}    error
    Should Be Equal    ${error_message}    Invalid token

# GET-CLIENT-33 - Tempo de resposta para cliente inexistente (SLA: 0.5s)
GET-CLIENT-33 - Validate Response Time For Nonexistent Client - client by id
    [Documentation]    Validar se o tempo de resposta para um cliente inexistente está dentro do SLA (0.5s)
    ...
    ...    ID: GET-CLIENT-33
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET /clients/{id} para um cliente inexistente
    ...    Então o tempo de resposta deve ser menor que 0.5 segundos
    [Tags]    performance    negative    sla_0.5s    known_issue    GET-CLIENT-33
    ${response}    ${response_time}=    Get Response Time For Single Client    client_id=0    expected_status=404
    Validate Response Time - client    ${response_time}    0.8
    Status Should Be    404    ${response}
    Validate Response Has Content - client    ${response}

# GET-CLIENT-34 - Tempo de resposta para listagem de clientes com filtro (SLA: 1s)
GET-CLIENT-34 - Validate Get Clients Response Time - client with filter
    [Documentation]    Validar se o tempo de resposta da listagem está dentro do SLA (1s)
    ...
    ...    ID: GET-CLIENT-34
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients com filtro
    ...    Então o tempo de resposta deve ser menor que 1 segundo
    [Tags]    performance    positive    sla_1s    known_issue    GET-CLIENT-34
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-135]
    &{filters}=    Create Dictionary    
    ...    name=test
    ...    application=test
    ...    group=test
    FOR    ${key}    ${value}    IN    &{filters}
        ${response}    ${response_time}=    Get Response Time For Clients List With Filter    ${key}    ${value}
        Validate Response Time - client    ${response_time}    1
        Status Should Be    200    ${response}
        Validate Response Has Content - client    ${response}
    END

# GET-CLIENT-35 - Tempo de resposta para pesquisa de cliente sem resultados (SLA: 1s)
GET-CLIENT-35 - Validate Response Time For Empty Search Results - client with filter
    [Documentation]    Validar se o tempo de resposta quando não há resultados para o filtro está dentro do SLA (1s)
    ...
    ...    ID: GET-CLIENT-35
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET /clients com filtro que não retorna resultados
    ...    Então o tempo de resposta deve ser menor que 1 segundo
    [Tags]    performance    positive    sla_1s    known_issue    GET-CLIENT-35
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-135]
        &{filters}=    Create Dictionary    
        ...    name=nome_inexistente_xyz
        ...    application=aplicacao_inexistente_xyz
        ...    group=grupo_inexistente_xyz
    FOR    ${key}    ${value}    IN    &{filters}
        ${response}    ${response_time}=    Get Response Time For Clients List With Filter    ${key}    ${value}
        Validate Response Time - client    ${response_time}    1
        Status Should Be    200    ${response}
        Validate Response Has Content - client    ${response}
    END

### TESTES DE CACHE ###

# GET-CLIENT-36 - Validação de Headers de Cache
GET-CLIENT-36 - Validate Cache Headers - client list
    [Documentation]    Validar headers de cache na resposta
    ...
    ...    ID: GET-CLIENT-36
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients
    ...    Então devo receber headers de cache apropriados
    [Tags]    cache    positive    known_issue    GET-CLIENT-36
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-127] - Headers de cache não estão implementados corretamente
    ${response}=    Get Clients
    Validate Cache Headers Response - client    ${response}

# GET-CLIENT-37 - Validação de Headers de Cache
GET-CLIENT-37 - Validate Cache Headers - client by id
    [Documentation]    Validar headers de cache na resposta
    ...
    ...    ID: GET-CLIENT-37
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients/{id}
    ...    Então devo receber headers de cache apropriados
    [Tags]    cache    positive    known_issue    GET-CLIENT-36
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-127] - Headers de cache não estão implementados corretamente
    ${response}=    Get Client By ID    client_id=1    expected_status=200
    Validate Cache Headers Response - client    ${response}

# GET-CLIENT-38 - Validação de Cache com ETag
GET-CLIENT-38 - Validate ETag Cache - client list
    [Documentation]    Validar se o cache usando ETag está funcionando corretamente
    ...
    ...    ID: GET-CLIENT-38
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients
    ...    Então devo receber um ETag no header
    ...    E ao usar o ETag em uma nova requisição, devo receber status code 304
    [Tags]    cache    positive    known_issue    GET-CLIENT-38
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-127] - Mecanismo de ETag não está implementado corretamente
    # Primeira requisição para obter o ETag
    ${response1}=    Get Clients
    ${etag}=    Get From Dictionary    ${response1.headers}    ETag

    # Segunda requisição usando If-None-Match
    ${response2}=    Get Clients With ETag    ${etag}
    Status Should Be    304    ${response2}

# GET-CLIENT-39 - Validação de Cache com ETag
GET-CLIENT-39 - Validate ETag Cache - client by id
    [Documentation]    Validar se o cache usando ETag está funcionando corretamente
    ...
    ...    ID: GET-CLIENT-39
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients/{id}
    ...    Então devo receber um ETag no header
    ...    E ao usar o ETag em uma nova requisição, devo receber status code 304
    [Tags]    cache    positive    known_issue    GET-CLIENT-39
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-127] - Mecanismo de ETag não está implementado corretamente
    # Primeira requisição para obter o ETag
    ${response1}=    Get Client By ID    client_id=1    expected_status=200
    ${etag}=    Get From Dictionary    ${response1.headers}    ETag

    # Segunda requisição usando If-None-Match
    ${response2}=    Get Client By ID With ETag    ${etag}    client_id=1
    Status Should Be    304    ${response2}

# GET-CLIENT-40 - Validação de Cache Expirado
GET-CLIENT-40 - Validate Expired Cache - client list
    [Documentation]    Validar comportamento quando o cache está expirado
    ...
    ...    ID: GET-CLIENT-40
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients
    ...    Então devo receber um ETag no header
    ...    E ao usar um ETag inválido, devo receber status code 200
    ...    E devo receber um novo ETag
    [Tags]    cache    positive    known_issue    GET-CLIENT-40
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-127] - Mecanismo de cache expirado não está implementado
    # Primeira requisição para obter o ETag
    ${response1}=    Get Clients
    ${etag}=    Get From Dictionary    ${response1.headers}    ETag

    # Espera o cache expirar (simulado com ETag inválido)
    ${response2}=    Get Clients With ETag    "invalid-etag"
    Status Should Be    200    ${response2}
    Validate Response Has Content - client    ${response2}

    # Verifica se recebeu novo ETag
    Dictionary Should Contain Key    ${response2.headers}    ETag
    ${new_etag}=    Get From Dictionary    ${response2.headers}    ETag
    Should Not Be Equal    ${new_etag}    "invalid-etag"

# GET-CLIENT-41 - Validação de Cache Expirado
GET-CLIENT-41 - Validate Expired Cache - client by id
    [Documentation]    Validar comportamento quando o cache está expirado
    ...
    ...    ID: GET-CLIENT-41
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients
    ...    Então devo receber um ETag no header
    ...    E ao usar um ETag inválido, devo receber status code 200
    ...    E devo receber um novo ETag
    [Tags]    cache    positive    known_issue    GET-CLIENT-40
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-127] - Mecanismo de cache expirado não está implementado
    # Primeira requisição para obter o ETag
    ${response1}=    Get Client By ID    client_id=1    expected_status=200
    ${etag}=    Get From Dictionary    ${response1.headers}    ETag

    # Espera o cache expirar (simulado com ETag inválido)
    ${response2}=    Get Client By ID With ETag    "invalid-etag"    client_id=1
    Status Should Be    200    ${response2}
    Validate Response Has Content - client    ${response2}

    # Verifica se recebeu novo ETag
    Dictionary Should Contain Key    ${response2.headers}    ETag
    ${new_etag}=    Get From Dictionary    ${response2.headers}    ETag
    Should Not Be Equal    ${new_etag}    "invalid-etag"

### TESTES DE TAMANHO DE RESPOSTA ###

# GET-CLIENT-42 - Validação de Resposta Pequena
GET-CLIENT-42 - Validate Small Response Size - client
    [Documentation]    Validar comportamento com conjunto pequeno de dados (até 10 registros)
    ...
    ...    ID: GET-CLIENT-42
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients com paginação de 10 registros por página
    ...    Então devo receber status code 200
    ...    E o tempo de resposta deve ser adequado
    ...    E o tamanho do payload deve ser pequeno
    [Tags]    response_size    performance    positive    known_issue    GET-CLIENT-42
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-123]
    ${response}=    Get Clients With Pagination    page=1    per_page=10
    Validate Small Response - client    ${response}

# GET-CLIENT-43 - Validação de Resposta Média
GET-CLIENT-43 - Validate Medium Response Size - client
    [Documentation]    Validar comportamento com conjunto médio de dados (50-100 registros)
    ...
    ...    ID: GET-CLIENT-43
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients com paginação de 50 registros por página
    ...    Então devo receber status code 200
    ...    E o tempo de resposta deve ser adequado
    ...    E o tamanho do payload deve ser médio
    [Tags]    response_size    performance    positive    known_issue    GET-CLIENT-43
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-123]
    ${response}=    Get Clients With Pagination    page=1    per_page=50
    Validate Medium Response    ${response}

# GET-CLIENT-44 - Validação de Resposta Grande
GET-CLIENT-44 - Validate Large Response Size - client
    [Documentation]    Validar comportamento com conjunto grande de dados (>100 registros)
    ...
    ...    ID: GET-CLIENT-44
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients com paginação de 100 registros por página
    ...    Então devo receber status code 200
    ...    E o tempo de resposta deve ser adequado
    ...    E o tamanho do payload deve ser grande
    [Tags]    response_size    performance    positive    known_issue    GET-CLIENT-44
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-123]
    ${response}=    Get Clients With Pagination    page=1    per_page=100
    Validate Large Response - client    ${response}

### TESTES DE CONCORRÊNCIA ###

# GET-CLIENT-45 - Validação de Requisições Concorrentes
GET-CLIENT-45 - Validate Concurrent Requests - client list
    [Documentation]    Validar comportamento do endpoint sob múltiplas requisições simultâneas
    ...
    ...    ID: GET-CLIENT-45
    ...
    ...    Dado que faço múltiplas requisições GET para /clients simultaneamente
    ...    Então devo receber respostas consistentes
    ...    E o tempo de resposta deve ser adequado
    ...    E o status code deve ser consistente
    [Tags]    concurrent    performance    positive    GET-CLIENT-45
    ${responses}=    Run Concurrent Requests - client    Get Clients    10
    Validate Concurrent Responses    ${responses}    Validate Client Item Structure

# GET-CLIENT-46 - Validação de Requisições Concorrentes
GET-CLIENT-46 - Validate Concurrent Requests - client by id
    [Documentation]    Validar comportamento do endpoint sob múltiplas requisições simultâneas
    ...
    ...    ID: GET-CLIENT-46
    ...
    ...    Dado que faço múltiplas requisições GET para /clients/{id} simultaneamente
    ...    Então devo receber respostas consistentes
    ...    E o tempo de resposta deve ser adequado
    ...    E o status code deve ser consistente
    [Tags]    concurrent    performance    positive    GET-CLIENT-46
    ${responses}=    Run Concurrent Requests - client    Get Client By ID    10    1    200

# GET-CLIENT-47 - Validação de Concorrência com Cache
GET-CLIENT-47 - Validate Concurrent Cached Requests - client list
    [Documentation]    Validar comportamento do cache sob múltiplas requisições simultâneas
    ...
    ...    ID: GET-CLIENT-47
    ...
    ...    Dado que faço múltiplas requisições GET para /clients com cache simultaneamente
    ...    Então devo receber respostas consistentes
    ...    E o ETag deve ser consistente
    [Tags]    concurrent    cache    performance    positive    GET-CLIENT-47
    # Primeira requisição para obter ETag
    ${initial_response}=    Get Clients
    ${etag}=    Get From Dictionary    ${initial_response.headers}    ETag
    ${responses}=    Run Concurrent Requests - client    Get Clients With Cache    10    ${etag}
    Validate Concurrent Cache Responses - client    ${responses}

# GET-CLIENT-48 - Validação de Concorrência com Cache
GET-CLIENT-48 - Validate Concurrent Cached Requests - client by id
    [Documentation]    Validar comportamento do cache sob múltiplas requisições simultâneas
    ...
    ...    ID: GET-CLIENT-48
    ...
    ...    Dado que faço múltiplas requisições GET para /clients/{id} com cache simultaneamente
    ...    Então devo receber respostas consistentes
    ...    E o ETag deve ser consistente
    [Tags]    concurrent    cache    performance    positive    GET-CLIENT-48
    # Primeira requisição para obter ETag
    ${initial_response}=    Get Client By ID    client_id=1    expected_status=200
    ${etag}=    Get From Dictionary    ${initial_response.headers}    ETag
    ${responses}=    Run Concurrent Requests - client    Get Client By ID With Cache    10    ${etag}    1
    Validate Concurrent Cache Responses - client    ${responses}

# GET-CLIENT-49 - Validação de Concorrência com Paginação
GET-CLIENT-49 - Validate Concurrent Paginated Requests - client
    [Documentation]    Validar comportamento da paginação sob múltiplas requisições simultâneas
    ...
    ...    ID: GET-CLIENT-49
    ...
    ...    Dado que faço múltiplas requisições GET para /clients com paginação simultaneamente
    ...    Então devo receber respostas consistentes
    ...    E os registros não devem ser duplicados entre páginas
    [Tags]    concurrent    pagination    performance    positive    known_issue    GET-CLIENT-49
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-123]
    ${pages}=    Create List    1    2    3    4    5
    @{responses}=    Create List

    FOR    ${page}    IN    @{pages}
        ${response}=    Get Clients With Pagination    page=${page}
        Append To List    ${responses}    ${response}
    END

    Validate Concurrent Pagination Responses - client    ${responses}

### TESTES DE SEGURANÇA ###

# GET-CLIENT-50 - Validação de Autenticação
GET-CLIENT-50 - Validate Authentication Security - client list
    [Documentation]    Validar aspectos de segurança relacionados à autenticação
    ...
    ...    ID: GET-CLIENT-50
    ...
    ...    Dado que envio um token de autenticação inválido
    ...    Quando faço uma requisição GET para /clients
    ...    Então devo receber status code 401
    ...    E devo receber a mensagem "Invalid token"
    [Tags]    security    negative    regression    GET-CLIENT-50
    ${response}=    Get Clients Without Token
    Validate Status Code 401    ${response}
    Validate Error Message    ${response}    Invalid token

    ${response}=    Get Clients With Invalid Key
    Validate Status Code 401    ${response}
    Validate Error Message    ${response}    Invalid token

# GET-CLIENT-51 - Validação de Autenticação
GET-CLIENT-51 - Validate Authentication Security - client by id
    [Documentation]    Validar aspectos de segurança relacionados à autenticação
    ...
    ...    ID: GET-CLIENT-51
    ...
    ...    Dado que envio um token de autenticação inválido
    ...    Quando faço uma requisição GET para /clients/{id}
    ...    Então devo receber status code 401
    ...    E devo receber a mensagem "Invalid token"
    [Tags]    security    negative    regression    GET-CLIENT-51
    ${response}=    Get Client By ID Without Token    client_id=1
    Validate Status Code 401    ${response}
    Validate Error Message    ${response}    Invalid token

    ${response}=    Get Client By ID With Invalid Key    client_id=1
    Validate Status Code 401    ${response}
    Validate Error Message    ${response}    Invalid token

# GET-CLIENT-52 - Validação de Headers de Segurança
GET-CLIENT-52 - Validate Security Headers - client list
    [Documentation]    Validar headers de segurança na resposta
    ...
    ...    ID: GET-CLIENT-52
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients
    ...    Então devo receber headers de segurança apropriados
    [Tags]    security    negative    regression    known_issue    GET-CLIENT-52
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-131]
    ${response}=    Get Clients

    @{security_headers}=    Create List
    ...    X-Content-Type-Options
    ...    X-Frame-Options
    ...    X-XSS-Protection
    ...    Content-Security-Policy

    FOR    ${header}    IN    @{security_headers}
        Should Contain    ${response.headers}    ${header}
    END

# GET-CLIENT-53 - Validação de Headers de Segurança
GET-CLIENT-53 - Validate Security Headers - client by id
    [Documentation]    Validar headers de segurança na resposta
    ...
    ...    ID: GET-CLIENT-52
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients/{id}
    ...    Então devo receber headers de segurança apropriados
    [Tags]    security    negative    regression    known_issue    GET-CLIENT-53
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-131]
    ${response}=    Get Client By ID    client_id=1    expected_status=200

    @{security_headers}=    Create List
    ...    X-Content-Type-Options
    ...    X-Frame-Options
    ...    X-XSS-Protection
    ...    Content-Security-Policy

    FOR    ${header}    IN    @{security_headers}
        Should Contain    ${response.headers}    ${header}
    END

# GET-CLIENT-54 - Validação de Rate Limiting
GET-CLIENT-54 - Validate Rate Limiting - client list
    [Documentation]    Validar se o rate limiting está funcionando
    ...
    ...    ID: GET-CLIENT-54
    ...
    ...    Dado que faço múltiplas requisições em sequência
    ...    Quando o limite de requisições é atingido
    ...    Então devo receber headers de rate limit apropriados
    [Tags]    security    negative    regression    known_issue    GET-CLIENT-54
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-129]
    FOR    ${i}    IN RANGE    10
        ${response}=    Get Clients

        Should Contain    ${response.headers}    X-RateLimit-Limit
        Should Contain    ${response.headers}    X-RateLimit-Remaining
        Should Contain    ${response.headers}    X-RateLimit-Reset
    END

# GET-CLIENT-55 - Validação de Rate Limiting
GET-CLIENT-55 - Validate Rate Limiting - client by id
    [Documentation]    Validar se o rate limiting está funcionando
    ...
    ...    ID: GET-CLIENT-55
    ...
    ...    Dado que faço múltiplas requisições em sequência
    ...    Quando o limite de requisições é atingido
    ...    Então devo receber headers de rate limit apropriados
    [Tags]    security    negative    regression    known_issue    GET-CLIENT-55
    [Setup]    Skip    Skipping test: ${KNOWN_ISSUES}[API-129]
    FOR    ${i}    IN RANGE    10
        ${response}=    Get Client By ID    client_id=1    expected_status=200

        Should Contain    ${response.headers}    X-RateLimit-Limit
        Should Contain    ${response.headers}    X-RateLimit-Remaining
        Should Contain    ${response.headers}    X-RateLimit-Reset
    END

# ESTOU EM DUVIDA
## GET-CLIENT-56 - Validação de Proteção de Dados
#GET-CLIENT-56 - Validate Data Protection - client list
#    [Documentation]    Validar proteção de dados sensíveis
#    ...
#    ...    ID: GET-CLIENT-56
#    ...
#    ...    Dado que tenho um token de autenticação válido
#    ...    Quando faço uma requisição GET para /clients
#    ...    Então os dados sensíveis devem estar mascarados
#    [Tags]    security    negative    regression    known_issue    GET-CLIENT-56

# ESTOU EM DUVIDA
## GET-CLIENT-57 - Validação de Proteção de Dados
#GET-CLIENT-57 - Validate Data Protection - client list
#    [Documentation]    Validar proteção de dados sensíveis
#    ...
#    ...    ID: GET-CLIENT-57
#    ...
#    ...    Dado que tenho um token de autenticação válido
#    ...    Quando faço uma requisição GET para /clients/{id}
#    ...    Então os dados sensíveis devem estar mascarados
#    [Tags]    security    negative    regression    known_issue    GET-CLIENT-57

### TESTES DE VALIDAÇÃO DE DADOS ###

## GET-CLIENT-59 - Validação de Tipos de Dados
#GET-CLIENT-59 - Validate Data Types - cliet by id
#    [Documentation]    Validar se os tipos de dados dos campos estão corretos
#    ...
#    ...    ID: GET-CLIENT-59
#    ...
#    ...    Dado que tenho um token de autenticação válido
#    ...    Quando faço uma requisição GET para /clients/{id}
#    ...    Então os tipos de dados dos campos devem estar corretos
#    [Tags]    data_validation    positive    regression    GET-CLIENT-59

## GET-CLIENT-60 - Validação de Campos Obrigatórios
#GET-CLIENT-60 - Validate Required Fields - client list
#    [Documentation]    Validar se todos os campos obrigatórios estão presentes
#    ...
#    ...    ID: GET-CLIENT-60
#    ...
#    ...    Dado que tenho um token de autenticação válido
#    ...    Quando faço uma requisição GET para /clients
#    ...    Então todos os campos obrigatórios devem estar presentes
#    [Tags]    data_validation    positive    regression    GET-CLIENT-60
#
## GET-CLIENT-61 - Validação de Campos Obrigatórios
#GET-CLIENT-61 - Validate Required Fields - client by id
#    [Documentation]    Validar se todos os campos obrigatórios estão presentes
#    ...
#    ...    ID: GET-CLIENT-61
#    ...
#    ...    Dado que tenho um token de autenticação válido
#    ...    Quando faço uma requisição GET para /clients/{id}
#    ...    Então todos os campos obrigatórios devem estar presentes
#    [Tags]    data_validation    positive    regression    GET-CLIENT-61

## GET-CLIENT-62 - Validação de Formatos de Dados
#GET-CLIENT-62 - Validate Data Formats - client list
#    [Documentation]    Validar se os formatos dos dados retornados estão corretos
#    ...
#    ...    ID: GET-CLIENT-62
#    ...
#    ...    Dado que tenho um token de autenticação válido
#    ...    Quando faço uma requisição GET para /clients
#    ...    Então devo receber status code 200
#    ...    E para cada cliente retornado:
#    ...    - O ID deve estar no formato UUID
#    ...    - O email deve estar em formato válido
#    ...    - O nome deve conter apenas caracteres permitidos
#    ...    - As datas devem estar no formato ISO 8601
#    [Tags]    data_validation    positive    regression    GET-CLIENT-62
#
## GET-CLIENT-63 - Validação de Formatos de Dados
#GET-CLIENT-63 - Validate Data Formats - client by id
#    [Documentation]    Validar se os formatos dos dados retornados estão corretos
#    ...
#    ...    ID: GET-CLIENT-63
#    ...
#    ...    Dado que tenho um token de autenticação válido
#    ...    Quando faço uma requisição GET para /clients/{id}
#    ...    Então devo receber status code 200
#    ...    E para o cliente retornado:
#    ...    - O ID deve estar no formato UUID
#    ...    - O email deve estar em formato válido
#    ...    - O nome deve conter apenas caracteres permitidos
#    ...    - As datas devem estar no formato ISO 8601
#    [Tags]    data_validation    positive    regression    GET-CLIENT-63
#
## GET-CLIENT-64 - Validação de Valores Limites
#GET-CLIENT-64 - Validate Field Length Limits - client list
#    [Documentation]    Validar limites de tamanho dos campos
#    ...
#    ...    ID: GET-CLIENT-64
#    ...
#    ...    Dado que tenho um token de autenticação válido
#    ...    Quando faço uma requisição GET para /clients
#    ...    Então os campos devem respeitar os limites de tamanho
#    [Tags]    data_validation    negative    regression    GET-CLIENT-64
#
## GET-CLIENT-64 - Validação de Valores Limites
#GET-CLIENT-64 - Validate Field Length Limits - client by id
#    [Documentation]    Validar limites de tamanho dos campos
#    ...
#    ...    ID: GET-CLIENT-64
#    ...
#    ...    Dado que tenho um token de autenticação válido
#    ...    Quando faço uma requisição GET para /clients/{id}
#    ...    Então os campos devem respeitar os limites de tamanho
#    [Tags]    data_validation    negative    regression    GET-CLIENT-64

## GET-CLIENT-65 - Validação de Caracteres Especiais
#GET-CLIENT-65 - Validate Special Characters In Fields - client list
#    [Documentation]    Validar tratamento de caracteres especiais nos campos
#    ...
#    ...    ID: GET-42
#    ...
#    ...    Dado que tenho um token de autenticação válido
#    ...    Quando faço uma requisição GET para /clients
#    ...    Então os campos devem tratar adequadamente caracteres especiais
#    [Tags]    data_validation    negative    regression    GET-CLIENT-65

## GET-CLIENT-66 - Validação de Caracteres Especiais
#GET-CLIENT-66 - Validate Special Characters In Fields - client by id
#    [Documentation]    Validar tratamento de caracteres especiais nos campos
#    ...
#    ...    ID: GET-CLIENT-66
#    ...
#    ...    Dado que tenho um token de autenticação válido
#    ...    Quando faço uma requisição GET para /clients/{id}
#    ...    Então os campos devem tratar adequadamente caracteres especiais
#    [Tags]    data_validation    negative    regression    GET-CLIENT-66

## GET-CLIENT-67 - Validação de Campos Opcionais
#GET-CLIENT-67 - Validate Optional Fields - client list
#    [Documentation]    Validar campos opcionais quando presentes
#    ...
#    ...    ID: GET-CLIENT-67
#    ...
#    ...    Dado que tenho um token de autenticação válido
#    ...    Quando faço uma requisição GET para /clients
#    ...    Então os campos opcionais devem estar presentes quando aplicável
#    [Tags]    data_validation    positive    regression    GET-CLIENT-67
#
## GET-CLIENT-68 - Validação de Campos Opcionais
#GET-CLIENT-68 - Validate Optional Fields - client list
#    [Documentation]    Validar campos opcionais quando presentes
#    ...
#    ...    ID: GET-CLIENT-68
#    ...
#    ...    Dado que tenho um token de autenticação válido
#    ...    Quando faço uma requisição GET para /clients/{id}
#    ...    Então os campos opcionais devem estar presentes quando aplicável
#    [Tags]    data_validation    positive    regression    GET-CLIENT-68