# Add-OpsGenieAlertNote

this function add a note to an existing alerts

## Parameters

possible params are:

parameter | mandatory | type | description | limit
---|---|---|---|---
APIKey | true | string | the APIKey
EU | false | switch | use this switch parameter, if you need to connect to the EU-instance of OpsGenie
Proxy | false | string | the URI of the proxy server, only if needed
ProxyCredential | false | PSCredential | Credentials for the proxy server, only if needed
alias | true | string | Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.|512 chars
note| true | string | the note text to add | 25000 chars
user | false | string | Display name of the request owner. | | 100 chars
source | false | string | Display name of the request source. | | 100 chars

## Example

```PowerShell
Add-OpsGenieAlertNote -APIKey $APIKey -EU -alias $Alias -note "this is a new note"
```