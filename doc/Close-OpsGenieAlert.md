# Close-OpsGenieAlert

this function close an existing alerts

## Parameters

possible params are:

parameter | mandatory | type | description | limit
---|---|---|---|---
APIKey | true | string | the APIKey
EU | false | switch | use this switch parameter, if you need to connect to the EU-instance of OpsGenie
Proxy | false | string | the URI of the proxy server, only if needed
ProxyCredential | false | PSCredential | Credentials for the proxy server, only if needed
alias | false | string | Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.|512 chars
note | false | string | Additional alert note to add. | | 25000 chars
user | false | string | Display name of the request owner. | | 100 chars
source | false | string | Display name of the request source. | | 100 chars

## Example

```PowerShell
Close-OpsGenieAlert -APIKey $APIKey -EU -alias $Alias
```

## Links

- [https://docs.opsgenie.com/docs/alert-api#close-alert](https://docs.opsgenie.com/docs/alert-api#close-alert)
