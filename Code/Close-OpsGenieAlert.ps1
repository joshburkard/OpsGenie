function Close-OpsGenieAlert {
    <#
        .SYNOPSIS
            This function acknowledge a existing alert in OpsGenie

        .DESCRIPTION
            This function acknowledge a existing alert in OpsGenie through the API v2

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

            this string parameter is not mandatory but should be used, it will accept 512 chars

        .PARAMETER note
            Additional note that will be added while creating the alert.

            this string parameter is not mandatory and accepts 25000 characters.

        .PARAMETER source
            Source field of the alert. Default value is IP address of the incoming request.

            this string parameter is not mandatory and accepts 100 characters

        .PARAMETER user
            Display name of the request owner.

            this string parameter is not mandatory and accepts 100 characters.

        .EXAMPLE
            Close-OpsGenieAlert -APIKey $APIKey -EU -alias $Alias

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
        [Parameter(Mandatory=$false)]
        [ValidateLength(1,512)][string]$alias
        ,
        [Parameter(Mandatory=$false)]
        [ValidateLength(1,100)][string]$source
        ,
        [Parameter(Mandatory=$false)]
        [ValidateLength(1,100)][string]$user
        ,
        [Parameter(Mandatory=$false)]
        [ValidateLength(1,25000)][string]$note
        ,
        [switch]$wait
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"
    try {
        $URIPart = "alerts/$( $alias )/close"
        $IDType = Get-OpsGenieGuidType -id $alias
        if ( $IDType -ne 'identifier' ) {
            $URIPart = "${URIPart}?identifierType=${IDType}"
        }
        $InvokeParams = @{
            URIPart     = $URIPart
            Method = 'POST'
        }

        foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -in @('APIKey', 'EU', 'Proxy', 'ProxyCredential', 'wait' ) } ) ) {
            $InvokeParams.Add( $Key , $PSBoundParameters."$( $Key )")
        }

        if ( $PSBoundParameters.Keys | Where-Object { $_ -notin @('APIKey', 'EU', 'Proxy', 'ProxyCredential', 'alias', 'wait' ) } ) {
            $PostParams = @{}
            foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -notin @('APIKey', 'EU', 'Proxy', 'ProxyCredential', 'alias', 'wait' ) } ) ) {
                $PostParams.Add( $Key , $PSBoundParameters."$( $Key )")
            }
            $InvokeParams.Add( 'PostParams', $PostParams )
        }

        $ret = Invoke-OpsGenieWebRequest @InvokeParams

        return $ret

        <#

            $CurrentProxy = [system.net.webrequest]::defaultwebproxy
        $CurrentSecurityProtocol = [Net.ServicePointManager]::SecurityProtocol
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
		if ( $alias ) {
            $Params = @{}
            foreach ( $Key in $PSBoundParameters.Keys | Where-Object { $_ -in @('APIKey', 'alias', 'EU', 'Proxy', 'ProxyCredential') } ) {
                $BodyParams.Add( $Key , $PSBoundParameters."$( $Key )")
            }
            $alert = Get-OpsGenieAlert @Params
            if ( [boolean]$alert ) {
                $identifier = $alert.id
            }
        }
        if ( [boolean]$EU ) {
            $URI = "https://api.eu.opsgenie.com/v2/alerts/$( $identifier )/close"
        }
        else {
            $URI = "https://api.opsgenie.com/v2/alerts/$( $identifier )/close"
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
            if ( [boolean]$ProxyCredential ) {
                $InvokeParams.Add('ProxyCredential', $ProxyCredential )
            }
        }
        else {
            $TempProxy = new-object System.Net.WebProxy
			[System.Net.WebRequest]::DefaultWebProxy = $TempProxy
        }

        try {
            $request = Invoke-RestMethod @InvokeParams
        }
        catch {
            $err = $_.Exception
            if ( [boolean]$_.Exception.Response ) {
                $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
                $ErrResp = $streamReader.ReadToEnd() | ConvertFrom-Json
                $streamReader.Close()
            }
            else {
                $ErrResp = 'Error ResponseStream is empty'
            }
            $ret = @{
                ErrResp = $ErrResp
                Message = $err.Message
                Response = $err.Response
                Status = $err.Status
            }
            throw $ret
        }

        [System.Net.WebRequest]::DefaultWebProxy = $CurrentProxy
        [Net.ServicePointManager]::SecurityProtocol = $CurrentSecurityProtocol
        $ret = $request.requestId
        return $ret
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
}
