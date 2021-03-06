# Semantic Versioning: https://semver.org/

get-Module | Remove-Module -Force
Import-Module Pester -RequiredVersion 4.6.0

Write-Host "[BUILD] [START] Launching Build Process" -ForegroundColor Green

#region prepare folders
    $Current          = (Split-Path -Path $MyInvocation.MyCommand.Path)
    $Root             = ((Get-Item $Current).Parent).FullName
    $TestsPath        = Join-Path -Path $Root -ChildPath "Tests"
    $CISourcePath     = Join-Path -Path $Root -ChildPath "CI"
    $TestsScript      = Join-Path -Path $TestsPath -ChildPath "Functions.Tests.ps1"
    $TestsFailures    = Join-Path -Path $TestsPath -ChildPath "Functions.Tests.json"
    $Settings         = Join-Path -Path $CISourcePath -ChildPath "Module-Settings.json"
    $HelpPath         = Join-Path -Path $Root -ChildPath "Help"
#endregion

#region Module-Settings
    if(Test-Path -Path $Settings){
        $ModuleSettings    = Get-content -Path $Settings | ConvertFrom-Json
        $ModuleName        = $ModuleSettings.ModuleName
        $ModuleDescription = $ModuleSettings.ModuleDescription
        $ModuleVersion     = $ModuleSettings.ModuleVersion
        $prompt            = Read-Host "Enter the Version number of this module in the Semantic Versioning notation [$( $ModuleVersion )]"
        if (!$prompt -eq "") { $ModuleVersion = $prompt }
        $ModuleAuthor      = $ModuleSettings.ModuleAuthor
        $ModuleCompany     = $ModuleSettings.ModuleCompany
        $ModulePrefix      = $ModuleSettings.ModulePrefix
        $ProjectUri      = $ModuleSettings.ProjectUri
    }
    else{
        $ModuleName        = Read-Host 'Enter the name of the module without the extension'
        $ModuleVersion     = Read-Host 'Enter the Version number of this module in the Semantic Versioning notation'
        $ModuleDescription = Read-Host 'Enter the Description of the functionality provided by this module'
        $ModuleAuthor      = Read-Host 'Enter the Author of this module'
        $ModuleCompany     = Read-Host 'Enter the Company or vendor of this module'
        $ModulePrefix      = Read-Host 'Enter the Prefix for all functions of this module'
        $ProjectUri        = Read-Host 'Enter the Project URI for this module'
    }
    [PSCustomObject] @{
        ModuleName        = $ModuleName
        ModuleVersion     = $ModuleVersion
        ModuleDescription = $ModuleDescription
        ModuleAuthor      = $ModuleAuthor
        ModuleCompany     = $ModuleCompany
        ModulePrefix      = $ModulePrefix
        ProjectUri        = $ProjectUri
    } | ConvertTo-Json | Out-File -FilePath $Settings -Encoding utf8
#endregion

#region Running Pester Tests
    if (Test-Path -Path $TestsFailures) {
        $file      = Get-Item -Path $TestsFailures
        $timestamp = Get-Date ($file.LastWriteTime) -f 'yyyyMMdd_HHmmss'
        $newname   = $($file.Name -replace '.json',"-$($timestamp).json")
        Rename-Item -Path $TestsFailures -NewName $newname
    }
    Write-Host "[BUILD] [TEST]  Running Function-Tests" -ForegroundColor Green
    if((Get-Module -Name Pester).Version -match '^3\.\d{1}\.\d{1}'){
        Remove-Module -Name Pester
    }
    Import-Module -Name Pester -MinimumVersion 4.4.1 -Force
    $TestsResult      = Invoke-Pester -Script $TestsScript -PassThru -Show None
#end region

