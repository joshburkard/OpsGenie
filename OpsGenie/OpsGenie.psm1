<#
    Generated at 07/28/2021 18:37:24 by Josh Burkard (josh@burkard.it)
#>
#region namespace OpsGenie
function Get-OpsGenieAlert {
    <#
        .SYNOPSIS
            This function creates a new alert in OpsGenie

        .DESCRIPTION
            This function creates a new alert in OpsGenie through the API v2

            more info about the API under https://docs.opsgenie.com/docs/alert-api

        .PARAMETER APIKey
            The APIKey from OpsGenie

        .PARAMETER alias
            Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.

            this string parameter is not mandatory but should be used, it will accept 512 chars

        .PARAMETER identifier
            Identifier of the alert

        .PARAMETER EU
            if this switch parameter is set, the function will connect to API URI in EU otherwise, the global URI

        .PARAMETER Proxy
            defines the proxy server to use

        .PARAMETER ProxyCredential
            defines the credential for the Proxy-Server

        .EXAMPLE
            Get-SomeSettings.ps1 -Param1 'run'

        .NOTES
            Date, Author, Version, Notes
            27.07.2021, Josua Burkard, 0.0.00001, initial creation

    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$APIKey
        ,
        [Parameter(Mandatory=$false)]
        [ValidateLength(1,512)][string]$alias
        ,
        [Parameter(Mandatory=$false)]
        [string]$identifier
        ,
        [switch]$EU
        ,
        [Parameter(Mandatory=$false)]
        [string]$Proxy
        ,
        [Parameter(Mandatory=$false)]
        [System.Management.Automation.PSCredential]$ProxyCredential
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"
    try {
        if ( [boolean]$EU ) {
            $URI = "https://api.eu.opsgenie.com/v2/alerts"
        }
        else {
            $URI = "https://api.opsgenie.com/v2/alerts"
        }

        $InvokeParams = @{
            'Headers'     = @{
                "Authorization" = "GenieKey $APIKey"
            }
            'Uri'         = $URI
            'ContentType' = 'application/json'
            'Method'      = 'GET'
        }
        if ( [boolean]$Proxy ) {
            $InvokeParams.Add('Proxy', $Proxy )
        }
        if ( [boolean]$ProxyCredential ) {
            $InvokeParams.Add('ProxyCredential', $ProxyCredential )
        }

        $request = Invoke-RestMethod @InvokeParams
        $datas = $request.data
        if ( [boolean]$alias ) {
            $datas = $datas | Where-Object { $_.alias -eq $alias }
        }
        elseif ( [boolean]$identifier ) {
            $datas = $datas | Where-Object { $_.id -eq $identifier }
        }
        $ret = $datas
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
function New-OpsGenieAlert {
    <#
        .SYNOPSIS
            This function creates a new alert in OpsGenie

        .DESCRIPTION
            This function creates a new alert in OpsGenie through the API v2

            more info about the API under https://docs.opsgenie.com/docs/alert-api

        .PARAMETER APIKey
            The APIKey from OpsGenie

        .PARAMETER message
            The Message for the OpsGenie Alert

            this string parameter is mandatory and accepts max 130 chars

        .PARAMETER responders
            Teams, users, escalations and schedules that the alert will be routed to send notifications. type field is mandatory for each item,
            where possible values are team, user, escalation and schedule. If the API Key belongs to a team integration, this field will be
            overwritten with the owner team. Either id or name of each responder should be provided.You can refer below for example values.

            this parameter is mandatory and should be an hash array like this
            @(
                @{
                    name = "Team-Name"
                    type = "team"
                },
                @{
                    username = "trinity@opsgenie.com"
                    type = "team"
                }
            )

            this parameter accepts max. 50 teams or users in total

        .PARAMETER alias
            Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.

            this string parameter is not mandatory but should be used, it will accept 512 chars

        .PARAMETER description
            Description field of the alert that is generally used to provide a detailed information about the alert.

            this string parameter is not mandatory, it will accept 15000 chars

        .PARAMETER visibleTo
            Teams and users that the alert will become visible to without sending any notification.type field is mandatory for each item,
            where possible values are team and user. In addition to the type field, either id or name should be given for teams and either id or
            username should be given for users. Please note: that alert will be visible to the teams that are specified withinresponders field by
            default, so there is no need to re-specify them within visibleTo field. You can refer below for example values.

            this parameter is not mandatory and should be an hash array like this
            @(
                @{
                    name = "Team-Name"
                    type = "team"
                },
                @{
                    username = "trinity@opsgenie.com"
                    type = "team"
                }
            )

            this parameter accepts max. 50 teams or users in total

        .PARAMETER actions
            Custom actions that will be available for the alert.

            this string array parameter is not mandatory and accepts 10 x 50 characters

        .PARAMETER tags
            Tags of the alert.

            this string array parameter is not mandatory and accepts 20 x 50 characters

        .PARAMETER details
            Map of key-value pairs to use as custom properties of the alert.

            this parameter is not mandatory and accepts an hashtable with 8000 characters in total

        .PARAMETER entity
            Entity field of the alert that is generally used to specify which domain alert is related to.

            this string parameter is not mandatory and accepts 512 characters

        .PARAMETER source
            Source field of the alert. Default value is IP address of the incoming request.

            this string parameter is not mandatory and accepts 100 characters

        .PARAMETER priority
            Priority level of the alert. Possible values are P1, P2, P3, P4 and P5.

            this parameter is not mandatory. the Default value is P3.

        .PARAMETER user
            Display name of the request owner.

            this string parameter is not mandatory and accepts 100 characters.

        .PARAMETER note
            Additional note that will be added while creating the alert.

            this string parameter is not mandatory and accepts 25000 characters.

        .PARAMETER EU
            if this switch parameter is set, the function will connect to API URI in EU otherwise, the global URI

        .PARAMETER Proxy
            defines the proxy server to use

        .PARAMETER ProxyCredential
            defines the credential for the Proxy-Server

        .EXAMPLE
            Get-SomeSettings.ps1 -Param1 'run'

        .NOTES
            Date, Author, Version, Notes
            27.07.2021, Josua Burkard, 0.0.00001, initial creation

    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$APIKey
        ,
        [Parameter(Mandatory=$true)]
        [ValidateLength(1,130)][string]$message
        ,
        [Parameter(Mandatory=$true)]
        [ValidateCount(1,50)][Array]$responders
        ,
        [Parameter(Mandatory=$false)]
        [ValidateLength(1,512)][string]$alias
        ,
        [Parameter(Mandatory=$false)]
        [ValidateLength(1,15000)][string]$description
        ,
        [Parameter(Mandatory=$false)]
        [ValidateCount(1,50)][Array]$visibleTo
        ,
        [Parameter(Mandatory=$false)]
        [ValidateCount(1,10)][ValidateLength(1,50)][string[]]$actions
        ,
        [Parameter(Mandatory=$false)]
        [ValidateCount(1,20)][ValidateLength(1,50)][string[]][string[]]$tags
        ,
        [Parameter(Mandatory=$false)]
        [object]$details
        ,
        [Parameter(Mandatory=$false)]
        [ValidateLength(1,512)][string]$entity
        ,
        [Parameter(Mandatory=$false)]
        [ValidateLength(1,100)][string]$source
        ,
        [Parameter(Mandatory=$false)]
        [ValidateSet("P1","P2","P3","P4","P5")]
        [string]$priority
        ,
        [Parameter(Mandatory=$false)]
        [ValidateLength(1,100)][string]$user
        ,
        [Parameter(Mandatory=$false)]
        [ValidateLength(1,25000)][string]$note
        ,
        [switch]$EU
        ,
        [Parameter(Mandatory=$false)]
        [string]$Proxy
        ,
        [Parameter(Mandatory=$false)]
        [System.Management.Automation.PSCredential]$ProxyCredential
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"
    try {
        if ( [boolean]$EU ) {
            $URI = "https://api.eu.opsgenie.com/v2/alerts"
        }
        else {
            $URI = "https://api.opsgenie.com/v2/alerts"
        }

        $BodyParams = @{}
        foreach ( $Key in $PSBoundParameters.Keys | Where-Object { $_ -notin @('APIKey', 'Proxy', 'ProxyCredential', 'EU') } ) {
            $BodyParams.Add( $Key , $PSBoundParameters."$( $Key )")
        }
        $body = $BodyParams | ConvertTo-Json

        $InvokeParams = @{
            'Headers'     = @{
                "Authorization" = "GenieKey $APIKey"
            }
            'Uri'         = $URI
            'ContentType' = 'application/json'
            'Body'        = $body
            'Method'      = 'POST'
        }
        if ( [boolean]$Proxy ) {
            $InvokeParams.Add('Proxy', $Proxy )
        }
        if ( [boolean]$ProxyCredential ) {
            $InvokeParams.Add('ProxyCredential', $ProxyCredential )
        }

        $request = Invoke-RestMethod @InvokeParams
        $ret = $request.requestId
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
function Test-OpsGenieIsGuid {
    <#
        .SYNOPSIS
            This function checks if a string contains a GUID

        .DESCRIPTION
            This function checks if a string contains a GUID

        .PARAMETER ObjectGuid
            the string to check

        .EXAMPLE
            Test-OpsGenieIsGuid -ObjectGuid 'TestString'                           # returns false
            Test-OpsGenieIsGuid -ObjectGuid 'a50ccfd6-892d-491d-8f01-a5a4c6758705' # returns true

        .NOTES
            Date, Author, Version, Notes
            28.07.2021, Josua Burkard, 0.0.00001, initial creation

    #>

    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$ObjectGuid
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"
    try {

        # Define verification regex
        [regex]$guidRegex = '(?im)^[{(]?[0-9A-F]{8}[-]?(?:[0-9A-F]{4}[-]?){3}[0-9A-F]{12}[)}]?$'

        # Check guid against regex
        return $ObjectGuid -match $guidRegex
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
#endregion
