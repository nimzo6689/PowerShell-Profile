# Required version is 3.0 or above.

#����ۑ��J�X�^�}�C�Y�Ή�
set PsHist "~\_pshist" -Option Constant
set PSReadLineHist $env:APPDATA\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt -Option Constant

$HKCUShellFolder = Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
$HKLMShellFolder = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'

#�^�[�~�i���̊��ݒ�
(Get-Host).UI.RawUI.WindowTitle = "Windows PowerShell $pwd"

#Override
function Prompt() {
    if ($?) {
        (h)[-1] | epcsv -Path $PsHist -Append -NoTypeInformation
    }
    return (Split-Path $pwd -Qualifier) + "~" + (Split-Path $pwd -Leaf) + ">"
}

#�������̓ǂݍ���
if (Test-Path $PsHist) {
    $filteredHistory = ipcsv $PsHist | 
        #ISE����ps1�t�@�C�������s�������̂��폜
        ? {$_.CommandLine -notmatch "^[:A-Za-z0-9\._\\-]+\.ps1"} |
        #�����s�Ŏ��s�����R�}���h�͍폜�B`���g�p���Ă��Ȃ����s�s�i�Ⴆ�΃p�C�v�Ȃǁj�͏�������܂���B
        ? {$_.CommandLine -notmatch '(`|\|)$'} |
        #�d�����������̍폜
        sort CommandLine -Unique | sort Id | select -Last 9999
    #Id�̔�єԂ��l�߂�
    for ($i = 1; $i -lt $filteredHistory.Count; $i++) {
        $filteredHistory[$i].Id = $i
    }
    $filteredHistory | epcsv -Path $PsHist -NoTypeInformation
    $filteredHistory | % {$_.CommandLine} | Out-File -FilePath $PSReadLineHist -Encoding utf8
    $filteredHistory | Add-History
}

#Script�t�H���_���ɂ���ps1�t�@�C����S�ēǂݍ���
$Script:scripts = Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) "Scripts"
if (Test-Path $Script:scripts) {
    ls $Script:scripts -Include *.ps1 -Recurse -Force | % {& ($_.FullName)}
}