<#
    Require -Version 5.0 or above.

    �y�V�u�b�N�X���Ќ���API �փA�N�Z�X���邽�߂̃R�}���h���b�g�Q
    Rakuten Web Service / �y�V�u�b�N�X���Ќ���API (version:2013-05-22)

    version : 0.0.1
    author : nimzo
    see    : https://webservice.rakuten.co.jp/api/booksbooksearch/
#>
using namespace System
using namespace System.Text
using namespace System.Web

Add-Type -AssemblyName System.Web

$ErrorActionPreference = "stop"
Set-StrictMode -Version 3.0

<#
.Synopsis
   �y�V�u�b�N�X���Ќ���API����R�~�b�N�����擾���܂��B
.DESCRIPTION
   �^�C�g�����w�肵�A�q�b�g�������̒�����W���\�[�g�ŏ��30���܂ł�z��ŕԂ��܂��B
   ��������͈ȉ��̂悤�ɂȂ�܂��B

   title          : ONE�@PIECE�i��77�j
   titleKana      : ���� �s�[�X
   subTitle       : 
   subTitleKana   : 
   seriesName     : �W�����v�E�R�~�b�N�X
   seriesNameKana : �W�����v �R�~�b�N�X
   contents       : �X�}�C��
   author         : ���c�h��Y
   authorKana     : �I�_,�G�C�C�`���E
   publisherName  : �W�p��
   size           : �R�~�b�N
   isbn           : 9784088803265
   itemCaption    : 
   salesDate      : 2015�N04��03��
   itemPrice      : 432
   listPrice      : 0
   discountRate   : 0
   discountPrice  : 0
   itemUrl        : http://books.rakuten.co.jp/rb/13158718/
   affiliateUrl   : 
   smallImageUrl  : http://thumbnail.image.rakuten.co.jp/@0_mall/book/cabinet/3265
                 /9784088803265.jpg?_ex=64x64
   mediumImageUrl : http://thumbnail.image.rakuten.co.jp/@0_mall/book/cabinet/3265
                 /9784088803265.jpg?_ex=120x120
   largeImageUrl  : http://thumbnail.image.rakuten.co.jp/@0_mall/book/cabinet/3265
                 /9784088803265.jpg?_ex=200x200
   chirayomiUrl   : 
   availability   : 1
   postageFlag    : 0
   limitedFlag    : 0
   reviewCount    : 204
   reviewAverage  : 4.71
   booksGenreId   : 001001001008
.NOTES
   ���[�U�[���ϐ��A�܂��́A�V�X�e�����ϐ���RWS_ApplicationId��ݒ肷��K�v������܂��B
.EXAMPLE
   $onePiece77 = Get-ComicInfo -Title "ONE PIECE 77"
   �����̃L�[���[�h���w�肵�����ꍇ�͔��p�X�y�[�X�����܂��B
.EXAMPLE
   $onePieceLatest = 77..79 | % {"ONE PIECE $_"} | Get-ComicInfo -Verbose
   �p�C�v�Ŏ��s�������ꍇ��1�R�[��������1�b�̃X���[�v�������s���܂��B
.EXAMPLE
   Get-ComicInfo -title "ONE PIECE" -Sort highPrice -Verbose | select -First 1
   �y�V�u�b�N�X���Ќ���API��sort�p�����[�^��S�ė��p���邱�Ƃ��ł��܂��B
   PowerShell�̃V���^�b�N�X�n�C���C�g���@�\�����邽�߂ɁA�l�͈ꕔ�ύX���Ă��܂��B
#>
function Get-ComicInfo {
    [CmdletBinding()]
    [Alias()]
    [OutputType([PSCustomObject[]])]
    Param (
        # ���Ђ̃^�C�g�����猟���B
        # �����L�[���[�h���猟���������ꍇ�́A���p�X�y�[�X�ŋ�؂��ĉ������B
        # ���ꂼ��̃L�[���[�h��2�����ȏ�ł���K�v������܂��B�i�ᔽ�����ꍇ��HTTP�X�e�[�^�X�R�[�h��400�ŕԋp����܂��B�j
        # �ȉ��A�������x�ł��B
        # "ONE PIECE (1)"              -> OK�@�ꌅ�̊����́i�j�ň͂��K�v������B
        # "ONEPIECE(1)" or "ONEPIECE1" -> OK�@����̃^�C�g���ɃX�y�[�X�����邪�A�l�߂Ďw�肵�Ă��\�B
        # "ONE PIECE (01)"             -> NG�@0�l�߂œo�^����Ă��Ȃ��f�[�^�Ɋւ��Ă͂��̏ꍇ�擾�s�\�B
        # "�R�c�����7�l�̖���(1)"          -> OK
        # "�R�c����Ǝ��l�̖���(1)"         -> OK�@�����̏ꍇ�A�������ł��\�B�܂��A���p�^�S�p�͉e�����Ȃ��B
        # "�R�c�N��7�l�̖���(1)"          -> NG�@�Ђ炪�ȂƊ����͋�ʂ����B
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Title,
        # standard      : �W��
        # sales         : ����Ă���
        # oldest        : ������(�Â�)
        # newest        : ������(�V����)
        # lowPrice      : ���i������
        # highPrice     : ���i������
        # reviewCount   : ���r���[�̌����������i�W�������L�[���[�h�Ɋ֘A�������ʂ����₷���j
        # reviewAverage : ���r���[�̕]��(����)������
        [ValidateSet("standard", "sales", "oldest", "newest", 
                     "lowPrice", "highPrice", "reviewCount", "reviewAverage")]
        [string]
        $Sort = "standard"
    )

    Begin {
        switch ($Sort) {
            "oldest" {
                $replacedSort = $Sort.Replace("oldest", "+releaseDate")
            }
            "newest" {
                $replacedSort = $Sort.Replace("newest", "-releaseDate")
            }
            "lowPrice" {
                $replacedSort = $Sort.Replace("lowPrice", "+itemPrice")
            }
            "highPrice" {
                $replacedSort = $Sort.Replace("highPrice", "-itemPrice")
            }
            Default {
                $replacedSort = $Sort
            }
        }
        $encodedSort = [HttpUtility]::UrlEncode($replacedSort)
        $uriBuiler = New-Object StringBuilder
        [void]$uriBuiler.Append("https://app.rakuten.co.jp/services/api/BooksBook/Search/20130522?sort=")
        [void]$uriBuiler.Append($encodedSort)
        [void]$uriBuiler.Append("&applicationId=")
        [void]$uriBuiler.Append($env:RWS_ApplicationId)
        [void]$uriBuiler.Append("&elements=Items&formatVersion=2&booksGenreId=001001&title=")
        $uri = $uriBuiler.ToString()
    }

    Process {
        try {
            sleep -Seconds 1
            $encodedTitle = [HttpUtility]::UrlEncode($title)
            $response = curl -Uri ($uri + $encodedTitle)
            $result = $response.Content | ConvertFrom-Json
            return $result.Items
        } catch [Exception] {
            Write-Error -Exception $Global:Error[0].Exception
        }
    }
}