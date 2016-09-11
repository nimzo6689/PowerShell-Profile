<#
    Require -Version 5.0 or above.

    楽天ブックス書籍検索API へアクセスするためのコマンドレット群
    Rakuten Web Service / 楽天ブックス書籍検索API (version:2013-05-22)

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
   楽天ブックス書籍検索APIからコミック情報を取得します。
.DESCRIPTION
   タイトルを指定し、ヒットした情報の中から標準ソートで上位30件までを配列で返します。
   得られる情報は以下のようになります。

   title          : ONE　PIECE（巻77）
   titleKana      : ワン ピース
   subTitle       : 
   subTitleKana   : 
   seriesName     : ジャンプ・コミックス
   seriesNameKana : ジャンプ コミックス
   contents       : スマイル
   author         : 尾田栄一郎
   authorKana     : オダ,エイイチロウ
   publisherName  : 集英社
   size           : コミック
   isbn           : 9784088803265
   itemCaption    : 
   salesDate      : 2015年04月03日
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
   ユーザー環境変数、または、システム環境変数にRWS_ApplicationIdを設定する必要があります。
.EXAMPLE
   $onePiece77 = Get-ComicInfo -Title "ONE PIECE 77"
   複数のキーワードを指定したい場合は半角スペースを入れます。
.EXAMPLE
   $onePieceLatest = 77..79 | % {"ONE PIECE $_"} | Get-ComicInfo -Verbose
   パイプで実行させた場合は1コール当たり1秒のスリープ処理が行われます。
.EXAMPLE
   Get-ComicInfo -title "ONE PIECE" -Sort highPrice -Verbose | select -First 1
   楽天ブックス書籍検索APIのsortパラメータを全て利用することができます。
   PowerShellのシンタックスハイライトを機能させるために、値は一部変更しています。
#>
function Get-ComicInfo {
    [CmdletBinding()]
    [Alias()]
    [OutputType([PSCustomObject[]])]
    Param (
        # 書籍のタイトルから検索。
        # 複数キーワードから検索したい場合は、半角スペースで区切って下さい。
        # それぞれのキーワードは2文字以上である必要があります。（違反した場合はHTTPステータスコードが400で返却されます。）
        # 以下、検索精度です。
        # "ONE PIECE (1)"              -> OK　一桁の巻数は（）で囲う必要がある。
        # "ONEPIECE(1)" or "ONEPIECE1" -> OK　漫画のタイトルにスペースが入るが、詰めて指定しても可能。
        # "ONE PIECE (01)"             -> NG　0詰めで登録されていないデータに関してはこの場合取得不可能。
        # "山田くんと7人の魔女(1)"          -> OK
        # "山田くんと七人の魔女(1)"         -> OK　数字の場合、漢数字でも可能。また、半角／全角は影響しない。
        # "山田君と7人の魔女(1)"          -> NG　ひらがなと漢字は区別される。
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Title,
        # standard      : 標準
        # sales         : 売れている
        # oldest        : 発売日(古い)
        # newest        : 発売日(新しい)
        # lowPrice      : 価格が安い
        # highPrice     : 価格が高い
        # reviewCount   : レビューの件数が多い（標準よりもキーワードに関連した結果が得やすい）
        # reviewAverage : レビューの評価(平均)が高い
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