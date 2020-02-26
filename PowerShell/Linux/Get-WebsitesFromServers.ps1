<#
    .SYNOPSIS
    Dump website config information by finding and parsing standard apache .conf files.
    Pulls all .conf files from a given directory (default or user-passed) for 1 or more 
    remote servers and parses them for website configuration based on a known format.

    .DESCRIPTION
    This script ENTIRELY depends on the standard local ssh config framework.
    You will need to have config entries for Apache servers you care about 
    in ~/.ssh/config and reference those friendly names as the input to this script.

    The script itself will simply dump all .conf files from the given directory for each 
    server passed and pull out known information, creating objects for each and 
    returning them.

    List of Fields to Possibly be returned:
        ErrorLog
        ServerName
        DocumentRoot
        SSHAlias 
        HostDef
        ServerAlias
        CustomLog
        Options
        Hostname
        HostType
        IPs
        ServerAdmin
        ConfigFile

    .PARAMETER Servers
    SSH Server 'friendly' name(s) as defined in ~/.ssh/config.
    Comma separated list.

    .PARAMETER ConfigDir
    Config directory to look for .conf files.
    Common ones:
        /etc/apache2/sites-enabled      (default)
        /opt/bitnami/apps/wordpress/conf

    .EXAMPLE
    Get-WebsitesFromServers.ps1 WebServer1

    .EXAMPLE
    Get-WebsitesFromServers.ps1 WebServer1,WebServer2 -ConfigDir "/opt/bitnami/apps/wordpress/conf

    .EXAMPLE
    Get-WebsitesFromServers.ps1 WebServer1 | Select-Object Hostname,ServerName,ConfigFile,HostDef,DocumentRoot,IPs

    .LINK
    https://docs.bitnami.com/general/apps/wordpress/
    https://linuxize.com/post/using-the-ssh-config-file/
    https://github.com/jchupick/development/tree/master/PowerShell/Linux
#>


param(
    [Parameter(Mandatory=$True)][string[]]$Servers, 
    [string]$ConfigDir = "/etc/apache2/sites-enabled" 
)

$ServerArray      = @()
$ConfFileEntries  = @()

$ServerArray += Write-Output $Servers

# Whack off the trailing '/' if the user passed it...
if ($ConfigDir -match '(.*)[/]$') { $ConfigDir = $Matches[1] }

