*** Settings ***
Documentation     Testes do endpoint POST /devices
...    
...    Endpoint responsável pelo cadastro de dispositivos no sistema.
...    
...    Cenários testados:
...    1. Criação bem-sucedida (201)
...    - Cadastro de dispositivo único
...    - Cadastro de múltiplos dispositivos
...    
...    2. Validações de negócio (400)
...    - SerialId duplicado
...    - Payload inválido
...    - Campos obrigatórios ausentes
...    - Múltiplos dispositivos com serialIds duplicados
...    
...    3. Segurança (401, 413)
...    - Autenticação inválida
...    - Payload muito grande
...    
...    Payload esperado:
...    {
...        "devices": [
...            {
...                "serialId": "ABC123XYZ789"
...            }
...        ],
...        "productCode": "0000000"
...    }
...    
...    Headers obrigatórios:
...    - Content-Type: application/json
...    - Accept: application/json
...    - x-api-key: chave de autenticação válida
Resource          ../../../resources/resource.resource
Resource          ../../../resources/page/api/1device/2POST_devices.resource
Suite Setup       Suite Setup
Suite Teardown    Suite Teardown

*** Variables ***
${DEVICE_ENDPOINT}    ${BASE_URL}/devices
${CURRENT_DATE}    ${EMPTY}

*** Test Cases ***

# # 1 - Criação bem-sucedida (201 Created)
POST-DEVICE-1 - CODE 201 Post Successful Creation
    [Documentation]    Testa a criação bem-sucedida de um dispositivo
    ...    @endpoint: POST /devices
    ...    @status_code: 201 Created
    ...
    [Tags]    POST    DEVICE    CRUD    SUCCESS    API    SMOKE
    Skip   [BUG: CONSYS-220] A API está retornando uma resposta vazia quando deveria retornar a mensagem "The device has been created successfully"
    Dado Que Tenho Um Payload Valido Para Criacao De Dispositivo
    Quando Envio Uma Requisicao POST Para /devices
    E a mensagem "The device has been created successfully"


# # 2 - Requisição inválida (400 Bad Request)
POST-DEVICE-2 - CODE 400 Post Invalid Request
    [Documentation]    Testa o comportamento ao enviar uma requisição com serialId duplicado
    ...    @endpoint: POST /devices
    ...    @status_code: 400 Bad Request
    ...
    [Tags]    POST    DEVICE    ERROR    API    VALIDATION
    Dado Que Tento Cadastrar Um Dispositivo Com SerialId Duplicado
    Quando Envio Uma Requisicao POST Para /devices
    Entao A API Deve Retornar Status 400 Bad Request
    E A Mensagem De Erro Deve Ser "Device already exists"

POST-DEVICE-3 - CODE 201 Post Multiple Devices With Unique SerialIds
    [Documentation]    Testa o cadastro de múltiplos dispositivos com serialIds únicos
    ...    @endpoint: POST /devices
    ...    @status_code: 201 Created
    ...
    [Tags]    POST    DEVICE    SUCCESS    API    MULTIPLE
    Skip    [BUG: CONSYS-220] A API está retornando uma resposta vazia quando deveria retornar a mensagem "The device has been created successfully"
    Dado Que Envio Um Payload Com Multiplos Dispositivos Unicos
    Quando Envio Uma Requisicao POST Para /devices
    Entao A API Deve Retornar Status 201 Created
    E Todos Os Dispositivos Devem Ser Cadastrados

POST-DEVICE-4 - CODE 201 Post Multiple Devices With Some Duplicate SerialIds
    [Documentation]    Testa o cadastro de múltiplos dispositivos com alguns serialIds duplicados
    ...    @endpoint: POST /devices
    ...    @status_code: 201 Created
    ...
    [Tags]    POST    DEVICE    SUCCESS    API    MULTIPLE
    Dado Que Envio Um Payload Com Multiplos Dispositivos E Alguns SerialIds Duplicados
    Quando Envio Uma Requisicao POST Para /devices
    Entao A API Deve Retornar Status 201 Created
    E Apenas Os Dispositivos Com SerialIds Unicos Devem Ser Cadastrados

