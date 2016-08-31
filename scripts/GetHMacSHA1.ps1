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

Get-HMACSHA1 -publicKey abcdefg -privateKey 12345