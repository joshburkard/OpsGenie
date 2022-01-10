# Invoke-OpsGenieAlertAction

this function invokes actions on an alert.

## Parameters

possible values for the parameter **action** are:

- acknowledge
- assign
- close
- CustomAction
- snooze
- unacknowledge

every action accepts this parameters:

parameter | mandatory | type | description | limit
---|---|---|---|---
APIKey | true | string | the APIKey
EU | false | switch | use this switch parameter, if you need to connect to the EU-instance of OpsGenie
Proxy | false | string | the URI of the proxy server, only if needed
ProxyCredential | false | PSCredential | Credentials for the proxy server, only if needed
action | true | string |
note | false | string | Additional alert note to add. | | 25000 chars
user | false | string | Display name of the request owner. | | 100 chars
source | false | string | Display name of the request source. | | 100 chars

some of this actions need additional parameters:

### assign

parameter | mandatory | type | description | limit
---|---|---|---|---
owner | true | string | User that the alert will be assigned to. Either id or username of the user should be provided. |

### CustomAction

parameter | mandatory | type | description | limit
---|---|---|---|---
CustomAction | true | string | The name of the custom action to execute | |

## Example