if($TestsResult.FailedCount -eq 0) {
    $ModuleFolderPath = Join-Path -Path $Root -ChildPath $ModuleName
    #$ModuleFolderPath = $Root
    $CodeSourcePath   = Join-Path -Path $Root -ChildPath "Code"
    if(-not(Test-Path -Path $ModuleFolderPath)){
        $null = New-Item -Path $ModuleFolderPath -ItemType Directory
    }

    #region Update the Module-File
        # Remove existent PSM1-File
        $ExportPath = Join-Path -Path $ModuleFolderPath -ChildPath "$($ModuleName).psm1"
        if(Test-Path $ExportPath){
            Write-Host "[BUILD] [PSM1 ] PSM1 file detected. Deleting..." -ForegroundColor Green
            Remove-Item -Path $ExportPath -Force
        }

        # Prepare new PSM1-File
        $Date = Get-Date
        "<#" | out-File -FilePath $ExportPath -Encoding utf8 -Append
        "    Generated at $($Date) by $($ModuleAuthor)" | out-File -FilePath $ExportPath -Encoding utf8 -Append
        "#>" | out-File -FilePath $ExportPath -Encoding utf8 -Append

        Write-Host "[BUILD] [Code ] Loading Class, public and private functions" -ForegroundColor Green
        $PublicFunctions  = Get-ChildItem -Path $CodeSourcePath -Filter 'Public\*-*.ps1' | sort-object Name
        $PrivateFunctions  = Get-ChildItem -Path $CodeSourcePath -Filter 'Private\*-*.ps1' | sort-object Name
        $MainPSM1Contents = @()
        $MainPSM1Contents += $PublicFunctions
        $MainPSM1Contents += $PrivateFunctions

        #Creating PSM1
        Write-Host "[BUILD] [START] [PSM1] Building Module PSM1" -ForegroundColor Green
        "#region namespace $($ModuleName)" | out-File -FilePath $ExportPath -Encoding utf8 -Append
        $MainPSM1Contents | ForEach-Object{
            Get-Content -Path $($_.FullName) | out-File -FilePath $ExportPath -Encoding utf8 -Append
        }
        "#endregion" | out-File -FilePath $ExportPath -Encoding utf8 -Append

        Write-Host "[BUILD] [END  ] [PSM1] building Module PSM1 " -ForegroundColor Green
    #endregion

    #region Update the Manifest-File
        Write-Host "[BUILD] [START] [PSD1] Manifest PSD1" -ForegroundColor Green
        $FullModuleName = Join-Path -Path $ModuleFolderPath -ChildPath "$($ModuleName).psd1"
        if (Test-Path $FullModuleName) {
            Remove-Item -Path $FullModuleName -Force -Confirm:$false
        }
        if(-not(Test-Path $FullModuleName)){
            New-ModuleManifest -Path $FullModuleName -ModuleVersion $ModuleVersion -Description $ModuleDescription -Author $ModuleAuthor -CompanyName $ModuleCompany -RootModule "$($ModuleName).psm1" -PowerShellVersion 5.1 -AliasesToExport @("*")
        }

        Write-Host "[BUILD] [PSD1 ] Adding functions to export" -ForegroundColor Green
        $FunctionsToExport = $PublicFunctions.BaseName
        $Manifest = Join-Path -Path $ModuleFolderPath -ChildPath "$($ModuleName).psd1"
        Update-ModuleManifest -Path $Manifest -FunctionsToExport $FunctionsToExport -AliasesToExport '*' -ProjectUri $ProjectUri

        Write-Host "[BUILD] [END  ] [PSD1] building Manifest" -ForegroundColor Green
    #endregion

    #region General Module-Tests
        Describe 'General module control' -Tags 'FunctionalQuality'   {

            It "Import $ModuleName without errors" {
                { Import-Module -Name $Manifest -Force -ErrorAction Stop } | Should Not Throw
                Get-Module $ModuleName | Should Not BeNullOrEmpty
            }

            It "Get-Command $ModuleName without errors" {
                { Get-Command -Module $ModuleName -ErrorAction Stop } | Should Not Throw
                Get-Command -Module $ModuleName | Should Not BeNullOrEmpty
            }

            $FunctionsToExport | ForEach-Object {
                $functionname = $_
                It "Get-Command -Module $ModuleName should include Function $($functionname)" {
                    Get-Command -Module $ModuleName | ForEach-Object {
                        {if($functionname -match $_.Name){$true}} | should -betrue
                    }
                }
            }

            It "Removes $ModuleName without error" {
                { Remove-Module -Name $ModuleName -ErrorAction Stop} | Should not Throw
                Get-Module $ModuleName | Should beNullOrEmpty
            }

        }
    #endregion
    Write-Host "[BUILD] [END]   Launching Build Process" -ForegroundColor Green
}
else{
    $TestsArray = $TestsResult.TestResult | ForEach-Object {
        if($_.Passed -eq $false){
            [PSCustomObject] @{
                Describe = $_.Describe
                Context  = $_.Context
                Test     = $_.Name
                Result   = $_.Result
                Message  = $_.FailureMessage
            }
        }
    }
    $TestsArray | ConvertTo-Json | Out-File -FilePath $TestsFailures -Encoding utf8
    Write-Host "[BUILD] [END]   [TEST] Function-Tests, any Errors can be found in $($TestsFailures)" -ForegroundColor Red
    Write-Host "[BUILD] [END]   Launching Build Process with $($TestsResult.FailedCount) Errors" -ForegroundColor Red
}