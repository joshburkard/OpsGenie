function Get-OpsGenieGuidType {
    <#
        .SYNOPSIS
            This function checks the format of the id and returns the type

        .DESCRIPTION
            This function checks the format of the id and returns the type

            possible returns are:
            - alias
            - identifier
            - tinyid
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
                    return 'tinyid'
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
