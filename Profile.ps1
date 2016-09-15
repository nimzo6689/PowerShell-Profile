# Required version is 3.0 or above.

#履歴保存カスタマイズ対応
set PsHist "~\_pshist" -Option Constant
set PSReadLineHist $env:APPDATA\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt -Option Constant

$HKCUShellFolder = Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
$HKLMShellFolder = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'

#ターミナルの環境設定
(Get-Host).UI.RawUI.WindowTitle = "Windows PowerShell $pwd"

#Override
function Prompt() {
    if ($?) {
        (h)[-1] | epcsv -Path $PsHist -Append -NoTypeInformation
    }
    return (Split-Path $pwd -Qualifier) + "~" + (Split-Path $pwd -Leaf) + ">"
}

#履歴情報の読み込み
if (Test-Path $PsHist) {
    $filteredHistory = ipcsv $PsHist | 
        #ISEからps1ファイルを実行したものを削除
        ? {$_.CommandLine -notmatch "^[:A-Za-z0-9\._\\-]+\.ps1"} |
        #複数行で実行したコマンドは削除。`を使用していない実行行（例えばパイプなど）は除去されません。
        ? {$_.CommandLine -notmatch '(`|\|)$'} |
        #重複した履歴の削除
        sort CommandLine -Unique | sort Id | select -Last 9999
    #Idの飛び番を詰める
    for ($i = 1; $i -lt $filteredHistory.Count; $i++) {
        $filteredHistory[$i].Id = $i
    }
    $filteredHistory | epcsv -Path $PsHist -NoTypeInformation
    $filteredHistory | % {$_.CommandLine} | Out-File -FilePath $PSReadLineHist -Encoding utf8
    $filteredHistory | Add-History
}

#Scriptフォルダ内にあるps1ファイルを全て読み込む
$Script:scripts = Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) "Scripts"
if (Test-Path $Script:scripts) {
    ls $Script:scripts -Include *.ps1 -Recurse -Force | % {& ($_.FullName)}
}