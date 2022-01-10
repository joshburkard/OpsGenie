# Get-OpsGenieAlert

this function reads alerts

## Parameters

if an alias or an identifier is submited, the result will be filtered to this entry.

possible params are:

parameter | mandatory | type | description | limit
---|---|---|---|---
APIKey | true | string | the APIKey
EU | false | switch | use this switch parameter, if you need to connect to the EU-instance of OpsGenie
Proxy | false | string | the URI of the proxy server, only if needed
ProxyCredential | false | PSCredential | Credentials for the proxy server, only if needed
alias | false | string | Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.|512 chars
identifier | false | string | Identifier of the alert |

## Example

this examle gets a single existing alert by alias:

```PowerShell
$alert = Get-OpsGenieAlert -APIKey $APIKey -EU -alias $alias
```

this examle gets a single existing alert by identifier:

```PowerShell
$alert = Get-OpsGenieAlert -APIKey $APIKey -EU -identifier $identifier
```

this examle gets all existing alerts:

```PowerShell
$alerts = Get-OpsGenieAlert -APIKey $APIKey -EU
```

## Links

- [https://docs.opsgenie.com/docs/alert-api#get-alert](https://docs.opsgenie.com/docs/alert-api#get-alert)
