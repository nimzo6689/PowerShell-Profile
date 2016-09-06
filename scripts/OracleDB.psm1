<#
    Oracle DB へアクセスするためのコマンドレット群

    SELECT用：
        Get-OracleDB
    UPDATE, DELETE, INSERT用：
        Update-OracleDB

    @author nimzo
#>
$ErrorActionPreference = "stop"

Add-Type -AssemblyName System.Data.OracleClient

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
   "SELECT * FROM EMPLOYEE WHERE HITEDATE > `
   + "TO_DATE('$([datetime]::now.AddMonths(-1).ToString('yyyy/MM/dd HH:mm:ss'))', 'YYYY/MM/DD HH24:MI:SS')"
   
   EMPNO    : 7900
   NAME     : JAMES
   JOB      : CLERK
   HIREDATE : 2016/09/06 20:27:09
   SALARY   : 950
   DEPTNO   : 30

   EMPNO    : 7854
   NAME     : TURNER
   JOB      : SALESMAN
   HIREDATE : 2016/09/06 20:27:09
   SALARY   : 1500
   DEPTNO   : 30
#>
function Get-OracleDB {
    [CmdletBinding(PositionalBinding=$false)]
    [Alias()]
    [OutputType([array])]
    Param (
        [Parameter(Mandatory=$true)]
        [string]
        $connStr,
        [Parameter(Mandatory=$true)]
        [ValidatePattern("^SELECT.+$")]
        [string]
        $query
    )
    Write-Verbose $query
    try {
        $OraConn = New-Object System.Data.OracleClient.OracleConnection($connStr)
        $oraDa = New-Object System.Data.OracleClient.OracleDataAdapter($query, $OraConn)
        $dtSet = New-Object System.Data.DataSet
        [void]$OraDa.Fill($dtSet)
        return $dtSet.Tables[0].Rows
    } catch [Exception] {
        Write-Output Error[0]
        return $null
    } finally {
        $oraConn.Close()
        $oraConn.Dispose()
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
#>
function Update-OracleDB { 
    [CmdletBinding(PositionalBinding=$false)]
    [Alias()]
    [OutputType([int])]
    Param (
        [Parameter(Mandatory=$true)]
        [string]
        $connStr,
        [Parameter(Mandatory=$true)]
        [ValidatePattern("^(UPDATE|DELETE|INSERT).+$")]
        [string]
        $query
    )
    Write-Verbose $query
    try {
        $oraConn = New-Object System.Data.OracleClient.OracleConnection($connStr)
        $oraCmd = $oraConn.CreateCommand()
        $oraConn.Open()
        $oraCmd.CommandText = $query
        $recordCnt = $oraCmd.ExecuteNonQuery()
        return $recordCnt
    } catch [Exception] {
        Write-Output Error[0]
        return $null
    } finally {
        $oraCmd.Dispose()
        $oraConn.Close()
        $oraConn.Dispose()
    }
}
