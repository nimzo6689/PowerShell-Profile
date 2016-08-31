<#
    ZŠ³‹K‰»ƒXƒNƒŠƒvƒg
    ƒƒPƒ^ƒbƒ`API‚Æ‚µ‚Ä’ñ‹Ÿ‚³‚ê‚Ä‚¢‚½ZŠ³‹K‰»API‚Ìƒ‰ƒbƒp[ŠÖ”‚Å‚·B

    @author nimzo
    @see http://blog.livedoor.jp/techblog/archives/67363033.html
#>
$ErrorActionPreference = "stop"
$Script:endpoint = "https://api.loctouch.com/v1/geo/address_normalize?address="

<#
.Synopsis
   ³‹K‰»‚³‚ê‚½ZŠ‚ğæ“¾‚Å‚«‚Ü‚·
.DESCRIPTION
   ³‹K‰»‚³‚ê‚Ä‚¢‚È‚¢ZŠ‚ğw’è‚µ‚ÄÀs‚·‚é‚ÆA
   ˆÈ‰º‚ÌPSCustomObject‚Å³‹K‰»‚³‚ê‚½ZŠ‚ğæ“¾‚Å‚«‚Ü‚·B
.EXAMPLE
   Get-NormalizedAddress -Address "ˆ¤•QŒ§¼Rs•¶‹‹æ4-2¼R‘åŠw–^Œ¤‹†º"

   number region town build   
   ------ ------ ---- -----   
   4-2    ˆ¤•QŒ§¼Rs •¶‹‹æ  ¼R‘åŠw–^Œ¤‹†º
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

$result = Get-NormalizedAddress -Address "ˆ¤•QŒ§¼Rs•¶‹‹æ4-2¼R‘åŠw–^Œ¤‹†º"
Write-Output $result
