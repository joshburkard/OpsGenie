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
            $alert = Get-OpsGenieAlert -APIKey $APIKey -EU -alias $alias

        .EXAMPLE
            $alert = Get-OpsGenieAlert -APIKey $APIKey -EU -identifier $identifier

        .EXAMPLE
            $alerts = Get-OpsGenieAlert -APIKey $APIKey -EU

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
        [string]$Proxy
        ,
        [Parameter(Mandatory=$false)]
        [System.Management.Automation.PSCredential]$ProxyCredential
        ,
        [switch]$EU
        ,
        [Parameter(Mandatory=$false)]
        [ValidateLength(1,512)][string]$alias
        ,
        [Parameter(Mandatory=$false)]
        [string]$identifier
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"
    try {
        if ( -not [boolean]$identifier ) {
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

            try {
                $request = Invoke-RestMethod @InvokeParams
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

            $datas = $request.data
            if ( [boolean]$alias ) {
                $datas = $datas | Where-Object { $_.alias -eq $alias }
                $identifier = $datas.id
            }
            else {
                $identifier = $null
            }
        }
        if ( [boolean]$identifier ) {
            if ( [boolean]$EU ) {
                $URI = "https://api.eu.opsgenie.com/v2/alerts/$( $identifier )"
            }
            else {
                $URI = "https://api.opsgenie.com/v2/alerts/$( $identifier )"
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

            try {
                $request = Invoke-RestMethod @InvokeParams
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
            $datas = $request.data
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
