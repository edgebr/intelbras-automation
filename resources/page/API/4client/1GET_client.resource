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
    [Documentation]    Envia uma requisição POST com JSON inválido para gerar erro 400
    ${malformed_json}=    Set Variable    {invalid_json
    &{headers}=    Create Dictionary
    ...    x-api-key=${HEADERS}[x-api-key]
    ...    Content-Type=application/json

    ${response}=    POST On Session
    ...    alias=user
    ...    url=${BASE_URL}/clients
    ...    headers=${headers}
    ...    data=${malformed_json}
    ...    expected_status=400

    RETURN    ${response}

Get Non Existent Client
    [Documentation]    Executa GET /clients para um cliente inexistente
    ${response}=    GET On Session
    ...    alias=user
    ...    url=${BASE_URL}/clients/999999
    ...    headers=${HEADERS}
    ...    expected_status=404
    RETURN    ${response}

Get Clients With Server Error
    [Documentation]    Simula uma requisição que causa erro 500 no servidor
    ${invalid_headers}=    Create Dictionary
    ...    x-api-key=${HEADERS}[x-api-key]
    ...    Content-Type=invalid/content-type
    ${response}=    GET On Session
    ...    alias=user
    ...    url=${BASE_URL}/clients
    ...    headers=${invalid_headers}
    ...    params=id=error500
    ...    expected_status=500
    ${error_response}=    Set Variable    ${response.json()}
    RETURN    ${error_response}

### KEYWORDS DE VALIDAÇÃO ###
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
    Should Be Equal    ${response_json}[error]    Bad Request
    Should Be Equal    ${response_json}[message]    Expected property name or '}' in JSON at position 1
    Should Be Equal    ${response_json}[statusCode]    ${400}

Validate Status Code 404 - client
    [Arguments]    ${response}
    [Documentation]    Valida que o código de status é 404 e as mensagens de erro
    Status Should Be    404    ${response}

    ${response_json}=    Set Variable    ${response.json()}
    Should Be Equal    ${response_json}[error]    Not Found
    Should Be Equal    ${response_json}[message]    Cannot GET /clients/999999
    Should Be Equal    ${response_json}[statusCode]    ${404}

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