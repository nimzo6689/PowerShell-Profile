$ErrorActionPreference = "stop"

function global:Get-BasicAuth($User, $Pass) {
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
    return [System.Convert]::ToBase64String($credsOfAscii)
}