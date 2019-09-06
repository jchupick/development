param( 
    $file1, 
    $file2,
    [string]$Match = '',
    [switch]$IncludeEqual
)
$content1 = Get-Content $file1 
$content2 = Get-Content $file2

$comparedLines = Compare-Object -IncludeEqual:$IncludeEqual $content1 $content2

$linenumber = 1;

$comparedLines | foreach {
    if (($Match.Length -le 0) -or ($_.InputObject -match $Match))
    {
        [PSCustomObject] @{
            Line            = [int]$lineNumber 
            InputObject     = $_.InputObject
            SideIndicator   = $_.SideIndicator  
        }
    }
    $linenumber++
}
