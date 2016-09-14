# Required version is 3.0 or above.

#履歴保存対応（CSV形式にて出力）
set PsHist "~\_pshist" -Option Constant

$HKCUShellFolder = Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
$HKLMShellFolder = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'

#ターミナルの環境設定
(Get-Host).UI.RawUI.WindowTitle = "Windows PowerShell $pwd"

#Override
function Prompt() { 
    epcsv -Path $PsHist -InputObject (h)[-1] -Append
    return (Split-Path $pwd -Qualifier) + "~" + (Split-Path $pwd -Leaf) + ">"
}

#履歴情報の読み込み
if (Test-Path $PsHist) {
    ipcsv $PsHist | Add-History
}

#Scriptフォルダ内にあるps1ファイルを全て読み込む
$Script:scripts = Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) "Scripts"
if (Test-Path $Script:scripts) {
    ls $Script:scripts -Include *.ps1 -Recurse -Force | % {& ($_.FullName)}
}