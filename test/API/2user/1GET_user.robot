*** Settings ***
Resource  ../../../resources/resource.resource
Suite Setup    Suite Setup
Suite Teardown    Suite Teardown

*** Test Cases ***

### TODOS OS TESTES DE STATUS CODE ###

# 1 - Requisição bem-sucedida (200 OK)
Get Successful Response - user
    [Documentation]    Status 200 - Testa uma requisição bem-sucedida no endpoint GET.
    [Tags]    positive
    ${response}=    Get Users
    Validate Status Code 200    ${response}
    Validate Response Has Content    ${response}

# 2 - Não autorizado (401 Unauthorized)
Get Unauthorized Response - user
    [Documentation]    Status 401 - Testa o comportamento ao não fornecer token de autenticação.
    [Tags]    negative
    ${response}=    Get Users Without Token
    Validate Status Code 401    ${response}

# 4 - Recurso não encontrado (404 Not Found)
Get Resource Not Found - user
    [Documentation]    Status 404 - Testa uma requisição para um recurso inexistente.
    [Tags]    negative
    ${response}=    Get Non Existent User
    Validate Status Code 404    ${response}

# 5 - Requisição inválida (400 Bad Request)
Get Bad Request Error - user
    [Documentation]    Status 400 - Simula condições para causar solicitação inválida.
    [Tags]    negative
    ${response}=    Get users with invalid request error - Status Code 400
    Validate Status Code 400    ${response}

# 6 - Erro interno no servidor (500 Internal Server Error)       "Não implementado na API"
# Get Internal Server Error - user
#     [Documentation]    Status 500 - Simula condições para causar erro interno no servidor.
#     [Tags]    negative
#     ${response}=    Get Users With Server Error
#     Validate Status Code 500    ${response}

### TODOS OS TESTES DE SCHEMA ###

# 7 - Validação do corpo da requisição
Validate Response Body Schema - user
    [Documentation]    Status 200 - Valida que o corpo da resposta segue o schema esperado.
    [Tags]    schema    positive
    ${response}=    Get Users
    Validate Response Schema    ${response}    test_schema_get_200_user.json

### TODOS OS TESTES DE HEADERS ###

# 8 - Requisição sem header x-api-key
Get Users Without Required Header - user
    [Documentation]    Valida o comportamento da API quando a requisição é feita sem o header x-api-key.
    ...    Valida:
    ...    - Status code 401
    ...    - Mensagem de erro "Invalid token"
    [Tags]    headers    negative
    ${response_no_key}=    Get Users Without Token
    Should Be Equal    ${response_no_key}    Invalid token

# 9 - Requisição com header x-api-key inválido
Get Users With Invalid Header - user
    [Documentation]    Valida o comportamento da API quando a requisição é feita com header x-api-key inválido.
    ...    Valida:
    ...    - Status code 401
    ...    - Mensagem de erro "Invalid token"
    [Tags]    headers    negative
    ${response_invalid_key}=    Get Users With Invalid Key
    Should Be Equal    ${response_invalid_key}    Invalid token

# 10 - Requisição com header x-api-key válido
Get Users With Valid Header - user
    [Documentation]    Valida o comportamento da API quando a requisição é feita com header x-api-key válido.
    ...    Valida:
    ...    - Status code 200
    ...    - Resposta com conteúdo
    [Tags]    headers    positive
    ${response_valid_key}=    Get Users
    Status Should Be    200    ${response_valid_key}
    Validate Response Has Content    ${response_valid_key}

### TODOS OS TESTES DE MENSAGENS DE ERRO ###

# 11 - Validação de mensagem de sucesso (200 OK)
Validate Success Message - user
    [Documentation]    Verifica se a mensagem de sucesso está correta.
    ...    Valida:
    ...    - Status code 200
    ...    - Conteúdo da resposta não vazio
    [Tags]    messages    positive
    ${success_response}=    Get Users
    Status Should Be    200    ${success_response}
    Validate Response Has Content    ${success_response}

