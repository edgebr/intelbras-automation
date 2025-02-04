*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    JSONLibrary
Resource    ../../../resource.resource

*** Variables ***


*** Keywords ***
Create Device
    [Documentation]    Cria um novo dispositivo
    [Arguments]    ${device_data}
    ${headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Accept=application/json
    ...    x-api-key=${HEADERS}[x-api-key]
    
    ${response}=    POST On Session    device    /devices
    ...    json=${device_data}
    ...    headers=${headers}
    ...    expected_status=any
    RETURN    ${response}

Validate Device Creation Response
    [Documentation]    Valida a resposta de criação de dispositivo
    [Arguments]    ${response}
    Should Be Equal As Strings    ${response.status_code}    201

Generate Random Serial Id
    [Documentation]    Gera um serialId aleatório no formato 3NXJAKSIEZE234UP
    ${letters}=    Evaluate    'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    ${numbers}=    Evaluate    '0123456789'
    
    ${part1}=    Evaluate    ''.join([random.choice('${letters}') for _ in range(3)])    modules=random
    ${part2}=    Evaluate    ''.join([random.choice('${letters}') for _ in range(2)])    modules=random
    ${part3}=    Evaluate    ''.join([random.choice('${letters}') for _ in range(3)])    modules=random
    ${part4}=    Evaluate    ''.join([random.choice('${numbers}') for _ in range(3)])    modules=random
    
    ${serialId}=    Set Variable    ${part1}${part2}${part3}${part4}
    RETURN    ${serialId}

Dado Que Tenho Um Payload Valido Para Criacao De Dispositivo
    [Documentation]    Cria um payload válido para criação de dispositivo
    ${serialId}=    Generate Random Serial Id
    ${device_data}=    Create Dictionary
    ...    devices=@{EMPTY}
    ...    productCode=0000000
    
    ${device}=    Create Dictionary
    ...    serialId=${serialId}
    
    Append To List    ${device_data}[devices]    ${device}
    Set Test Variable    ${DEVICE_PAYLOAD}    ${device_data}

Quando Envio Uma Requisicao POST Para /devices
    [Documentation]    Envia a requisição POST para criar o dispositivo
    # Verifica se existem headers customizados
    ${exists_custom_headers}=    Run Keyword And Return Status    Variable Should Exist    ${CUSTOM_HEADERS}
    ${headers}=    Set Variable If    ${exists_custom_headers}    ${CUSTOM_HEADERS}    ${HEADERS}
    
    ${response}=    POST On Session    device    /devices
    ...    json=${DEVICE_PAYLOAD}
    ...    headers=${headers}
    ...    expected_status=any
    
    Set Test Variable    ${RESPONSE}    ${response}

Entao A API Deve Retornar Status 201 Created
    [Documentation]    Valida o status code da resposta
    Should Be Equal As Strings    ${RESPONSE.status_code}    201

E A Mensagem "${expected_message}"
    [Documentation]    Valida a mensagem retornada pela API
    Should Be Equal As Strings    ${RESPONSE.text}    ${expected_message}

E O Schema Deve Ser "${schema_file}"
    [Documentation]    Valida se a resposta segue o schema especificado
    ${schema}=    Get File    ${EXECDIR}/resources/json/POST_DEVICES/${schema_file}
    ${schema_json}=    Evaluate    json.loads('''${schema}''')    json
    ${response_json}=    Set Variable    ${RESPONSE.json()}
    ${is_valid}=    Evaluate    jsonschema.validate(${response_json}, ${schema_json})    modules=jsonschema

Dado Que Envio Um Payload Invalido
    [Documentation]    Cria um payload inválido faltando campo obrigatório serialId
    ${invalid_payload}=    Create Dictionary
    ...    devices=@{EMPTY}
    ...    productCode=0000000
    
    ${device}=    Create Dictionary
    # Não incluímos o serialId para tornar o payload inválido
    
    Append To List    ${invalid_payload}[devices]    ${device}
    Set Test Variable    ${DEVICE_PAYLOAD}    ${invalid_payload}

Dado Que Envio Um Payload Sem Campos Obrigatorios
    [Documentation]    Cria um payload sem campos obrigatórios
    ${invalid_payload}=    Create Dictionary
    ...    devices=@{EMPTY}
    # Omitindo productCode
    
    ${device}=    Create Dictionary
    # Omitindo serialId
    
    Append To List    ${invalid_payload}[devices]    ${device}
    Set Test Variable    ${DEVICE_PAYLOAD}    ${invalid_payload}

E A Mensagem De Erro Deve Indicar Os Campos Obrigatorios Faltantes
    [Documentation]    Valida se a mensagem de erro indica os campos obrigatórios faltantes
    ${body}=    Set Variable    ${RESPONSE.json()}
    Dictionary Should Contain Key    ${body}    message
    Dictionary Should Contain Key    ${body}    error
    Dictionary Should Contain Key    ${body}    statusCode
    
    # Valida o conteúdo das mensagens
    List Should Contain Value    ${body}[message]    devices.0.serialId should not be empty
    List Should Contain Value    ${body}[message]    productCode should not be empty
    List Should Contain Value    ${body}[message]    productCode must be longer than or equal to 7 characters
    
    # Valida o erro e status code
    Should Be Equal As Strings    ${body}[error]    Bad Request
    Should Be Equal As Numbers    ${body}[statusCode]    400

Dado Que Cadastro Um Dispositivo Com SerialId Unico
    [Documentation]    Cadastra um dispositivo com serialId único e salva o serialId
    ${serialId}=    Generate Random Serial Id
    ${device_data}=    Create Dictionary
    ...    devices=@{EMPTY}
    ...    productCode=0000000
    
    ${device}=    Create Dictionary
    ...    serialId=${serialId}
    
    Append To List    ${device_data}[devices]    ${device}
    Set Test Variable    ${DEVICE_PAYLOAD}    ${device_data}
    ${response}=    Create Device    ${device_data}
    Should Be Equal As Strings    ${response.status_code}    201
    Set Suite Variable    ${SERIAL_ID_CADASTRADO}    ${serialId}

Dado Que Tento Cadastrar Um Dispositivo Com SerialId Duplicado
    [Documentation]    Prepara um payload com serialId duplicado
    # Primeiro cadastra um dispositivo
    ${serialId}=    Generate Random Serial Id
    ${device_data}=    Create Dictionary
    ...    devices=@{EMPTY}
    ...    productCode=0000000
    
    ${device}=    Create Dictionary
    ...    serialId=${serialId}
    
    Append To List    ${device_data}[devices]    ${device}
    ${response}=    Create Device    ${device_data}
    Should Be Equal As Strings    ${response.status_code}    201
    
    # Prepara o payload com o mesmo serialId
    ${device_data}=    Create Dictionary
    ...    devices=@{EMPTY}
    ...    productCode=0000000
    
    ${device}=    Create Dictionary
    ...    serialId=${serialId}
    
    Append To List    ${device_data}[devices]    ${device}
    Set Test Variable    ${DEVICE_PAYLOAD}    ${device_data}

Entao A API Deve Retornar Status 400 Bad Request
    [Documentation]    Valida o status code da resposta
    Should Be Equal As Strings    ${RESPONSE.status_code}    400

E A Mensagem De Erro Deve Ser "${expected_message}"
    [Documentation]    Valida se a mensagem de erro é a esperada
    ${body}=    Set Variable    ${RESPONSE.json()}
    Dictionary Should Contain Key    ${body}    error
    Should Be Equal As Strings    ${body}[error]    ${expected_message}

Dado Que Envio Um Payload Com Multiplos Dispositivos Unicos
    [Documentation]    Cria um payload com múltiplos dispositivos com serialIds únicos
    ${device_data}=    Create Dictionary
    ...    devices=@{EMPTY}
    ...    productCode=0000000
    
    @{serial_ids}=    Create List
    FOR    ${i}    IN RANGE    3
        ${serialId}=    Generate Random Serial Id
        ${device}=    Create Dictionary
        ...    serialId=${serialId}
        Append To List    ${device_data}[devices]    ${device}
        Append To List    ${serial_ids}    ${serialId}
    END
    
    Set Test Variable    ${DEVICE_PAYLOAD}    ${device_data}
    Set Test Variable    ${SERIAL_IDS_CADASTRADOS}    ${serial_ids}

E Todos Os Dispositivos Devem Ser Cadastrados
    [Documentation]    Valida se todos os dispositivos foram cadastrados com sucesso
    # Primeiro valida a mensagem de sucesso
    Should Be Equal As Strings    ${RESPONSE.text}    The device has been created successfully
    
    # Depois verifica se cada dispositivo foi cadastrado
    FOR    ${serial_id}    IN    @{SERIAL_IDS_CADASTRADOS}
        ${response}=    GET On Session    device    /devices/${serial_id}
        Should Be Equal As Strings    ${response.status_code}    200
        Dictionary Should Contain Key    ${response.json()}    serialId
        Should Be Equal As Strings    ${response.json()}[serialId]    ${serial_id}
    END

Dado Que Envio Um Payload Com Multiplos Dispositivos E Alguns SerialIds Duplicados
    [Documentation]    Cria um payload com múltiplos dispositivos, alguns com serialIds duplicados
    # Primeiro cadastra um dispositivo para ter um serialId existente
    ${serialId_existente}=    Generate Random Serial Id
    ${device_data}=    Create Dictionary
    ...    devices=@{EMPTY}
    ...    productCode=0000000
    
    # Cria o primeiro dispositivo e cadastra
    ${device}=    Create Dictionary
    ...    serialId=${serialId_existente}
    Append To List    ${device_data}[devices]    ${device}
    ${response}=    Create Device    ${device_data}
    Should Be Equal As Strings    ${response.status_code}    201
    
    # Cria novo payload com dispositivos únicos e duplicados
    ${new_device_data}=    Create Dictionary
    ...    devices=@{EMPTY}
    ...    productCode=0000000
    
    # Lista para armazenar os serialIds únicos para validação posterior
    @{serial_ids_unicos}=    Create List
    
    # Adiciona 3 dispositivos: 1 duplicado e 2 únicos
    ${device1}=    Create Dictionary
    ...    serialId=${serialId_existente}  # Duplicado
    Append To List    ${new_device_data}[devices]    ${device1}
    
    # Adiciona 2 dispositivos únicos
    FOR    ${i}    IN RANGE    2
        ${novo_serialId}=    Generate Random Serial Id
        ${device}=    Create Dictionary
        ...    serialId=${novo_serialId}
        Append To List    ${new_device_data}[devices]    ${device}
        Append To List    ${serial_ids_unicos}    ${novo_serialId}
    END
    
    Set Test Variable    ${DEVICE_PAYLOAD}    ${new_device_data}
    Set Test Variable    ${SERIAL_IDS_UNICOS}    ${serial_ids_unicos}
    Set Test Variable    ${SERIAL_ID_DUPLICADO}    ${serialId_existente}

E Apenas Os Dispositivos Com SerialIds Unicos Devem Ser Cadastrados
    [Documentation]    Valida se apenas os dispositivos com serialIds únicos foram cadastrados
    # Valida o status code
    Should Be Equal As Strings    ${RESPONSE.status_code}    201
    
    # Verifica se os dispositivos únicos foram cadastrados
    FOR    ${serial_id}    IN    @{SERIAL_IDS_UNICOS}
        ${response}=    GET On Session    device    /devices/${serial_id}
        Should Be Equal As Strings    ${response.status_code}    200
        Dictionary Should Contain Key    ${response.json()}    serialId
        Should Be Equal As Strings    ${response.json()}[serialId]    ${serial_id}
    END
    
    # Verifica se o dispositivo duplicado não foi cadastrado novamente
    ${response}=    GET On Session    device    /devices/${SERIAL_ID_DUPLICADO}
    Should Be Equal As Strings    ${response.status_code}    200
    Dictionary Should Contain Key    ${response.json()}    serialId
    Should Be Equal As Strings    ${response.json()}[serialId]    ${SERIAL_ID_DUPLICADO}

Dado Que Envio Um Payload Com Multiplos Dispositivos E Todos SerialIds Duplicados
    [Documentation]    Cria um payload com múltiplos dispositivos, todos com serialIds já existentes
    # Primeiro cadastra alguns dispositivos para ter serialIds existentes
    @{serial_ids_existentes}=    Create List
    FOR    ${i}    IN RANGE    3
        ${serialId}=    Generate Random Serial Id
        ${device_data}=    Create Dictionary
        ...    devices=@{EMPTY}
        ...    productCode=0000000
        
        ${device}=    Create Dictionary
        ...    serialId=${serialId}
        
        Append To List    ${device_data}[devices]    ${device}
        ${response}=    Create Device    ${device_data}
        Should Be Equal As Strings    ${response.status_code}    201
        Append To List    ${serial_ids_existentes}    ${serialId}
    END
    
    # Cria novo payload tentando cadastrar os mesmos serialIds
    ${new_device_data}=    Create Dictionary
    ...    devices=@{EMPTY}
    ...    productCode=0000000
    
    # Adiciona os dispositivos com serialIds duplicados
    FOR    ${serialId}    IN    @{serial_ids_existentes}
        ${device}=    Create Dictionary
        ...    serialId=${serialId}
        Append To List    ${new_device_data}[devices]    ${device}
    END
    
    Set Test Variable    ${DEVICE_PAYLOAD}    ${new_device_data}

Dado Que Envio Um Payload Com Multiplos Dispositivos E Alguns Invalidos
    [Documentation]    Cria um payload com múltiplos dispositivos, alguns com serialIds inválidos
    ${device_data}=    Create Dictionary
    ...    devices=@{EMPTY}
    ...    productCode=0000000
    
    # Adiciona um dispositivo com serialId válido
    ${device1}=    Create Dictionary
    ...    serialId=${EMPTY}  # serialId vazio (inválido)
    Append To List    ${device_data}[devices]    ${device1}
    
    # Adiciona um dispositivo com serialId válido
    ${serialId}=    Generate Random Serial Id
    ${device2}=    Create Dictionary
    ...    serialId=${serialId}
    Append To List    ${device_data}[devices]    ${device2}
    
    # Adiciona outro dispositivo com serialId inválido
    ${device3}=    Create Dictionary
    ...    serialId=123  # serialId muito curto (inválido)
    Append To List    ${device_data}[devices]    ${device3}
    
    Set Test Variable    ${DEVICE_PAYLOAD}    ${device_data}

E A Mensagem De Erro Deve Indicar Quais Dispositivos Tem Problemas
    [Documentation]    Valida se a mensagem de erro indica quais dispositivos têm problemas
    ${body}=    Set Variable    ${RESPONSE.json()}
    Dictionary Should Contain Key    ${body}    message
    Dictionary Should Contain Key    ${body}    error
    Dictionary Should Contain Key    ${body}    statusCode
    
    # Valida o conteúdo das mensagens
    List Should Contain Value    ${body}[message]    devices.0.serialId should not be empty
    List Should Contain Value    ${body}[message]    devices.2.serialId has invalid format
    
    # Valida o erro e status code
    Should Be Equal As Strings    ${body}[error]    Bad Request
    Should Be Equal As Numbers    ${body}[statusCode]    400

Dado Que Envio Um Payload Valido Com Autenticacao Invalida
    [Documentation]    Cria um payload válido mas com x-api-key inválida
    # Cria o payload válido
    ${serialId}=    Generate Random Serial Id
    ${device_data}=    Create Dictionary
    ...    devices=@{EMPTY}
    ...    productCode=0000000
    
    ${device}=    Create Dictionary
    ...    serialId=${serialId}
    
    Append To List    ${device_data}[devices]    ${device}
    Set Test Variable    ${DEVICE_PAYLOAD}    ${device_data}
    
    # Define um header com x-api-key inválida
    ${invalid_headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Accept=application/json
    ...    x-api-key=invalid_api_key_123
    
    Set Test Variable    ${CUSTOM_HEADERS}    ${invalid_headers}

Entao A API Deve Retornar Status 401 Unauthorized
    [Documentation]    Valida se o status code é 401 Unauthorized
    Should Be Equal As Strings    ${RESPONSE.status_code}    401

Dado Que Envio Um Payload Com Tamanho Excedido
    [Documentation]    Cria um payload que excede o limite de tamanho permitido
    ${device_data}=    Create Dictionary
    ...    devices=@{EMPTY}
    ...    productCode=0000000
    
    # Cria uma lista grande de dispositivos para exceder o limite
    FOR    ${i}    IN RANGE    1000
        ${serialId}=    Generate Random Serial Id
        ${device}=    Create Dictionary
        ...    serialId=${serialId}
        Append To List    ${device_data}[devices]    ${device}
    END
    
    Set Test Variable    ${DEVICE_PAYLOAD}    ${device_data}

Entao A API Deve Retornar Status 413 Payload Too Large
    [Documentation]    Valida se o status code é 413 Payload Too Large
    Should Be Equal As Strings    ${RESPONSE.status_code}    413

Dado Que Envio Um Payload Valido
    [Documentation]    Cria um payload válido para o teste
    ${serialId}=    Generate Random Serial Id
    ${device_data}=    Create Dictionary
    ...    devices=@{EMPTY}
    ...    productCode=0000000
    
    ${device}=    Create Dictionary
    ...    serialId=${serialId}
    
    Append To List    ${device_data}[devices]    ${device}
    Set Test Variable    ${DEVICE_PAYLOAD}    ${device_data}

Quando Envio Uma Requisicao POST Para /devices Com Timeout
    [Documentation]    Envia a requisição POST com um timeout muito baixo
    ${headers}=    Set Variable    ${HEADERS}
    
    # Define um timeout muito baixo (0.001 segundo) para forçar o timeout
    ${response}=    POST On Session    device    /devices
    ...    json=${DEVICE_PAYLOAD}
    ...    headers=${headers}
    ...    timeout=0.001
    ...    expected_status=any
    
    Set Test Variable    ${RESPONSE}    ${response}

Entao A API Deve Retornar Status 504 Gateway Timeout
    [Documentation]    Valida se o status code é 504 Gateway Timeout
    Should Be Equal As Strings    ${RESPONSE.status_code}    504

Dado Que Envio Um Payload Valido Sem Headers Obrigatorios
    [Documentation]    Cria um payload válido mas sem headers obrigatórios
    ${serialId}=    Generate Random Serial Id
    ${device_data}=    Create Dictionary
    ...    devices=@{EMPTY}
    ...    productCode=0000000
    
    ${device}=    Create Dictionary
    ...    serialId=${serialId}
    
    Append To List    ${device_data}[devices]    ${device}
    Set Test Variable    ${DEVICE_PAYLOAD}    ${device_data}
    Set Test Variable    ${CUSTOM_HEADERS}    ${EMPTY}

E A Mensagem De Erro Deve Ser Missing required headers
    [Documentation]    Valida se a mensagem de erro indica headers faltantes
    ${body}=    Set Variable    ${RESPONSE.json()}
    Dictionary Should Contain Key    ${body}    error
    Should Be Equal As Strings    ${body}[error]    Missing required headers