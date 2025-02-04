*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    JSONLibrary
Resource    ../../../resource.resource

*** Variables ***


*** Keywords ***

Dado Que Tenho Um Payload Valido Para Atualizacao De Cliente Com ID "${id}"
    [Documentation]    Cria um payload válido para atualização de cliente
    ${email}    Gerar Email Aleatorio
    # Certifica-se de que o ID é tratado como inteiro
    ${id_int}    Evaluate    int(${id})
    ${payload}    Create Dictionary
    ...    id=${id_int}                  # Garantir que o ID é um número inteiro
    ...    email=${email}                # Email gerado aleatoriamente
    ...    enabled=${True}               # Booleano
    ...    applicationId=${1}            # Número inteiro
    ${client_group}    Create Dictionary
    ...    relayAccess=${0}              # Número inteiro
    ...    relayDuration=${1}            # Número inteiro
    ...    groupId=${1}                  # Número inteiro
    ${client_groups}    Create List    ${client_group}
    Set To Dictionary    ${payload}    clientGroups=${client_groups}
    # Log para depuração
    Log    \n=== PAYLOAD GERADO ===\n${payload}
    Log    PAYLOAD GERADO: ${payload}
    # Salva o payload para uso posterior
    Set Test Variable    ${CLIENT_PAYLOAD}    ${payload}

Gerar Email Aleatorio
    ${email}    Evaluate    "user" + str(random.randint(1000, 9999)) + "@test.com"    random
    [Return]    ${email}

Quando Envio Uma Requisicao PUT Para /clients
    [Documentation]    Envia a requisição PUT para atualizar um cliente
    # Verifica se existem headers customizados
    ${exists_custom_headers}=    Run Keyword And Return Status    Variable Should Exist    ${CUSTOM_HEADERS}
    ${headers}=    Set Variable If    ${exists_custom_headers}    ${CUSTOM_HEADERS}    ${HEADERS}
    # Envia a requisição PUT
    ${response}=    PUT On Session    client    /clients
    ...    json=${CLIENT_PAYLOAD}
    ...    headers=${headers}
    ...    expected_status=any
    # Armazena a resposta da API
    Set Test Variable    ${RESPONSE}    ${response}

Entao A API Deve Retornar Status Code ${expected_status}
    [Documentation]    Valida o status code da resposta
    Should Be Equal As Strings    ${RESPONSE.status_code}    ${expected_status}

E A Mensagem De Erro Deve Ser "${expected_message}"
    [Documentation]    Valida se a mensagem de erro é a esperada
    ${body}=    Set Variable    ${RESPONSE.json()}
    Dictionary Should Contain Key    ${body}    error
    Log    ${body}[error]
    Should Be Equal As Strings    ${body}[error]    ${expected_message}

E A applicationId "${app_id}" Informada No Payload Nao Existe No Sistema
    [Documentation]    Altera o applicationId no payload para um valor inexistente
    # Garante que o payload foi previamente gerado
    Variable Should Exist    ${CLIENT_PAYLOAD}
    # Converte app_id para inteiro (caso tenha sido passado como string)
    ${app_id_int}=    Evaluate    int(${app_id})
    # Atualiza o applicationId no payload garantindo que seja um inteiro
    Set To Dictionary    ${CLIENT_PAYLOAD}    applicationId=${app_id_int}
    # Log para depuração
    Log To Console    \n=== PAYLOAD ATUALIZADO ===\n${CLIENT_PAYLOAD}
    Log    PAYLOAD ATUALIZADO: ${CLIENT_PAYLOAD}

E O groupId "${group_id}" Informado No Payload Nao Existe No Sistema
    [Documentation]    Altera o groupId no payload para um valor inexistente dentro de clientGroups
    # Garante que o payload foi previamente gerado
    Variable Should Exist    ${CLIENT_PAYLOAD}
    # Converte group_id para inteiro (caso tenha sido passado como string)
    ${group_id_int}=    Evaluate    int(${group_id})
    # Atualiza o groupId no primeiro elemento do array clientGroups
    Set To Dictionary    ${CLIENT_PAYLOAD}[clientGroups][0]    groupId=${group_id_int}
    # Log para depuração
    Log To Console    \n=== PAYLOAD ATUALIZADO ===\n${CLIENT_PAYLOAD}
    Log    PAYLOAD ATUALIZADO: ${CLIENT_PAYLOAD}

Dado Que Tenho Um Payload Valido Com Autenticacao Invalida Para Atualizacao De Cliente Com ID "${id}"
    [Documentation]    Cria um payload válido mas com x-api-key inválida
    Dado Que Tenho Um Payload Valido Para Atualizacao De Cliente Com ID "${id}"
    # Define um header com x-api-key inválida
    ${invalid_headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Accept=application/json
    ...    x-api-key=invalid_api_key_123
    Set Test Variable    ${CUSTOM_HEADERS}    ${invalid_headers}

Dado Que Tenho Um Payload Sem Campos Obrigatorios Preenchidos Para Atualizacao De Cliente Com ID "${id}"
    [Documentation]    Cria um payload sem os campos obrigatórios:
    ...                - email
    ...                - enabled
    ...                - clientGroups: relayAccess, relayDuration, groupId
    # Certifica-se de que o ID é tratado como inteiro
    ${id_int}    Evaluate    int(${id})
    ${payload_invalido}    Create Dictionary
    ...    id=${id_int}                  # Garantir que o ID é um número inteiro
    ...    applicationId=${1}            # Número inteiro
    ${client_group}    Create Dictionary
    ${client_groups}    Create List    ${client_group}
    Set To Dictionary    ${payload_invalido}    clientGroups=${client_groups}
    # Log para depuração
    Log    \n=== PAYLOAD GERADO ===\n${payload_invalido}
    Log    PAYLOAD GERADO: ${payload_invalido}
    # Salva o payload para uso posterior
    Set Test Variable    ${CLIENT_PAYLOAD}    ${payload_invalido}

E A Mensagem De Erro Deve Indicar Os Campos Obrigatorios Faltantes
    [Documentation]    Valida se a mensagem de erro indica os campos obrigatórios faltantes
    ${body}=    Set Variable    ${RESPONSE.json()}
    Dictionary Should Contain Key    ${body}    message
    Dictionary Should Contain Key    ${body}    error
    Dictionary Should Contain Key    ${body}    statusCode
    # Valida o conteúdo das mensagens
    List Should Contain Value    ${body}[message]    email should not be empty
    List Should Contain Value    ${body}[message]    enabled should not be empty
    List Should Contain Value    ${body}[message]    clientGroups.0.groupId should not be empty
    List Should Contain Value    ${body}[message]    clientGroups.0.relayAccess should not be empty
    List Should Contain Value    ${body}[message]    clientGroups.0.relayDuration should not be empty
    # Valida o erro e status code
    Should Be Equal As Strings    ${body}[error]    Bad Request
    Should Be Equal As Numbers    ${body}[statusCode]    400