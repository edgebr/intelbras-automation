*** Settings ***
# DEVICE
# Resource     page/api/1device/1GET_devices.resource
# Resource     page/api/1device/2POST_devices.resource
# Resource     page/api/1device/3DELETE_devices.resource
# Resource     page/api/1device/4PUT_devices.resource
# USER
Resource     page/api/2user/1GET_user.resource
# Resource     page/api/2user/2POST_user.resource
# Resource     page/api/2user/3DELETE_user.resource
# Resource     page/api/2user/4PUT_user.resource
# # AUTH
# Resource     page/api/3auth/1GET_auth.resource
# Resource     page/api/3auth/2POST_auth.resource
# Resource     page/api/3auth/3DELETE_auth.resource
# Resource     page/api/3auth/4PUT_auth.resource
# # CLIENT
# Resource     page/api/4client/1GET_client.resource
# Resource     page/api/4client/2POST_client.resource
# Resource     page/api/4client/3DELETE_client.resource
# Resource     page/api/4client/4PUT_client.resource
# # TELEMETRY CONFIG
# Resource     page/api/5telemetryConfig/1GET_telemetryConfig.resource
# Resource     page/api/5telemetryConfig/2POST_telemetryConfig.resource
# Resource     page/api/5telemetryConfig/3DELETE_telemetryConfig.resource
# Resource     page/api/5telemetryConfig/4PUT_telemetryConfig.resource
# # RELAY
# Resource     page/api/6relay/1GET_relay.resource
# Resource     page/api/6relay/2POST_relay.resource
# Resource     page/api/6relay/3DELETE_relay.resource
# Resource     page/api/6relay/4PUT_relay.resource
# # GROUP
# Resource     page/api/7group/1GET_group.resource
# Resource     page/api/7group/2POST_group.resource
# Resource     page/api/7group/3DELETE_group.resource
# Resource     page/api/7group/4PUT_group.resource
# # SIGNALING
# Resource     page/api/8signaling/1GET_signaling.resource
# Resource     page/api/8signaling/2POST_signaling.resource
# Resource     page/api/8signaling/3DELETE_signaling.resource
# Resource     page/api/8signaling/4PUT_signaling.resource
# # APPLICATION
# Resource     page/api/9application/1GET_application.resource
# Resource     page/api/9application/2POST_application.resource
# Resource     page/api/9application/3DELETE_application.resource
# Resource     page/api/9application/4PUT_application.resource

# LIBRARY
Library           RequestsLibrary
Library           OperatingSystem
Library           Collections
Library           DateTime
Library           JSONLibrary
Library           String
Library           json
Library           BuiltIn
Library           Process           # Para manipulação de processos

*** Variables ***
${BASE_URL}       http://18.228.160.85:5000
&{HEADERS}        x-api-key=c91f3812554f58600bdecffa4233f8ef397a6c3e42d00489e1b4ed168fb0cbfc
${INVALID_PERMISSION_TOKEN}    x-api-key=c91f3812554f58600bdecffa4233f8ef397a6c3e42d00489e1b4ed168fb0cbfc2   

*** Keywords ***
Suite Setup
    Create Session    device    ${BASE_URL}    headers=${HEADERS}
    Create Session    user    ${BASE_URL}    headers=${HEADERS}

Suite Teardown
    Delete All Sessions

### KEYWORDS DE VALIDAÇÃO JSON ###
Validate Json Against Schema
    [Documentation]    Valida um JSON contra um schema
    [Arguments]    ${json_data}    ${schema_path}
    ${schema}=    Get File    ${schema_path}
    ${schema_json}=    Convert String To Json    ${schema}
    
    # Verifica se o schema é para array
    ${schema_type}=    Get From Dictionary    ${schema_json}    type
    ${is_array_schema}=    Run Keyword And Return Status
    ...    Should Be Equal    ${schema_type}    array
    
    IF    ${is_array_schema}
        # Valida que o JSON é uma lista
        ${is_list}=    Run Keyword And Return Status    
        ...    Evaluate    isinstance($json_data, list)
        Should Be True    ${is_list}    
        ...    O JSON deve ser uma lista, mas recebeu: ${json_data}
        
        # Valida cada item da lista
        ${items_schema}=    Get From Dictionary    ${schema_json}    items
        FOR    ${item}    IN    @{json_data}
            Validate Json Object    ${item}    ${items_schema}
        END
    ELSE
        Validate Json Object    ${json_data}    ${schema_json}
    END
    
    Log    JSON validado com sucesso contra o schema ${schema_path}    DEBUG

