*** Settings ***
Resource  ../../../resources/resource.resource
Suite Setup    Suite Setup

*** Variables ***


*** Test Cases ***

# # 1 - Atualização bem-sucedida (200 OK)
# Put Successful Update
#     [Documentation]    Testa a atualização bem-sucedida de um recurso usando o método PUT.


# # 2 - Atualização sem resposta de conteúdo (204 No Content)
# Put No Content Update
#     [Documentation]    Testa a atualização de um recurso que não retorna conteúdo.


# # 3 - Recurso não encontrado (404 Not Found)
# Put Resource Not Found
#     [Documentation]    Testa a tentativa de atualização de um recurso inexistente.


# # 4 - Não autorizado (401 Unauthorized)
# Put Unauthorized Request
#     [Documentation]    Testa a tentativa de atualização sem autenticação.


# # 5 - Acesso proibido (403 Forbidden)
# Put Forbidden Request
#     [Documentation]    Testa a tentativa de atualização com autenticação inválida.


# # 6 - Erro interno no servidor (500 Internal Server Error)
# Put Internal Server Error


# # 7 - Validação de campos obrigatórios
# Put Mandatory Fields Validation


# # 8 - Validação de tipos de dados no corpo da requisição
# Put Data Type Validation
#     [Documentation]    Testa a validação de tipos de dados no payload.


# # 9 - Validação de tamanho de payload
# Put Payload Size Validation
#     [Documentation]    Testa o envio de payloads muito grandes.


# # 10 - Idempotência do método PUT
# Put Idempotency Validation
#     [Documentation]    Verifica a idempotência do método PUT.


# # 11 - Validação de mensagens de erro claras
# Put Error Message Validation
#     [Documentation]    Testa se mensagens de erro são claras e consistentes.


# # 12 - Headers obrigatórios na requisição
# Put Required Headers
#     [Documentation]    Testa o comportamento ao omitir headers obrigatórios.


# # 13 - Atualização com parâmetros inválidos
# Put Invalid Parameters
#     [Documentation]    Testa o envio de parâmetros inválidos na requisição PUT.


# # 14 - Atualização parcial de recurso (se suportado)
# Put Partial Update
#     [Documentation]    Testa a atualização parcial de um recurso, caso o endpoint suporte.


# # 15 - Simulação de exclusão seguida de atualização
# Put After Deletion
#     [Documentation]    Testa a tentativa de atualizar um recurso após ele ser excluído.


# # 16 - Atualização com autenticação inválida
# Put Invalid Authentication
#     [Documentation]    Testa o envio de uma requisição PUT com token de autenticação inválido.


# # 17 - Validação de segurança contra alterações não autorizadas
# Put Unauthorized Security
#     [Documentation]    Verifica se um recurso protegido não pode ser atualizado por usuários sem permissão.


# # 18 - Testes de concorrência para atualizações simultâneas
# Put Concurrent Updates
#     [Documentation]    Envia múltiplas requisições PUT simultaneamente para o mesmo recurso.


# # 19 - Validação de valores padrão para campos omitidos
# Put Default Values
#     [Documentation]    Testa a atualização de um recurso omitindo campos opcionais para verificar se valores padrão são aplicados.


# # 20 - Teste com headers adicionais
# Put Extra Headers
#     [Documentation]    Testa o comportamento ao incluir headers adicionais na requisição PUT.
