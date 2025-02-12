# 定義 Registry 路徑
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree"

# 取得所有 Task 子鍵
$tasks = Get-ChildItem -Path $regPath -ErrorAction SilentlyContinue

# 確保 Registry Key 存在
if ($tasks -eq $null -or $tasks.Count -eq 0) {
    Write-Output "沒有找到任何 Task。請確保註冊表路徑正確。"
    exit
}

# 建立輸出格式化表格
$taskList = @()

# 遍歷 Task 並列出所有 Task 和 SD 值
foreach ($task in $tasks) {
    try {
        # 取得該 Task 子鍵的所有值
        $values = Get-ItemProperty -Path $task.PSPath -ErrorAction Stop

        # 取得 SD 值（如果存在）
        $sdValue = if ($values.PSObject.Properties.Name -contains "SD") {
            [BitConverter]::ToString($values.SD)
        } else {
            "無 SD 值"
        }

        # 加入到輸出列表
        $taskList += [PSCustomObject]@{
            TaskName = $task.Name
            SDValue = $sdValue
        }
    }
    catch {
        $taskList += [PSCustomObject]@{
            TaskName = $task.Name
            SDValue = "讀取失敗/權限不足"
        }
    }
}

# 輸出表格格式
$taskList | Format-Table -AutoSize
