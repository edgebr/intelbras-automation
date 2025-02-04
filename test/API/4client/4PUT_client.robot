*** Settings ***
Resource  ../../../resources/resource.resource
Suite Setup    Suite Setup

*** Variables ***


*** Test Cases ***

#PUT-CLIENT-X - Atualizacao bem-sucedida
#   [Documentation]    Validar a atualização bem-sucedida de um cliente existente
#   ...
#   ...    @endpoint: PUT /clients
#   ...    @status_code: 204 No Content
#   ...
#    Dado Que Tenho Um Payload Valido Para Atualizacao De Cliente
#    Quando Envio Uma Requisicao PUT Para /clients
#    Entao A API Deve Retornar Status 204 No Content
    
#
#PUT-CLIENT-X - Atualizacao de cliente inexistente
#   [Documentation]    Validar tentativa de atualização de um cliente inexistente
#   ...
#   ...    @endpoint: PUT /clients
#   ...    @status_code: 404 Not Found
#   ...
#    Dado Que Tenho Um Payload Valido Para Atualizacao De Cliente
#    E O ID Do Cliente Informado No Payload Nao Existe No Sistema
#    Quando Envio Uma Requisicao PUT Para /clients
#    Entao A API Deve Retornar Status 404 Not Found
#    E A Resposta Deve Conter Uma Mensagem Indicando Que O Cliente Nao Foi Encontrado

#PUT-CLIENT-X - Atualizar cliente com applicationId inexistente
#   [Documentation]    Validar o comportamento da API ao tentar atualizar um cliente com um applicationId que não existe
#   ...
#   ...    @endpoint: PUT /clients
#   ...    @status_code: 404 Not Found
#   ...
#    Dado Que Tenho Um Payload Valido Para Atualizacao De Cliente
#    E a applicationId Informada No Payload Nao Existe No Sistema
#    Quando Envio Uma Requisicao PUT Para /clients
#    Entao A API Deve Retornar Status 404 Not Found
#    E A Resposta Deve Conter Uma Mensagem Indicando Que A applicationId Nao Foi Encontrada

#PUT-CLIENT-X - Atualizar cliente com groupId inexistente
#   [Documentation]    Validar o comportamento da API ao tentar atualizar um cliente associando-o a um groupId inexistente
#   ...
#   ...    @endpoint: PUT /clients
#   ...    @status_code: 404 Not Found
#   ...
#    Dado Que Tenho Um Payload Valido Para Atualizacao De Cliente
#    E o groupId Informado No Payload Nao Existe No Sistema
#    Quando Envio Uma Requisicao PUT Para /clients
#    Entao A API Deve Retornar Status 404 Not Found
#    E A Resposta Deve Conter Uma Mensagem Indicando Que O groupId Nao Foi Encontrado


#PUT-CLIENT-X - Requisicao sem autenticacao
#   [Documentation]    Validar que a API não permite atualização sem autenticação
#   ...
#   ...    @endpoint: PUT /clients
#   ...    @status_code: 401 Unauthorized
#   ...
#    Dado Que Tenho Um Payload Valido Com Autenticacao Invalida
#    Quando Envio Uma Requisicao PUT Para /clients
#    Entao A API Deve Retornar Status 401 Unauthorized
#    E A Mensagem De Erro Deve Ser "Invalid token"

#PUT-CLIENT-X - Validacao de campos obrigatorios
#   [Documentation]    Validar que a API retorna erro quando campos obrigatórios estão ausentes
#   ...
#   ...    @endpoint: PUT /clients
#   ...    @status_code: 400 Bad Request
#   ...
#    Dado Que Tenho Um Payload Sem Campos Obrigatorios
#    Quando Envio Uma Requisicao PUT Para /clients
#    Entao A API Deve Retornar Status 400 Bad Request
#    E A Mensagem De Erro Deve Indicar Os Campos Obrigatorios Faltantes

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