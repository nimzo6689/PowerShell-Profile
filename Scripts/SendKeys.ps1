Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName System.Windows.Forms

<#
.Synopsis
   実行中の任意のプロセスにキーストロークを送る操作をします。
.EXAMPLE
   Send-Key "test%({Enter})" -ProcessName "LINE"
#>
function Send-Key
{
    [CmdletBinding()]
    [Alias("sdky")]
    [OutputType([int])]
    Param
    (
        # キーストローク
        # アプリケーションに送りたいキーストローク内容を指定します。
        # キーストロークの記述方法は下記のWebページを参照。
        # https://msdn.microsoft.com/ja-jp/library/system.windows.forms.sendkeys(v=vs.110).aspx
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        $KeyStroke,

        # プロセス名
        # キーストロークを送りたいアプリケーションのプロセス名を指定します。
        # 複数ある場合は、PIDが一番低いプロセスを対象とする。
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $ProcessName,

        # 待機時間
        # コマンドを実行する前の待機時間をミリ秒単位で指定します。
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [int]
        $Wait = 0
    )

    Begin
    {
    }
    Process
    {
        $Process = ps | ? {$_.Name -eq $ProcessName} | select -First 1
        Write-Verbose $Process", KeyStroke = "$KeyStroke", Wait = "$Wait" ms."
        sleep -Milliseconds $Wait
        [Microsoft.VisualBasic.Interaction]::AppActivate($Process.ID)
        [System.Windows.Forms.SendKeys]::SendWait($KeyStroke)
    }
    End
    {
    }
}