function Parse-ApacheConfXml
{
    param(
        [String[]]$FileLines, 
        [String]$Server,
        [String]$Hostname,
        [String]$IPs,
        [String]$ConfigFilename 
    )

    #$ConfFileDump = Get-Content $Filename
    $ConfFileDump = $FileLines

    $START_SECTION_REGEX = '^<(\w+)\s*([A-Za-z_0-9.:*"$/\\-]*)>$'
    $END_SECTION_REGEX   = '^<[/](\w+)>'
    
    $inSubsection = $false
    $inSection    = $false
    $currentSectionName  = ""
    $currentSectionValue = ""
    $currentSubSectionName = ""
    $NameValuesTempHash    = @{}
    
    foreach ($ConfFileLine in $ConfFileDump)
    {
        $ConfFileLineTrimmed = $ConfFileLine.Trim()
    
        if ($ConfFileLineTrimmed -match '^#')  { Continue }
        if ($ConfFileLineTrimmed.Length -eq 0) { Continue }
    
        if (($ConfFileLineTrimmed -match $START_SECTION_REGEX) -and (-not $inSection))
        {
            $inSection = $true
            $currentSectionName  = $Matches[1]
            $currentSectionValue = $Matches[2]
            Write-Verbose("Start a section ::: " + $currentSectionName + " ===> " + $currentSectionValue)
    
            $NameValuesTempHash.Set_Item('SSHAlias',   $Server)
            $NameValuesTempHash.Set_Item('Hostname',   $Hostname)
            $NameValuesTempHash.Set_Item('IPs',        $IPs)
            $NameValuesTempHash.Set_Item('ConfigFile', $ConfigFilename)
            $NameValuesTempHash.Set_Item('HostType',   $currentSectionName)
            $NameValuesTempHash.Set_Item('HostDef',    $currentSectionValue)
    
            Continue
        }
        elseif ($ConfFileLineTrimmed -match $END_SECTION_REGEX)
        {
            if ($Matches[1] -eq $currentSectionName)
            {
                Write-Verbose("End a section ::: " + $currentSectionName)
    
                $newObject = New-Object PSObject -Property $NameValuesTempHash
                $NameValuesTempHash = @{}
    
                $inSection = $false
                $currentSectionName     = ""
                $currentSectionValue = ""
    
                $newObject
                Continue
            }
        }
        
        if ($inSection)
        {
            if (($ConfFileLineTrimmed -match $START_SECTION_REGEX) -and (-not $inSubsection))
            {
                $inSubsection = $true
                $currentSubSectionName = $Matches[1]
                Write-Verbose("Start a sub-section ===> " + $currentSubSectionName)
                Continue
            }
            elseif ($ConfFileLineTrimmed -match $END_SECTION_REGEX)
            {
                if ($Matches[1] -eq $currentSubSectionName)
                {
                    $inSubsection = $false
                    $currentSubSectionName = ""
                    Write-Verbose("End a sub-section ===> "+ $currentSubSectionName)
                    Continue
                }
            }
    
            # Gather the name-value pairs
            if (-not $inSubsection)
            {
                $namevalue = $ConfFileLineTrimmed -split '\s+', 2
    
                $name = $namevalue[0] ; $value = $namevalue[1]
    
                if ($name.Length -gt 0)
                {
                    Write-Verbose("Name:Value pair: " + $name + " ===> " + $value)
                    $existingvalue  = $NameValuesTempHash.$name
                    $existingvalue += $value + " "
                    $NameValuesTempHash.Set_Item($name, $existingvalue)
                }
            }
        }
    }
}

foreach ($ServerIter in $ServerArray)
{
    # Get the Hostname and IPs
    $cmd = "ssh $ServerIter `" hostname `" "
    $Hostname = (Invoke-Expression $cmd)

    $IPList    = ""
    $IPRawList = @()
    $cmd = "ssh $ServerIter `" ip addr | grep -P '^\s*?inet\s' `" "
    Write-Verbose("==============================================")
    Write-Verbose($cmd)
    $IPRawList = (Invoke-Expression $cmd)

    foreach ($IPIter in $IPRawList)
    {
        Write-Verbose($IPIter)
        $GotIPMatch = $IPIter.Trim() -match 'inet\s+(.*?)[/]'
        if ($GotIPMatch)
        {
            if ($Matches[1] -eq "127.0.0.1") { Continue }
            $IPList += ($Matches[1] + " ")
        }
    }
    $IPList = $IPList -replace ".$"         # Chop off the last character
    Write-Verbose($IPList)

    #$cmd = "ssh $ServerIter 'ls -lL --time-style=+%Y%m%d-%H%M%S' /etc/apache2/sites-enabled/ | tail -n+2"
    $cmd = "ssh $ServerIter 'ls -1L $ConfigDir' "

    Write-Verbose("==============================================")
    Write-Verbose($cmd)
    $SiteEnabledConfFiles = Invoke-Expression $cmd

    #foreach ($ConfFileIter in $SiteEnabledConfFiles)
    foreach ($ConfFile in $SiteEnabledConfFiles)
    {
        #$ConfFileDetails = $ConfFileIter -split '\s+'
        #$ConfFile = $ConfFileDetails[6]
        if ($ConfFile -notmatch '[.]conf$') { Continue }

        $conffilecatcmd = "ssh $ServerIter 'cat $ConfigDir/$ConfFile' "
        $ConfFileDump   = Invoke-Expression $conffilecatcmd

        Parse-ApacheConfXml -FileLines $ConfFileDump $ServerIter $Hostname $IPList $ConfFile
    }
}
#$ConfFileEntries

