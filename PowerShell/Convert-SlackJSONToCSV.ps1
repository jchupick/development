param(
    [string]$SlackJSONFile
)
$EPOCH_START = [datetime]'01/01/1970'

$ConvertedObject = Get-Content $SlackJSONFile | ConvertFrom-Json

# 2 passes - first to get an ID to username mapping, 
# second to change the '@' references from userid to username 
# from that mapping

$userhash = @{}

foreach ($message in $ConvertedObject)
{
    if (($message.user) -and 
        (-not ($userhash.ContainsKey($message.user))) -and 
        ($message.user_profile.real_name)
       )
    {
        $userhash.Add($message.user, $message.user_profile.real_name)
    }
}

$REGEX_USERID = '<@(U[A-Z0-9]{8})>'
foreach ($message in $ConvertedObject)
{
    $textline  = $message.text
    
    $havematch = $textline -match $REGEX_USERID
    while ($havematch)
    {
        if ($userhash.ContainsKey($Matches[1]))
        {
            $userinmsg = $userhash[$Matches[1]]
        }
        else
        {
            $userinmsg = '---unknown---'
        }
        $textline  = $textline -replace $Matches[1], $userinmsg
        # try again in case there are more than 1 '@' references in the message
        $havematch = $textline -match $REGEX_USERID
    }
    
    [PSCustomObject]@{
            DateTime = $EPOCH_START.AddSeconds($message.ts)
            User     = $message.user_profile.real_name
            UserId   = $message.user
            Message  = $textline
        }
}
