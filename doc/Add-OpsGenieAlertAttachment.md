# Add-OpsGenieAlertAttachment

this function add an attachment to an existing alerts

## Parameters

possible params are:

parameter | mandatory | type | description | limit
---|---|---|---|---
APIKey | true | string | the APIKey
EU | false | switch | use this switch parameter, if you need to connect to the EU-instance of OpsGenie
Proxy | false | string | the URI of the proxy server, only if needed
ProxyCredential | false | PSCredential | Credentials for the proxy server, only if needed
alias | true | string | Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.|512 chars
FilePath| true | string | the path to the file to attach|

## Example

```PowerShell
Add-OpsGenieAlertAttachment -APIKey $APIKey -EU -alias $alias -FilePath $FilePath
```

## Links

- [https://docs.opsgenie.com/docs/alert-api-continued#create-alert-attachment](https://docs.opsgenie.com/docs/alert-api-continued#create-alert-attachment)