Validate Json Object
    [Arguments]    ${json_object}    ${schema}
    [Documentation]    Valida um objeto JSON contra um schema
    
    # Valida que é um objeto
    ${is_dict}=    Run Keyword And Return Status
    ...    Evaluate    isinstance($json_object, dict)
    Should Be True    ${is_dict}    
    ...    O valor deve ser um objeto, mas recebeu: ${json_object}
    
    # Valida campos obrigatórios
    ${has_required}=    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    ${schema}    required
    
    IF    ${has_required}
        ${required}=    Get From Dictionary    ${schema}    required
        FOR    ${field}    IN    @{required}
            Dictionary Should Contain Key    ${json_object}    ${field}
            ...    msg=Campo obrigatório '${field}' não encontrado
        END
    END
    
    # Valida tipos das propriedades
    ${properties}=    Get From Dictionary    ${schema}    properties
    
    FOR    ${property}    ${definition}    IN    &{properties}
        ${has_value}=    Run Keyword And Return Status
        ...    Dictionary Should Contain Key    ${json_object}    ${property}
        
        IF    ${has_value}
            ${value}=    Get From Dictionary    ${json_object}    ${property}
            ${type}=    Get From Dictionary    ${definition}    type
            
            # Verifica se type é uma lista ou string única
            ${is_type_list}=    Run Keyword And Return Status
            ...    Evaluate    isinstance($type, list)
            
            ${valid_type}=    Set Variable    ${FALSE}
            
            IF    ${is_type_list}
                FOR    ${allowed_type}    IN    @{type}
                    ${type_valid}=    Validate Single Type    ${value}    ${allowed_type}
                    IF    ${type_valid}
                        ${valid_type}=    Set Variable    ${TRUE}
                        BREAK
                    END
                END
            ELSE
                ${valid_type}=    Validate Single Type    ${value}    ${type}
            END
            
            Should Be True    ${valid_type}
            ...    Campo '${property}' com valor '${value}' não corresponde ao(s) tipo(s) permitido(s): ${type}
        END
    END

Validate Multiple Types
    [Arguments]    ${value}    ${allowed_types}
    [Documentation]    Valida se um valor corresponde a um dos tipos permitidos
    FOR    ${type}    IN    @{allowed_types}
        ${is_valid}=    Validate Single Type    ${value}    ${type}
        IF    ${is_valid}    RETURN    ${TRUE}
    END
    RETURN    ${FALSE}

### KEYWORDS DE VALIDAÇÃO DE TIPOS ###
Should Be Integer
    [Arguments]    ${value}
    ${is_integer}=    Run Keyword And Return Status
    ...    Evaluate    isinstance(${value}, int)
    Should Be True    ${is_integer}    Value '${value}' is not an integer

Should Be String
    [Arguments]    ${value}
    ${is_string}=    Run Keyword And Return Status
    ...    Evaluate    isinstance(${value}, str)
    Should Be True    ${is_string}    Value '${value}' is not a string

Should Be Number
    [Arguments]    ${value}
    ${is_number}=    Run Keyword And Return Status
    ...    Evaluate    isinstance(${value}, (int, float))
    Should Be True    ${is_number}    Value '${value}' is not a number

Should Be Boolean
    [Arguments]    ${value}
    ${is_bool}=    Run Keyword And Return Status
    ...    Evaluate    isinstance(${value}, bool)
    Should Be True    ${is_bool}    Value '${value}' is not a boolean

Should Be List
    [Arguments]    ${value}
    ${is_list}=    Run Keyword And Return Status
    ...    Evaluate    isinstance(${value}, list)
    Should Be True    ${is_list}    Value '${value}' is not a list

Should Be Dictionary
    [Arguments]    ${value}
    ${is_dict}=    Run Keyword And Return Status
    ...    Evaluate    isinstance(${value}, dict)
    Should Be True    ${is_dict}    Value '${value}' is not a dictionary

