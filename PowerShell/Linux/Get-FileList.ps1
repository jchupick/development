<#
    .SYNOPSIS
    Get list of files from remote servers accessible via standard ssh framework

    .DESCRIPTION
    This script ENTIRELY depends on the standard local ssh config framework.
    You will need to have config entries for servers you care about 
    in ~/.ssh/config and reference those friendly names as the input to this script.

    .PARAMETER Servers
    SSH Server 'friendly' name(s) as defined in ~/.ssh/config.
    Comma separated list.

    .PARAMETER ConfigDir
    Config directory to look for .conf files..\Get-WebsitesFromServers.ps1^C

    .EXAMPLE
    Get-FileList.ps1 server01

    .LINK
    https://github.com/jchupick/development/tree/master/PowerShell/Linux
#>


param(
    [Parameter(Mandatory=$True)][string[]]$Servers, 
    [string]$FilePath = "~", 
    [Parameter(Mandatory=$True)]$FileName
)

$ServerArray  = @()
$ServerArray += Write-Output $Servers
$ServerArray  = $Servers

if (-Not $FilePath.EndsWith("/"))
{
    $FilePath += "/"
}
if ((-Not $FilePath.StartsWith("/")) -And (-Not $FilePath.StartsWith("~")))
{
    $FilePath = ("~/" + $FilePath)
}
$LSCommand = ("`"" + "ls -lad --time-style=long-iso " + $FilePath + $FileName + "`"")
Write-Verbose($LSCommand)

foreach ($ServerIter in $ServerArray)
{
    # Get the Hostname
    Write-Verbose("==============================================")
    #$cmd = "ssh $ServerIter `"hostname`" "
    # Write-Verbose($cmd)
    #$Hostname = (Invoke-Expression $cmd)

    $FileCount = 0
    $FileList  = ssh $ServerIter $LSCommand 2>&1 | ConvertFrom-String -Delimiter '\s+' -PropertyNames Perms,Unk,User,Group,Size,Date,Time,Filename
    
    if ($?)
    {
        foreach ($fileEntry in $FileList)
        {
            $objuser = $fileEntry.User
            if ($objuser -match "KWITZG[\\](.*)")
            {
                $objuser = ($matches[1] + "+")
            }
            $objgroup = $fileEntry.Group
            if ($objgroup -match "KWITZG[\\](.*)")
            {
                $objgroup = ($matches[1] + "+")
            }
            
            Write-Verbose($ServerIter + ": " + $fileEntry.Filename)
            
            $newobject = [PSCustomObject]@{ Servername = $ServerIter }
            
            $newobject | Add-Member -NotePropertyName Filename  -NotePropertyValue $fileEntry.Filename
            $newobject | Add-Member -NotePropertyName Size      -NotePropertyValue $fileEntry.Size
            $newobject | Add-Member -NotePropertyName DateTime  -NotePropertyValue ([DateTime]((Get-Date -Date $fileEntry.Date -Format 'yyyy-MM-dd') + " " + $fileEntry.Time.ToString()))
            $newobject | Add-Member -NotePropertyName User      -NotePropertyValue $objuser
            $newobject | Add-Member -NotePropertyName Group     -NotePropertyValue $objgroup
            
            $newobject
        }
        $FileCount = ($FileList | Measure-Object).Count
    }
    
    Write-Verbose($ServerIter + ": " + $FileCount)
    if ($FileCount -eq 0)
    {
        [PSCustomObject]@{ 
            Servername = $ServerIter 
            FileName   = ""
            Size       = ""
            DateTime   = ""
            User       = ""
            Group      = ""
        }
    }
}
