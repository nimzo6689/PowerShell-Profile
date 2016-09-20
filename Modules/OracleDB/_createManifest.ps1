$script:module = "OracleDB"
$script:moduleVersion = "0.0.2"
$script:description = "PowerShell Oracle Database library";
$script:copyright = "14/Sept/2016 -"
$script:RequiredModules = @()
$script:clrVersion = "4.0.0.0" 

$script:functionToExport = @(
        "Set-ConnectionString",
        "Get-OracleDB",
        "Update-OracleDB",
        "Format-SQL"
)

$script:variableToExport = ""
$script:AliasesToExport = @()

$script:moduleManufest = @{
    Path = "$module.psd1";
    Author = $env:USERNAME;
    CompanyName = "";
    Copyright = ""; 
    ModuleVersion = $moduleVersion;
    Description = $description;
    PowerShellVersion = "5.0";
    DotNetFrameworkVersion = "4.0";
    ClrVersion = $clrVersion;
    RequiredModules = $RequiredModules;
    NestedModules = "$module.psm1";
    CmdletsToExport = "*";
    FunctionsToExport = $functionToExport;
    VariablesToExport = $variableToExport;
    AliasesToExport = $AliasesToExport;
}

New-ModuleManifest @moduleManufest