### KEYWORDS DE VALIDAÇÃO DE ESTRUTURA ###
Validate List Items Structure
    [Arguments]    ${items}    ${expected_keys}
    Should Be List    ${items}
    FOR    ${item}    IN    @{items}
        Should Be Dictionary    ${item}
        FOR    ${key}    IN    @{expected_keys}
            Dictionary Should Contain Key    ${item}    ${key}
        END
    END

Validate Single Type
    [Arguments]    ${value}    ${expected_type}
    [Documentation]    Valida se um valor corresponde ao tipo esperado
    
    # Converte expected_type para string e lida com casos de lista
    ${type_str}=    Set Variable    ${expected_type}
    ${is_list}=    Run Keyword And Return Status
    ...    Evaluate    isinstance($expected_type, list)
    
    IF    ${is_list}
        ${type_str}=    Get From List    ${expected_type}    0
    END
    
    IF    '${type_str}' == 'string'
        ${is_string}=    Run Keyword And Return Status
        ...    Evaluate    isinstance($value, str)
        RETURN    ${is_string}
    ELSE IF    '${type_str}' == 'null'
        ${is_none}=    Run Keyword And Return Status
        ...    Evaluate    $value is None
        RETURN    ${is_none}
    ELSE IF    '${type_str}' == 'number'
        ${is_number}=    Run Keyword And Return Status
        ...    Evaluate    isinstance($value, (int, float))
        RETURN    ${is_number}
    ELSE IF    '${type_str}' == 'integer'
        ${is_integer}=    Run Keyword And Return Status
        ...    Evaluate    isinstance($value, int)
        RETURN    ${is_integer}
    ELSE IF    '${type_str}' == 'boolean'
        ${is_boolean}=    Run Keyword And Return Status
        ...    Evaluate    isinstance($value, bool)
        RETURN    ${is_boolean}
    ELSE IF    '${type_str}' == 'array'
        ${is_array}=    Run Keyword And Return Status
        ...    Evaluate    isinstance($value, list)
        RETURN    ${is_array}
    ELSE IF    '${type_str}' == 'object'
        ${is_object}=    Run Keyword And Return Status
        ...    Evaluate    isinstance($value, dict)
        RETURN    ${is_object}
    END
    RETURN    ${FALSE}

### KEYWORDS DE CONCORRÊNCIA ###
Run Concurrent Requests
    [Arguments]    ${keyword}    ${number_of_requests}    ${args}=${EMPTY}
    [Documentation]    Executa requisições sequenciais simulando concorrência
    @{responses}=    Create List
    
    # Executa requisições em sequência rápida
    FOR    ${index}    IN RANGE    ${number_of_requests}
        ${response}=    Run Keyword    ${keyword}    ${index}    ${args}
        Append To List    ${responses}    ${response}
        Sleep    0.1s    # Pequeno delay para não sobrecarregar
    END
    
    RETURN    ${responses}

Validate Concurrent Responses
    [Arguments]    ${responses}    ${validate_item_structure}=None
    [Documentation]    Valida as respostas de requisições concorrentes
    
    FOR    ${response}    IN    @{responses}
        # Valida status code
        ${status_code}=    Convert To String    ${response.status_code}
        Should Be Equal As Strings    ${status_code}    200
        ...    Status code ${status_code} diferente do esperado (200)
        
        # Valida estrutura da resposta
        ${body}=    Set Variable    ${response.json()}
        ${is_list}=    Evaluate    isinstance($body, list)
        Should Be True    ${is_list}
        ...    Resposta deve ser uma lista, mas recebeu: ${body}
        
        # Valida tempo de resposta
        ${response_time}=    Get Response Time    ${response}
        Should Be True    ${response_time} < 2
        ...    Tempo de resposta (${response_time}s) acima do esperado sob concorrência (2s)
        
        # Valida estrutura específica dos itens se fornecida
        IF    $validate_item_structure is not None
            FOR    ${item}    IN    @{body}
                Run Keyword    ${validate_item_structure}    ${item}
            END
        END
    END

Get Response Time
    [Arguments]    ${response}
    [Documentation]    Retorna o tempo de resposta em segundos
    ${response_time}=    Get From Dictionary    ${response.headers}    X-Response-Time    0.1
    RETURN    ${response_time}



