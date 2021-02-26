<#
    .SYNOPSIS
    Put a synopsis here...

    .DESCRIPTION
    Put a description here...

    .PARAMETER 

    .PARAMETER 

    .EXAMPLE
    
    .LINK
    http://dev.mysql.com/downloads/connector/net/
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
