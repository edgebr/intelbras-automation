*** Settings ***
Documentation     Testes do endpoint POST /devices
...    
...    Endpoint responsável pelo cadastro de dispositivos no sistema.
...    
...    Cenários testados:
...    1. Status Codes (201, 400, 401, 413, 504)
...    2. Validação de Payload
...    3. Autenticação e Segurança
...    4. Múltiplos Dispositivos
...    5. Headers e Timeout
...    
Resource          ../../../resources/resource.resource
Resource          ../../../resources/page/api/1device/2POST_devices.resource
Suite Setup       Suite Setup
Suite Teardown    Suite Teardown

*** Variables ***
${DEVICE_ENDPOINT}    ${BASE_URL}/devices
${CURRENT_DATE}    ${EMPTY}

*** Test Cases ***
############# Testes de Status Code #############
POST-DEVICE-1 - CODE 201 Post Successful Creation
    [Documentation]    Testa a criação bem-sucedida de um dispositivo
    ...    @endpoint: POST /devices
    ...    @status_code: 201 Created
    [Tags]    POST    DEVICE    CRUD    SUCCESS    API    SMOKE
    Skip   [BUG: CONSYS-220] A API está retornando uma resposta vazia quando deveria retornar a mensagem "The device has been created successfully"
    Dado Que Tenho Um Payload Valido Para Criacao De Dispositivo
    Quando Envio Uma Requisicao POST Para /devices
    E a mensagem "The device has been created successfully"

POST-DEVICE-2 - CODE 400 Post Invalid Request
    [Documentation]    Testa o comportamento ao enviar uma requisição com serialId duplicado
    ...    @endpoint: POST /devices
    ...    @status_code: 400 Bad Request
    [Tags]    POST    DEVICE    ERROR    API    VALIDATION
    Dado Que Tento Cadastrar Um Dispositivo Com SerialId Duplicado
    Quando Envio Uma Requisicao POST Para /devices
    Entao A API Deve Retornar Status 400 Bad Request
    E A Mensagem De Erro Deve Ser "Device already exists"

POST-DEVICE-11 - CODE 401 Post Device With Invalid Authentication
    [Documentation]    Testa o cadastro de dispositivo com autenticação inválida
    ...    @endpoint: POST /devices
    ...    @status_code: 401 Unauthorized
    [Tags]    POST    DEVICE    ERROR    API    AUTH
    Dado Que Envio Um Payload Valido Com Autenticacao Invalida
    Quando Envio Uma Requisicao POST Para /devices
    Entao A API Deve Retornar Status 401 Unauthorized
    E A Mensagem De Erro Deve Ser "Invalid token"

POST-DEVICE-12 - CODE 413 Post Device With Payload Size Exceeded
    [Documentation]    Testa o cadastro de dispositivo com limite de tamanho de payload excedido
    ...    @endpoint: POST /devices
    ...    @status_code: 413 Payload Too Large
    [Tags]    POST    DEVICE    ERROR    API    LIMITS
    Skip    [BUG: CONSYS-223] A API está retornando status 201 quando deveria retornar 413 Payload Too Large para payloads muito grandes
    Dado Que Envio Um Payload Com Tamanho Excedido
    Quando Envio Uma Requisicao POST Para /devices
    Entao A API Deve Retornar Status 413 Payload Too Large
    E A Mensagem De Erro Deve Ser "Payload too large"

############# Testes de Validação de Payload #############
POST-DEVICE-5 - CODE 400 Post Invalid Payload
    [Documentation]    Testa o cadastro de dispositivo com payload inválido
    [Tags]    POST    DEVICE    ERROR    API    VALIDATION
    Skip    [BUG: CONSYS-221] A API está retornando status 201 quando deveria retornar 400 Bad Request para payload sem serialId
    Dado Que Envio Um Payload Invalido
    Quando Envio Uma Requisicao POST Para /devices
    Entao A API Deve Retornar Status 400 Bad Request
    E A Mensagem De Erro Deve Ser "Invalid payload format"

POST-DEVICE-6 - CODE 400 Post Missing Required Fields
    [Documentation]    Testa o cadastro de dispositivo sem campos obrigatórios
    [Tags]    POST    DEVICE    ERROR    API    VALIDATION
    Dado Que Envio Um Payload Sem Campos Obrigatorios
    Quando Envio Uma Requisicao POST Para /devices
    Entao A API Deve Retornar Status 400 Bad Request
    E A Mensagem De Erro Deve Indicar Os Campos Obrigatorios Faltantes

############# Testes de Múltiplos Dispositivos #############
POST-DEVICE-3 - CODE 201 Post Multiple Devices With Unique SerialIds
    [Documentation]    Testa o cadastro de múltiplos dispositivos com serialIds únicos
    [Tags]    POST    DEVICE    SUCCESS    API    MULTIPLE
    Skip    [BUG: CONSYS-220] A API está retornando uma resposta vazia quando deveria retornar a mensagem "The device has been created successfully"
    Dado Que Envio Um Payload Com Multiplos Dispositivos Unicos
    Quando Envio Uma Requisicao POST Para /devices
    Entao A API Deve Retornar Status 201 Created
    E Todos Os Dispositivos Devem Ser Cadastrados

POST-DEVICE-4 - CODE 201 Post Multiple Devices With Some Duplicate SerialIds
    [Documentation]    Testa o cadastro de múltiplos dispositivos com alguns serialIds duplicados
    [Tags]    POST    DEVICE    SUCCESS    API    MULTIPLE
    Dado Que Envio Um Payload Com Multiplos Dispositivos E Alguns SerialIds Duplicados
    Quando Envio Uma Requisicao POST Para /devices
    Entao A API Deve Retornar Status 201 Created
    E Apenas Os Dispositivos Com SerialIds Unicos Devem Ser Cadastrados

