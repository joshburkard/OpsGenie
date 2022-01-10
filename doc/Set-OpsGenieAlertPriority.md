# Set-OpsGenieAlertPriority

This function set the priority of an alert in OpsGenie

## Parameters

possible params are:

parameter | mandatory | type | description | limit
---|---|---|---|---
APIKey | true | string | the APIKey
EU | false | switch | use this switch parameter, if you need to connect to the EU-instance of OpsGenie
Proxy | false | string | the URI of the proxy server, only if needed
ProxyCredential | false | PSCredential | Credentials for the proxy server, only if needed
alias | true | string | Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.|512 chars
priority | true | string | one of this values: P1, P2, P3, P4, P5 |

## Example

```PowerShell
Set-OpsGenieAlertPriority -APIKey $APIKey -EU -alias $Alias -priority P4
```