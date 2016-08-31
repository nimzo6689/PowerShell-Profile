<#
    �Z�����K���X�N���v�g
    ���P�^�b�`API�Ƃ��Ē񋟂���Ă����Z�����K��API�̃��b�p�[�֐��ł��B

    @author nimzo
    @see http://blog.livedoor.jp/techblog/archives/67363033.html
#>
$ErrorActionPreference = "stop"
$Script:endpoint = "https://api.loctouch.com/v1/geo/address_normalize?address="

<#
.Synopsis
   ���K�����ꂽ�Z�����擾�ł��܂�
.DESCRIPTION
   ���K������Ă��Ȃ��Z�����w�肵�Ď��s����ƁA
   �ȉ���PSCustomObject�Ő��K�����ꂽ�Z�����擾�ł��܂��B
.EXAMPLE
   Get-NormalizedAddress -Address "���Q�����R�s������4-2���R��w�^������"

   number region town build   
   ------ ------ ---- -----   
   4-2    ���Q�����R�s ������  ���R��w�^������
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

$result = Get-NormalizedAddress -Address "���Q�����R�s������4-2���R��w�^������"
Write-Output $result
