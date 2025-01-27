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
    ...    E a mensagem de erro deve indicar token inválido
    [Tags]    device    GET    error    auth    security
    ${response}=    Get Devices Without Auth
    Validate Device Status Code 401    ${response}

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
    ...    @endpoint: GET /devices/{id}
    ...    @status_code: 500 Internal Server Error
    ...    @param: id=123 456
    ...
    ...    Dado que busco um dispositivo com ID contendo espaço
    ...    Quando faço uma requisição GET para /devices/{id}
    ...    Então o status code deve ser 500 Internal Server Error
    ...    E a mensagem de erro deve indicar erro interno no servidor
    [Tags]    device    GET    error    server_error     robot:skip
    ${response}=    Get Device With Invalid Id    id=%
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

### TESTES DE HEADERS ###

GET-DEVICE-7 - Requisição sem header x-api-key (401 Invalid token)
    [Documentation]    Verifica se a requisição GET /devices retorna 401 quando não possui x-api-key
    ...    @endpoint: GET /devices
    ...    @status_code: 401 Invalid token
    ...    @error: Invalid token
    ...
    ...    Dado que não envio o header x-api-key
    ...    Quando faço uma requisição GET para /devices
    ...    Então o status code deve ser 401 Invalid token
    ...    E a mensagem de erro deve ser "Invalid token"
    [Tags]    device    GET    error    auth    security    header
    ${response}=    Get Devices Without Api Key
    Validate Device Status Code 401    ${response}

GET-DEVICE-8 - Requisição com header x-api-key inválido (401 Invalid token)
    [Documentation]    Verifica se a requisição GET /devices retorna 401 quando x-api-key é inválido
    ...    @endpoint: GET /devices
    ...    @status_code: 401 Invalid token
    ...    @error: Invalid token
    ...
    ...    Dado que envio um header x-api-key inválido
    ...    Quando faço uma requisição GET para /devices
    ...    Então o status code deve ser 401 Invalid token
    ...    E a mensagem de erro deve ser "Invalid token"
    [Tags]    device    GET    error    auth    security    header
    ${response}=    Get Devices With Invalid Api Key
    Validate Device Status Code 401    ${response}

GET-DEVICE-9 - Requisição com header x-api-key válido (200 OK)
    [Documentation]    Verifica se a requisição GET /devices retorna 200 quando x-api-key é válido
    ...    @endpoint: GET /devices
    ...    @status_code: 200 OK
    ...    @header: x-api-key=${HEADERS}[x-api-key]
    ...
    ...    Dado que envio um header x-api-key válido
    ...    Quando faço uma requisição GET para /devices
    ...    Então o status code deve ser 200 OK
    ...    E a lista de dispositivos deve ser retornada
    [Tags]    device    GET    success    auth    security    header
    ${response}=    Get Devices With Valid Api Key
    Validate Device Status Code 200    ${response}


### TESTES DE SCHEMA ###

GET-DEVICE-10 - Validação do corpo da requisição (200 OK)
    [Documentation]    Verifica se o corpo da resposta do GET /devices está no formato correto
    ...    @endpoint: GET /devices
    ...    @status_code: 200 OK
    ...    @schema: test_schema_get_200_device.json
    ...
    ...    Dado que o serviço está operacional
    ...    Quando faço uma requisição GET para /devices
    ...    Então o status code deve ser 200 OK
    ...    E o corpo da resposta deve seguir o schema definido
    [Tags]    device    GET    success    schema    contract
    ${response}=    Get Devices
    Validate Device Status Code 200    ${response}
    Validate Device Schema    ${response}

### TESTES DE LISTAGEM ###

GET-DEVICE-11 - Validação de Listagem de Dispositivos (200 OK)
    [Documentation]    Verifica se a listagem de dispositivos retorna corretamente
    ...    @endpoint: GET /devices
    ...    @status_code: 200 OK
    ...
    ...    Dado que quero visualizar a lista de dispositivos
    ...    Quando faço uma requisição GET para /devices
    ...    Então o status code deve ser 200 OK
    ...    E deve retornar a lista completa de dispositivos
    [Tags]    device    GET    success    list
    ${response}=    Get Devices
    Validate Device Status Code 200    ${response}
    Validate Device List    ${response}

### TESTES DE PAGINAÇÃO ###

GET-DEVICE-12 - Validação de Paginação - Primeira Página (200 OK)
    [Documentation]    Verifica se a paginação retorna corretamente a primeira página
    ...    @endpoint: GET /devices?page=0&size=10
    ...    @status_code: 200 OK
    ...    @param: page=0
    ...    @param: size=10
    ...
    ...    Dado que quero visualizar a primeira página
    ...    Quando faço uma requisição GET para /devices com page=0 e size=10
    ...    Então o status code deve ser 200 OK
    ...    E deve retornar a primeira página com 10 itens
    ...    E deve conter as informações de paginação
    [Tags]    device    GET    success    pagination    robot:skip
    ${response}=    Get Devices With Pagination    page=0    size=10
    Validate Device Status Code 200    ${response}
    Validate Pagination Info    ${response}    expected_page=0    expected_size=10

GET-DEVICE-13 - Validação de Paginação - Segunda Página (200 OK)
    [Documentation]    Verifica se a paginação retorna corretamente a segunda página
    ...    @endpoint: GET /devices?page=1&size=10
    ...    @status_code: 200 OK
    ...    @param: page=1
    ...    @param: size=10
    ...
    ...    Dado que quero visualizar a segunda página
    ...    Quando faço uma requisição GET para /devices com page=1 e size=10
    ...    Então o status code deve ser 200 OK
    ...    E deve retornar a segunda página com 10 itens
    ...    E deve conter as informações de paginação
    [Tags]    device    GET    success    pagination    robot:skip
    ${response}=    Get Devices With Pagination    page=1    size=10
    Validate Device Status Code 200    ${response}
    Validate Pagination Info    ${response}    expected_page=1    expected_size=10

GET-DEVICE-14 - Validação de Paginação - Página Inexistente (404 Not Found)
    [Documentation]    Verifica se a paginação retorna erro quando a página não existe
    ...    @endpoint: GET /devices?page=999&size=10
    ...    @status_code: 404 Not Found
    ...    @param: page=999
    ...    @param: size=10
    ...
    ...    Dado que busco uma página que não existe
    ...    Quando faço uma requisição GET para /devices com page=999
    ...    Então o status code deve ser 404 Not Found
    ...    E a mensagem de erro deve indicar página não encontrada
    [Tags]    device    GET    error    pagination    not_found    robot:skip
    ${response}=    Get Devices With Pagination    page=999    size=10
    Validate Device Status Code 404    ${response}

