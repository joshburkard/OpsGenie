function Add-OpsGenieAlertAttachment {
    <#
        .SYNOPSIS
            This function add an attachment to an existing alert in OpsGenie

        .DESCRIPTION
            This function add an attachment to an existing alert in OpsGenie through the API v2

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

            this string parameter not mandatory, it will accept 512 chars

        .PARAMETER FilePath
            the path to the file to attache

            this string parameter is mandatory

        .EXAMPLE
            Add-OpsGenieAlertAttachment -APIKey $APIKey -EU -alias $Alias -FilePath $FilePath

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
        [string]$FilePath
        ,
        [Parameter(Mandatory=$false)]
        [ValidateLength(1,512)][string]$alias
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"
    try {
        $InvokeParams = @{
            URIPart     = 'alerts'
            Method      = 'GET'
            <#
            alias       = $alias
            APIKey = $APIKey
            EU = $true
            #>
        }
        foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -in @('alias', 'APIKey', 'EU', 'Proxy', 'ProxyCredential', 'wait' ) } ) ) {
            $InvokeParams.Add( $Key , $PSBoundParameters."$( $Key )")
        }
        $ret = Invoke-OpsGenieWebRequest @InvokeParams

        $CurrentProxy = [system.net.webrequest]::defaultwebproxy
        $CurrentSecurityProtocol = [Net.ServicePointManager]::SecurityProtocol
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        Add-Type -AssemblyName System.Net.Http

        if ( [boolean]$EU ) {
            $URI = "https://api.eu.opsgenie.com/v2/alerts/$( $ret.data.id )/attachments"
        }
        else {
            $URI = "https://api.opsgenie.com/v2/alerts/$( $ret.data.id )/attachments"
        }

        if ( [boolean]$Proxy ) {
            [System.Net.WebRequest]::DefaultWebProxy = New-Object System.Net.WebProxy($Proxy)
            # [System.Net.Http.HttpClient]::DefaultProxy = New-Object System.Net.WebProxy($Proxy)
            if ( [boolean]$ProxyCredential ) {
                [System.Net.WebRequest]::DefaultWebProxy.Credentials = $ProxyCredential
                # [System.Net.Http.HttpClient]::DefaultProxy.Credentials = $ProxyCredential
            }
        }
        else {
            $TempProxy = new-object System.Net.WebProxy
            [System.Net.WebRequest]::DefaultWebProxy = $TempProxy
        }
        Write-Verbose $URI
        $httpClient = New-Object System.Net.Http.HttpClient
        $arr = Get-Content $FilePath -Encoding Byte -ReadCount 0
        $binaryContent = New-Object System.Net.Http.ByteArrayContent -ArgumentList @(,$arr)
        $form = [System.Net.Http.MultipartFormDataContent]::new()
        $form.Add( $binaryContent, "file", ( [System.IO.FileInfo]$FilePath ).Name )
        $httpClient.DefaultRequestHeaders.Authorization = "GenieKey $APIKey"
        $request = $httpClient.PostAsync( $URI, $form )
        $contentJSON = $request.Result.Content.ReadAsStringAsync().Result
        $content = $contentJSON | ConvertFrom-Json

        [System.Net.WebRequest]::DefaultWebProxy = $CurrentProxy
        [Net.ServicePointManager]::SecurityProtocol = $CurrentSecurityProtocol

        return $content.result
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
