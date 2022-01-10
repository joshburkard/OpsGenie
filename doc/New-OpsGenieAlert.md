# New-OpsGenieAlert

this function create a new alert

## Parameters

possible params are:

parameter | mandatory | type | description | limit
---|---|---|---|---
APIKey | true | string | the APIKey
EU | false | switch | use this switch parameter, if you need to connect to the EU-instance of OpsGenie
Proxy | false | string | the URI of the proxy server, only if needed
ProxyCredential | false | PSCredential | Credentials for the proxy server, only if needed
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
wait | false | switch | wait till the alert is created |


## Example

```PowerShell
$AlertParams = @{
    APIKey      = $APIKey
    EU          = $EU
    message     = "This is a test message"
    priority    = 'P4'
    source      = "script $( $MyInvocation.MyCommand.Path )"
    description = @"
    This is a Test
    this is the second line
"@
}
$NewAlert = New-OpsGenieAlert @AlertParams -wait
$alias = $NewAlert.data.alertId
```

## Links

- [https://docs.opsgenie.com/docs/alert-api#create-alert](https://docs.opsgenie.com/docs/alert-api#create-alert)