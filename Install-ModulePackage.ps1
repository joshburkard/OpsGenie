<#
    .SYNOPSIS
        Deploy PowerShell Modules with ConfigMgr

    .DESCRIPTION
        Deploy PowerShell Modules with ConfigMgr

    .NOTES
        File-Name:  Install-ModulePackage.ps1
        Author:     Josh Burkard
        Version:    1.0.1

        Changelog:
                    1.0.0, 28.02.2022, Josh Burkard, initial creation
                    1.0.1, 10.03.2022, Josh Burkard, allows modules with multiple versions

    .LINK

        https://gitlab.swisscloud.io/cfmg-sccm-scripts/CM0_ALL_OPR_Helpers
        https://skatterbrainz.wordpress.com/2019/10/01/deploy-powershell-modules-with-configmgr-task-sequences/

    .PARAMETER ModuleName
        defines the name of the Module, which should be in a child folder of the current path

    .PARAMETER Version
        defines the version to install, should be in a child folder of ModuleName

    .EXAMPLE
        .\Install-ModulePackage.ps1 -ModuleName "ModuleName"

    .EXAMPLE
        .\Install-ModulePackage.ps1 -ModuleName "ModuleName" -Version "1.1.44"

    .EXAMPLE
        .\Install-ModulePackage.ps1

#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$ModuleName = ''
    ,
    [Parameter(Mandatory=$false)]
    [string]$Version = ''
)
try {
    $CurrentFile = $MyInvocation.MyCommand

    if ( [boolean]$ModuleName ) {
        $SourcePath = Join-Path -Path $PSScriptRoot -ChildPath $ModuleName
    }
    else {
        $SourcePath = $PSScriptRoot
    }
    Write-Verbose $SourcePath
    $MName = Split-Path $SourcePath -Leaf
    Write-Verbose "module: $MName"
    $MVersions = Get-ChildItem -Path $SourcePath -Directory
    if ( $MVersions ) {
        if ( [boolean]$Version ) {
            $MVersions = $MVersions | Where-Object { $_ -in $Version}
        }
        foreach ( $MVersion in $MVersions ) {
            Write-Verbose "version: $MVersion"
            $TargetPath = Join-Path -Path $env:ProgramFiles -ChildPath "WindowsPowerShell\Modules\$MName\$MVersion"
            # check if module + version target folder exists
            if (-not (Test-Path $TargetPath)) {
                $VSourcePath = Join-Path -Path $SourcePath -ChildPath $MVersion
                Write-Verbose "installing module: $MName $MVersion"
                mkdir $TargetPath -Force -ErrorAction Stop | Out-Null
                xcopy $VSourcePath\*.* $TargetPath /s
                $result = 0
            }
            else {
                Write-Verbose "module already installed"
                $result = 1
            }
        }
    }
    else {
        $TargetPath = Join-Path -Path $env:ProgramFiles -ChildPath "WindowsPowerShell\Modules\$MName"
        # check if module + version target folder exists
        if (-not (Test-Path $TargetPath)) {
            Write-Verbose "installing module: $MName"
            mkdir $TargetPath -Force -ErrorAction Stop | Out-Null
            xcopy $SourcePath\*.* $TargetPath /s /exclude:$( $CurrentFile.Name )
            $result = 0
        }
        else {
            Write-Verbose "module already installed"
            $result = 1
        }
    }
}
catch {
    Write-Verbose $_.Exception.Message
    $result = -1
}
finally {
    Write-Output $result
}