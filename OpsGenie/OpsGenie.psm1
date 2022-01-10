<#
    Generated at 01/10/2022 20:09:16 by Josh Burkard (josh@burkard.it)
#>
#region namespace OpsGenie
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
function Add-OpsGenieAlertNote {
    <#
        .SYNOPSIS
            This function add a new note to an already existing alert in OpsGenie

        .DESCRIPTION
            This function add a new note to an already existing alert in OpsGenie through the API v2

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

        .PARAMETER note
            defines the new note

            this string parameter is mandatory

        .EXAMPLE
            Add-OpsGenieAlertNote -APIKey $APIKey -EU -alias $Alias -note "this is a new note"

        .NOTES
            Date, Author, Version, Notes
            28.11.2021, Josua Burkard, 0.0.00001, initial creation

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
        ,
        [Parameter(Mandatory=$true)]
        [string]$note
        ,
        [Parameter(Mandatory=$false)]
        [string]$user
        ,
        [Parameter(Mandatory=$false)]
        [string]$source
        ,
        [switch]$wait
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"
    try {
        $InvokeParams = @{
            URIPart     = 'alerts'
            action      = 'notes'
            Method      = 'POST'
            # alias       = $ret.data.id
            # APIKey = $APIKey
            # EU = $true
        }

        foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -in @('alias', 'APIKey', 'EU', 'Proxy', 'ProxyCredential', 'wait' ) } ) ) {
            $InvokeParams.Add( $Key , $PSBoundParameters."$( $Key )")
        }

        $PostParams = @{}
        foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -notin @('APIKey', 'EU', 'Proxy', 'ProxyCredential', 'alias', 'wait' ) } ) ) {
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
function Add-OpsGenieAlertResponder {
    <#
        .SYNOPSIS
            This function add a new responder to an already existing alert in OpsGenie

        .DESCRIPTION
            This function add a new responder to an already existing alert in OpsGenie through the API v2

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

        .PARAMETER ResponderType
            the type of the responder, user or team

            this string parameter is mandatory

        .PARAMETER Responder
            the name or id of the responder

            this string parameter is mandatory

        .EXAMPLE
            Add-OpsGenieAlertResponder -APIKey $APIKey -EU -alias $alias -responderType user -responder $UserMail

        .EXAMPLE
            Add-OpsGenieAlertResponder -APIKey $APIKey -EU -alias $alias -responderType team -responder $TeamName

        .NOTES
            Date, Author, Version, Notes
            28.11.2021, Josua Burkard, 0.0.00001, initial creation

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
        ,
        [Parameter(Mandatory=$true)]
        [ValidateSet('user','team')]
        [string]$responderType
        ,
        [Parameter(Mandatory=$true)]
        [string]$responder
        ,
        [Parameter(Mandatory=$false)]
        [string]$note
        ,
        [Parameter(Mandatory=$false)]
        [string]$user
        ,
        [Parameter(Mandatory=$false)]
        [string]$source
        ,
        [switch]$wait
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"
    try {
        $URIPart = "alerts/$( $alias )/responders"
        $IDType = Get-OpsGenieGuidType -id $alias
        if ( $IDType -ne 'identifier' ) {
            $URIPart = "${URIPart}?identifierType=${IDType}"
        }
        $InvokeParams = @{
            URIPart     = $URIPart
            # action      = 'responders'
            Method      = 'POST'
            # alias       = $alias
            # APIKey = $APIKey
            # EU = $true
        }

        foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -in @('APIKey', 'EU', 'Proxy', 'ProxyCredential', 'wait' ) } ) ) {
            $InvokeParams.Add( $Key , $PSBoundParameters."$( $Key )")
        }

        $PostParams = @{}
        <#
        foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -notin @('APIKey', 'EU', 'Proxy', 'ProxyCredential', 'alias', 'wait' ) } ) ) {
            $PostParams.Add( $Key , $PSBoundParameters."$( $Key )")
        }
        #>
        # $PostParams.Add( 'responderType', 'team' )
        # $PostParams.Add( 'responder', 'Test-001' )

        if ( $responderType -eq 'user' ) {
            if ( Test-OpsGenieIsGuid -ObjectGuid $responder ) {
                $responderobj = @{
                    type = $responderType
                    id = $responder
                }
            }
            else {
                $responderobj = @{
                    type = $responderType
                    username = $responder
                }
            }
        }
        else {
            if ( Test-OpsGenieIsGuid -ObjectGuid $responder ) {
                $responderobj = @{
                    type = $responderType
                    id = $responder
                }
            }
            else {
                $responderobj = @{
                    type = $responderType
                    name = $responder
                }
            }
        }
        Write-Verbose ( $responderobj | ConvertTo-Json )
        $PostParams.Add( 'responder' , $responderobj )

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
function Add-OpsGenieAlertTag {
    <#
        .SYNOPSIS
            This function add a new tag to an already existing alert in OpsGenie

        .DESCRIPTION
            This function add a new tag to an already existing alert in OpsGenie through the API v2

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

        .PARAMETER tags
            List of tags to add into alert.

            this string array parameter is mandatory

        .EXAMPLE
            Add-OpsGenieAlertTag -APIKey $APIKey -EU -alias $alias -tags 'Test-01'

        .NOTES
            Date, Author, Version, Notes
            28.11.2021, Josua Burkard, 0.0.00001, initial creation

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
        ,
        [Parameter(Mandatory=$true)]
        [string[]]$tags
        ,
        [Parameter(Mandatory=$false)]
        [string]$note
        ,
        [Parameter(Mandatory=$false)]
        [string]$user
        ,
        [Parameter(Mandatory=$false)]
        [string]$source
        ,
        [switch]$wait
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"
    try {
        $URIPart = "alerts/$( $alias )/tags"
        $IDType = Get-OpsGenieGuidType -id $alias
        if ( $IDType -ne 'identifier' ) {
            $URIPart = "${URIPart}?identifierType=${IDType}"
        }
        $InvokeParams = @{
            URIPart     = $URIPart
            # action      = 'tags'
            Method      = 'POST'
            # alias       = $ret.data.id
            # APIKey = $APIKey
            # EU = $true
        }

        foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -in @('APIKey', 'EU', 'Proxy', 'ProxyCredential', 'wait' ) } ) ) {
            $InvokeParams.Add( $Key , $PSBoundParameters."$( $Key )")
        }

        $PostParams = @{}
        foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -notin @('APIKey', 'EU', 'Proxy', 'ProxyCredential', 'alias', 'wait' ) } ) ) {
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
function Add-OpsGenieAlertTeam {
    <#
        .SYNOPSIS
            This function add a new note to an already existing alert in OpsGenie

        .DESCRIPTION
            This function add a new note to an already existing alert in OpsGenie through the API v2

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

        .PARAMETER Team
            the name of the team

            this string parameter is mandatory

        .EXAMPLE
            Add-OpsGenieAlertTeam -APIKey $APIKey -EU -alias $alias -team $TeamName

        .NOTES
            Date, Author, Version, Notes
            28.11.2021, Josua Burkard, 0.0.00001, initial creation

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
        ,
        [Parameter(Mandatory=$true)]
        [string]$team
        ,
        [Parameter(Mandatory=$false)]
        [string]$note
        ,
        [Parameter(Mandatory=$false)]
        [string]$user
        ,
        [Parameter(Mandatory=$false)]
        [string]$source
        ,
        [switch]$wait
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"
    try {
        $URIPart = "alerts/$( $alias )/teams"
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

        if ( Test-OpsGenieIsGuid -ObjectGuid $team ) {
            $teamobj = @{
                id = $team
            }
        }
        else {
            $teamobj = @{
                name = $team
            }
        }
        $PostParams.Add( 'team' , $teamobj )


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
function Get-OpsGenieAlertNote {
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
        $URIPart = "alerts/$( $alias )/notes"
        $IDType = Get-OpsGenieGuidType -id $alias
        if ( $IDType -ne 'identifier' ) {
            $URIPart = "${URIPart}?identifierType=${IDType}"
        }
        $InvokeParams = @{
            URIPart     = $URIPart
            Method = 'GET'
        }

        foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -in @('APIKey', 'EU', 'Proxy', 'ProxyCredential' ) } ) ) {
            $InvokeParams.Add( $Key , $PSBoundParameters."$( $Key )")
        }

        $ret = Invoke-OpsGenieWebRequest @InvokeParams -Verbose

        if ( $ret.StatusCode -eq 200 ) {
            return $ret.data
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
function Get-OpsGenieGuidType {
    <#
        .SYNOPSIS
            This function checks the format of the id and returns the type

        .DESCRIPTION
            This function checks the format of the id and returns the type

            possible returns are:
            - alias
            - identifier
            - tiny
            - unknown

        .PARAMETER id
            the id to check

        .EXAMPLE
            Get-OpsGenieGuidType -id $alert.id

        .EXAMPLE
            Get-OpsGenieGuidType -id $alert.alias

        .EXAMPLE
            Get-OpsGenieGuidType -id $alert.tinyId

        .EXAMPLE
            Get-OpsGenieGuidType -id ( New-Guid ).Guid
    #>
    [CmdLetBinding()]
    Param (
        [string]$id
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"
    try {
        if ( $id -match "(?im)^([{(]?[0-9A-F]{8}[-]?(?:[0-9A-F]{4}[-]?){3}[0-9A-F]{12}[)}]?[-][0-9A-F]{13})" ) {
            return 'identifier'
        }
        elseif ( $id -match "(?im)^([{(]?[0-9a-f]{8}[-]?(?:[0-9a-f]{4}[-]?){3}[-]?(?:[0-9a-f]{12}[-]?))") {
            return 'alias'
        }
        else {
            try {
                $intid = [int]$id
                if ( [string]$intid -eq $id ) {
                    return 'tiny'
                }
            }
            catch {

            }
        }
        return 'unknown'
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
function Invoke-OpsGenieAlertAction {
    <#
        .SYNOPSIS
            This function invokes an action on an existing alert in OpsGenie

        .DESCRIPTION
            This function invokes an action on an existing alert in OpsGenie

            more info about the API under https://docs.opsgenie.com/docs/alert-api

        .PARAMETER APIKey
            The APIKey from OpsGenie

        .PARAMETER identifier
            Identifier of the alert

        .PARAMETER EU
            if this switch parameter is set, the function will connect to API URI in EU otherwise, the global URI

        .PARAMETER Proxy
            defines the proxy server to use

        .PARAMETER ProxyCredential
            defines the credential for the Proxy-Server

        .PARAMETER action
            the action which should be invoked

        .PARAMETER note
            defines the note for the alert

        .PARAMETER source
            defines the source for the alert

        .PARAMETER user
            defines the user for the alert

        .EXAMPLE
            Confirm-OpsGenieAlert -APIKey $APIKey -Identifier '9450e556-b8cb-432f-b4a7-e3cb1933819c'

        .NOTES
            Date, Author, Version, Notes
            28.07.2021, Josua Burkard, 0.0.00001, initial creation
            29.11.2021, Josua Burkard, 0.0.00003, removed actions which are now in separate functions

    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$APIKey
        ,
        [Parameter(Mandatory=$false)]
        [string]$identifier
        ,
        [Parameter(Mandatory=$false)]
        [string]$alias
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
        [ValidateSet('acknowledge',
                     'assign',
                     'CustomAction',
                     'description',
                     'snooze',
                     'unacknowledge')]
        [string]$action
        ,
        [Parameter(Mandatory=$false)]
        [string]$note
        ,
        [Parameter(Mandatory=$false)]
        [string]$user
        ,
        [Parameter(Mandatory=$false)]
        [string]$source
        ,
        [switch]$wait
    )
    DynamicParam {
        $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        if ($action -eq "assign") {
            $Attribute = New-Object System.Management.Automation.ParameterAttribute
            $Attribute.Mandatory = $true
            $Attribute.HelpMessage = "Escalation that the alert will be escalated. Either id or name of the escalation should be provided."
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeCollection.Add($Attribute)
            $Param = New-Object System.Management.Automation.RuntimeDefinedParameter('owner', [string], $attributeCollection)
            $paramDictionary.Add('owner', $Param)
        }
        if ($action -eq "CustomAction") {
            $Attribute = New-Object System.Management.Automation.ParameterAttribute
            $Attribute.Mandatory = $true
            $Attribute.HelpMessage = "Name of the action to execute"
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeCollection.Add($Attribute)
            $Param = New-Object System.Management.Automation.RuntimeDefinedParameter('CustomAction', [string], $attributeCollection)
            $paramDictionary.Add('CustomAction', $Param)
        }
        if ($action -eq "description") {
            $Attribute = New-Object System.Management.Automation.ParameterAttribute
            $Attribute.Mandatory = $true
            $Attribute.HelpMessage = "Path to the file to upload"
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeCollection.Add($Attribute)
            $Param = New-Object System.Management.Automation.RuntimeDefinedParameter('description', [string], $attributeCollection)
            $paramDictionary.Add('description', $Param)
        }
        if ($action -eq "snooze") {
            $Attribute = New-Object System.Management.Automation.ParameterAttribute
            $Attribute.Mandatory = $true
            $Attribute.HelpMessage = "Enter the End Date Time"
            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeCollection.Add($Attribute)
            $Param = New-Object System.Management.Automation.RuntimeDefinedParameter('endTime', [datetime], $attributeCollection)
            $paramDictionary.Add('endTime', $Param)
        }


        return $paramDictionary
    }
    Process {
        $function = $($MyInvocation.MyCommand.Name)
        Write-Verbose "Running $function"
        try {
            $PostParams = @{}
            $URIPart = "alerts/$( $alias )/$( $action )"
            switch ( $action ) {
                'assign' {
                    if ( Test-OpsGenieIsGuid -ObjectGuid $PSBoundParameters['owner'] ) {
                        $owner = @{
                            id = $PSBoundParameters['owner']
                        }
                    }
                    else {
                        $owner = @{
                            username = $PSBoundParameters['owner']
                        }
                    }
                    $PostParams.Add( 'owner' , $owner )
                }
                'CustomAction' {
                    $URIPart = "alerts/$( $alias )/action/$( $PSBoundParameters['CustomAction'] )"
                }
                'description' {
                    $PostParams.Add( 'description', $PSBoundParameters['description'] )
                }
                'snooze' {
                    $PostParams.Add( 'endTime', ( Get-Date ( Get-Date $PSBoundParameters['endTime'] ).ToUniversalTime() -UFormat '+%Y-%m-%dT%H:%M:%S.000Z' ) )
                }
            }

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

            foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -in @('note', 'user', 'source') } ) ) {
                $PostParams.Add( $Key , $PSBoundParameters."$( $Key )")
            }
            if ( $PostParams -ne @{} ) {
                $InvokeParams.Add( 'PostParams', $PostParams )
            }

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
}
function New-OpsGenieAlert {
    <#
        .SYNOPSIS
            This function creates a new alert in OpsGenie

        .DESCRIPTION
            This function creates a new alert in OpsGenie through the API v2

            more info about the API under https://docs.opsgenie.com/docs/alert-api

        .PARAMETER APIKey
            The APIKey from OpsGenie

        .PARAMETER message
            The Message for the OpsGenie Alert

            this string parameter is mandatory and accepts max 130 chars

        .PARAMETER responders
            Teams, users, escalations and schedules that the alert will be routed to send notifications. type field is mandatory for each item,
            where possible values are team, user, escalation and schedule. If the API Key belongs to a team integration, this field will be
            overwritten with the owner team. Either id or name of each responder should be provided.You can refer below for example values.

            this parameter is mandatory and should be an hash array like this
            @(
                @{
                    name = "Team-Name"
                    type = "team"
                },
                @{
                    username = "trinity@opsgenie.com"
                    type = "team"
                }
            )

            this parameter accepts max. 50 teams or users in total

        .PARAMETER alias
            Client-defined identifier of the alert, that is also the key element of Alert De-Duplication.

            this string parameter is not mandatory but should be used, it will accept 512 chars

        .PARAMETER description
            Description field of the alert that is generally used to provide a detailed information about the alert.

            this string parameter is not mandatory, it will accept 15000 chars

        .PARAMETER visibleTo
            Teams and users that the alert will become visible to without sending any notification.type field is mandatory for each item,
            where possible values are team and user. In addition to the type field, either id or name should be given for teams and either id or
            username should be given for users. Please note: that alert will be visible to the teams that are specified withinresponders field by
            default, so there is no need to re-specify them within visibleTo field. You can refer below for example values.

            this parameter is not mandatory and should be an hash array like this
            @(
                @{
                    name = "Team-Name"
                    type = "team"
                },
                @{
                    username = "trinity@opsgenie.com"
                    type = "team"
                }
            )

            this parameter accepts max. 50 teams or users in total

        .PARAMETER actions
            Custom actions that will be available for the alert.

            this string array parameter is not mandatory and accepts 10 x 50 characters

        .PARAMETER tags
            Tags of the alert.

            this string array parameter is not mandatory and accepts 20 x 50 characters

        .PARAMETER details
            Map of key-value pairs to use as custom properties of the alert.

            this parameter is not mandatory and accepts an hashtable with 8000 characters in total

        .PARAMETER entity
            Entity field of the alert that is generally used to specify which domain alert is related to.

            this string parameter is not mandatory and accepts 512 characters

        .PARAMETER source
            Source field of the alert. Default value is IP address of the incoming request.

            this string parameter is not mandatory and accepts 100 characters

        .PARAMETER priority
            Priority level of the alert. Possible values are P1, P2, P3, P4 and P5.

            this parameter is not mandatory. the Default value is P3.

        .PARAMETER user
            Display name of the request owner.

            this string parameter is not mandatory and accepts 100 characters.

        .PARAMETER note
            Additional note that will be added while creating the alert.

            this string parameter is not mandatory and accepts 25000 characters.

        .PARAMETER EU
            if this switch parameter is set, the function will connect to API URI in EU otherwise, the global URI

        .PARAMETER Proxy
            defines the proxy server to use

        .PARAMETER ProxyCredential
            defines the credential for the Proxy-Server

        .PARAMETER wait
            if this switch parameter is used, the function will wait till the alert is created

        .EXAMPLE
            $AlertParams = @{
                APIKey      = $APIKey
                EU          = $EU
                alias = $alias
                message     = "This is a test message"
                priority    = 'P4'
                source      = "script $( $CurrentFile.Name )"
                description = @"
                    This is a Test
                    this is the second line
                "@
            }
            New-OpsGenieAlert @AlertParams -wait

        .NOTES
            Date, Author, Version, Notes
            27.07.2021, Josua Burkard, 0.0.00001, initial creation

    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$APIKey
        ,
        [Parameter(Mandatory=$true)]
        [ValidateLength(1,130)][string]$message
        ,
        [Parameter(Mandatory=$false)]
        [ValidateCount(1,50)][Array]$responders
        ,
        [Parameter(Mandatory=$false)]
        [ValidateLength(1,512)][string]$alias
        ,
        [Parameter(Mandatory=$false)]
        [ValidateLength(1,15000)][string]$description
        ,
        [Parameter(Mandatory=$false)]
        [ValidateCount(1,50)][Array]$visibleTo
        ,
        [Parameter(Mandatory=$false)]
        [ValidateCount(1,10)][ValidateLength(1,50)][string[]]$actions
        ,
        [Parameter(Mandatory=$false)]
        [ValidateCount(1,20)][ValidateLength(1,50)][string[]][string[]]$tags
        ,
        [Parameter(Mandatory=$false)]
        [object]$details
        ,
        [Parameter(Mandatory=$false)]
        [ValidateLength(1,512)][string]$entity
        ,
        [Parameter(Mandatory=$false)]
        [ValidateLength(1,100)][string]$source
        ,
        [Parameter(Mandatory=$false)]
        [ValidateSet("P1","P2","P3","P4","P5")]
        [string]$priority
        ,
        [Parameter(Mandatory=$false)]
        [ValidateLength(1,100)][string]$user
        ,
        [Parameter(Mandatory=$false)]
        [ValidateLength(1,25000)][string]$note
        ,
        [switch]$EU
        ,
        [Parameter(Mandatory=$false)]
        [string]$Proxy
        ,
        [Parameter(Mandatory=$false)]
        [System.Management.Automation.PSCredential]$ProxyCredential
        ,
        [switch]$wait
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"
    try {
        $InvokeParams = @{
            URIPart = 'alerts'
            Method = 'POST'
        }
        foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -in @('APIKey', 'EU', 'Proxy', 'ProxyCredential','wait' ) } ) ) {
            $InvokeParams.Add( $Key , $PSBoundParameters."$( $Key )")
        }

        $PostParams = @{}
        foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -notin @('APIKey', 'EU', 'Proxy', 'ProxyCredential', 'alias', 'wait' ) } ) ) {
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
function Remove-OpsGenieAlert {
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
            Remove-OpsGenieAlert -APIKey $APIKey -EU -alias $Alias

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
        ,
        [switch]$wait
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
            Method = 'DELETE'
        }

        foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -in @('APIKey', 'EU', 'Proxy', 'ProxyCredential','wait' ) } ) ) {
            $InvokeParams.Add( $Key , $PSBoundParameters."$( $Key )")
        }

        $ret = Invoke-OpsGenieWebRequest @InvokeParams -Verbose

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
function Remove-OpsGenieAlertAttachment {
    <#
        .SYNOPSIS
            This function removes an attachment from an existing alert in OpsGenie

        .DESCRIPTION
            This function removes an attachments from an existing alert in OpsGenie through the API v2

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

        .PARAMETER attachmentId
            Identifier of the attachment

        .EXAMPLE
            Remove-OpsGenieAlertAttachment -APIKey $APIKey -EU -alias $Alias -attachmentId $attachmentId

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
        ,
        [Parameter(Mandatory=$true)]
        [string]$attachmentId
        ,
        [switch]$wait
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"
    try {
        $URIPart = "alerts/$( $alias )/attachments/$( $attachmentId )"
        $IDType = Get-OpsGenieGuidType -id $alias
        if ( $IDType -ne 'identifier' ) {
            $URIPart = "${URIPart}?alertIdentifierType=${IDType}"
        }
        $InvokeParams = @{
            URIPart     = $URIPart
            Method = 'DELETE'
        }

        foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -in @('APIKey', 'EU', 'Proxy', 'ProxyCredential','wait' ) } ) ) {
            $InvokeParams.Add( $Key , $PSBoundParameters."$( $Key )")
        }

        $ret = Invoke-OpsGenieWebRequest @InvokeParams -Verbose

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
function Remove-OpsGenieAlertTag {
    <#
        .SYNOPSIS
            This function remove a tag to an already existing alert in OpsGenie

        .DESCRIPTION
            This function remove a tag to an already existing alert in OpsGenie through the API v2

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

        .PARAMETER tags
            List of tags to add into alert.

            this string array parameter is mandatory

        .EXAMPLE
            Remove-OpsGenieAlertTag -APIKey $APIKey -EU -alias $alias -tags 'Test-01'

        .NOTES
            Date, Author, Version, Notes
            28.11.2021, Josua Burkard, 0.0.00001, initial creation

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
        ,
        [Parameter(Mandatory=$true)]
        [string[]]$tags
        ,
        [Parameter(Mandatory=$false)]
        [string]$note
        ,
        [Parameter(Mandatory=$false)]
        [string]$user
        ,
        [Parameter(Mandatory=$false)]
        [string]$source
        ,
        [switch]$wait
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"
    try {
        $URIPart = "alerts/$( $alias )/tags"
        $IDType = Get-OpsGenieGuidType -id $alias
        if ( $IDType -ne 'identifier' ) {
            $URIPart = "${URIPart}?alertIdentifierType=${IDType}"
        }
        $InvokeParams = @{
            URIPart     = $URIPart
            Method = 'DELETE'
        }
        foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -in @('APIKey', 'EU', 'Proxy', 'ProxyCredential', 'wait' ) } ) ) {
            $InvokeParams.Add( $Key , $PSBoundParameters."$( $Key )")
        }

        $GetParams = @{
            tags = @( $tags )  -join ','
        }
        $InvokeParams.Add( 'GetParams', $GetParams )

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
function Set-OpsGenieAlertPriority {
    <#
        .SYNOPSIS
            This function creates a new alert in OpsGenie

        .DESCRIPTION
            This function creates a new alert in OpsGenie through the API v2

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
        [ValidateSet("P1","P2","P3","P4","P5")]
        [string]$priority
        ,
        [switch]$wait
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"
    try {
        $URIPart = "alerts/$( $alias )/priority"
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
        foreach ( $Key in ( $PSBoundParameters.Keys | Where-Object { $_ -notin @('APIKey', 'EU', 'Proxy', 'ProxyCredential', 'alias', 'wait' ) } ) ) {
            $PostParams.Add( $Key , $PSBoundParameters."$( $Key )")
        }

        $InvokeParams.Add( 'PostParams', $PostParams )

        $ret = Invoke-OpsGenieWebRequest @InvokeParams

        return $ret

        <#
        if ( [boolean]$EU ) {
            $URI = "https://api.eu.opsgenie.com/v2/alerts/$( $alias )/priority?identifierType=alias"
        }
        else {
            $URI = "https://api.opsgenie.com/v2/alerts/$( $alias )/priority?identifierType=alias"
        }

        $BodyParams = @{
            priority = $priority
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

        $request = Invoke-RestMethod @InvokeParams
        try {
            $ret = $request.requestId
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
function Test-OpsGenieIsGuid {
    <#
        .SYNOPSIS
            This function checks if a string contains a GUID

        .DESCRIPTION
            This function checks if a string contains a GUID

        .PARAMETER ObjectGuid
            the string to check

        .EXAMPLE
            Test-OpsGenieIsGuid -ObjectGuid 'TestString'                           # returns false
            Test-OpsGenieIsGuid -ObjectGuid 'a50ccfd6-892d-491d-8f01-a5a4c6758705' # returns true

        .NOTES
            Date, Author, Version, Notes
            28.07.2021, Josua Burkard, 0.0.00001, initial creation

    #>

    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$ObjectGuid
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"
    try {

        # Define verification regex
        [regex]$guidRegex = '(?im)^[{(]?[0-9A-F]{8}[-]?(?:[0-9A-F]{4}[-]?){3}[0-9A-F]{12}[)}]?$'

        # Check guid against regex
        return $ObjectGuid -match $guidRegex
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
            'Uri'         = $URI
            'ContentType' = 'application/json'
            'Method'      = $Method
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
            [system.net.webrequest]::defaultwebproxy = $TempProxy
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
#endregion
