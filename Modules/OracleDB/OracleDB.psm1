<#
    Oracle DB へアクセスするためのモジュール

    DBへの接続設定用：
        Set-ConnectionString
    SELECT用：
        Get-OracleDB
    UPDATE, DELETE, INSERT用：
        Update-OracleDB
    SQL整形用：
        Format-SQL
    （注意）
    もし、ユーザーから入力された内容をSQLに組み込む場合、
    SQLインジェクション防止のために当モジュールは使用しないでください。

    minimum requiered version : 5.0
    version : 0.0.3
    author : nimzo
#>
using namespace System
using namespace System.Text
using namespace System.Runtime.InteropServices
using namespace System.Data
using namespace System.Data.OracleClient

Add-Type -AssemblyName System.Data.OracleClient

$ErrorActionPreference = "stop"
Set-StrictMode -Version 3.0

# DBへの接続名
Set-Variable -Name ConnectionString -Scope Script

<#
.Synopsis
   DBへの接続名をセットする
.DESCRIPTION
   このコマンドレットを通して保持された接続情報は
   当モジュールのコマンドレットから引数で指定された場合を除き自動で参照されます。
.EXAMPLE
   Set-ConnectionString -ConnectionString `
   "Data Source=localhost:1521/XE;User ID=hoge;Password=hoge;Integrated Security=false;"
.EXAMPLE
   C:~nimzo> Set-ConnectionString -Step
   ホスト名:ポート名/SID ＞: localhost:1521/XE
   ユーザー名 ＞: hoge
   パスワード ＞: ****
#>
function Set-ConnectionString {
    [CmdletBinding()]
    [Alias()]
    Param (
        [Parameter(Position=0)]
        [String]
        $ConnectionString = "Data Source=localhost:1521/XE;User ID=hoge;Password=hoge;Integrated Security=false;",
        [switch]
        $Step
    )
    if (!$Step) {
        $Script:ConnectionString = $ConnectionString
    } else {
        $userId = Read-Host "ユーザー名 ＞"
        $securedPass = Read-Host -AsSecureString "パスワード ＞"
        $passAsBSTR = [Marshal]::SecureStringToBSTR($securedPass)
        $password = [Marshal]::PtrToStringBSTR($passAsBSTR)
        $connBuilder = New-Object StringBuilder
        [void]$connBuilder.Append("Data Source=localhost:1521/XE;User ID=")
        [void]$connBuilder.Append($userId)
        [void]$connBuilder.Append(";Password=")
        [void]$connBuilder.Append($password)
        [void]$connBuilder.Append(";Integrated Security=false;")
        $Script:ConnectionString = $connBuilder.ToString()
    }
}

<#
.Synopsis
   Oracle DBにSELECT文を実行します。
.DESCRIPTION
   検索で得られた情報をレコードごとに格納された配列として返します。
   Errorが発生した場合はnull値を返します。
   connStrはOracleの接続文字列を指定する必要があり、
   下記のような書式で指定できます。
   "Data Source=localhost:1521/XE;User ID=hoge;Password=hoge;Integrated Security=false;"
.EXAMPLE
   PS:~ > Get-OracleDB -connStr $dataSrc -query "SELECT * FROM EMPLOYEE WHERE EMPNO = 7854"
   
   EMPNO    : 7854
   NAME     : TURNER
   JOB      : SALESMAN
   HIREDATE : 2016/09/06 20:27:09
   SALARY   : 1500
   DEPTNO   : 30
.EXAMPLE
   PS:~ > Get-OracleDB -connStr $dataSrc -query `
   "SELECT NAME, HIREDATE FROM EMPLOYEE WHERE HITEDATE > `
   + "TO_DATE('$([datetime]::now.AddMonths(-1).ToString('yyyy/MM/dd HH:mm:ss'))', 'YYYY/MM/DD HH24:MI:SS')"
   
   NAME     : JAMES
   HIREDATE : 2016/09/06 20:27:09

   NAME     : TURNER
   HIREDATE : 2016/09/06 20:27:09
.EXAMPLE
   PS:~ > $GetCsvFileInfo = {ls | ? {$_.Name -match "^scot_[0-9]{8}\.csv$"} | sort Name | select -Last 1}
   PS:~ > $GetCsvObj = {gc $(& $GetCsvFileInfo) | ConvertFrom-Csv}
   PS:~ > Get-OracleDB "SELECT NAME, HIREDATE FROM employee WHERE empno IN ($((& $GetCsvObj).empno -join ','))" -Verbose
   詳細: Data Source=localhost:1521/XE;User ID=hoge;Password=hoge;Integrated Security=false;
   詳細: SELECT * FROM employee WHERE empno IN (7782,7934)

   NAME     : CLARK
   HIREDATE : 2009/11/01 0:00:00

   NAME     : MILLER
   HIREDATE : 2011/04/01 0:00:00
