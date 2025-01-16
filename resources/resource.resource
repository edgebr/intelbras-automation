*** Settings ***
# # DEVICE
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

*** Variables ***
${BASE_URL}       http://18.228.160.85:5000
&{HEADERS}        x-api-key=c91f3812554f58600bdecffa4233f8ef397a6c3e42d00489e1b4ed168fb0cbfc



*** Keywords ***


Suite Setup
    Create Session    user    ${BASE_URL}    headers=${HEADERS}
Suite Teardown
    Delete All Sessions

