# Add-OpsGenieAlertDetails

This function add additional details (custom properties) to an already existing alert in OpsGenie

## Parameters

possible params are:

parameter | mandatory | type | description | limit
---|---|---|---|---
APIKey | true | string | the APIKey
EU | false | switch | use this switch parameter, if you need to connect to the EU-instance of OpsGenie
Proxy | false | string | the URI of the proxy server, only if needed
ProxyCredential | false | PSCredential | Credentials for the proxy server, only if needed
alias | true | string | Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.|512 chars
details | true | hashtable | Key-value pairs to add as custom property into alert. You can refer below for example values |

## Example

this example adds two custom properties to an existing alert:

```PowerShell
$CustomProperties = @{
    'Test-1' = 'this is a first test property'
    'Test-2' = 'this is a second test property'
}

Add-OpsGenieAlertDetails -APIKey $APIKey -EU -alias $alias -details $CustomProperties
```