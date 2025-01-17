*** Settings ***
Resource  ../../../resources/resource.resource
Suite Setup    Suite Setup
Suite Teardown    Suite Teardown

*** Variables ***


*** Test Cases ***

# # 1 - Requisição bem-sucedida (200 OK)
# Get Successful Response
#     [Documentation]    Testa uma requisição bem-sucedida no endpoint GET.


# # 2 - Não autorizado (401 Unauthorized)
# Get Unauthorized Response
#     [Documentation]    Testa o comportamento ao não fornecer token de autenticação.

# # 3 - Acesso proibido (403 Forbidden)
# Get Forbidden Response
#     [Documentation]    Testa o comportamento com credenciais válidas, mas sem permissões.

# # 4 - Recurso não encontrado (404 Not Found)
# Get Resource Not Found
#     [Documentation]    Testa uma requisição para um recurso inexistente.

# # 5 - Erro interno no servidor (500 Internal Server Error)
# Get Internal Server Error
#     [Documentation]    Simula condições para causar erro interno no servidor.

# # 6 - Validação do corpo da requisição
# Validate Response Body Schema
#     [Documentation]    Valida que o corpo da resposta segue o schema esperado.

# # 7 - Mensagens de erro
# Validate Error Messages
#     [Documentation]    Verifica se as mensagens de erro são claras e consistentes.

# # 8 - Headers da requisição
# Validate Request Headers
#     [Documentation]    Valida o envio e manipulação dos headers obrigatórios.

# # 9 - Validação do tempo de resposta
# Validate Response Time
#     [Documentation]    Verifica se o tempo de resposta está dentro do SLA.

#------------------------------------

# # 11 - Paginação
# Validate Pagination
#     [Documentation]    Verifica o suporte à paginação no endpoint GET.

# # 12 - Filtros e parâmetros
# Validate Filters
#     [Documentation]    Testa combinações de filtros no endpoint GET.

# # 13 - Validar cache
# Validate Cache Headers
#     [Documentation]    Verifica cabeçalhos relacionados a cache na resposta.

# # 14 - Diferentes tamanhos de resposta
# Validate Response Size
#     [Documentation]    Testa pequenos, médios e grandes conjuntos de dados.

# # 15 - Cenários de concorrência
# Validate Concurrent Requests
#     [Documentation]    Envia múltiplas requisições simultaneamente e verifica a consistência.

# # 16 - Locais e idiomas
# Validate Localization
#     [Documentation]    Testa respostas para diferentes idiomas.


# # 17 - Segurança
# Validate Sensitive Information
#     [Documentation]    Verifica se informações sensíveis não são expostas.

# # 18 - Valores nulos ou padrão
# Validate Default Values
#     [Documentation]    Testa comportamento com valores omitidos.

# # 19 - Desconexão de rede
# Validate Network Failure
#     [Documentation]    Simula falha de conexão e valida o comportamento.

# # 20 - Tipos de dados na resposta
# Validate Response Data Types
#     [Documentation]    Garante que os campos retornados têm os tipos corretos.



