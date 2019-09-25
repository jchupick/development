## WMI

### WMI Core Classes
One-liner to get a service by name, get the associated proceess, and find out what it's start time was

```
(((Get-Process -Id (Get-WmiObject win32_service | Where-Object {$_.Name -like 'plugplay'}).ProcessId).StartTime)).ToString('yyyyMMdd HH:mm:ss')
```

Total and Free Memory on a Server
```
Get-WmiObject -ComputerName webserver-prod01 -Class Win32_OperatingSystem | Select-Object PSComputerName,FreePhysicalMemory,TotalVisibleMemorySize
```

Processor Information
```
Get-WmiObject -Class Win32_Processor -ComputerName webserver-prod01 | Select-Object -Property *
```

### WMI Performance Counters Classes

Get CPU and Memory use for a process on a given server
```
Get-WmiObject -ComputerName webserver-prod01,webserver-prod02 -Class Win32_PerfFormattedData_PerfProc_Process | Where-Object { $_.Name -like 'w3wp*' } |  Select-Object PSComputerName,Name,IDProcess,PercentProcessorTime,WorkingSet
```

Memory Usage for a Server
```
Get-WmiObject -ComputerName webserver-prod01 -Class Win32_PerfFormattedData_PerfOS_Memory | Select-Object PSComputerName,CommittedBytes,AvailableBytes
```

Processor Information
```
Get-WmiObject -Class Win32_PerfFormattedData_PerfOS_Processor -ComputerName webserver-prod01
```

## Windows EventLog
```
Get-EventLog -ComputerName localhost -LogName System | Where-Object { ($_.TimeWritten -gt '2019-05-19') -and ($_.Source -like 'S*') -and ($_.EntryType -like 'Error') }
```
