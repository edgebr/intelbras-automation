*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    OperatingSystem
Library    String
Library    DateTime
Library    JSONLibrary
Resource    ../../../resource.resource

*** Variables ***


*** Keywords ***

### KEYWORDS DE REQUISIÇÃO ###
Get Devices
    [Documentation]    Executa GET /devices para listar todos os dispositivos
    ${response}=    GET On Session    
    ...    alias=device    
    ...    url=${BASE_URL}/devices    
    ...    headers=${HEADERS}    
    ...    expected_status=200
    RETURN    ${response}

Get Devices With Headers
    [Arguments]    ${headers}
    [Documentation]    Executa GET /devices com headers customizados
    ${response}=    GET On Session    
    ...    alias=device    
    ...    url=${BASE_URL}/devices    
    ...    headers=${headers}    
    ...    expected_status=any
    RETURN    ${response}

Get Devices With Pagination
    [Arguments]    ${page}=1    ${per_page}=10
    [Documentation]    Executa GET /devices com paginação
    ${headers}=    Create Dictionary    x-api-key=${HEADERS}[x-api-key]
    ${params}=    Create Dictionary    
    ...    page=${page}    
    ...    per_page=${per_page}
    ${response}=    GET On Session    
    ...    alias=device    
    ...    url=${BASE_URL}/devices    
    ...    headers=${headers}    
    ...    params=${params}    
    ...    expected_status=any
    RETURN    ${response}

Get Response Time
    [Arguments]    ${response}
    [Documentation]    Retorna o tempo de resposta em segundos
    ${response_time}=    Get From Dictionary    ${response.headers}    X-Response-Time    0.1
    RETURN    ${response_time}

Get Response Size
    [Arguments]    ${response}
    [Documentation]    Retorna o tamanho do response em bytes
    ${response_size}=    Get Length    ${response.content}
    RETURN    ${response_size}

### KEYWORDS DE CONCORRÊNCIA ###
Run Concurrent Requests
    [Arguments]    ${keyword}    ${number_of_requests}    ${args}=${EMPTY}
    [Documentation]    Executa requisições sequenciais simulando concorrência
    @{responses}=    Create List
    
    # Executa requisições em sequência rápida
    FOR    ${index}    IN RANGE    ${number_of_requests}
        ${response}=    Run Keyword    ${keyword}    ${args}
        Append To List    ${responses}    ${response}
        Sleep    0.1s    # Pequeno delay para não sobrecarregar
    END
    
    RETURN    ${responses}

Validate Concurrent Responses
    [Arguments]    ${responses}
    [Documentation]    Valida as respostas de requisições concorrentes
    
    FOR    ${response}    IN    @{responses}
        # Valida status code
        Status Should Be    200    ${response}
        
        # Valida estrutura da resposta
        ${body}=    Set Variable    ${response.json()}
        Should Be True    isinstance($body, list)
        
        # Valida tempo de resposta
        ${response_time}=    Get Response Time    ${response}
        Should Be True    ${response_time} < 2
        ...    Tempo de resposta (${response_time}s) acima do esperado sob concorrência (2s)
    END

Validate Concurrent Cache Responses
    [Arguments]    ${responses}
    [Documentation]    Valida as respostas de requisições concorrentes com cache
    
    ${cache_hits}=    Set Variable    ${0}
    
    FOR    ${response}    IN    @{responses}
        # Valida status code (200 ou 304)
        ${status}=    Convert To String    ${response.status_code}
        Should Be True    ${status} in ['200', '304']
        
        # Conta cache hits
        IF    '${status}' == '304'
            ${cache_hits}=    Evaluate    ${cache_hits} + 1
        END
    END
    
    # Valida taxa de hit do cache
    ${hit_rate}=    Evaluate    ${cache_hits} / len($responses)
    Should Be True    ${hit_rate} >= 0.7
    ...    Taxa de hit do cache (${hit_rate}) abaixo do esperado (70%)

Status Should Be
    [Arguments]    ${expected_status}    ${response}
    [Documentation]    Valida o status code da resposta
    ${actual_status}=    Convert To String    ${response.status_code}
    Should Be Equal As Strings    ${actual_status}    ${expected_status}
    ...    Status code ${actual_status} diferente do esperado (${expected_status})

### KEYWORDS DE VALIDAÇÃO ###
Should Be True
    [Arguments]    ${condition}    ${message}=${EMPTY}
    [Documentation]    Valida se uma condição é verdadeira
    ${result}=    Run Keyword And Return Status    Evaluate    ${condition}
    Should Be Equal As Strings    ${result}    ${TRUE}    ${message}

Get From Dictionary
    [Arguments]    ${dictionary}    ${key}    ${default}=${EMPTY}
    [Documentation]    Retorna um valor do dicionário com valor padrão
    ${value}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${dictionary}    ${key}
    IF    ${value}
        ${result}=    Set Variable    ${dictionary}[${key}]
    ELSE
        ${result}=    Set Variable    ${default}
    END
    RETURN    ${result}

Create Dictionary
    [Documentation]    Cria um novo dicionário
    [Arguments]    &{items}
    ${dictionary}=    Evaluate    dict()
    FOR    ${key}    ${value}    IN    &{items}
        Set To Dictionary    ${dictionary}    ${key}    ${value}
    END
    RETURN    ${dictionary}

Create List
    [Documentation]    Cria uma nova lista
    [Arguments]    @{items}
    ${list}=    Evaluate    []
    FOR    ${item}    IN    @{items}
        Append To List    ${list}    ${item}
    END
    RETURN    ${list}

Create Set
    [Documentation]    Cria um novo conjunto
    [Arguments]    @{items}
    ${set}=    Evaluate    set()
    FOR    ${item}    IN    @{items}
        Add To Set    ${set}    ${item}
    END
    RETURN    ${set}

Add To Set
    [Arguments]    ${set}    ${item}
    [Documentation]    Adiciona um item ao conjunto
    ${result}=    Evaluate    ${set}.add('''${item}''')
    RETURN    ${set}

Should Not Contain
    [Arguments]    ${set}    ${item}    ${message}=${EMPTY}
    [Documentation]    Verifica se um conjunto não contém um item
    ${contains}=    Run Keyword And Return Status    Evaluate    '''${item}''' in ${set}
    Should Be Equal As Strings    ${contains}    ${FALSE}    ${message}

### KEYWORDS DE CONCORRÊNCIA ###
Start Paginated Request Thread
    [Arguments]    ${page}
    [Documentation]    Inicia uma thread para fazer uma requisição GET /devices paginada
    ${response}=    Get Devices With Pagination    page=${page}
    RETURN    ${response}