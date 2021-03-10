<#
    .SYNOPSIS
    Get a list of servers by wrapping a MicroSoft AD PowerShell call

    .DESCRIPTION
    Wrapper to Get-ADComputer to find servers on a network.
    This will also ping each server to return it's IP and include that in the results.

    Windows ActiveDirectory feature must be installed as a prerequsite for running this script

        Install-WindowsFeature -Name RSAT-AD-Tools

    .PARAMETER SearchSring
    Use as filter to Get-ADComputer. Implicit adding of wildcards to either side or string ( eg. 'prod' will send '*prod*' )
#>

[CmdletBinding()]

param(
    [Parameter(Mandatory=$True)][string]$SearchSring, 
    [switch]$NoStream
)

$objectCollection = @()
$filterString = ""
if ($SearchSring)
{
    $filterString = "Name -like `"*$SearchSring*`""
}
else
{
    $filterString = "Name -like `"*`""
}
Write-Verbose($filterString)

$ComputerList = Get-ADComputer -Filter $filterString | Select-Object -Property DistinguishedName,DNSHostName,Name
#Get-ADComputer

foreach ($server in $ComputerList)
{
    $pingedHostName = ""
    $IP = ""
    
    $pingresults = ping -n 1 -w 1 $server.Name
    foreach ($pingresultsline in $pingresults)
    {
        $matchresult = $pingresultsline -match "Pinging (.*?) [\[](.*?)[\]] with 32 bytes of data"
        if ($matchresult)
        {
            if ($matches[1] -ne $server.DNSHostName)
            {
                Write-Verbose("AD and DNS(ping) Servername mismatch. AD: " + $server.DNSHostName + " DNS(ping): " + $matches[1])
            }
            $pingedHostName = $matches[1]
            $IP = $matches[2]
        }
    }
    $newobject = [PSCustomObject]@{
        #DistinguishedName = $server.DistinguishedName
        Name              = $server.Name
        IP                = $IP
        ADHostName        = $server.DNSHostName
        PingedHostName    = $pingedHostName
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
