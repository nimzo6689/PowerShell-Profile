$script:module = @("ConvertUtils.psm1", "MathUtils.psm1", "NormalizeUtils.psm1")
$script:moduleVersion = "0.0.1"
$script:description = "PowerShell Commons library";
$script:copyright = "14/Sept/2016 -"
$script:RequiredModules = @()
$script:clrVersion = "4.0.0.0" 

$script:variableToExport = ""
$script:AliasesToExport = @()

$script:moduleManufest = @{
    Path = "Commons.psd1";
    Author = $env:USERNAME;
    CompanyName = "";
    Copyright = "";
    ModuleVersion = $moduleVersion;
    Description = $description;
    PowerShellVersion = "5.0";
    DotNetFrameworkVersion = "4.0";
    ClrVersion = $clrVersion;
    RequiredModules = $RequiredModules;
    NestedModules = "$module";
    CmdletsToExport = "*";
    FunctionsToExport = "*";
    VariablesToExport = $variableToExport;
    AliasesToExport = $AliasesToExport;
}

New-ModuleManifest @moduleManufest