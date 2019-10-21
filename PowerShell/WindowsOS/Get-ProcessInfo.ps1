#
#
#
param(
    [Parameter(Mandatory=$True)]$Servers, 
    [string]$Name = '*',
    [switch]$NoStream
)

$ServerArray      = @()
$objectCollection = @()

$ServerArray += Write-Output $Servers

foreach ($server in $ServerArray)
{
    $currentDT = Get-Date     # Get a new DateTime for each server
    $processes = Get-WmiObject -Class Win32_Process -ComputerName $server | Where-Object { $_.Name -like $Name }

    foreach ($process in $processes)
    {
        $processDateTime    = $process.ConvertToDateTime($process.CreationDate)
        $processrunningTime = $currentDT - $processDateTime
        $strRunningTime     = ""
        $rtMatchObject      = $processrunningTime -match '(.*)[.].*'
        $strRunningTime     = $Matches[1]
        $perfprocessobject  = Get-WmiObject -Class Win32_PerfFormattedData_PerfProc_Process -ComputerName $server | Where-Object { $_.IDProcess -like $process.ProcessId }
        
        $newobject = [PSCustomObject]@{
            MachineName     = $process.PSComputerName
            ProcessId       = $process.ProcessId
            WorkingSet      = $process.WorkingSetSize
            StartDateTime   = $processDateTime
            RunningTime     = "{0,12}" -f $strRunningTime
            Executable      = $process.Name
            CPUPercent      = $perfprocessobject.PercentProcessorTime
        }
        if ($NoStream)
        {
            $objectCollection += $newobject
        }
        else
        {
            $newobject
        }
    }
}
# Send it down the pipeline
if ($NoStream)
{
    $objectCollection | Sort-Object StartDateTime
}
