param(
    [string]$Filename = ("~\.ssh\config"), 
    [switch]$NoStream, 
    [Parameter(Mandatory=$True)][switch]$Go, 
    [string]$EntryMatch 
)

$SSHDefEntries = @()

# Get the contents of the file as a single string (not array) for splitting
Write-Verbose("Getting SSH config from: $Filename")
$wholefileasstring = (Get-Content $Filename) | Where-Object { $_.Trim() -notmatch '^[#]' } | Out-String

# Hacky way to split on 'Host', but still keep 'Host' in the resulting split array
$SPLIT_DUMMY_DELIMITER = "-----"
$splitarray = $wholefileasstring.Replace("Host ", $SPLIT_DUMMY_DELIMITER + "Host ") -split $SPLIT_DUMMY_DELIMITER

foreach ($line in $splitarray)
{
    # Ignore empty results from the split
    # ( Should just be element [0] )
    $line = $line.Trim()
    if ($line.Length -eq 0) { Continue }

    $linearray  = $line -split '\s+'
    $linekey = $linearray[0] ; $linevalue = $linearray[1]

    if (($linekey -ieq "Host") -and ($linevalue -notmatch '[*]'))
    {
        if (($EntryMatch.Length -gt 0) -and ($linevalue -notmatch $EntryMatch)) { continue }

        $newobject = [PSCustomObject]@{
            Host         = $linevalue
            HostName     = ""
            IdentityFile = ""
            User         = ""
            Port         = ""
        }    
        $SSHDefEntries += $newobject
    }
}

foreach ($IterObject in $SSHDefEntries)
{
    foreach ($line in $splitarray)
    {
        # Ignore empty results from the split
        # ( Should just be element [0] )
        $line = $line.Trim()
        if ($line.Length -eq 0) { Continue }

        $linearray  = $line -split '\s+'
        $currentkey = ""
        # Reset all the key and value variables
        $HostValue = $HostNameValue = $IdentityFileValue = $UserValue = $PortValue = ""

        # After splitting on whitespace, even numbered array elements (starting with 0)
        # are 'keys' and odd numbered elements are their values.
        # So 'toggle' by resetting the key to emtpy string each time we get a pair
        #
        foreach ($item in $linearray)
        {
            if ($currentkey -eq "")
            {
                $currentkey = $item
            }
            else
            {
                if      ($currentkey -eq "Host")         { $HostValue         = $item } 
                elseif  ($currentkey -eq "HostName")     { $HostNameValue     = $item }
                elseif  ($currentkey -eq "IdentityFile") { $IdentityFileValue = $item }
                elseif  ($currentkey -eq "User")         { $UserValue         = $item }
                elseif  ($currentkey -eq "Port")         { $PortValue         = $item }
                $currentkey = ""
            }
        }

        $keyregex = $HostValue.Replace('*', '.*?')
        $IterHostString = $IterObject.Host 

        if ($IterHostString -match $keyregex)
        {
            if ($IterObject.HostName.Length -le 0)
            {
                Write-Verbose("Host entry added for: $IterHostString from match with $HostNameValue")
                $IterObject.HostName = $HostNameValue
            }
            if ($IterObject.IdentityFile.Length -le 0)
            {
                Write-Verbose("IdentityFile entry added for: $IterHostString from match with $HostValue")
                $IterObject.IdentityFile = $IdentityFileValue
            }
            if ($IterObject.User.Length -le 0)
            {
                Write-Verbose("User entry added for: $IterHostString from match with $HostValue")
                $IterObject.User = $UserValue
            }
            if ($IterObject.Port.Length -le 0)
            {
                Write-Verbose("Port entry added for: $IterHostString from match with $HostValue")
                $IterObject.Port = $PortValue
            }
        }
    }
    if (-not $NoStream) { $IterObject }
}
if ($NoStream) { $SSHDefEntries }
