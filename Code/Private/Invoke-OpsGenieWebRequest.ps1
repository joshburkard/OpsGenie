function Invoke-OpsGenieWebRequest {
    <#
        .SYNOPSIS
            This function receives all notes from an existing alert in OpsGenie

        .DESCRIPTION
            This function receives all notes from an existing alert in OpsGenie through the API v2

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
            Invoke-OpsGenieWebRequest -APIKey $APIKey -EU -Method GET -URIPart 'alerts' -identifier $identifier

        .EXAMPLE
            Invoke-OpsGenieWebRequest -APIKey $APIKey -EU -Method GET -URIPart 'alerts' -alias $alias

        .EXAMPLE
            Invoke-OpsGenieWebRequest -APIKey $APIKey -EU -Method GET -URIPart 'alerts'

        .NOTES
            Date, Author, Version, Notes
            28.07.2021, Josua Burkard, 0.0.00001, initial creation

    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$APIKey
        ,
        [Parameter(Mandatory=$false)]
        [switch]$EU
        ,
        [Parameter(Mandatory=$true)]
        [ValidateSet('GET','POST','DELETE')]
        [string]$Method = 'GET'
        ,
        [Parameter(Mandatory=$false)]
        [string]$Proxy
        ,
        [Parameter(Mandatory=$false)]
        [System.Management.Automation.PSCredential]$ProxyCredential
        ,
        [Parameter(Mandatory=$true)]
        [string]$URIPart = 'alerts'
        ,
        [Alias("identifier","tinyid")]
        [Parameter(Mandatory=$false)]
        [string]$alias
        ,
        [Parameter(Mandatory=$false)]
        [string]$action
        ,
        [Parameter(Mandatory=$false)]
        [string]$actionId
        ,
        [Parameter(Mandatory=$false)]
        [ValidateSet('identifierType', 'alertIdentifierType')]
        [string]$IDTypeParam = 'identifierType'
        ,
        [Parameter(Mandatory=$false)]
        [hashtable]$GetParams = @{}
        ,
        [Parameter(Mandatory=$false)]
        [hashtable]$PostParams = @{}
        ,
        [switch]$wait
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"
    try {
        <#
        if ( [boolean]$alias ) {
            Write-Verbose "alias $alias"
            $Params = @{
                # APIKey = $APIKey
                # EU = $true
            }
            foreach ( $Key in $PSBoundParameters.Keys | Where-Object { $_ -in @('APIKey', 'EU', 'Proxy', 'ProxyCredential') } ) {
                $Params.Add( $Key , $PSBoundParameters."$( $Key )")
            }
            $Params.Add('Method', 'GET')
            $Params.Add('URIPart', 'alerts')
            # $Params
            $result = Invoke-OpsGenieWebRequest @Params
            $datas = $result.data

            $datas = $datas | Where-Object { $_.alias -eq $alias }
            if ( [boolean]$datas ) {
                Write-Verbose "alias found"
                Write-Verbose $datas.id
                $identifier = $datas.id
            }
            else {
                Write-Verbose "alias not found"
                return
            }
        }
        #>
        $CurrentProxy = [system.net.webrequest]::defaultwebproxy
        $CurrentSecurityProtocol = [Net.ServicePointManager]::SecurityProtocol
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        if ( [boolean]$EU ) {
            $URI = "https://api.eu.opsgenie.com/v2/$( $URIPart )"
        }
        else {
            $URI = "https://api.opsgenie.com/v2/$( $URIPart )"
        }
        if ( [boolean]$alias ) {
            Write-Verbose "alias is $alias"
            $URI = "$( $URI )/$( $alias )"

            if ( [boolean]$action ) {
                Write-Verbose "action is $action"
                $URI = "$( $URI )/$( $action )"
                if ( [boolean]$actionId ) {
                    Write-Verbose "actionId is $actionId"
                    $URI = "$( $URI )/$( $actionId )"
                }
            }
        }

        if ( -not [boolean]$PostParams ) {
            Write-Verbose "PostParams not defined"
            $PostParams = @{}
        }
        <#
        if ( -not [boolean]$GetParams ) {
            Write-Verbose "GetParams not defined"
            $GetParams = @{}
        }
        if ( ( [boolean]$alias ) -and ( $URIPart -ne 'alerts/requests' ) ) {
            $IDType = Get-OpsGenieGuidType -id $alias
            Write-Verbose "IDType: $( $IDType )"
            if ( $IDType -ne 'identifier' ) {
                if ( $Method -eq 'GET' ) {
                    if ( $GetParams.Keys | Where-Object { $_ -eq $IDTypeParam } ) {
                        $GetParams."$( $IDTypeParam )" -eq $IDType
                    }
                    else {
                        $GetParams.Add( $IDTypeParam, $IDType )
                    }
                }
                else {
                    if ( $PostParams.Keys | Where-Object { $_ -eq $IDTypeParam } ) {
                        $PostParams."$( $IDTypeParam )" -eq $IDType
                    }
                    else {
                        $PostParams.Add( $IDTypeParam, $IDType )
                    }
                }
            }
        }

        #>

        # if ( ( [boolean]$PostParams ) -and ( $Method -in @('GET', 'DELETE') ) ) {
        # if ( [boolean]$PostParams ) {

            $EncodedPostParams = ( $GetParams.Keys | ForEach-Object { "$( $_)=$( [System.Web.HttpUtility]::UrlEncode( $GetParams."$( $_ )" ) )" } ) -join "&"
            # $EncodedPostParams = ( $PostParams.Keys | Where-Object { ( ( $Method -ne 'GET' ) -and ( $_ -eq $IDTypeParam ) ) -or ( $Method -eq 'GET' )  } | ForEach-Object { "$( $_)=$( [System.Web.HttpUtility]::UrlEncode( $PostParams."$( $_ )" ) )" } ) -join "&"
            if ( $EncodedPostParams ) {
                if ( $URI -match "\?" ) {
                    $URI = "$( $URI )?$( $EncodedPostParams )"
                }
                else {
                    $URI = "$( $URI )?$( $EncodedPostParams )"
                }

            }
        # }
        $InvokeParams = @{
            'Headers'     = @{
                # "Authorization" = "GenieKey $($APIKey)a"
                "Authorization" = "GenieKey $APIKey"
            }
            'Uri'               = $URI
            'ContentType'       = 'application/json'
            'Method'            = $Method
            'UseBasicParsing'   = $true
        }

        if ( ( [boolean]$PostParams ) -and ( $Method -notin @('GET') ) ) {
            $body = $PostParams | ConvertTo-Json
            $InvokeParams.Add( 'body', $body )
            Write-Verbose $body
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
            # $res = Invoke-RestMethod @InvokeParams
            $return = Invoke-WebRequest @InvokeParams
            $JSONContent = $return.Content | ConvertFrom-Json
            $StatusCode = [int]( $return.StatusCode )
            $StatusDescription = $return.StatusDescription
        }
        catch {
            $err = $_.Exception
            $JSONContent = $null
            $StatusCode = [int]( $err.Response.StatusCode.value__ )
            $StatusDescription = $err.Message
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
            # throw $ret
        }

        if ( ( $StatusCode -eq 202 ) -and ( [boolean]$wait ) ) {
            $RequestParams = @{
                URIPart = "alerts/requests/$( $JSONContent.requestId )"
                Method = 'GET'
            }
            <#
            $RequestParams.URIPart = "alerts/requests/086a6889-d18f-434b-a0ab-64bd7bf0bf08"
            $RequestParams.add('APIKey', $APIKeySMA )
            $RequestParams.add('EU', $true )
            #>

            foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -in @('APIKey', 'EU', 'Proxy', 'ProxyCredential' ) } ) ) {
                $RequestParams.Add( $Key , $PSBoundParameters."$( $Key )")
            }
            $RequestStartTime = Get-Date
            do {
                $RequestResult = Invoke-OpsGenieWebRequest @RequestParams

                if ( [int]$RequestResult.StatusCode -eq 202 ) {
                    Start-Sleep -Seconds 1
                }
            } until ( ( [int]$RequestResult.StatusCode -notin @(202, 404) ) -or ( ( Get-Date ) -gt $RequestStartTime.AddMinutes(5) ))
            $ret = @{
                data              = $RequestResult.data
                result            = $RequestResult.data.isSuccess
                requestId         = $JSONContent.requestId
                took              = $JSONContent.took
                expandable        = $JSONContent.expandable
                StatusCode        = $RequestResult.StatusCode
                StatusDescription = $RequestResult.StatusDescription
            }
        }
        else {
            $ret = @{
                data              = ( $JSONContent.data | Where-Object { [boolean]$_ } )
                result            = $JSONContent.result
                requestId         = $JSONContent.requestId
                took              = $JSONContent.took
                expandable        = $JSONContent.expandable
                StatusCode        = $StatusCode
                StatusDescription = $StatusDescription
            }
        }

        [System.Net.WebRequest]::DefaultWebProxy = $CurrentProxy
        [Net.ServicePointManager]::SecurityProtocol = $CurrentSecurityProtocol
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