POST-DEVICE-5 - CODE 400 Post Invalid Payload
    [Documentation]    Testa o cadastro de dispositivo com payload inválido
    ...    @endpoint: POST /devices
    ...    @status_code: 400 Bad Request
    ...
    [Tags]    POST    DEVICE    ERROR    API    VALIDATION
    Skip    [BUG: CONSYS-221] A API está retornando status 201 quando deveria retornar 400 Bad Request para payload sem serialId
    Dado Que Envio Um Payload Invalido
    Quando Envio Uma Requisicao POST Para /devices
    Entao A API Deve Retornar Status 400 Bad Request
    E A Mensagem De Erro Deve Ser "Invalid payload format"

POST-DEVICE-6 - CODE 400 Post Missing Required Fields
    [Documentation]    Testa o cadastro de dispositivo sem campos obrigatórios
    ...    @endpoint: POST /devices
    ...    @status_code: 400 Bad Request
    ...
    [Tags]    POST    DEVICE    ERROR    API    VALIDATION
    Dado Que Envio Um Payload Sem Campos Obrigatorios
    Quando Envio Uma Requisicao POST Para /devices
    Entao A API Deve Retornar Status 400 Bad Request
    E A Mensagem De Erro Deve Indicar Os Campos Obrigatorios Faltantes

POST-DEVICE-7 - CODE 201 Post Multiple Devices With All Unique SerialIds
    [Documentation]    Testa o cadastro de múltiplos dispositivos com todos serialIds únicos
    ...    @endpoint: POST /devices
    ...    @status_code: 201 Created
    ...
    [Tags]    POST    DEVICE    SUCCESS    API    MULTIPLE
    Skip    [BUG: CONSYS-220] A API está retornando uma resposta vazia quando deveria retornar a mensagem "The device has been created successfully"
    Dado Que Envio Um Payload Com Multiplos Dispositivos Unicos
    Quando Envio Uma Requisicao POST Para /devices
    Entao A API Deve Retornar Status 201 Created
    E Todos Os Dispositivos Devem Ser Cadastrados

POST-DEVICE-8 - CODE 201 Post Multiple Devices With Some Duplicate SerialIds
    [Documentation]    Testa o cadastro de múltiplos dispositivos com alguns serialIds duplicados
    ...    @endpoint: POST /devices
    ...    @status_code: 201 Created
    ...
    [Tags]    POST    DEVICE    SUCCESS    API    MULTIPLE
    Dado Que Envio Um Payload Com Multiplos Dispositivos E Alguns SerialIds Duplicados
    Quando Envio Uma Requisicao POST Para /devices
    Entao A API Deve Retornar Status 201 Created
    E Apenas Os Dispositivos Com SerialIds Unicos Devem Ser Cadastrados

POST-DEVICE-9 - CODE 400 Post Multiple Devices With All Duplicate SerialIds
    [Documentation]    Testa o cadastro de múltiplos dispositivos com todos serialIds duplicados
    ...    @endpoint: POST /devices
    ...    @status_code: 400 Bad Request
    ...
    [Tags]    POST    DEVICE    ERROR    API    MULTIPLE
    Skip    [BUG: CONSYS-222] A API está retornando status 201 quando deveria retornar 400 Bad Request para payload com todos serialIds duplicados
    Dado Que Envio Um Payload Com Multiplos Dispositivos E Todos SerialIds Duplicados
    Quando Envio Uma Requisicao POST Para /devices
    Entao A API Deve Retornar Status 400 Bad Request
    E A Mensagem De Erro Deve Ser "All devices already exist"

POST-DEVICE-10 - CODE 400 Post Multiple Devices With Partially Invalid Payload
    [Documentation]    Testa o cadastro de múltiplos dispositivos com payload parcialmente inválido
    ...    @endpoint: POST /devices
    ...    @status_code: 400 Bad Request
    ...
    [Tags]    POST    DEVICE    ERROR    API    MULTIPLE
    Skip    [BUG: CONSYS-221] A API está retornando status 201 quando deveria retornar 400 Bad Request para payload com serialId inválido
    Dado Que Envio Um Payload Com Multiplos Dispositivos E Alguns Invalidos
    Quando Envio Uma Requisicao POST Para /devices
    Entao A API Deve Retornar Status 400 Bad Request
    E A Mensagem De Erro Deve Indicar Quais Dispositivos Tem Problemas


