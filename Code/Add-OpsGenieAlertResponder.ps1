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
    )
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
        if ( [boolean]$EU ) {
            $URI = "https://api.eu.opsgenie.com/v2/alerts/$( $identifier )/responders"
        }
        else {
            $URI = "https://api.opsgenie.com/v2/alerts/$( $identifier )/responders"
        }

        if ( [boolean]$Proxy ) {
            [System.Net.Http.HttpClient]::DefaultProxy = New-Object System.Net.WebProxy($Proxy)
        }
        if ( [boolean]$ProxyCredential ) {
            [System.Net.Http.HttpClient]::DefaultProxy.Credentials = $ProxyCredential
        }

        $BodyParams = @{}
        foreach ( $Key in $PSBoundParameters.Keys | Where-Object { $_ -in @('user', 'source', 'note') } ) {
            $BodyParams.Add( $Key , $PSBoundParameters."$( $Key )")
        }
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
        $BodyParams.Add( 'responder' , $responderobj )
        $body = $BodyParams | ConvertTo-Json

        $InvokeParams = @{
            'Headers'     = @{
                "Authorization" = "GenieKey $APIKey"
            }
            'Uri'         = $URI
            body = $body
            ContentType   = 'application/json'
            'Method'      = 'POST'
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