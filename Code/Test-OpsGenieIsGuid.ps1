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
