*** Settings ***
Documentation     Testes do endpoint PUT /clients
...
...    Endpoint responsável pela atualização de clientes no sistema.
...
...    Cenários testados:
...    1.
...    2.
...    3.
...    4.
...    5.
...
Resource          ../../../resources/resource.resource
Resource          ../../../resources/page/api/4client/4PUT_client.resource
Suite Setup    Suite Setup
Suite Teardown    Delete All Sessions

*** Variables ***


*** Test Cases ***

PUT-CLIENT-X - Atualizacao Bem-sucedida
    [Documentation]    Validar a atualização bem-sucedida de um cliente existente
    ...
    ...    @endpoint: PUT /clients
    ...    @status_code: 204 No Content
    ...
    [Tags]    PUT    CLIENT    SUCCESS    API
    Dado Que Tenho Um Payload Valido Para Atualizacao De Cliente Com ID "1"
    Quando Envio Uma Requisicao PUT Para /clients
    Entao A API Deve Retornar Status Code 204

PUT-CLIENT-X - Atualizacao De Cliente Inexistente
    [Documentation]    Validar tentativa de atualização de um cliente inexistente
    ...
    ...    @endpoint: PUT /clients
    ...    @status_code: 404 Not Found
    ...
    [Tags]    PUT    CLIENT    ERROR    API
    Dado Que Tenho Um Payload Valido Para Atualizacao De Cliente Com ID "0"
    Quando Envio Uma Requisicao PUT Para /clients
    Entao A API Deve Retornar Status Code 404
    E A Mensagem De Erro Deve Ser "Client not found"

PUT-CLIENT-X - Atualizar Cliente Com applicationId Inexistente
    [Documentation]    Validar o comportamento da API ao tentar atualizar um cliente com um applicationId que não existe
    ...
    ...    @endpoint: PUT /clients
    ...    @status_code: 404 Not Found
    ...
    [Tags]    PUT    CLIENT    ERROR    API
    Skip    [BUG: CONSYS-228] Ausência de erro ao enviar requisição para PUT /clients com applicationId = 0
    Dado Que Tenho Um Payload Valido Para Atualizacao De Cliente Com ID "1"
    E A applicationId "0" Informada No Payload Nao Existe No Sistema
    Quando Envio Uma Requisicao PUT Para /clients
    Entao A API Deve Retornar Status Code 404
    E A Mensagem De Erro Deve Ser "Application not found"

PUT-CLIENT-X - Atualizar Cliente Com groupId Inexistente
    [Documentation]    Validar o comportamento da API ao tentar atualizar um cliente associando-o a um groupId inexistente
    ...
    ...    @endpoint: PUT /clients
    ...    @status_code: 404 Not Found
    ...
    [Tags]    PUT    CLIENT    ERROR    API
    Skip    [BUG: CONSYS-213] Ausência de erro ao enviar requisição para PUT /clients com groupId inexistente
    Dado Que Tenho Um Payload Valido Para Atualizacao De Cliente Com ID "1"
    E O groupId "0" Informado No Payload Nao Existe No Sistema
    Quando Envio Uma Requisicao PUT Para /clients
    Entao A API Deve Retornar Status Code 404
    E A Mensagem De Erro Deve Ser "Group not found"

PUT-CLIENT-X - Requisicao Com Autenticacao Invalida
    [Documentation]    Validar que a API não permite atualização com autenticação válida
    ...
    ...    @endpoint: PUT /clients
    ...    @status_code: 401 Unauthorized
    ...
    [Tags]    PUT    CLIENT    ERROR    API
    Dado Que Tenho Um Payload Valido Com Autenticacao Invalida Para Atualizacao De Cliente Com ID "1"
    Quando Envio Uma Requisicao PUT Para /clients
    Entao A API Deve Retornar Status Code 401
    E A Mensagem De Erro Deve Ser "Invalid token"

PUT-CLIENT-X - Validacao De Campos Obrigatorios
   [Documentation]    Validar que a API retorna erro quando campos obrigatórios estão ausentes
    ...
    ...    @endpoint: PUT /clients
    ...    @status_code: 400 Bad Request
    ...
    [Tags]    PUT    CLIENT    ERROR    API
    Dado Que Tenho Um Payload Sem Campos Obrigatorios Preenchidos Para Atualizacao De Cliente Com ID "1"
    Quando Envio Uma Requisicao PUT Para /clients
    Entao A API Deve Retornar Status Code 400
    E A Mensagem De Erro Deve Indicar Os Campos Obrigatorios Faltantes