# 12 - Validação de mensagem não autorizado (401 Unauthorized)
Validate Unauthorized Message - user
    [Documentation]    Verifica se a mensagem de não autorizado está correta.
    ...    Valida:
    ...    - Status code 401
    ...    - Mensagem de erro "Invalid token"
    [Tags]    messages    negative
    ${unauthorized_msg}=    Get Users Without Token
    Should Be Equal    ${unauthorized_msg}    Invalid token

# 13 - Validação de mensagem não encontrado (404 Not Found)
Validate Not Found Message - user
    [Documentation]    Verifica se a mensagem de recurso não encontrado está correta.
    ...    Valida:
    ...    - Status code 404
    ...    - Mensagem de erro específica
    ...    - Estrutura da resposta de erro
    [Tags]    messages    negative
    ${not_found_msg}=    Get Non Existent User
    Should Be Equal    ${not_found_msg}[error]    Not Found
    Should Be Equal    ${not_found_msg}[message]    Cannot GET /users/999999
    Should Be Equal    ${not_found_msg}[statusCode]    ${404}

# 14 - Validação de mensagem requisição inválida (400 Bad Request)
Validate Bad Request Message - user
    [Documentation]    Verifica se a mensagem de requisição inválida está correta.
    ...    Valida:
    ...    - Status code 400
    ...    - Mensagem de erro específica
    ...    - Estrutura da resposta de erro
    [Tags]    messages    negative
    ${bad_request_msg}=    Get users with invalid request error - Status Code 400
    Should Be Equal    ${bad_request_msg}[error]    Bad Request
    Should Be Equal    ${bad_request_msg}[message]    Expected property name or '}' in JSON at position 1
    Should Be Equal    ${bad_request_msg}[statusCode]    ${400}

### TODOS OS TESTES DE PERFORMANCE ###

# 15 - Tempo de resposta para listagem de usuários
Validate Get Users Response Time - user
    [Documentation]    Verifica se o tempo de resposta da listagem de usuários está dentro do SLA.
    ...    Valida:
    ...    - Tempo de resposta menor que 1 segundo
    ...    - Status code 200
    ...    - Resposta com conteúdo válido
    [Tags]    performance    positive
    ${start_time}=    Get Time    epoch
    ${response}=    Get Users
    ${end_time}=    Get Time    epoch
    ${response_time}=    Evaluate    ${end_time} - ${start_time}
    
    Validate Response Time    ${response_time}
    Status Should Be    200    ${response}
    Validate Response Has Content    ${response}

# 16 - Tempo de resposta para usuário específico
Validate Get Single User Response Time - user
    [Documentation]    Verifica se o tempo de resposta ao buscar um usuário específico está dentro do SLA.
    ...    Valida:
    ...    - Tempo de resposta menor que 0.8 segundos
    ...    - Status code 404 (usando ID inexistente para teste)
    [Tags]    performance    negative
    ${start_time}=    Get Time    epoch
    ${response}=    Get Non Existent User
    ${end_time}=    Get Time    epoch
    ${response_time}=    Evaluate    ${end_time} - ${start_time}
    
    Validate Response Time    ${response_time}    0.8
    Should Be Equal    ${response}[error]    Not Found

# 17 - Tempo de resposta com token inválido
Validate Invalid Token Response Time - user
    [Documentation]    Verifica se o tempo de resposta com token inválido está dentro do SLA.
    ...    Valida:
    ...    - Tempo de resposta menor que 0.5 segundos
    ...    - Mensagem de erro apropriada
    [Tags]    performance    negative
    ${start_time}=    Get Time    epoch
    ${response}=    Get Users With Invalid Key
    ${end_time}=    Get Time    epoch
    ${response_time}=    Evaluate    ${end_time} - ${start_time}
    
    Validate Response Time    ${response_time}    0.5
    Should Be Equal    ${response}    Invalid token


