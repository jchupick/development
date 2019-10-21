#
#
#
param(
    [Parameter(Mandatory=$True)]$Servers, 
    [switch]$CPUCheck, 
    [switch]$NoStream
)

$ServerArray      = @()
$objectCollection = @()

$ServerArray += $Servers

foreach ($server in $ServerArray)
{
    $currentDT = Get-Date     # Get a new DateTime for each server
    $osess     = Get-CimInstance -Class Win32_OperatingSystem -ComputerName $server

    foreach ($osobj in $osess)      # Should just be 1
    {
        $ProcessorArray         = @()
        $ProcessorString        = ''
        $processorWMIArray      = @()

        $OSFullString       = $osobj.Name -Split '\|'
        $restartDateTime    = $osobj.LastBootUpTime
        $uptime             = $currentDT - $restartDateTime
        $strUptime          = ""
        $UptimeMatchObject  = $uptime -match '(.*)[.].*'
        $strUptime          = '{0,12}'      -f $Matches[1]
        $percentMemoryUsage = '{0,10:n1} %' -f (100 - (($osobj.FreePhysicalMemory / $osobj.TotalVisibleMemorySize) * 100))
        
        $newobject = [PSCustomObject]@{
            MachineName          = $osobj.PSComputerName
            FreePhysicalMemory   = $osobj.FreePhysicalMemory
            TotalMemory          = $osobj.TotalVisibleMemorySize
            'MemoryUsage%'       = $percentMemoryUsage
            OS                   = $OSFullString[0]
            Version              = $osobj.Version
            Uptime               = $strUptime
            RestartDateTime      = $restartDateTime
        }
        
        if ($CPUCheck)
        {
            # For CPU
            $processorWMIArray  = Get-CimInstance -Class Win32_PerfFormattedData_Counters_ProcessorInformation -ComputerName $server
            
            foreach ($processorobj in $processorWMIArray)
            {
                $customprocessorobject = $null
                
                if ($processorobj.Name -eq '_Total')
                {
                    $customprocessorobject = [PSCustomObject]@{
                        ID     = 'TOTAL'
                        PctUse = '{0:d2}' -f $processorobj.PercentProcessorTime
                    }
                }
                else
                {
                    $CPUMatchObj = $processorobj.Name -match '\d+[,](\d+)'
                    if ($CPUMatchObj)
                    {
                        $customprocessorobject = [PSCustomObject]@{
                            ID     = 'CPU' + $Matches[1]
                            PctUse = '{0:d2}' -f $processorobj.PercentProcessorTime
                        }
                    }
                }
                if ($customprocessorobject)
                { 
                    $ProcessorArray  += $customprocessorobject
                    $ProcessorString += $customprocessorobject.ID + ' ' + $customprocessorobject.PctUse + '% '
                }
            }
            $newobject | Add-Member -MemberType NoteProperty -Name CPU       -Value $ProcessorArray  -Force
            $newobject | Add-Member -MemberType NoteProperty -Name CPUString -Value $ProcessorString  -Force
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
