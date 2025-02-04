*** Settings ***
Resource          ../../../resources/page/api/2user/2POST_user.resource

Force Tags        api    post_users
Default Tags      regression

Suite Setup       Suite Setup
Suite Teardown    Delete All Sessions

*** Variables ***


*** Test Cases ***