#>
function Get-OracleDB {
    [CmdletBinding(PositionalBinding=$false)]
    [Alias()]
    [OutputType([System.Data.DataRow])]
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidatePattern("^SELECT.+")]
        [String]
        $Query,
        [String]
        $ConnStr
    )
    if (![String]::IsNullOrEmpty($ConnStr)) {
        Set-ConnectionString -connectionString $ConnStr
    } else {
        if ([String]::IsNullOrEmpty($Script:ConnectionString)) {
            Set-ConnectionString
        }
    }
    Write-Verbose $Script:ConnectionString
    Write-Verbose $Query
    try {
        $oraDa = New-Object OracleDataAdapter($Query, $Script:ConnectionString)
        $dtSet = New-Object DataSet
        [void]$oraDa.Fill($dtSet)
        return $dtSet.Tables[0].Rows
    } catch [Exception] {
        Write-Error -Exception $Global:Error[0].Exception
    }
}

<#
.Synopsis
   Oracle DBにUPDAE、DELETE、INSERT文を実行します。
.DESCRIPTION
   更新、削除、挿入された件数をInt32型の値で返します。
   Errorが発生した場合はnull値を返します。
   connStrはOracleの接続文字列を指定する必要があり、
   下記のような書式で指定できます。
   "Data Source=localhost:1521/XE;User ID=hoge;Password=hoge;Integrated Security=false;"
.EXAMPLE
   PS:~ > Update-OracleDB -connStr $dataSrc -query "DELETE FROM EMPLOYEE WHERE EMPNO IN (7854, 7900)"
   2
.EXAMPLE
   PS:~ > Update-OracleDB -connStr $dataSrc -query `
   "UPDATE EMPLOYEE SET TIME_STAMP = TO_DATE('$([datetime]::now.ToString('yyyy/MM/dd HH:mm:ss'))'," `
   + "'YYYY/MM/DD HH24:MI:SS') WHERE EMPNO IN (7854, 7900, 7911)"
   3
.EXAMPLE
   PS:~ > $GetCsvFileInfo = {ls | ? {$_.Name -match "^scot_[0-9]{8}\.csv$"} | sort Name | select -Last 1}
   PS:~ > $GetCsvObj = {gc $(& $GetCsvFileInfo) | ConvertFrom-Csv}
   PS:~ > Update-OracleDB "UPDATE employee SET salary = $((& $GetCsvObj).salary[1]) WHERE empno = $((& $GetCsvObj).empno[0])" -Verbose
   詳細: Data Source=localhost:1521/XE;User ID=hoge;Password=hoge;Integrated Security=false;
   詳細: UPDATE employee SET salary = 1300 WHERE empno = 7782
   1
#>
function Update-OracleDB { 
    [CmdletBinding(PositionalBinding=$false)]
    [Alias()]
    [OutputType([int])]
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [ValidatePattern("^(UPDATE|DELETE|INSERT).+")]
        [String]
        $Query,
        [String]
        $ConnStr
    )
    if (![String]::IsNullOrEmpty($ConnStr)) {
        Set-ConnectionString -connectionString $ConnStr
    } else {
        if ([String]::IsNullOrEmpty($Script:ConnectionString)) {
            Set-ConnectionString
        }
    }
    Write-Verbose $Script:ConnectionString
    Write-Verbose $Query
    try {
        $oraConn = New-Object OracleConnection($Script:ConnectionString)
        $oraCmd = New-Object OracleCommand($Query, $oraConn)
        $oraConn.Open()
        return $oraCmd.ExecuteNonQuery()
    } catch [Exception] {
        Write-Error -Exception $Global:Error[0].Exception
    } finally {
        $oraConn.Close()
    }
}

<#
.Synopsis
   SQLの整形関数
.DESCRIPTION
   精度低め。Beta版です。
.EXAMPLE
   Format-SQL "select * from employee where empno = 7782"
   SELECT *
     FROM employee
    WHERE empno = 7782
#>
function Format-SQL {
    [OutputType([String])]
    Param (
        [Parameter(Mandatory=$true,
                   Position=0)]
        [String]
        $Qeury
    )
    $Qeury = $Qeury -replace "SELECT ", "SELECT "
    $Qeury = $Qeury -replace " FROM ", "`n  FROM "
    $Qeury = $Qeury -replace " ON ", "`n    ON "
    $Qeury = $Qeury -replace " WHERE ", "`n WHERE "
    $Qeury = $Qeury -replace " AND ", "`n   AND "
    $Qeury = $Qeury -replace " OR ", "`n    OR "
    $Qeury = $Qeury -replace " LIKE ", " LIKE "
    $Qeury = $Qeury -replace " IN ", " IN "
    $Qeury = $Qeury -replace " BETWEEN ", " BETWEEN "
    $Qeury = $Qeury -replace " ORDER BY ", "`n ORDER BY "
    $Qeury = $Qeury -replace " ASC ", " ASC "
    $Qeury = $Qeury -replace " DESC ", " DESC "
    $Qeury = $Qeury -replace " GROUP BY ", "`n GROUP BY "
    $Qeury = $Qeury -replace "UPDATE ", "UPDATE "
    $Qeury = $Qeury -replace " SET ", "`n   SET "
    $Qeury = $Qeury -replace "INSERT INTO ", "INSERT INTO "
    $Qeury = $Qeury -replace "DELETE ", "DELETE "
    return $Qeury
}

Export-ModuleMember -Function *