function Add-OpsGenieAlertDetails {
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
        ,
        [switch]$wait
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"
    try {
        $URIPart = "alerts/$( $alias )/details"
        $IDType = Get-OpsGenieGuidType -id $alias
        if ( $IDType -ne 'identifier' ) {
            $URIPart = "${URIPart}?identifierType=${IDType}"
        }
        $InvokeParams = @{
            URIPart     = $URIPart
            Method      = 'POST'
        }

        foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -in @('APIKey', 'EU', 'Proxy', 'ProxyCredential', 'wait' ) } ) ) {
            $InvokeParams.Add( $Key , $PSBoundParameters."$( $Key )")
        }

        $PostParams = @{}
        foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -notin @('APIKey', 'EU', 'Proxy', 'ProxyCredential', 'alias', 'wait', 'team' ) } ) ) {
            $PostParams.Add( $Key , $PSBoundParameters."$( $Key )")
        }

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