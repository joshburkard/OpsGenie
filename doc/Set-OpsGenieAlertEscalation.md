# Set-OpsGenieAlertEscalation

This function escalates an alert in OpsGenie to an escalation group

## Parameters

possible params are:

parameter | mandatory | type | description | limit
---|---|---|---|---
APIKey | true | string | the APIKey
EU | false | switch | use this switch parameter, if you need to connect to the EU-instance of OpsGenie
Proxy | false | string | the URI of the proxy server, only if needed
ProxyCredential | false | PSCredential | Credentials for the proxy server, only if needed
alias | true | string | Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.|512 chars
id | false | string array | id of the escalation group |
name | false | string array | name of the escalation group |

## Example

this example escalates to a group by the group name:

```PowerShell
Set-OpsGenieAlertEscalation -APIKey $APIKey -EU -alias $Alias -name $groupname
```

this example escalates to a group by the group id:

```PowerShell
Set-OpsGenieAlertEscalation -APIKey $APIKey -EU -alias $Alias -id $groupid
```

## Links

- [https://docs.opsgenie.com/docs/alert-api#escalate-alert-to-next](https://docs.opsgenie.com/docs/alert-api#escalate-alert-to-next)
