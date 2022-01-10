# Add-OpsGenieAlertTeam

this function add a team to an existing alerts

## Parameters

possible params are:

parameter | mandatory | type | description | limit
---|---|---|---|---
APIKey | true | string | the APIKey
EU | false | switch | use this switch parameter, if you need to connect to the EU-instance of OpsGenie
Proxy | false | string | the URI of the proxy server, only if needed
ProxyCredential | false | PSCredential | Credentials for the proxy server, only if needed
alias | true | string | Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.|512 chars
team | true | string | the name or id of the team |
note | false | string | Additional alert note to add. | | 25000 chars
user | false | string | Display name of the request owner. | | 100 chars
source | false | string | Display name of the request source. | | 100 chars

## Example

```PowerShell
Add-OpsGenieAlertTeam -APIKey $APIKey -EU -alias $alias -team $TeamName
```

## Links

- [https://docs.opsgenie.com/docs/alert-api#add-tags-to-alert](https://docs.opsgenie.com/docs/alert-api#add-tags-to-alert)
