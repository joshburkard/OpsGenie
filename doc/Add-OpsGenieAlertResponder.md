# Add-OpsGenieAlertResponder

this function add a responder to an existing alerts

## Parameters

possible params are:

parameter | mandatory | type | description | limit
---|---|---|---|---
APIKey | true | string | the APIKey
EU | false | switch | use this switch parameter, if you need to connect to the EU-instance of OpsGenie
Proxy | false | string | the URI of the proxy server, only if needed
ProxyCredential | false | PSCredential | Credentials for the proxy server, only if needed
alias | true | string | Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.|512 chars
respondertype| true | string | user or team |
responder | true | string | id or name of the user or team to add |
note | false | string | Additional alert note to add. | | 25000 chars
user | false | string | Display name of the request owner. | | 100 chars
source | false | string | Display name of the request source. | | 100 chars

## Example

this examples set a single user as a responder:

```PowerShell
Add-OpsGenieAlertResponder -APIKey $APIKey -EU -alias $alias -responderType user -responder $UserMail
```

this examples set a team as a responder:

```PowerShell
Add-OpsGenieAlertResponder -APIKey $APIKey -EU -alias $alias -responderType team -responder $TeamName
```
