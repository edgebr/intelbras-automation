*** Settings ***
Documentation     Testes do endpoint GET /devices
Resource          ../../../resources/resource.resource
Resource          ../../../resources/page/api/1device/1GET_devices.resource
Suite Setup       Suite Setup
Suite Teardown    Suite Teardown

*** Variables ***
${STORED_SERIAL_ID}    ${EMPTY}

*** Test Cases ***
### TESTES STATUS CODE ###
GET-DEVICE-1 - Requisição bem-sucedida (200 OK)
    [Documentation]    Verifica se a requisição GET /devices retorna 200 OK
    ...    @endpoint: GET /devices
    ...    @status_code: 200 OK
    ...
    ...    Dado que o serviço esteja operacional
    ...    Quando faço uma requisição GET para /devices
    ...    Então o status code deve ser 200 OK
    [Tags]    device    GET    success    smoke
    ${response}=    Get Devices
    Validate Device Status Code 200    ${response}

GET-DEVICE-2 - Requisição sem autenticação (401 Unauthorized)
    [Documentation]    Verifica se a requisição GET /devices retorna 401 quando não autenticada
    ...    @endpoint: GET /devices
    ...    @status_code: 401 Unauthorized
    ...
    ...    Dado que não possuo um token de autenticação
    ...    Quando faço uma requisição GET para /devices
    ...    Então o status code deve ser 401 Unauthorized
    [Tags]    device    GET    error    auth    security
    ${response}=    Get Devices Without Auth
    ${status_code}=    Convert To String    ${response.status_code}
    Should Be Equal As Strings    ${status_code}    401

GET-DEVICE-3 - Requisição inválida (400 Bad Request)
    [Documentation]    Verifica se a requisição GET /devices retorna 400 com JSON inválido
    ...    @endpoint: GET /devices
    ...    @status_code: 400 Bad Request
    ...
    ...    Dado que tenho um JSON inválido no corpo da requisição
    ...    Quando faço uma requisição GET para /devices
    ...    Então o status code deve ser 400 Bad Request
    ...    E a mensagem de erro deve indicar JSON inválido
    [Tags]    device    GET    error    validation
    ${response}=    Get Devices With Invalid Params
    Validate Device Status Code 400    ${response}

GET-DEVICE-4 - Recurso não encontrado (404 Not Found)
    [Documentation]    Verifica se a requisição GET /devices retorna 404 quando o dispositivo não existe
    ...    @endpoint: GET /devices/{id}
    ...    @status_code: 404 Not Found
    ...
    ...    Dado que busco um dispositivo com ID inexistente
    ...    Quando faço uma requisição GET para /devices/{id}
    ...    Então o status code deve ser 404 Not Found
    ...    E a mensagem de erro deve indicar que o dispositivo não foi encontrado
    [Tags]    device    GET    error    not_found
    ${response}=    Get Device Not Found
    Validate Device Status Code 404    ${response}

GET-DEVICE-5 - Erro interno no servidor (500 Internal Server Error)
    [Documentation]    Verifica se a requisição GET /devices retorna 500 em caso de erro interno
    ...    @endpoint: GET /devices
    ...    @status_code: 500 Internal Server Error
    ...
    ...    Dado que ocorre um erro interno no servidor
    ...    Quando faço uma requisição GET para /devices
    ...    Então o status code deve ser 500 Internal Server Error
    ...    E a mensagem de erro deve indicar erro interno no servidor
    ...
    ...    Issue: Endpoint /error500 não está disponível para simular erro 500
    [Tags]    device    GET    error    server_error    robot:skip
    ${response}=    Get Device Internal Server Error
    Validate Device Status Code 500    ${response}

GET-DEVICE-6 - Buscar dispositivo por serialId (200 OK)
    [Documentation]    Verifica se a requisição GET /devices com serialId retorna 200 OK
    ...    @endpoint: GET /devices?serialId={serialId}
    ...    @status_code: 200 OK
    ...
    ...    Dado que tenho um serialId válido
    ...    Quando faço uma requisição GET para /devices com o serialId
    ...    Então o status code deve ser 200 OK
    ...    E o dispositivo retornado deve ter o serialId informado
    [Tags]    device    GET    success    filter    serialId
    [Setup]    Get And Store Serial Id
    ${response}=    Get Device By Serial Id    serialId=${STORED_SERIAL_ID}
    Validate Device Status Code 200    ${response}
    Validate Device Serial Id    ${response}    serialId=${STORED_SERIAL_ID}


    
