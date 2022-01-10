function Set-OpsGenieAlertEscalation {
    <#
        .SYNOPSIS
            This function escalates an alert in OpsGenie to an escalation group

        .DESCRIPTION
            This function escalates an alert in OpsGenie to an escalation group

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

        .PARAMETER priority
            Priority level of the alert. Possible values are P1, P2, P3, P4 and P5.

            this parameter is not mandatory. the Default value is P3.

        .EXAMPLE
            Set-OpsGenieAlertPriority -APIKey $APIKey -EU -alias $Alias -priority P4

        .NOTES
            Date, Author, Version, Notes
            28.07.2021, Josua Burkard, 0.0.00001, initial creation

    #>

    [CmdletBinding()]
    Param (
        [parameter(Mandatory=$true,ParameterSetName="id")]
        [parameter(Mandatory=$true,ParameterSetName="name")]
        [string]$APIKey
        ,
        [parameter(Mandatory=$false,ParameterSetName="id")]
        [parameter(Mandatory=$false,ParameterSetName="name")]
        [switch]$EU
        ,
        [parameter(Mandatory=$false,ParameterSetName="id")]
        [parameter(Mandatory=$false,ParameterSetName="name")]
        [string]$Proxy
        ,
        [parameter(Mandatory=$false,ParameterSetName="id")]
        [System.Management.Automation.PSCredential]$ProxyCredential
        ,
        [parameter(Mandatory=$true,ParameterSetName="id")]
        [parameter(Mandatory=$true,ParameterSetName="name")]
        [ValidateLength(1,512)][string]$alias
        ,
        [parameter(Mandatory=$false,ParameterSetName="id")]
        [string]$id
        ,
        [parameter(Mandatory=$false,ParameterSetName="name")]
        [string]$name
        ,
        [parameter(Mandatory=$false,ParameterSetName="id")]
        [parameter(Mandatory=$false,ParameterSetName="name")]
        [switch]$wait
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"
    try {
        $URIPart = "alerts/$( $alias )/escalate"
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
        foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -notin @('APIKey', 'EU', 'Proxy', 'ProxyCredential', 'alias', 'wait', 'name','id' ) } ) ) {
            $PostParams.Add( $Key , $PSBoundParameters."$( $Key )")
        }

        if ( [boolean]$id ) {
            $PostParams.Add( 'escalation' , @{ id = $id } )
        }
        if ( [boolean]$name ) {
            $PostParams.Add( 'escalation' , @{ name = $name } )
        }

        $InvokeParams.Add( 'PostParams', $PostParams )


        $ret = Invoke-OpsGenieWebRequest @InvokeParams

        return $ret

        <#


        if ( [boolean]$EU ) {
            $URI = "https://api.eu.opsgenie.com/v2/alerts/$( $alias )/escalate?identifierType=alias"
        }
        else {
            $URI = "https://api.opsgenie.com/v2/alerts/$( $alias )/escalate?identifierType=alias"
        }

        $BodyParams = @{}
        if ( [boolean]$id ) {
            $BodyParams.Add( 'escalation' , @{ id = $id } )
        }
        if ( [boolean]$name ) {
            $BodyParams.Add( 'escalation' , @{ name = $name } )
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
