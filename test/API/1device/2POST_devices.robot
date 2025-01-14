*** Settings ***
Resource  ../../../resources/resource.resource
Suite Setup    Suite Setup

*** Variables ***


*** Test Cases ***

# # 1 - Criação bem-sucedida (201 Created)
# Post Successful Creation
#     [Documentation]    Testa a criação bem-sucedida de um recurso usando o método POST.


# # 2 - Requisição inválida (400 Bad Request)
# Post Invalid Request
#     [Documentation]    Testa o comportamento ao enviar uma requisição inválida (payload malformado).


# # 3 - Não autorizado (401 Unauthorized)
# Post Unauthorized Request
#     [Documentation]    Testa o comportamento sem fornecer credenciais.


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
