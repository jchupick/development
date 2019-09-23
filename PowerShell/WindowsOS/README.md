### WMI and System Info Queries
One-liner to get a service by name, get the associated proceess, and find out what it's start time was

```
(((Get-Process -Id (Get-WmiObject win32_service | Where-Object {$_.Name -like 'plugplay'}).ProcessId).StartTime)).ToString('yyyyMMdd HH:mm:ss')
```

Get CPU and Memory use for a process on a given server
```
Get-WmiObject -ComputerName webserver-prod01,webserver-prod02 -Class Win32_PerfFormattedData_PerfProc_Process | Where-Object { $_.Name -like 'w3wp*' } |  Select-Object PSComputerName,Name,IDProcess,PercentProcessorTime,WorkingSet
```

Total and Free Memory on a Server
```
Get-WmiObject -ComputerName webserver-prod01 -Class Win32_OperatingSystem | Select-Object PSComputerName,FreePhysicalMemory,TotalVisibleMemorySize
```
Similar, but using different WMI Class
```
Get-WmiObject -ComputerName webserver-prod01 -Class Win32_PerfFormattedData_PerfOS_Memory | Select-Object PSComputerName,CommittedBytes,AvailableBytes
```
### Windows EventLog Queries
```
Get-EventLog -ComputerName localhost -LogName System | Where-Object { ($_.TimeWritten -gt '2019-05-19') -and ($_.Source -like 'S*') -and ($_.EntryType -like 'Error') }
```
