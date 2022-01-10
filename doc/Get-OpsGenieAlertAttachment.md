# Get-OpsGenieAlertAttachment

this function lists all attachements of an existing alerts

## Parameters

possible params are:

parameter | mandatory | type | description | limit
---|---|---|---|---
APIKey | true | string | the APIKey
EU | false | switch | use this switch parameter, if you need to connect to the EU-instance of OpsGenie
Proxy | false | string | the URI of the proxy server, only if needed
ProxyCredential | false | PSCredential | Credentials for the proxy server, only if needed
alias | true | string | Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.|512 chars

## Example

```PowerShell
Get-OpsGenieAlertAttachment -APIKey $APIKey -EU -alias $Alias
```

## Links

- [https://docs.opsgenie.com/docs/alert-api-continued#get-alert-attachment](https://docs.opsgenie.com/docs/alert-api-continued#get-alert-attachment)
- [https://docs.opsgenie.com/docs/alert-api-continued#list-alert-attachments](https://docs.opsgenie.com/docs/alert-api-continued#list-alert-attachments)
