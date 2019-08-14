param(
	[int]$SleepTimeS = 10
)

# Output something if we start off with no Jobs:
$CurrentJobCount = @(Get-Job).Count
If ($CurrentJobCount -le 0) { Write-Output "No Current Jobs..."; Return }

$masterjobhash = @{}
Write-Output "Monitoring $CurrentJobCount total jobs..."

While (($CurrentJobArray = Get-Job).Count -gt 0)
{
    $RunningJobIdsStr = ""
    $CurrentJobArray | ForEach-Object -Process {
        $JobId    = $_.Id
        $Server   = $_.Location
        $JobState = $_.State

        If ($JobState -ne "Running")
        {
            Write-Output "Server $Server`: JobId $JobId is in state <$JobState>"
            Write-Output "Job Results:"
            $JobText = Receive-Job $JobId -Keep
            # Store it before we delete it
            $masterjobhash.Add($JobId, @{"Id" = $JobId; "State" = $JobState; "Text" = $JobText} )
            Remove-Job $JobId
            Write-Output ""
        }
        Else
        {
            $RunningJobIdsStr += "$JobId "
        }
    }
    
    # Process edge condition for clean output and no unnecessary sleep
    $JobCountLocal = @(Get-Job).Count
    If ($JobCountLocal -gt 0)
    {
        Write-Output "Sleeping for $SleepTimeS seconds to let Jobs complete. $JobCountLocal Jobs still running [ $RunningJobIdsStr]"
        Write-Output ""
        Start-Sleep $SleepTimeS
    }
}

"{0,-4} {1,-12} {2}" -f "Id", "State", "Job Text"
"-------------------------------------------------------------"
foreach ($key in $masterjobhash.Keys)
{
    "{0,-4} {1,-12} {2}" -f $masterjobhash.$key["Id"], $masterjobhash.$key["State"], $masterjobhash.$key["Text"]
    Write-Output ""
}
