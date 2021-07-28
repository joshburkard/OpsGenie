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
        [ValidateSet('acknowledge',
                     'AddNote',
                     'AddResponder',
                     'AddTags',
                     'AddTeam',
                     'assign',
                     'close',
                     'CustomAction',
                     'escalate',
                     'priority',
                     'RemoveTags',
                     'snooze',
                     'unacknowledge')]
        [string]$action
        ,
        [string]$user
        ,
        [string]$source
    )
    DynamicParam {
        $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        $Attribute = New-Object System.Management.Automation.ParameterAttribute
        if ($action -eq "AddNote") {
            $Attribute.Mandatory = $true
        }
        else {
            $Attribute.Mandatory = $false
        }
        $Attribute.HelpMessage = "Additional alert note to add."
        $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $attributeCollection.Add($Attribute)
        $Param = New-Object System.Management.Automation.RuntimeDefinedParameter('note', [string], $attributeCollection)
        $paramDictionary.Add('note', $Param)

        if ($action -eq "AddResponder") {
            $Attribute = New-Object System.Management.Automation.ParameterAttribute
            $Attribute.Mandatory = $true
            $Attribute.HelpMessage = "type of responder, team or user"
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeCollection.Add($Attribute)
            $arrSet = @( 'team', 'user')
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
            $attributeCollection.Add($ValidateSetAttribute)
            $Param = New-Object System.Management.Automation.RuntimeDefinedParameter('responderType', [string], $attributeCollection)
            $paramDictionary.Add('responderType', $Param)

            $Attribute = New-Object System.Management.Automation.ParameterAttribute
            $Attribute.Mandatory = $true
            $Attribute.HelpMessage = "Team or user that the alert will be routed to."
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeCollection.Add($Attribute)
            $Param = New-Object System.Management.Automation.RuntimeDefinedParameter('responder', [string], $attributeCollection)
            $paramDictionary.Add('responder', $Param)

        }
        if ($action -eq "AddTeam") {
            $Attribute = New-Object System.Management.Automation.ParameterAttribute
            $Attribute.Mandatory = $true
            $Attribute.HelpMessage = "Team to route the alert. Either id or name of the team should be provided. You can refer below for example values."
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeCollection.Add($Attribute)
            $Param = New-Object System.Management.Automation.RuntimeDefinedParameter('team', [string], $attributeCollection)
            $paramDictionary.Add('team', $Param)
        }
        if ($action -in @( 'AddTags', 'RemoveTags') ) {
            $Attribute = New-Object System.Management.Automation.ParameterAttribute
            $Attribute.Mandatory = $true
            if ( $action -eq 'AddTags' ) {
                $Attribute.HelpMessage = "List of tags to add into alert."
            }
            else {
                $Attribute.HelpMessage = "List of tags to remove from alert."
            }
            $ValidateLengthAttribute = New-Object System.Management.Automation.ValidateLengthAttribute(1,50)
            $ValidateCountAttribute = New-Object System.Management.Automation.ValidateCountAttribute(1,10)
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeCollection.Add($Attribute)
            $attributeCollection.Add($ValidateLengthAttribute)
            $attributeCollection.Add($ValidateCountAttribute)
            $Param = New-Object System.Management.Automation.RuntimeDefinedParameter('tags', [string[]], $attributeCollection)
            $paramDictionary.Add('tags', $Param)
        }
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
        if ($action -eq "escalate") {
            $Attribute = New-Object System.Management.Automation.ParameterAttribute
            $Attribute.Mandatory = $true
            $Attribute.HelpMessage = "Escalation that the alert will be escalated. Either id or name of the escalation should be provided."
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeCollection.Add($Attribute)
            $Param = New-Object System.Management.Automation.RuntimeDefinedParameter('EscalationTarget', [string], $attributeCollection)
            $paramDictionary.Add('EscalationTarget', $Param)
        }
        if ($action -eq "priority") {
            $Attribute = New-Object System.Management.Automation.ParameterAttribute
            $Attribute.Mandatory = $true
            $Attribute.HelpMessage = "Enter the End Date Time"
            $arrSet = @( 'P1', 'P2', 'P3', 'P4', 'P5')
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeCollection.Add($Attribute)
            $attributeCollection.Add($ValidateSetAttribute)
            $Param = New-Object System.Management.Automation.RuntimeDefinedParameter('priority', [string], $attributeCollection)
            $paramDictionary.Add('priority', $Param)
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
                if ( [boolean]$Proxy ) {
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
            switch ( $action ) {
                'AddNote' {
                    $action = "notes"
                }
                'AddResponder' {
                    $action = 'responders'
                    if ( Test-OpsGenieIsGuid -ObjectGuid $PSBoundParameters['responder'] ) {
                        $responder = @{
                            type = $PSBoundParameters['responderType']
                            id = $PSBoundParameters['responder']
                        }
                    }
                    elseif ( $PSBoundParameters['responderType'] -eq 'user' ) {
                        $responder = @{
                            type = $PSBoundParameters['responderType']
                            user = $PSBoundParameters['responder']
                        }
                    }
                    else {
                        $responder = @{
                            type = $PSBoundParameters['responderType']
                            team = $PSBoundParameters['responder']
                        }
                    }
                    $BodyParams.Add( 'responder' , $responder )

                }
                'AddTags' {
                    $action = "tags"
                    $BodyParams.Add( 'tags' , $tags )
                }
                'AddTeam' {
                    $action = 'teams'
                    if ( Test-OpsGenieIsGuid -ObjectGuid $PSBoundParameters['team'] ) {
                        $team = @{
                            id = $PSBoundParameters['team']
                        }
                    }
                    else {
                        $team = @{
                            name = $PSBoundParameters['team']
                        }
                    }
                    $BodyParams.Add( 'team' , $team )
                }
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
                    $BodyParams.Add( 'owner' , $owner )
                }
                'CustomAction' {
                    $action = "actions/$( $PSBoundParameters['CustomAction'] )"
                }
                'escalate' {
                    if ( Test-OpsGenieIsGuid -ObjectGuid $PSBoundParameters['EscalationTarget'] ) {
                        $escalation = @{
                            id = $PSBoundParameters['EscalationTarget']
                        }
                    }
                    else {
                        $escalation = @{
                            username = $PSBoundParameters['EscalationTarget']
                        }
                    }
                    $BodyParams.Add( 'escalation' , $escalation )
                }
                'priority' {
                    $BodyParams.Add( 'priority', $PSBoundParameters['priority'] )
                }
                'RemoveTags' {
                    $action = "tags"
                    $BodyParams.Add( 'tags' , $tags )
                    $Methode = 'DELETE'
                }
                'snooze' {
                    $BodyParams.Add( 'endTime' , ( Get-Date ( Get-Date $PSBoundParameters['endTime'] ).ToUniversalTime() -UFormat '+%Y-%m-%dT%H:%M:%S.000Z' ) )
                }
            }
            $body = $BodyParams | ConvertTo-Json


            if ( [boolean]$EU ) {
                $URI = "https://api.eu.opsgenie.com/v2/alerts/$( $identifier )/$( $action )"
            }
            else {
                $URI = "https://api.opsgenie.com/v2/alerts/$( $identifier )/$( $action )"
            }

            $InvokeParams = @{
                'Headers'     = @{
                    "Authorization" = "GenieKey $APIKey"
                }
                'Uri'         = $URI
                'ContentType' = 'application/json'
                'Body'        = $body
                'Method'      = $Methode
            }
            if ( [boolean]$Proxy ) {
                $InvokeParams.Add('Proxy', $Proxy )
            }
            if ( [boolean]$ProxyCredential ) {
                $InvokeParams.Add('ProxyCredential', $ProxyCredential )
            }

            $request = Invoke-RestMethod @InvokeParams
            $ret = $request
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
