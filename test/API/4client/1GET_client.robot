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
...    - API-133: GET /users/{id} retorna 500 ao enviar ID numérico muito longo

Resource          ../../../resources/page/api/4client/1GET_client.resource

Force Tags        api    get_clients
Default Tags      regression

Suite Setup    Suite Setup
Suite Teardown    Delete All Sessions

*** Variables ***
&{KNOWN_ISSUES}
...    API-133=GET /users/{id} retorna 500 ao enviar ID numérico muito longo


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
    [Tags]    status_code    positive    regression    smoke    priority_high    data_validation    GET-1
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
    [Tags]    api    get_clients    negative    priority_high    regression    security    status_code    GET-2
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
    [Tags]    status_code    negative    regression    GET-3
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
    [Tags]    status_code    negative    regression    GET-4
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
    [Tags]    status_code    negative    known_issue    GET-5
    ${response}=    Get Clients With Server Error
    Validate Status Code 500 - client    ${response}
    Log    ${response}
    [Setup]    Log    API-129 - GET /users/{id} retorna 500 ao enviar ID numérico muito longo

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
    [Tags]    headers    negative    regression    GET-6
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
    [Tags]    headers    negative    regression    GET-7
    ${response}=    Get Clients With Invalid Key
    Validate Status Code 401    ${response}
    Validate Error Message    ${response}    Invalid token
    Log Response Details - client    ${response}

# GET-CLIENT-8 - Requisição com header x-api-key válido
GET-CLIENT-8 - Get Users With Valid Header - client
    [Documentation]    Validar comportamento da API quando a requisição é feita com header x-api-key válido
    ...
    ...    ID: GET-8
    ...
    ...    Dado que envio um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients
    ...    Então devo receber status code 200
    ...    E devo receber uma lista de clientes
    [Tags]    headers    positive    regression    GET-8
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
    [Tags]    schema    positive    regression    GET-9
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
    [Tags]    schema    positive    regression    GET-10
    ${response}=    Get Client By ID    1
    Validate Status Code 200 - client    ${response}
    Validate Response Schema    ${response}    test_schema_get_200_client_by_id.json
    Log    Schema validation completed successfully

### TESTES DE PAGINAÇÃO ###

## GET-13 - Validação de Paginação - Primeira Página
#Validate First Page - client
#    [Documentation]    Validar a primeira página no endpoint GET /users
#    ...
#    ...    ID: GET-13
#    ...
#    ...    Dado que tenho um token de autenticação válido
#    ...    Quando faço uma requisição GET para /clients com paginação na primeira página
#    ...    Então devo receber status code 200
#    ...    E devo receber a primeira página de resultados
#    [Tags]    pagination    positive    known_issue    GET-13

## GET-14 - Validação de Paginação - Segunda Página
#Validate Second Page - client
#    [Documentation]    Validar a segunda página no endpoint GET /clients
#    ...
#    ...    ID: GET-14
#    ...
#    ...    Dado que tenho um token de autenticação válido
#    ...    Quando faço uma requisição GET para /clients com paginação na segunda página
#    ...    Então devo receber status code 200
#    ...    E devo receber a segunda página de resultados
#    [Tags]    pagination    positive    known_issue    GET-14

## GET-15 - Validação de Paginação - Página Inexistente
#Validate Non Existent Page - user
#    [Documentation]    Validar comportamento ao solicitar uma página inexistente
#    ...
#    ...    ID: GET-15
#    ...
#    ...    Dado que tenho um token de autenticação válido
#    ...    Quando faço uma requisição GET para /clients com paginação em uma página inexistente
#    ...    Então devo receber status code 200
#    ...    E devo receber uma lista vazia
#    [Tags]    pagination    positive    known_issue    robot:skip    GET-15

### TESTES DE FILTROS ###

# GET-16 - Verificação do Filtro por ID existente
#Verify ID Filter - client
#    [Documentation]    Validar o filtro por ID no endpoint GET /clients/{id}
#    ...
#    ...    ID: GET-16
#    ...
#    ...    Dado que tenho um token de autenticação válido
#    ...    Quando faço uma requisição GET para /clientes/{id} para filtrar por um ID existente
#    ...    Então devo receber status code 200
#    ...    E o resultado deve corresponder ao filtro aplicado
#    [Tags]    filter    positive    smoke    regression    GET-16

## GET-17 - Verificação do Filtro por ID inexistente
#Verify ID Filter - client
#    [Documentation]    Validar o filtro por ID no endpoint GET /clients/{id}
#    ...
#    ...    ID: GET-17
#    ...
#    ...    Dado que tenho um token de autenticação válido
#    ...    Quando faço uma requisição GET para /clientes/{id} para filtrar por um ID inexistente
#    ...    Então devo receber status code 404
#    ...    E devo receber uma mensagem indicando que o cliente não foi encontrado
#    [Tags]    filter    negative    smoke    regression    GET-17

## GET-18 - Validação de Caracteres não permitidos no Filtro por ID
#Validate Special Characters In ID Filter - client
#    [Documentation]    Validar comportamento do filtro com caracteres especiais
#    ...
#    ...    ID: GET-18
#    ...
#    ...    Dado que tenho um token de autenticação válido
#    ...    Quando faço uma requisição GET para /clientes/{id} com filtro de ID contendo caracteres especiais
#    ...    Então devo receber status code 404
#    ...    E devo receber uma mensagem indicando que o id deve ser um número inteiro
#    [Tags]    filter    negative    regression    GET-18