#PUT-CLIENT-X - Atualizar cliente com campos opcionais nulos
#   [Documentation]    Validar o comportamento da API ao atualizar um cliente, enviando campos opcionais com valor null
#   ...
#   ...    @endpoint: PUT /clients
#   ...    @status_code: 204 No Content
#   ...
#    Dado Que Tenho Um Payload Com Campos Opcionais Nulos
#    Quando Envio Uma Requisicao PUT Para /clients
#    Entao A API Deve Retornar Status 204 No Content

#PUT-CLIENT-X - Validacao de tipos de dados no corpo da requisicao
#   [Documentation]    Garantir que a API retorna erro ao enviar dados com tipos inválidos no payload
#   ...
#   ...    @endpoint: PUT /clients
#   ...    @status_code: 400 Bad Request
#   ...
#   Dado Que Tenho Um Payload De Atualizacao De Cliente Com Tipos De Valores Invalidos
#   Quando Envio Uma Requisicao PUT Para /clients
#   Entao A API Deve Retornar Status 400 Bad Request
#   E A Mensagem De Erro Deve Indicar Os Campos Com Valores Invalidos

#PUT-CLIENT-X - Erro interno no servidor (500 Internal Server Error)
#   [Documentation]    Validar o comportamento da API ao receber uma requisição malformada ou erro inesperado
#   ...
#   ...    @endpoint: PUT /clients
#   ...    @status_code: 500 Internal Server Error
#   ...
#   ...    Dado que envio um payload inválido para a API
#   ...    Quando faço uma requisição PUT para atualizar um cliente
#   ...    Então a API deve retornar status 500 Internal Server Error

#PUT-CLIENT-X - E-mail ja em uso
#   [Documentation]    Validar o comportamento da API ao tentar atualizar um cliente com um e-mail já utilizado por outro cliente
#   ...
#   ...    @endpoint: PUT /clients
#   ...    @status_code: 400 Bad Request
#   ...
#   Dado Que Tenho Um Payload De Atualizacao De Cliente Com Email De Um Cliente Ja Cadastrado
#   Quando Envio Uma Requisicao PUT Para /clients
#   Entao A API Deve Retornar Status 400 Bad Request
#   E A Mensagem De Erro Deve Ser "Client e-mail is already in use"

#PUT-CLIENT-X - Validacao do tamanho do payload
#   [Documentation]    Validar o comportamento da API ao receber um payload com tamanho excessivo
#   ...
#   ...    @endpoint: PUT /clients
#   ...    @status_code: 413 Payload Too Large
#   ...
#    Dado Que Envio Um Payload De Atualizacao De Cliente Com Tamanho Excedido
#    Quando Envio Uma Requisicao PUT Para /clients
#    Entao A API Deve Retornar Status 413 Payload Too Large
#    E A Mensagem De Erro Deve Ser "Payload too large"

#PUT-CLIENT-X - Testes de concorrência para atualizações simultaneas
#   [Documentation]    Validar se a API mantém consistência ao processar múltiplas requisições PUT simultâneas para o mesmo cliente
#   ...
#   ...    @endpoint: PUT /clients
#   ...    @status_code: 204 No Content
#   ...
#    Dado Que Tenho Um Payload Valido Para Atualizacao De Cliente
#    Quando Envio Varias Requisicoes PUT Para /clients
#    Entao A API Deve Retornar Status 204 No Content Para Todas Requisicoes

#PUT-CLIENT-X - Atualizar cliente enviando relayAccess com valores invalidos (400 Bad Request)
#   [Documentation]    Validar erro ao atualizar um cliente com relayAccess inválido.
#   ...
#   ...    @endpoint: PUT /clients
#   ...    @status_code: 400 Bad Request
#   ...
#    Dado Que Tenho Um Payload Valido Para Atualizacao De Cliente Com relayAccess Igual A -1 Ou 3
#    Quando Envio Uma Requisicao PUT Para /clients
#    Entao A API Deve Retornar Status 400 Bad Request
#    E A Mensagem De Erro Deve Indicar Os Valores Permitidos (0, 1, 2)

#PUT-CLIENT-X - Atualizar cliente sem enviar clientGroups (204 No Content)
#   [Documentation]    Verificar se a atualização ocorre corretamente sem passar o array clientGroups.
#   ...
#   ...    @endpoint: PUT /clients
#   ...    @status_code: 204 No Content
#   ...
#    Dado Que Tenho Um Payload Valido Para Atualizacao De Cliente Sem o Campo clientGroups
#    Quando Envio Uma Requisicao PUT Para /clients
#    Entao A API Deve Retornar Status 204 No Content