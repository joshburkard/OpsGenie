# Module OpsGenie

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Description](#description)
- [Global parameter](#global-parameters)
- Functions:
  - [Add-OpsGenieAlertAttachment](doc/Add-OpsGenieAlertAttachment.md)
  - [Add-OpsGenieAlertDetails](doc/Add-OpsGenieAlertDetails.md)
  - [Add-OpsGenieAlertNote](doc/Add-OpsGenieAlertNote.md)
  - [Add-OpsGenieAlertResponder](doc/Add-OpsGenieAlertResponder.md)
  - [Add-OpsGenieAlertTag](doc/Add-OpsGenieAlertTag.md)
  - [Add-OpsGenieAlertTeam](doc/Add-OpsGenieAlertTeam.md)
  - [Close-OpsGenieAlert](doc/Close-OpsGenieAlert.md)
  - [Get-OpsGenieAlert](doc/Get-OpsGenieAlert.md)
  - [Get-OpsGenieAlertAttachment](doc/Get-OpsGenieAlertAttachment.md)
  - [Get-OpsGenieAlertNote](doc/Get-OpsGenieAlertNote.md)
  - [Get-OpsGenieGuidType](doc/Get-OpsGenieGuidType.md)
  - [Invoke-OpsGenieAlertAction](doc/Invoke-OpsGenieAlertAction)
  - [New-OpsGenieAlert](doc/New-OpsGenieAlert.md)
  - [Remove-OpsGenieAlert](doc/Remove-OpsGenieAlert)
  - [Remove-OpsGenieAlertAttachment](doc/Remove-OpsGenieAlertAttachment.md)
  - [Remove-OpsGenieAlertTag](doc/Remove-OpsGenieAlertTag.md)
  - [Set-OpsGenieAlertEscalation](doc/Set-OpsGenieAlertEscalation.md)
  - [Set-OpsGenieAlertPriority](doc/Set-OpsGenieAlertPriority.md)
- [Prerequisites](#prerequisites)
- [Examples](#examples)
  - [create a new alert](#create-a-new-alert)
  - [acknowledge an alert](#acknowledge-an-alert)
  - [close an alert](#close-an-alert)

## Description

This powershell module will interact with the OpsGenie API v2

more infos about the OpsGenie API is available at [https://docs.opsgenie.com/docs](https://docs.opsgenie.com/docs)

## Global parameters

this parameters are accepted in all functions:

parameter | mandatory | type | description
---|---|---|---
APIKey | true | string | the APIKey
EU | false | switch | use this switch parameter, if you need to connect to the EU-instance of OpsGenie
Proxy | false | string | the URI of the proxy server, only if needed
ProxyCredential | false | PSCredential | Credentials for the proxy server, only if needed

## Prerequisites

to interact with the OpsGenie API, you need an OpsGenie Team and an API Key for the Team-integration

to create the API Key, open OpsGenie and follow this steps:

- click on **Teams** on the main menu
- select your Team, for which the alerts should be used
- click **Integrations**
- click **Add integration**
- select the **API** integration and click **Add**
- you will see the API Key in this form
- make adjustments to the permissions and click to **Safe Integration**.

Note: you can create multiple API-integrations with different API-Keys and different permissions.

## Examples

you can start with this simple examples. other examples are under each function description.

### define the connection to OpsGenie

you can define a HashTable with the connection parameters

```PowerShell
$OpsGenieConnection = @{
    APIKey          = 'only-an-example-key-8e57c630b7ef'
    EU              = $true
    Proxy           = 'http://proxy.server.com:8080'
    ProxyCredential = $PSCredentialObject
}
```

### create a new alert

to create a new alert, use this command

```PowerShell
# create an alias to identify the alert later
$alias = ( New-Guid ).Guid

# create the alert
New-OpsGenieAlert @OpsGenieConnection -Message 'this is a Test-Alert' -alias $alias -priority P5
```

you can add additional parameters if needed

### acknowledge an alert

```PowerShell
Invoke-OpsGenieAlertAction @OpsGenieConnection -alias $alias -action 'acknowledge'
```

### close an alert

```PowerShell
Close-OpsGenieAlert @OpsGenieConnection -alias $alias
```
