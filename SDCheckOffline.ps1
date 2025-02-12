# 設定離線 Registry 檔案路徑（假設在桌面）
$offlineHivePath = "[path]"

# 指定要加載到的臨時 Registry 路徑
$mountKey = "HKLM\OfflineSoftware"

# 嘗試加載 Registry Hive
Write-Output "正在載入離線 Registry Hive..."
reg load $mountKey $offlineHivePath

# 確保加載成功
if ($?) {
    Write-Output "成功加載離線 Registry Hive！"

    # 讀取 TaskCache\Tree 註冊表
    $regPath = "HKLM:\OfflineSoftware\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree"

    # 取得所有 Task 子鍵
    $tasks = Get-ChildItem -Path $regPath -ErrorAction SilentlyContinue

    # 檢查是否有 Task
    if ($tasks -eq $null -or $tasks.Count -eq 0) {
        Write-Output "沒有找到任何 Task。請確保離線 Registry Hive 正確。"
    } else {
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
    }

    # **卸載離線 Registry Hive**
    Write-Output "正在卸載離線 Registry Hive..."
    reg unload $mountKey
    Write-Output "卸載成功！"
} else {
    Write-Output "加載離線 Registry Hive 失敗，請確保檔案存在並擁有管理員權限！"
}
