<#
    .SYNOPSIS
    Dump Wildfly config...

    .DESCRIPTION
    This script ENTIRELY depends on the standard local ssh config framework.
    You will need to have config entries for Apache servers you care about 
    in ~/.ssh/config and reference those friendly names as the input to this script.

    List of Fields to Possibly be returned:

    .PARAMETER Servers
    SSH Server 'friendly' name(s) as defined in ~/.ssh/config.
    Comma separated list.

    .PARAMETER ConfigDir
    Config directory to look for .xml files.
    Common ones:
        /opt/wildfly/standalone/configuration/      (default)

    .EXAMPLE
    Get-WebsitesFromServers.ps1 WebServer1

    .EXAMPLE
    Get-WebsitesFromServers.ps1 WebServer1,WebServer2 -ConfigDir "/opt/bitnami/apps/wordpress/conf"

    .EXAMPLE
    Get-WebsitesFromServers.ps1 WebServer1 | Select-Object Hostname,ServerName,ConfigFile,HostDef,DocumentRoot,IPs | Format-Table

    .LINK
    https://docs.bitnami.com/general/apps/wordpress/
    https://linuxize.com/post/using-the-ssh-config-file/
    https://github.com/jchupick/development/tree/master/PowerShell/Linux
#>


param(
    [Parameter(Mandatory=$True)]$Servers, 
    [string]$ConfigDir = "/opt/wildfly/standalone/configuration" 
)

$ServerArray      = @()

$ServerArray += Write-Output $Servers

# Whack off the trailing '/' if the user passed it...
if ($ConfigDir -match '(.*)[/]$') { $ConfigDir = $Matches[1] }

foreach ($ServerIter in $ServerArray)
{
    # Get the Hostname
    Write-Verbose("==============================================")
    #$cmd = "ssh $ServerIter `"hostname`" "
    Write-Verbose($ServerIter)
    #$Hostname = (Invoke-Expression $cmd)
    $catcmd = ("cat " + $ConfigDir + "/standalone.xml")
    Write-Verbose(("ssh " + $ServerIter + $catcmd))

    $ConnList = ([xml]( ssh $ServerIter $catcmd )).server.profile.subsystem.datasources.datasource.'connection-url'
    
    foreach ($connLine in $ConnList)
    {
        $haveConnectionDef = $connLine -match 'jdbc[:]mysql://(.*?)[.].*?:(.*?)/(.*)'
        
        if ($haveConnectionDef)
        {
            [PSCustomObject]@{ 
                Servername = $ServerIter 
                DBServer   = $matches[1]
                Port       = $matches[2]
                DBName     = $matches[3]
            }
        }
    }
}
