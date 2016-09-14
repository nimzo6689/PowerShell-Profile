$ErrorActionPreference = "stop"

function global:Get-BasicAuth([string]$User, [string]$Pass, [switch]$help) {
    if ($help) {
        Write-Host "This Cmdlet generates basic authorization value."
        Write-Host "Example:"
        Write-Host "PS C:\>Get-BasicAuth -User username -Pass password"
        Write-Host "PS C:\>Basic dXNlcm5hbWU6cGFzc3dvcmQ="
        return $null
    }
    $StrType = "System.String"
    if ([System.String]::IsNullOrWhiteSpace($User) `
            -or [System.String]::IsNullOrWhiteSpace($Pass)) {
        Write-Host ("The parameters is null, empty,"`
                + "or consists only of white-space characters.")
        return $null
    }
    if ($User.GetType().FullName -ne $StrType `
            -or $User.GetType().FullName -ne $StrType) {
        Write-Host ("The parameters is not valid data type.[" + $StrType + "]")
        return $null
    }
    $pair = $User + ":" + $Pass
    $credsOfAscii = [System.Text.Encoding]::ASCII.GetBytes($pair)
    return "Basic " + [System.Convert]::ToBase64String($credsOfAscii)
}

<#
    HMacSHA1の取得スクリプト

    @author nimzo
#>
$ErrorActionPreference = "stop"

function Get-HMACSHA1([string]$publicKey, [string]$privateKey){
    $hmacsha = New-Object System.Security.Cryptography.HMACSHA1
    $hmacsha.Key = [System.Text.Encoding]::ASCII.GetBytes($privateKey)

    [byte[]]$publicKeyBytes = [System.Text.Encoding]::ASCII.GetBytes($publicKey)
    [byte[]]$hash = $hmacsha.ComputeHash($publicKeyBytes)
    return [System.BitConverter]::ToString($hash).Replace("-","").ToLower()
}

function ConvertTo-Base64([string] $toEncode){
    [byte[]]$toEncodeAsBytes = [System.Text.ASCIIEncoding]::ASCII.GetBytes($toEncode)
    [string]$returnValue = [System.Convert]::ToBase64String($toEncodeAsBytes)
    return $returnValue
}