POST-DEVICE-11 - CODE 401 Post Device With Invalid Authentication
    [Documentation]    Testa o cadastro de dispositivo com autenticação inválida
    ...    @endpoint: POST /devices
    ...    @status_code: 401 Unauthorized
    ...
    [Tags]    POST    DEVICE    ERROR    API    AUTH
    Dado Que Envio Um Payload Valido Com Autenticacao Invalida
    Quando Envio Uma Requisicao POST Para /devices
    Entao A API Deve Retornar Status 401 Unauthorized
    E A Mensagem De Erro Deve Ser "Invalid token"


POST-DEVICE-12 - CODE 413 Post Device With Payload Size Exceeded
    [Documentation]    Testa o cadastro de dispositivo com limite de tamanho de payload excedido
    ...    @endpoint: POST /devices
    ...    @status_code: 413 Payload Too Large
    ...
    [Tags]    POST    DEVICE    ERROR    API    LIMITS
    Skip    [BUG: CONSYS-223] A API está retornando status 201 quando deveria retornar 413 Payload Too Large para payloads muito grandes
    Dado Que Envio Um Payload Com Tamanho Excedido
    Quando Envio Uma Requisicao POST Para /devices
    Entao A API Deve Retornar Status 413 Payload Too Large
    E A Mensagem De Erro Deve Ser "Payload too large"


# # 4 - Acesso proibido (403 Forbidden)
# Post Forbidden Request
#     [Documentation]    Testa o comportamento com credenciais inválidas.


# # 5 - Conflito de recurso (409 Conflict)
# Post Resource Conflict
#     [Documentation]    Testa o comportamento ao tentar criar um recurso já existente.


# # 6 - Erro interno no servidor (500 Internal Server Error)
# Post Internal Server Error
#     [Documentation]    Simula condições que causam erro interno no servidor.


# # 7 - Validação de campos obrigatórios
# Post Mandatory Fields Validation
#     [Documentation]    Testa o envio de requisições sem campos obrigatórios.


# # 8 - Validação de tamanho de payload
# Post Payload Size Validation
#     [Documentation]    Testa o comportamento ao enviar payloads grandes.


# # 9 - Headers obrigatórios
# Post Required Headers
#     [Documentation]    Verifica se os headers obrigatórios estão presentes.


# # 10 - Duplicação de recurso
# Post Duplicate Resource
#     [Documentation]    Testa o envio de requisições idênticas repetidamente.


# # 11 - Validação de tipos de dados no corpo da requisição
# Post Data Type Validation
#     [Documentation]    Testa se os campos do payload aceitam apenas os tipos corretos.


# # 12 - Resposta da criação (URI ou ID do recurso criado)
# Post Creation Response Validation
#     [Documentation]    Verifica se o ID ou URI do recurso criado é retornado.

# # 13 - Segurança (dados sensíveis no payload)
# Post Sensitive Data Validation
#     [Documentation]    Verifica se dados sensíveis no payload não são aceitos ou expostos.


# # 14 - Limites e restrições do payload
# Post Payload Restriction Validation
#     [Documentation]    Testa campos com valores fora dos limites permitidos.


# # 15 - Validação de mensagens de erro claras e consistentes
# Post Error Message Validation
#     [Documentation]    Verifica se as mensagens de erro retornadas são claras e consistentes.


# # 16 - Timeout da requisição
# Post Request Timeout
#     [Documentation]    Testa comportamento da API com requisições que excedem o tempo limite.


# # 17 - Criação com valores padrão
# Post Default Value Creation
#     [Documentation]    Testa a criação de recurso com valores padrão para campos omitidos.


# # 18 - Validação de comportamento em situações de concorrência
# Post Concurrent Requests
#     [Documentation]    Envia requisições POST simultaneamente para verificar a consistência.


# # 19 - Requisição com autenticação inválida
# Post Invalid Authentication
#     [Documentation]    Testa envio de requisições com autenticação inválida.


# # 20 - Testar comportamento com headers adicionais
# Post Extra Headers Validation
#     [Documentation]    Testa envio de headers extras e verifica comportamento.

