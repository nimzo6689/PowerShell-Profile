<#
    住所正規化スクリプト
    ロケタッチAPIとして提供されていた住所正規化APIのラッパー関数です。
    @author nimzo
    @see http://blog.livedoor.jp/techblog/archives/67363033.html
#>
$ErrorActionPreference = "stop"
$Script:endpoint = "https://api.loctouch.com/v1/geo/address_normalize?address="

<#
.Synopsis
   正規化された住所を取得できます
.DESCRIPTION
   正規化されていない住所を指定して実行すると、
   以下のPSCustomObjectで正規化された住所を取得できます。
.EXAMPLE
   Get-NormalizedAddress -Address "愛媛県松山市文京区4-2松山大学某研究室"
   number region town build   
   ------ ------ ---- -----   
   4-2    愛媛県松山市 文京区  松山大学某研究室
#>
function Global:Get-NormalizedAddress {
    [CmdletBinding()]
    [Alias('gna')]
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]
        $Address
    )

    Process {
        $json = CallNormalizedAddressApi -Address $Address | ConvertFrom-Json
        Write-Output $json.result.normalize
    }
}

function Local:CallNormalizedAddressApi([string]$Address) {
    $url = $endpoint + $Address
    $req = [System.Net.WebRequest]::Create($url)
    $req.Method ="GET"
    $req.ContentLength = 0
 
    $reader = new-object System.IO.StreamReader(
        $req.GetResponse().GetResponseStream()
    )
    Write-Output $reader.ReadToEnd()
}