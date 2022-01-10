# Get-OpsGenieGuidType

this function receives the type of an alert id

it returns one of this values:

- identifier
- alias
- tiny
- unknown

## Parameters

this function expects this parameters:

parameter | mandatory | type | description | limit
---|---|---|---|---
id | true | string | the identiefer, alias or tinyid to check |

## Examples

returns 'tiny':

```PowerShell
Get-OpsGenieGuidType -id 1
```

returns 'alias':

```PowerShell
Get-OpsGenieGuidType -id '00000000-0000-0000-0000-000000000000'
```

returns 'identifier':
```PowerShell
Get-OpsGenieGuidType -id '00000000-0000-0000-0000-000000000000-0000000000000'
```
