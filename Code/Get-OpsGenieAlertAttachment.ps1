function Get-OpsGenieAlertAttachment {
    <#
        .SYNOPSIS
            This function receives all attachments from an existing alert in OpsGenie

        .DESCRIPTION
            This function receives all attachments from an existing alert in OpsGenie through the API v2

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

        .EXAMPLE
            Get-OpsGenieAlertAttachment -APIKey $APIKey -EU -alias $Alias

        .NOTES
            Date, Author, Version, Notes
            28.07.2021, Josua Burkard, 0.0.00001, initial creation

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
            $URI = "https://api.eu.opsgenie.com/v2/alerts/$( $identifier )/attachments"
        }
        else {
            $URI = "https://api.opsgenie.com/v2/alerts/$( $identifier )/attachments/"
        }

        if ( [boolean]$Proxy ) {
            [System.Net.Http.HttpClient]::DefaultProxy = New-Object System.Net.WebProxy($Proxy)
        }
        if ( [boolean]$ProxyCredential ) {
            [System.Net.Http.HttpClient]::DefaultProxy.Credentials = $ProxyCredential
        }

        $InvokeParams = @{
            'Headers'     = @{
                "Authorization" = "GenieKey $APIKey"
            }
            'Uri'         = $URI
            'Method'      = 'GET'
        }
        try {
            $res = Invoke-RestMethod @InvokeParams
        }
        catch {
            $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
            $ErrResp = $streamReader.ReadToEnd() | ConvertFrom-Json
            $streamReader.Close()
            $err = $_.Exception
            $ret = @{
                ErrResp = $ErrResp
                Message = $err.Message
                Response = $err.Response
                Status = $err.Status
            }
            throw $ret
        }
        $ids = $res.data.id

        $results = @()
        # $id = @( $ids  )[0]
        foreach ( $id in $ids ) {
            $results += ( Invoke-RestMethod -Method Get -Uri "$( $URI )/$( $id )" -Headers $InvokeParams.Headers ).data | Select-Object @{ Name = 'id'; Expression = { $id } }, name, url
        }
        $ret = $results
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