### Useful Commands
One-liner to get a service by name, get the associated proceess, and find out what it's start time was
    (((Get-Process -Id (Get-WmiObject win32_service | Where-Object {$_.Name -like 'plugplay'}).ProcessId).StartTime)).ToString('yyyyMMdd HH:mm:ss')
