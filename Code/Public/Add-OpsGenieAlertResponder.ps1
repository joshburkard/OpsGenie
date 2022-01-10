function Add-OpsGenieAlertResponder {
    <#
        .SYNOPSIS
            This function add a new responder to an already existing alert in OpsGenie

        .DESCRIPTION
            This function add a new responder to an already existing alert in OpsGenie through the API v2

            more info about the API under https://docs.opsgenie.com/docs/alert-api

        .PARAMETER APIKey
            The APIKey from OpsGenie

        .PARAMETER EU
            if this switch parameter is set, the function will connect to API URI in EU otherwise, the global URI

        .PARAMETER Proxy
            defines the proxy server to use

        .PARAMETER ProxyCredential
            defines the credential for the Proxy-Server

        .PARAMETER alias
            Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.

            this string parameter is mandatory, it will accept 512 chars

        .PARAMETER ResponderType
            the type of the responder, user or team

            this string parameter is mandatory

        .PARAMETER Responder
            the name or id of the responder

            this string parameter is mandatory

        .EXAMPLE
            Add-OpsGenieAlertResponder -APIKey $APIKey -EU -alias $alias -responderType user -responder $UserMail

        .EXAMPLE
            Add-OpsGenieAlertResponder -APIKey $APIKey -EU -alias $alias -responderType team -responder $TeamName

        .NOTES
            Date, Author, Version, Notes
            28.11.2021, Josua Burkard, 0.0.00001, initial creation

    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$APIKey
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
        [ValidateLength(1,512)][string]$alias
        ,
        [Parameter(Mandatory=$true)]
        [ValidateSet('user','team')]
        [string]$responderType
        ,
        [Parameter(Mandatory=$true)]
        [string]$responder
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
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"
    try {
        $URIPart = "alerts/$( $alias )/responders"
        $IDType = Get-OpsGenieGuidType -id $alias
        if ( $IDType -ne 'identifier' ) {
            $URIPart = "${URIPart}?identifierType=${IDType}"
        }
        $InvokeParams = @{
            URIPart     = $URIPart
            # action      = 'responders'
            Method      = 'POST'
            # alias       = $alias
            # APIKey = $APIKey
            # EU = $true
        }

        foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -in @('APIKey', 'EU', 'Proxy', 'ProxyCredential', 'wait' ) } ) ) {
            $InvokeParams.Add( $Key , $PSBoundParameters."$( $Key )")
        }

        $PostParams = @{}
        <#
        foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -notin @('APIKey', 'EU', 'Proxy', 'ProxyCredential', 'alias', 'wait' ) } ) ) {
            $PostParams.Add( $Key , $PSBoundParameters."$( $Key )")
        }
        #>
        # $PostParams.Add( 'responderType', 'team' )
        # $PostParams.Add( 'responder', 'Test-001' )

        if ( $responderType -eq 'user' ) {
            if ( Test-OpsGenieIsGuid -ObjectGuid $responder ) {
                $responderobj = @{
                    type = $responderType
                    id = $responder
                }
            }
            else {
                $responderobj = @{
                    type = $responderType
                    username = $responder
                }
            }
        }
        else {
            if ( Test-OpsGenieIsGuid -ObjectGuid $responder ) {
                $responderobj = @{
                    type = $responderType
                    id = $responder
                }
            }
            else {
                $responderobj = @{
                    type = $responderType
                    name = $responder
                }
            }
        }
        Write-Verbose ( $responderobj | ConvertTo-Json )
        $PostParams.Add( 'responder' , $responderobj )

        $InvokeParams.Add( 'PostParams', $PostParams )

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