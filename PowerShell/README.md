## Windows PowerShell notes:

### Resources
https://devblogs.microsoft.com/scripting <br />
https://gallery.technet.microsoft.com/scriptcenter 

### Slack JSON Parser

#### Usage
    Convert-SlackJSONToCSV.ps1 <Slack json filename>

#### Sample input file:
    SlackChannelDump.json

### DateTime
Get 'now' date and time and format

    Get-Date -Format 'yyyyMMdd-HHmmss'

Format existing DateTime object

```
$dtobject = Get-Date
$dtobject.ToString('yyyyMMdd HH:mm:ss')
```

Convert WMI FOrmatted Date and Time to DateTime object
```
$mypid = 6620
$wmiobj         = Get-WmiObject -Class Win32_Process -ComputerName webserver-prod01 | Where-Object { $_.ProcessId -eq $mypid }
$newdatetimeobj = $wmiobj.ConvertToDateTime($wmiobj.CreationDate)
```
