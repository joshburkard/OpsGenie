# Remove-OpsGenieAlertTag

this function removes an existing alerts

## Parameters

possible params are:

parameter | mandatory | type | description | limit
---|---|---|---|---
APIKey | true | string | the APIKey
EU | false | switch | use this switch parameter, if you need to connect to the EU-instance of OpsGenie
Proxy | false | string | the URI of the proxy server, only if needed
ProxyCredential | false | PSCredential | Credentials for the proxy server, only if needed
alias | true | string | Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.|512 chars
tags | true | string array | tags to remove | 20 x 50 chars

## Example

```PowerShell
Remove-OpsGenieAlertTag -APIKey $APIKey -EU -alias $alias -tags 'Test-01'
```