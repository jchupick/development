Param([string]$filename, [string]$major, [string]$minor, [string]$build, [string]$patch, [string]$type, [switch]$help, [switch]$getversion)

$ScriptName = $MyInvocation.MyCommand.Name
# Define various regex's CONSTS here 
#
# For MS csproj file
#     -type starts with either is 'proj' or 'prj'
#     Search and populate for both <Version> and <FileVersion>
#     4th digit exists for <FileVersion>, does not for <Version>
#
$PROJECT_MATCHREGEX  = "^(.*?<.*?Version>)(\d+)[.](\d+)[.](\d+)[.]?(\d+)?(</.*?Version>.*)"
#
# For AssemblyInfo.cs file
#     -type starts with 'ass'
#     Search and populate for both <AssebmlyVersion> and <AssemblyFileVersion>
#
$ASSEMBLY_MATCHREGEX = "^(.*?Assembly.*?Version.*?)(\d+)[.](\d+)[.](\d+)[.](\d+)(.*)"
# 
# Increment operation
$INCREMENT_MATCHREGEX = "^inc.*"

# Default
$matchregex = $PROJECT_MATCHREGEX

function Usage
{
    Param([string]$errorstring)
    
    Write-Output ""
    Write-Output "Usage: "
    if ($errorstring) { Write-Output "" }
    if ($errorstring) { Write-Output "    $errorstring" }
    Write-Output ""
    Write-Output "    $ScriptName <filename>           "
    Write-Output "        OR                           "
    Write-Output "    $ScriptName -filename <filename> "
    Write-Output ""
}

if ($help)
{
    Usage
    Exit
}

if ((-not $filename) -or ($filename -and $filename.length -le 0))
{
    Usage "ERROR: -filename parameter is REQUIRED (either first argument or -filename named parameter)"
    Exit
}

if (-not [System.IO.File]::Exists($filename))
{
    Usage "ERROR: $filename does NOT exist"
    Exit
}

if (($major) -and (($major -notmatch $INCREMENT_MATCHREGEX) -and ($major -notmatch '\d+')))
{
    Usage "ERROR: -major must be an integer or 'increment' or 'inc'"
    Exit
}
if (($minor) -and (($minor -notmatch $INCREMENT_MATCHREGEX) -and ($minor -notmatch '\d+')))
{
    Usage "ERROR: -minor must be an integer or 'increment' or 'inc'"
    Exit
}
if (($build) -and (($build -notmatch $INCREMENT_MATCHREGEX) -and ($build -notmatch '\d+')))
{
    Usage "ERROR: -build must be an integer or 'increment' or 'inc'"
    Exit
}
if (($patch) -and (($patch -notmatch $INCREMENT_MATCHREGEX) -and ($patch -notmatch '\d+')))
{
    Usage "ERROR: -patch must be an integer or 'increment' or 'inc'"
    Exit
}

if ($type -and ($type -match '^ass'))
{
    $matchregex = $ASSEMBLY_MATCHREGEX
}
elseif ($type -and ($type -match '^pr[o]?j'))
{
    $matchregex = $PROJECT_MATCHREGEX
}

foreach ($line in Get-Content $filename)
{
    if ($line -match $matchregex)
    {
        $leading      = $matches[1]
        $filemajor    = $matches[2]
        $fileminor    = $matches[3]
        $filebuild    = $matches[4]
        $filepatch    = $matches[5]
        $trailing     = $matches[6]
        
        if ($major)
        {
            if ($major -match '\d+')
            {
                $filemajor = $major
            }
            elseif ($major -match $INCREMENT_MATCHREGEX)
            {
                $filelmajorint = [int]$filemajor
                $filelmajorint++
                $filemajor = [string]$filelmajorint
            }
        }
        if ($minor)
        {
            if ($minor -match '\d+')
            {
                $fileminor = $minor
            }
            elseif ($minor -match $INCREMENT_MATCHREGEX)
            {
                $filelminorint = [int]$fileminor
                $filelminorint++
                $fileminor = [string]$filelminorint
            }
        }
        if ($build)
        {
            if ($build -match '\d+')
            {
                $filebuild = $build
            }
            elseif ($build -match $INCREMENT_MATCHREGEX)
            {
                $filelbuildint = [int]$filebuild
                $filelbuildint++
                $filebuild = [string]$filelbuildint
            }
        }
        if ($patch -and $filepatch)     # Check if the 4th digit is in the line, if not - do nothing
        {
            if ($patch -match '\d+')
            {
                $filepatch = $patch
            }
            elseif ($patch -match $INCREMENT_MATCHREGEX)
            {
                $filelpatchint = [int]$filepatch
                $filelpatchint++
                $filepatch = [string]$filelpatchint
            }
        }
        
        # 4th digit may not exist in the line, so don't write it back out
        if ($filepatch)
        {
            if (-not $getversion) 
            { 
                Write-Output "$leading$filemajor.$fileminor.$filebuild.$filepatch$trailing"
            }
            else 
            {
                $VersionString = "$filemajor.$fileminor.$filebuild.$filepatch"
            }
        }
        else
        {
            if (-not $getversion)
            { 
                Write-Output "$leading$filemajor.$fileminor.$filebuild$trailing"
            }
            else
            {
                $VersionString = "$filemajor.$fileminor.$filebuild.$filepatch"
            }
        }
    }
    else
    {
        if (-not $getversion) { Write-Output $line }
    }
}
if ($getversion) { Write-Output $VersionString }
