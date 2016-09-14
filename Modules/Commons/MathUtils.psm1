<#
.Synopsis
   2�_�Ԃ̋������擾
.DESCRIPTION
   �q���x�j�̌��������Ƃ�2�_�Ԃ̋�����Double�^�ŕԂ��܂��B
   �Ԃ��l�̓f�t�H���g�ł̓L�����[�g���ł����A
   Unit�p�����[�^�ɂ��A�}�C���ƃm�b�g���T�|�[�g����Ă��܂��B
.EXAMPLE
   Calc-Distance -Lat1 35.6213625 -Lon1 139.5381833 -Lat2 35.6282346 -Lon2 139.5820428
   4.03700773767409
.EXAMPLE
   $TwoPoints = [PSCustomObject] @{
       Lat1 = 35.6213625
       Lon1 = 139.5381833
       Lat2 = 35.6282346
       Lon2 = 139.5820428
   }
   $TwoPoints | Calc-Distance
   4.03700773767409
#>
function Calc-Distance {
    [CmdletBinding()]
    [Alias()]
    [OutputType([double])]
    Param (
        # �ܓx�P
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [double]
        $Lat1,
        # �o�x�P
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [double]
        $Lon1,
        # �ܓx�Q
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [double]
        $Lat2,
        # �ܓx�Q
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [double]
        $Lon2,
        # K(�L�����[�g��), M(�}�C��), N(�m�b�g)
        [ValidateSet("K", "M", "N")]
        [string]
        $Unit = "K"
    )
    [double]$deg2rad = [Math]::PI / [Single]180
    [double]$rad2deg = [Single]180 / [Math]::PI
    [double]$theta = $lon1 - $lon2
    $sinLat = [Math]::Sin($lat1 * $deg2rad) * [Math]::Sin($lat2 * $deg2rad)
    $cosLat = [Math]::Cos($lat1 * $deg2rad) * [Math]::Cos($lat2 * $deg2rad) * [Math]::Cos($theta * $deg2rad)
    $dist = [Math]::Acos($sinLat + $cosLat) * $rad2deg
    $miles = $dist * 60 * 1.1515
    switch ($Unit) {
        "K" {
            return $miles * 1.609344
        }
        "N" {
            return $dist * 0.8684
        }
        "M" {
            return $dist
        }
    }
}