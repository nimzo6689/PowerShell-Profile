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