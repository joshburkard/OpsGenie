# Module Swisscom.SCS.OpsGenie

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Description](#description)
- [Global parameter](#global-parameters)
- [Functions](#functions)
  - [Add-OpsGenieAlertAttachment](#Add-OpsGenieAlertAttachment)
  - [Add-OpsGenieAlertNote](#Add-OpsGenieAlertNote)
  - [Add-OpsGenieAlertResponder](#Add-OpsGenieAlertResponder)
  - [Add-OpsGenieAlertTag](#Add-OpsGenieAlertTag)
  - [Add-OpsGenieAlertTeam](#Add-OpsGenieAlertTeam)
  - [Close-OpsGenieAlert](#close-opsgeniealert)
  - [Get-OpsGenieAlert](#get-opsgeniealert)
  - [New-OpsGenieAlert](#new-opsgeniealert)
  - [Invoke-OpsGenieAlertAction](#get-opsgeniealertaction)
  - [Remove-OpsGenieAlert](#remove-opsgeniealert)
  - [Remove-OpsGenieAlertAttachment](#remove-opsgeniealertattachment)
  - [Remove-OpsGenieAlertTag](#remove-opsgeniealerttag)
  - [Set-OpsGenieAlertEscalation](#Set-OpsGenieAlertEscalation)
  - [Set-OpsGenieAlertPriority](#Set-OpsGenieAlertPriority)
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

## Functions

### Add-OpsGenieAlertAttachment

this function add an attachment to an existing alerts

possible params are:

parameter | mandatory | type | description | limit
---|---|---|---|---
alias | true | string | Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.|512 chars
FilePath| true | string | the path to the file to attach|

### Add-OpsGenieAlertNote

this function add a note to an existing alerts

possible params are:

parameter | mandatory | type | description | limit
---|---|---|---|---
alias | true | string | Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.|512 chars
note| true | string | the note text to add | 25000 chars
user | false | string | Display name of the request owner. | | 100 chars
source | false | string | Display name of the request source. | | 100 chars

### Add-OpsGenieAlertResponder

this function add a responder to an existing alerts

possible params are:

parameter | mandatory | type | description | limit
---|---|---|---|---
alias | true | string | Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.|512 chars
respondertype| true | string | user or team |
responder | true | string | id or name of the user or team to add |
note | false | string | Additional alert note to add. | | 25000 chars
user | false | string | Display name of the request owner. | | 100 chars
source | false | string | Display name of the request source. | | 100 chars

### Add-OpsGenieAlertTag

this function add a tag to an existing alerts

possible params are:

parameter | mandatory | type | description | limit
---|---|---|---|---
alias | true | string | Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.|512 chars
tag | true | string | the tag to add |
note | false | string | Additional alert note to add. | | 25000 chars
user | false | string | Display name of the request owner. | | 100 chars
source | false | string | Display name of the request source. | | 100 chars

### Add-OpsGenieAlertTeam

this function add a team to an existing alerts

possible params are:

parameter | mandatory | type | description | limit
---|---|---|---|---
alias | true | string | Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.|512 chars
team | true | string | the name or id of the team |
note | false | string | Additional alert note to add. | | 25000 chars
user | false | string | Display name of the request owner. | | 100 chars
source | false | string | Display name of the request source. | | 100 chars

### Close-OpsGenieAlert

this function close an existing alerts

possible params are:

parameter | mandatory | type | description | limit
---|---|---|---|---
alias | false | string | Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.|512 chars
note | false | string | Additional alert note to add. | | 25000 chars
user | false | string | Display name of the request owner. | | 100 chars
source | false | string | Display name of the request source. | | 100 chars

### Get-OpsGenieAlert

this function reads alerts

if an alias or an identifier is submited, the result will be filtered to this entry.

possible params are:

parameter | mandatory | type | description | limit
---|---|---|---|---
alias | false | string | Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.|512 chars
identifier | false | string | Identifier of the alert |

### Get-OpsGenieAlertAttachment

this function lists all attachements of an existing alerts

possible params are:

parameter | mandatory | type | description | limit
---|---|---|---|---
alias | true | string | Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.|512 chars

### Get-OpsGenieAlertNote

this function lists all notes of an existing alerts

possible params are:

parameter | mandatory | type | description | limit
---|---|---|---|---
alias | true | string | Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.|512 chars

### Invoke-OpsGenieAlertAction

this function invokes actions on an alert.

possible values for the parameter **action** are:

- acknowledge
- assign
- close
- CustomAction
- snooze
- unacknowledge

every action accepts this parameters:

parameter | mandatory | type | description | limit
---|---|---|---|---
action | true | string |
note | false | string | Additional alert note to add. | | 25000 chars
user | false | string | Display name of the request owner. | | 100 chars
source | false | string | Display name of the request source. | | 100 chars

some of this actions need additional parameters:

#### assign

parameter | mandatory | type | description | limit
---|---|---|---|---
owner | true | string | User that the alert will be assigned to. Either id or username of the user should be provided. |

#### CustomAction

parameter | mandatory | type | description | limit
---|---|---|---|---
CustomAction | true | string | The name of the custom action to execute | |

### New-OpsGenieAlert

this function create a new alert

possible params are:

parameter | mandatory | type | description | limit
---|---|---|---|---
message | true | string | The Message for the OpsGenie Alert | 130 chars
responders | false | hashtable | Teams, users, escalations and schedules that the alert will be routed to send notifications. type field is mandatory for each item, where possible values are team, user, escalation and schedule. If the API Key belongs to a team integration, this field will be overwritten with the owner team. Either id or name of each responder should be provided.You can refer below for example values.| 50 teams or users in total
alias | false | string | Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.|512 chars
description | false | string | Description field of the alert that is generally used to provide a detailed information about the alert. | 15000 chars
visibleTo | false | hashtable | Teams and users that the alert will become visible to without sending any notification.type field is mandatory for each item, where possible values are team and user. In addition to the type field, either id or name should be given for teams and either id or username should be given for users. Please note: that alert will be visible to the teams that are specified withinresponders field by default, so there is no need to re-specify them within visibleTo field. You can refer below for example values. | 50 teams or users in total
actions|false|stringarray|Custom actions that will be available for the alert.|10x50 chars
tags | false | stringarray | Tags of the alert. | 20x50 chars
details | false | hashtable | Map of key-value pairs to use as custom properties of the alert. | 8000 chars in total after convert to json
entity | false | string | Entity field of the alert that is generally used to specify which domain alert is related to. | 512 chars
source | false | string | Source field of the alert. Default value is IP address of the incoming request. | 100 chars
priority | false | string | Priority level of the alert. Possible values are P1, P2, P3, P4 and P5. Default is P3 |
user | false | string | Display name of the request owner. | 100 chars
note | false | string | Additional note that will be added while creating the alert. | 25000 chars


### Remove-OpsGenieAlert

this function removes an existing alerts

possible params are:

parameter | mandatory | type | description | limit
---|---|---|---|---
alias | true | string | Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.|512 chars

### Remove-OpsGenieAlertAttachment

this function removes an attachment from an existing alerts

possible params are:

parameter | mandatory | type | description | limit
---|---|---|---|---
alias | true | string | Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.|512 chars
attachmentId | true | string | the id of the attachment | 20 x 50 chars

### Remove-OpsGenieAlertTag

this function removes an existing alerts

possible params are:

parameter | mandatory | type | description | limit
---|---|---|---|---
alias | true | string | Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.|512 chars
tags | true | string array | tags to remove | 20 x 50 chars

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

### define the connection to OpsGenie

yoz can define a HashTable with the connection parameters

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
