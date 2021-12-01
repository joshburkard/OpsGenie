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
    )
    DynamicParam {
        $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        $Attribute = New-Object System.Management.Automation.ParameterAttribute
        $Attribute.Mandatory = $false
        $Attribute.HelpMessage = "Additional alert note to add."
        $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $attributeCollection.Add($Attribute)
        $Param = New-Object System.Management.Automation.RuntimeDefinedParameter('note', [string], $attributeCollection)
        $paramDictionary.Add('note', $Param)

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
            if ( $alias ) {
                $Params = @{
                    APIKey = $APIKey
                    alias = $alias
                }
                if ( [boolean]$EU ) {
                    $Params.Add('EU', $true )
                }
                if ( [boolean]$Proxy ) {
                    $Params.Add('Proxy', $Proxy )
                }
                if ( [boolean]$ProxyCredential ) {
                    $Params.Add('ProxyCredential', $ProxyCredential )
                }
                $alert = Get-OpsGenieAlert @Params
                if ( [boolean]$alert ) {
                    $identifier = $alert.id
                }
            }

            $BodyParams = @{}
            foreach ( $Key in $PSBoundParameters.Keys | Where-Object { $_ -in @('user', 'source', 'note') } ) {
                $BodyParams.Add( $Key , $PSBoundParameters."$( $Key )")
            }
            $Methode = 'POST'
            $ContentType = 'application/json'
            switch ( $action ) {
                'assign' {
                    $newaction = $action
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
                    $BodyParams.Add( 'owner' , $owner )
                }
                'CustomAction' {
                    $newaction = "actions/$( $PSBoundParameters['CustomAction'] )"
                }
                'description' {
                    $newaction = $action
                    $BodyParams.Add( 'description', $PSBoundParameters['description'] )
                }
                'snooze' {
                    $newaction = $action
                    $BodyParams.Add( 'endTime' , ( Get-Date ( Get-Date $PSBoundParameters['endTime'] ).ToUniversalTime() -UFormat '+%Y-%m-%dT%H:%M:%S.000Z' ) )
                }
            }
            if ( $newaction -ne 'attachments' ) {
                $body = $BodyParams | ConvertTo-Json
            }

            if ( [boolean]$EU ) {
                $URI = "https://api.eu.opsgenie.com/v2/alerts/$( $identifier )/$( $newaction )"
            }
            else {
                $URI = "https://api.opsgenie.com/v2/alerts/$( $identifier )/$( $newaction )"
            }

            $InvokeParams = @{
                'Headers'     = @{
                    "Authorization" = "GenieKey $APIKey"
                }
                'Uri'         = $URI
                'ContentType' = $ContentType
                'Body'        = $body
                'Method'      = $Methode
            }
            if ( [boolean]$Proxy ) {
                $InvokeParams.Add('Proxy', $Proxy )
            }
            if ( [boolean]$ProxyCredential ) {
                $InvokeParams.Add('ProxyCredential', $ProxyCredential )
            }

            try {
                $request = Invoke-RestMethod @InvokeParams
                $ret = $request
            }
            catch {
                $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
                $ErrResp = $streamReader.ReadToEnd() | ConvertFrom-Json
                $ErrResp
                $streamReader.Close()
                $err = $_.Exception
                $err.Message
                $err.Response
                $err.Status
            }

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
