# Required version is 3.0 or above.

#����ۑ��Ή��iCSV�`���ɂďo�́j
set PsHist "~\_pshist" -Option Constant

$HKCUShellFolder = Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
$HKLMShellFolder = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'

#�^�[�~�i���̊��ݒ�
(Get-Host).UI.RawUI.WindowTitle = "Windows PowerShell $pwd"

#Override
function Prompt() { 
    epcsv -Path $PsHist -InputObject (h)[-1] -Append
    return (Split-Path $pwd -Qualifier) + "~" + (Split-Path $pwd -Leaf) + ">"
}

#�������̓ǂݍ���
if (Test-Path $PsHist) {
    ipcsv $PsHist | Add-History
}

#Script�t�H���_���ɂ���ps1�t�@�C����S�ēǂݍ���
$Script:scripts = Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) "Scripts"
if (Test-Path $Script:scripts) {
    ls $Script:scripts -Include *.ps1 -Recurse -Force | % {& ($_.FullName)}
}