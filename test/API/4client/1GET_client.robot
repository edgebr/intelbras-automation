*** Settings ***
Documentation     Testes do endpoint GET /clients
...
...    Endpoint: GET /clients
...    Descrição: Retorna lista de clientes cadastrados
...    Autenticação: x-api-key header required
...    Rate Limit: 1000 requests/hour
...    Cache: ETag implementation
...    SLA: 1s response time

Resource          ../../../resources/page/api/4client/1GET_client.resource

Force Tags        api    get_clients
Default Tags      regression

Suite Setup    Suite Setup
Suite Teardown    Delete All Sessions

*** Variables ***


*** Test Cases ***
### TESTES DE STATUS CODE ###

# GET-1 - Requisição bem-sucedida (200 OK)
Get Successful Response - client
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

# GET-2 - Requisição sem autenticação (401 Unauthorized)
Get Unauthorized Response - client
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

# GET-3 - Requisição inválida (400 Bad Request)
Get Bad Request Error - client
    [Documentation]    Validar comportamento da API com requisição inválida
    ...
    ...    ID: GET-3
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para /clients com parâmetros inválidos
    ...    Então devo receber status code 400
    ...    E devo receber uma mensagem de erro apropriada
    [Tags]    status_code    negative    regression    GET-3
    ${response}=    Get Clients With Invalid Request
    Validate Status Code 400 - client    ${response}
    Log Response Details - client    ${response}

# GET-4 - Recurso não encontrado (404 Not Found)
Get Resource Not Found - client
    [Documentation]    Validar comportamento da API ao buscar recurso inexistente
    ...
    ...    ID: GET-4
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição GET para um cliente que não existe
    ...    Então devo receber status code 404
    ...    E devo receber uma mensagem indicando que o recurso não foi encontrado
    [Tags]    status_code    negative    regression    GET-4
    ${response}=    Get Non Existent Client
    Validate Status Code 404 - client    ${response}
    Log Response Details - client    ${response}

# GET-5 - Erro interno no servidor (500 Internal Server Error)
Get Internal Server Error - client
    [Documentation]    Validar comportamento da API em caso de erro interno
    ...
    ...    ID: GET-5
    ...
    ...    Dado que tenho um token de autenticação válido
    ...    Quando faço uma requisição que causa erro interno no servidor
    ...    Então devo receber status code 500
    ...    E devo receber uma mensagem de erro interno do servidor
    [Tags]    status_code    negative    GET-5
    ${response}=    Get Clients With Server Error
    Validate Status Code 500 - client    ${response}
    Log    ${response}

### TESTES DE HEADERS ###

## GET-6 - Requisição sem header x-api-key
#Get Users Without Required Header - client
#    [Documentation]    Validar comportamento da API quando a requisição é feita sem o header x-api-key
#    ...
#    ...    ID: GET-6
#    ...
#    ...    Dado que não envio o header x-api-key
#    ...    Quando faço uma requisição GET para /clients
#    ...    Então devo receber status code 401
#    ...    E devo receber a mensagem "Invalid token"

## GET-7 - Requisição com header x-api-key inválido
#Get Users With Invalid Header - clients
#    [Documentation]    Validar comportamento da API quando requisição é feita com token inválido
#    ...
#    ...    ID: GET-7
#    ...
#    ...    Dado que envio um token de autenticação inválido
#    ...    Quando faço uma requisição GET para /clients
#    ...    Então devo receber status code 401
#    ...    E devo receber a mensagem "Invalid token"
#    ...    E os detalhes da resposta devem ser registrados

## GET-8 - Requisição com header x-api-key válido
#Get Users With Valid Header - client
#    [Documentation]    Validar comportamento da API quando a requisição é feita com header x-api-key válido
#    ...
#    ...    ID: GET-8
#    ...
#    ...    Dado que envio um token de autenticação válido
#    ...    Quando faço uma requisição GET para /clients
#    ...    Então devo receber status code 200
#    ...    E devo receber uma lista de clientes