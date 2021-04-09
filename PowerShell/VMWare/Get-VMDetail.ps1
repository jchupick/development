#
#
#
param(
    [string]$Name = '*',
    [switch]$NoStream
)

$objectCollection = @()

$vms = Get-VM -Name $Name

foreach ($vmitem in $vms)
{
    $ipCollection = @()
    
    foreach ($ip in $vmitem.Guest.IPAddress)
    {
        # Poor man's regex for IPv4 IPs, but good enough to filter out IPv6
        if ($ip -match '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
        {
            $ipCollection += $ip
        }
    }
    
    $newobject = [PSCustomObject]@{
        Name        = $vmitem.Name
        PowerState  = $vmitem.PowerState
        Id          = $vmitem.Id
        State       = $vmitem.Guest.State
        #IP          = $vmitem.Guest.IPAddress
        IP          = $ipCollection
        OS          = $vmitem.Guest.OSFullName
        VMHost      = $vmitem.VMHost
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

# Send it down the pipeline
if ($NoStream)
{
    $objectCollection | Sort-Object -Property Name
}
