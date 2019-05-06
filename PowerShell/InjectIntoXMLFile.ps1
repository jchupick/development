Param([string]$filename, [string]$snippetfile, [switch]$help)

$ScriptName = $MyInvocation.MyCommand.Name
# Define various regex's CONSTS here 
#
# For MS csproj file
#     -type starts with either is 'proj' or 'prj'
#     Search and populate for both <Version> and <FileVersion>
#     4th digit exists for <FileVersion>, does not for <Version>
#
$PROJECT_MATCHREGEX  = "^(.*?</Project.*)"
#
$INJECT_SNIPPET = @"
  <ItemGroup>
    <None Include="node_modules\**">
      <CopyToPublishDirectory>Always</CopyToPublishDirectory>
    </None>
  </ItemGroup>
"@
$PROJECT_END_BLOCK = "</Project>"

function Usage
{
    Param([string]$errorstring)
    
    Write-Output ""
    Write-Output "Usage: "
    if ($errorstring) { Write-Output "" }
    if ($errorstring) { Write-Output "    $errorstring" }
    Write-Output ""
    Write-Output "    $ScriptName <filename>           "
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

foreach ($line in Get-Content $filename)
{
    if ($line -match $PROJECT_MATCHREGEX)
    {
    }
    else
    {
        Write-Output $line
    }
}
Write-Output $INJECT_SNIPPET
Write-Output $PROJECT_END_BLOCK
