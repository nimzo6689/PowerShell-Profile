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
   ³‹K‰»‚³‚ê‚½ZŠ‚ðŽæ“¾‚Å‚«‚Ü‚·
.DESCRIPTION
   ³‹K‰»‚³‚ê‚Ä‚¢‚È‚¢ZŠ‚ðŽw’è‚µ‚ÄŽÀs‚·‚é‚ÆA
   ˆÈ‰º‚ÌPSCustomObject‚Å³‹K‰»‚³‚ê‚½ZŠ‚ðŽæ“¾‚Å‚«‚Ü‚·B
.EXAMPLE
   Get-NormalizedAddress -Address "ˆ¤•QŒ§¼ŽRŽs•¶‹ž‹æ4-2¼ŽR‘åŠw–^Œ¤‹†Žº"
   number region town build   
   ------ ------ ---- -----   
   4-2    ˆ¤•QŒ§¼ŽRŽs •¶‹ž‹æ  ¼ŽR‘åŠw–^Œ¤‹†Žº
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