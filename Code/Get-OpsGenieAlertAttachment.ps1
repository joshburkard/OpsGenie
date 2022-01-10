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
        $URIPart = "alerts/$( $alias )/attachments"
        $IDType = Get-OpsGenieGuidType -id $alias
        if ( $IDType -ne 'identifier' ) {
            $URIPart = "${URIPart}?alertIdentifierType=${IDType}"
        }
        $InvokeParams = @{
            URIPart     = $URIPart
            Method = 'GET'
        }
        # $InvokeParams.add('APIKey', $APIKeySMA )
        # $InvokeParams.add('EU', $true )

        foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -in @('APIKey', 'EU', 'Proxy', 'ProxyCredential', 'wait' ) } ) ) {
            $InvokeParams.Add( $Key , $PSBoundParameters."$( $Key )")
        }

        $result = Invoke-OpsGenieWebRequest @InvokeParams -PostParams $PostParams

        $attachments = @()
        # $item = @( $result.data )[0]
        foreach ( $item in @( $result.data ) ) {
            Write-Verbose $item.id
            $URIPart = "alerts/$( $alias )/attachments/$( $item.id )"
            if ( $IDType -ne 'identifier' ) {
                $URIPart = "${URIPart}?alertIdentifierType=${IDType}"
            }
            $InvokeParams = @{
                URIPart     = $URIPart
                Method = 'GET'
            }
            # $InvokeParams.add('APIKey', $APIKeySMA )
            # $InvokeParams.add('EU', $true )

            foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -in @('APIKey', 'EU', 'Proxy', 'ProxyCredential', 'wait' ) } ) ) {
                $InvokeParams.Add( $Key , $PSBoundParameters."$( $Key )")
            }

            $result = Invoke-OpsGenieWebRequest @InvokeParams -PostParams $PostParams
            $attachments += [PSCustomObject]@{
                Name = $result.data.name
                url = $result.data.url
                id = $item.id
            }

        }

        # $result.data | ConvertTo-Json

        return $attachments

        <#

        $InvokeParams = @{
            URIPart     = 'alerts'
            action      = 'attachments'
            Method      = 'GET'
            IDTypeParam = 'alertIdentifierType'
        }
        foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -in @('APIKey', 'EU', 'Proxy', 'ProxyCredential','alias' ) } ) ) {
            $InvokeParams.Add( $Key , $PSBoundParameters."$( $Key )")
        }

        $ret = Invoke-OpsGenieWebRequest @InvokeParams
        #>
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
    if ( $ret.StatusCode -eq 200 ) {
        return $ret.data
    }
    else {
        throw $ret
    }
}