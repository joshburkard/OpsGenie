function Set-OpsGenieAlertDetails {
    <#
        .SYNOPSIS
            This function add additional details (custom propwerties) to an already existing alert in OpsGenie

        .DESCRIPTION
            This function add additional details (custom propwerties) to an already existing alert in OpsGenie through the API v2

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

        .PARAMETER details
            defines the new details as hash table

            this hashtable parameter is mandatory

        .EXAMPLE
            Add-OpsGenieAlertDetails -APIKey $APIKey -EU -alias $alias -details @{ 'Test-1' = 'this is a first test property'; 'Test-2' = 'this is a second test property'}

        .NOTES
            Date, Author, Version, Notes
            28.11.2021, Josua Burkard, 0.0.00001, initial creation

    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,ParameterSetName="byAlias")]
        [Parameter(Mandatory=$true,ParameterSetName="byID")]
        [string]$APIKey
        ,
        [Parameter(Mandatory=$true,ParameterSetName="byAlias")]
        [Parameter(Mandatory=$true,ParameterSetName="byID")]
        [switch]$EU
        ,
        [Parameter(Mandatory=$false,ParameterSetName="byAlias")]
        [Parameter(Mandatory=$false,ParameterSetName="byID")]
        [string]$Proxy
        ,
        [Parameter(Mandatory=$false,ParameterSetName="byAlias")]
        [Parameter(Mandatory=$false,ParameterSetName="byID")]
        [System.Management.Automation.PSCredential]$ProxyCredential
        ,
        [Parameter(Mandatory=$true,ParameterSetName="byAlias")]
        [ValidateLength(1,512)][string]$alias
        ,
        [Parameter(Mandatory=$true,ParameterSetName="byID")]
        [string]$identifier
        ,
        [Parameter(Mandatory=$true,ParameterSetName="byAlias")]
        [Parameter(Mandatory=$true,ParameterSetName="byID")]
        [hashtable]$details
        ,
        [Parameter(Mandatory=$false,ParameterSetName="byAlias")]
        [Parameter(Mandatory=$false,ParameterSetName="byID")]
        [string]$note
        ,
        [Parameter(Mandatory=$false,ParameterSetName="byAlias")]
        [Parameter(Mandatory=$false,ParameterSetName="byID")]
        [string]$user
        ,
        [Parameter(Mandatory=$false,ParameterSetName="byAlias")]
        [Parameter(Mandatory=$false,ParameterSetName="byID")]
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
            $URI = "https://api.eu.opsgenie.com/v2/alerts/$( $identifier )/details"
        }
        else {
            $URI = "https://api.opsgenie.com/v2/alerts/$( $identifier )/details"
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
        $BodyParams.Add('details', $details )
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