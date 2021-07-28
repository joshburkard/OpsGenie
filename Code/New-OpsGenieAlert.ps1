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
