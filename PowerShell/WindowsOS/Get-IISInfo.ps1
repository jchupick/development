#
#
#
param(
    [Parameter(Mandatory=$True)]$Servers,
    [switch]$NoStream
)
# REGEX breakdown
#
$REGEX_APPCMD_SITE         = '(.*?)\s*?["](.*?)["]\s*?[(]id:(.*?),bindings:(.*?),state:(.*?)[)]'
$REGEX_APPCMD_APP          = '(.*?)\s*?["](.*?)["]\s*?[(]applicationPool:(.*?)[)]'
$REGEX_APPCMD_APPPOOL      = '(.*?)\s*?["](.*?)["]\s*?[(].*?state:(.*?)[)]'
$REGEX_APPCMD_WP           = '(.*?)\s*?["](.*?)["]\s*?[(](.*?)[)]'

$ServerArray      = @()
$objectCollection = @()

$ServerArray += Write-Output $Servers

foreach ($server in $ServerArray)
{
    $currentDT   = Get-Date     # Get a new DateTime for each server
    $SiteObjects = Invoke-Command -ComputerName $server { C:\Windows\System32\inetsrv\appcmd list site }

    foreach ($sitestring in $SiteObjects)
    {
        $thisapppool        = $null
        $thisapppoolstatus  = $null
        $thisprocessid      = $null
        
        $HaveSiteMatch = $sitestring -match $REGEX_APPCMD_SITE
            
        if ($HaveSiteMatch)
        {
            $thissite           = $Matches[2]
            $thissitebindings   = $Matches[4]
            $thissiteid         = $Matches[3]
            $thissitestatus     = $Matches[5]
            
            # Use the sitename to get the app info (append '/' to do so)
            $thissitearg = $thissite + '/'
            $appobject = Invoke-Command -ComputerName $server -ScriptBlock { param($s) C:\Windows\System32\inetsrv\appcmd list app $s } -ArgumentList $thissitearg
            
            $HaveAppMatch = $appobject -match $REGEX_APPCMD_APP
            if ($HaveAppMatch)
            {
                $thisapppool = $Matches[3]
            }
                
            $apppoolobject     = Invoke-Command -ComputerName $server -ScriptBlock { param($p) C:\Windows\System32\inetsrv\appcmd list apppool $p } -ArgumentList $thisapppool
            $HaveAppPoolMatch  = $apppoolobject -match $REGEX_APPCMD_APPPOOL
            if ($HaveAppPoolMatch)
            {
                $thisapppoolstatus = $Matches[3]
            }

            $thisapppoolarg = '/apppool.name:' + $thisapppool
            $wpobject       = Invoke-Command -ComputerName $server -ScriptBlock { param($i) C:\Windows\System32\inetsrv\appcmd list wp $i } -ArgumentList $thisapppoolarg
            $HaveWPMatch    = $wpobject -match $REGEX_APPCMD_WP

            if ($HaveWPMatch)
            {
                $thisprocessid = $Matches[2]
            }

            $strProcessrunningTime = ''
            $processDateTime       = $null
            if ($thisprocessid)
            {
                $WMIProcFilterStr      = 'IdProcess=' + $thisprocessid
                $procobject            = Get-WmiObject -Class Win32_PerfFormattedData_PerfProc_Process -ComputerName $server -Filter $WMIProcFilterStr
                $processrunningTime    = [TimeSpan]::fromseconds($procobject.ElapsedTime)
                $strProcessrunningTime = '{0,11}' -f $processrunningTime.ToString()
                $processDateTime       = $currentDT - $processrunningTime
            }

            $newobject = [PSCustomObject]@{
                MachineName   = $server
                SiteId        = [int]$thissiteid
                Site          = $thissite
                SiteStatus    = $thissitestatus
                Bindings      = $thissitebindings
                ProcessID     = [int]$thisprocessid
                StartDateTime   = $processDateTime
                RunningTime   = $strProcessrunningTime
                AppPool       = $thisapppool
                AppPoolStatus = $thisapppoolstatus
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
        else
        {
            Write-Host("Warning - process string does not match expected format")
            Write-Host("Process String is`: $procstring")
        }
    }
}
if ($NoStream)
{
    # Send it down the pipeline
    $objectCollection
}
