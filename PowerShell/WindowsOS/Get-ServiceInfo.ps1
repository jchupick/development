#
#
#
param(
    [Parameter(Mandatory=$True)]$Servers, 
    [string]$Name = '*',
    [switch]$NoStream
)

$ServerArray  = @()
$objectArray  = @()
$ServerArray += Write-Output $Servers

foreach ($server in $ServerArray)
{
    # Get a new DateTime for each server
    $currentDT       = Get-Date
    # Allow for '*' wildcards
    $WMISvcFilterStr = 'Name like "' + ($Name -replace '[*]','%') + '"'
    $wmiservices     = Get-CimInstance -Class Win32_Service -ComputerName $server -Filter $WMISvcFilterStr

    foreach ($wmiservice in $wmiservices)
    {
        # Need to treat quoted and not quoted differently
        $fullpath         = $wmiservice.PathName
        $matchObjectQuote = $fullpath -match '^["]'
        $matchObject      = $null
        if ($matchObjectQuote)
        {
            $matchObject = $fullpath -match  '^["].*[\\]([^"]*)["]'
        }
        else
        {
            $matchObject = $fullpath -match  '.*[\\]([^"]*)'
        }
        $exepath = $Matches[1]
        
        # Set defaults so that we display properly 
        # in case the service is not running
        $processDateTime       = $null
        $strProcessrunningTime = $null
        
        if ($wmiservice.State -eq 'Running')
        {
            $WMIProcFilterStr      = 'IdProcess=' + $wmiservice.ProcessId
            $procobject            = Get-WmiObject -Class Win32_PerfFormattedData_PerfProc_Process -ComputerName $server -Filter $WMIProcFilterStr
            $processrunningTime    = [TimeSpan]::fromseconds($procobject.ElapsedTime)
            $strProcessrunningTime = '{0,11}' -f $processrunningTime.ToString()
            $processDateTime       = $currentDT - $processrunningTime
        }
        
        # Get the actual service object in case the caller wants it
        $service = Get-Service -ComputerName $server -Name $wmiservice.Name
        
        $newobject = [PSCustomObject]@{
            MachineName     = $wmiservice.PSComputerName
            ProcessId       = $wmiservice.ProcessId
            State           = $wmiservice.State
            Status          = $wmiservice.Status
            StartMode       = $wmiservice.StartMode
            Name            = $wmiservice.Name
            RunAs           = $wmiservice.StartName
            Executable      = $exepath
            StartDateTime   = $processDateTime
            RunningTime     = $strProcessrunningTime
            FullPath        = $wmiservice.PathName
            ServiceObj      = $service
        }

        if ($NoStream)
        {
            $objectArray  += $newobject
        }
        else
        {
            # Output the objects one at a time - powershell seems to know how to 
            # still smash the output into an array of custom objects.
            $newobject
        }
    }
}
if ($NoStream)
{
    $objectArray
}
