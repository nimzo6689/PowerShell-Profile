Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName System.Windows.Forms

<#
.Synopsis
   ���s���̔C�ӂ̃v���Z�X�ɃL�[�X�g���[�N�𑗂鑀������܂��B
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
        # �L�[�X�g���[�N
        # �A�v���P�[�V�����ɑ��肽���L�[�X�g���[�N���e���w�肵�܂��B
        # �L�[�X�g���[�N�̋L�q���@�͉��L��Web�y�[�W���Q�ƁB
        # https://msdn.microsoft.com/ja-jp/library/system.windows.forms.sendkeys(v=vs.110).aspx
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        $KeyStroke,

        # �v���Z�X��
        # �L�[�X�g���[�N�𑗂肽���A�v���P�[�V�����̃v���Z�X�����w�肵�܂��B
        # ��������ꍇ�́APID����ԒႢ�v���Z�X��ΏۂƂ���B
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $ProcessName,

        # �ҋ@����
        # �R�}���h�����s����O�̑ҋ@���Ԃ��~���b�P�ʂŎw�肵�܂��B
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