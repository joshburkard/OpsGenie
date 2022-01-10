function Invoke-OpsGenieAlertAction {
    <#
        .SYNOPSIS
            This function invokes an action on an existing alert in OpsGenie

        .DESCRIPTION
            This function invokes an action on an existing alert in OpsGenie

            more info about the API under https://docs.opsgenie.com/docs/alert-api

        .PARAMETER APIKey
            The APIKey from OpsGenie

        .PARAMETER identifier
            Identifier of the alert

        .PARAMETER EU
            if this switch parameter is set, the function will connect to API URI in EU otherwise, the global URI

        .PARAMETER Proxy
            defines the proxy server to use

        .PARAMETER ProxyCredential
            defines the credential for the Proxy-Server

        .PARAMETER action
            the action which should be invoked

        .PARAMETER note
            defines the note for the alert

        .PARAMETER source
            defines the source for the alert

        .PARAMETER user
            defines the user for the alert

        .EXAMPLE
            Confirm-OpsGenieAlert -APIKey $APIKey -Identifier '9450e556-b8cb-432f-b4a7-e3cb1933819c'

        .NOTES
            Date, Author, Version, Notes
            28.07.2021, Josua Burkard, 0.0.00001, initial creation
            29.11.2021, Josua Burkard, 0.0.00003, removed actions which are now in separate functions

    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$APIKey
        ,
        [Parameter(Mandatory=$false)]
        [string]$identifier
        ,
        [Parameter(Mandatory=$false)]
        [string]$alias
        ,
        [switch]$EU
        ,
        [Parameter(Mandatory=$false)]
        [string]$Proxy
        ,
        [Parameter(Mandatory=$false)]
        [System.Management.Automation.PSCredential]$ProxyCredential
        ,
        [Parameter(Mandatory=$true)]
        [ValidateSet('acknowledge',
                     'assign',
                     'CustomAction',
                     'description',
                     'snooze',
                     'unacknowledge')]
        [string]$action
        ,
        [Parameter(Mandatory=$false)]
        [string]$note
        ,
        [Parameter(Mandatory=$false)]
        [string]$user
        ,
        [Parameter(Mandatory=$false)]
        [string]$source
        ,
        [switch]$wait
    )
    DynamicParam {
        $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        if ($action -eq "assign") {
            $Attribute = New-Object System.Management.Automation.ParameterAttribute
            $Attribute.Mandatory = $true
            $Attribute.HelpMessage = "Escalation that the alert will be escalated. Either id or name of the escalation should be provided."
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeCollection.Add($Attribute)
            $Param = New-Object System.Management.Automation.RuntimeDefinedParameter('owner', [string], $attributeCollection)
            $paramDictionary.Add('owner', $Param)
        }
        if ($action -eq "CustomAction") {
            $Attribute = New-Object System.Management.Automation.ParameterAttribute
            $Attribute.Mandatory = $true
            $Attribute.HelpMessage = "Name of the action to execute"
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeCollection.Add($Attribute)
            $Param = New-Object System.Management.Automation.RuntimeDefinedParameter('CustomAction', [string], $attributeCollection)
            $paramDictionary.Add('CustomAction', $Param)
        }
        if ($action -eq "description") {
            $Attribute = New-Object System.Management.Automation.ParameterAttribute
            $Attribute.Mandatory = $true
            $Attribute.HelpMessage = "Path to the file to upload"
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeCollection.Add($Attribute)
            $Param = New-Object System.Management.Automation.RuntimeDefinedParameter('description', [string], $attributeCollection)
            $paramDictionary.Add('description', $Param)
        }
        if ($action -eq "snooze") {
            $Attribute = New-Object System.Management.Automation.ParameterAttribute
            $Attribute.Mandatory = $true
            $Attribute.HelpMessage = "Enter the End Date Time"
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeCollection.Add($Attribute)
            $Param = New-Object System.Management.Automation.RuntimeDefinedParameter('endTime', [datetime], $attributeCollection)
            $paramDictionary.Add('endTime', $Param)
        }


        return $paramDictionary
    }
    Process {
        $function = $($MyInvocation.MyCommand.Name)
        Write-Verbose "Running $function"
        try {
            $PostParams = @{}
            $URIPart = "alerts/$( $alias )/$( $action )"
            switch ( $action ) {
                'assign' {
                    if ( Test-OpsGenieIsGuid -ObjectGuid $PSBoundParameters['owner'] ) {
                        $owner = @{
                            id = $PSBoundParameters['owner']
                        }
                    }
                    else {
                        $owner = @{
                            username = $PSBoundParameters['owner']
                        }
                    }
                    $PostParams.Add( 'owner' , $owner )
                }
                'CustomAction' {
                    $URIPart = "alerts/$( $alias )/action/$( $PSBoundParameters['CustomAction'] )"
                }
                'description' {
                    $PostParams.Add( 'description', $PSBoundParameters['description'] )
                }
                'snooze' {
                    $PostParams.Add( 'endTime', ( Get-Date ( Get-Date $PSBoundParameters['endTime'] ).ToUniversalTime() -UFormat '+%Y-%m-%dT%H:%M:%S.000Z' ) )
                }
            }

            $IDType = Get-OpsGenieGuidType -id $alias
            if ( $IDType -ne 'identifier' ) {
                $URIPart = "${URIPart}?identifierType=${IDType}"
            }
            $InvokeParams = @{
                URIPart     = $URIPart
                Method      = 'POST'
            }
            foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -in @('APIKey', 'EU', 'Proxy', 'ProxyCredential', 'wait' ) } ) ) {
                $InvokeParams.Add( $Key , $PSBoundParameters."$( $Key )")
            }

            foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -in @('note', 'user', 'source') } ) ) {
                $PostParams.Add( $Key , $PSBoundParameters."$( $Key )")
            }
            if ( $PostParams -ne @{} ) {
                $InvokeParams.Add( 'PostParams', $PostParams )
            }

            $ret = Invoke-OpsGenieWebRequest @InvokeParams
            return $ret
        }
        catch {
            $ret = $_

            Write-Output "Error occured in function $( $function )"
            if ( $_.InvocationInfo.ScriptLineNumber ){
                Write-Output "Error Occured at line: $($_.InvocationInfo.ScriptLineNumber)"
                Write-Output $_.Exception
            }
            else {
                Write-Output $_.Exception.Line
            }

            # clear all errors
            $error.Clear()

            # throw with only the last error
            throw $ret
        }
    }
}