POST-DEVICE-9 - CODE 400 Post Multiple Devices With All Duplicate SerialIds
    [Documentation]    Testa o cadastro de múltiplos dispositivos com todos serialIds duplicados
    [Tags]    POST    DEVICE    ERROR    API    MULTIPLE
    Skip    [BUG: CONSYS-222] A API está retornando status 201 quando deveria retornar 400 Bad Request para payload com todos serialIds duplicados
    Dado Que Envio Um Payload Com Multiplos Dispositivos E Todos SerialIds Duplicados
    Quando Envio Uma Requisicao POST Para /devices
    Entao A API Deve Retornar Status 400 Bad Request
    E A Mensagem De Erro Deve Ser "All devices already exist"

############# Testes de Headers e Timeout #############
POST-DEVICE-13 - CODE 401 Post Missing Required Headers
    [Documentation]    Testa o cadastro de dispositivo sem headers obrigatórios
    [Tags]    POST    DEVICE    ERROR    API    HEADERS
    Dado Que Envio Um Payload Valido Sem Headers Obrigatorios
    Quando Envio Uma Requisicao POST Para /devices
    Entao A API Deve Retornar Status 401 Unauthorized
    E A Mensagem De Erro Deve Ser "Invalid token"

############# Testes de Schema #############
POST-DEVICE-14 - CODE 201 Schema Validation Success Response
    [Documentation]    Testa se o schema da resposta 201 está correto
    ...    @endpoint: POST /devices
    ...    @status_code: 201 Created
    ...
    [Tags]    POST    DEVICE    SCHEMA    API    SUCCESS
    Skip    [BUG: CONSYS-220] A API está retornando uma resposta vazia quando deveria retornar a mensagem "The device has been created successfully"
    Dado Que Tenho Um Payload Valido Para Criacao De Dispositivo
    Quando Envio Uma Requisicao POST Para /devices
    Entao A API Deve Retornar Status 201 Created
    E O Schema Deve Ser "test_schema_post_201_device.json"

POST-DEVICE-15 - CODE 400 Schema Validation Error Response
    [Documentation]    Testa se o schema da resposta 400 está correto
    ...    @endpoint: POST /devices
    ...    @status_code: 400 Bad Request
    ...
    [Tags]    POST    DEVICE    SCHEMA    API    ERROR
    Dado Que Tento Cadastrar Um Dispositivo Com SerialId Duplicado
    Quando Envio Uma Requisicao POST Para /devices
    Entao A API Deve Retornar Status 400 Bad Request
    E O Schema Deve Ser "test_schema_post_400_device.json"

POST-DEVICE-16 - CODE 401 Schema Validation Unauthorized Response
    [Documentation]    Testa se o schema da resposta 401 está correto
    ...    @endpoint: POST /devices
    ...    @status_code: 401 Unauthorized
    ...
    [Tags]    POST    DEVICE    SCHEMA    API    ERROR
    Dado Que Envio Um Payload Valido Com Autenticacao Invalida
    Quando Envio Uma Requisicao POST Para /devices
    Entao A API Deve Retornar Status 401 Unauthorized
    E O Schema Deve Ser "test_schema_post_401_device.json"

POST-DEVICE-17 - CODE 413 Schema Validation Payload Too Large Response
    [Documentation]    Testa se o schema da resposta 413 está correto
    ...    @endpoint: POST /devices
    ...    @status_code: 413 Payload Too Large
    ...
    [Tags]    POST    DEVICE    SCHEMA    API    ERROR
    Skip    [BUG: CONSYS-223] A API está retornando status 201 quando deveria retornar 413 Payload Too Large para payloads muito grandes
    Dado Que Envio Um Payload Com Tamanho Excedido
    Quando Envio Uma Requisicao POST Para /devices
    Entao A API Deve Retornar Status 413 Payload Too Large
    E O Schema Deve Ser "test_schema_post_413_device.json"

############# Testes Pendentes de Implementação #############
# Duplicação de recurso
# Post Duplicate Resource
#     [Documentation]    Testa o envio de requisições idênticas repetidamente.

# Validação de tipos de dados
# Post Data Type Validation
#     [Documentation]    Testa se os campos do payload aceitam apenas os tipos corretos.

# Resposta da criação
# Post Creation Response Validation
#     [Documentation]    Verifica se o ID ou URI do recurso criado é retornado.

# Segurança
# Post Sensitive Data Validation
#     [Documentation]    Verifica se dados sensíveis no payload não são aceitos ou expostos.

# Limites e restrições
# Post Payload Restriction Validation
#     [Documentation]    Testa campos com valores fora dos limites permitidos.

# Mensagens de erro
# Post Error Message Validation
#     [Documentation]    Verifica se as mensagens de erro retornadas são claras e consistentes.

# Timeout
# Post Request Timeout
#     [Documentation]    Testa comportamento da API com requisições que excedem o tempo limite.

# Valores padrão
# Post Default Value Creation
#     [Documentation]    Testa a criação de recurso com valores padrão para campos omitidos.

# Concorrência
# Post Concurrent Requests
#     [Documentation]    Envia requisições POST simultaneamente para verificar a consistência.

# Headers adicionais
# Post Extra Headers Validation
#     [Documentation]    Testa envio de headers extras e verifica comportamento.

