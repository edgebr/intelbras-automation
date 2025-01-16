*** Settings ***
Resource  ../../../resources/resource.resource
Resource  ../../../resources/page/api/2user/1GET_user.resource
Suite Setup    Suite Setup
Suite Teardown    Suite Teardown

*** Test Cases ***
# 1 - Requisição bem-sucedida (200 OK)
Get Successful Response
    [Documentation]    Testa uma requisição bem-sucedida no endpoint GET.
    [Tags]    positive
    ${response}=    Get Users
    Validate Status Code 200    ${response}
    Validate Response Has Content    ${response}

# 2 - Não autorizado (401 Unauthorized)
Get Unauthorized Response
    [Documentation]    Testa o comportamento ao não fornecer token de autenticação.
    [Tags]    negative
    ${response}=    Get Users Without Token
    Validate Status Code 401    ${response}


