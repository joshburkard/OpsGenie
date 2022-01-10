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
        $URIPart = "alerts/$( $alias )"
        $IDType = Get-OpsGenieGuidType -id $alias
        if ( $IDType -ne 'identifier' ) {
            $URIPart = "${URIPart}?identifierType=${IDType}"
        }
        $InvokeParams = @{
            URIPart     = $URIPart
            Method = 'GET'
        }

        foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -in @('APIKey', 'EU', 'Proxy', 'ProxyCredential', 'wait' ) } ) ) {
            $InvokeParams.Add( $Key , $PSBoundParameters."$( $Key )")
        }

        $result = Invoke-OpsGenieWebRequest @InvokeParams -PostParams $PostParams
        # $result.data | ConvertTo-Json

        if ( $result.StatusCode -eq 200 ) {
            $ret = $result.data
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
