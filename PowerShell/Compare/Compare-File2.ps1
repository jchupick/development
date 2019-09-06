param( 
    $file1, 
    $file2,
    [string]$Match = ''
)
$content1 = Get-Content $file1 
$content2 = Get-Content $file2
$comparedLines = Compare-Object $content1 $content2 -IncludeEqual | Sort-Object { $_.InputObject.ReadCount } 
    
$lineNumber = 0 
$comparedLines | foreach {
    ## Keep track of the current line number, using the line 
    ## numbers in the "after" file for reference. 
    if ($_.SideIndicator -eq "==" -or $_.SideIndicator -eq "=>") 
    { 
        $lineNumber = $_.InputObject.ReadCount 
    } 
    if (($Match.Length -le 0) -or ($_.InputObject -match $Match))
    { 
        if ($_.SideIndicator -ne "==") 
        { 
            if ($_.SideIndicator -eq "=>") 
            { 
                $lineOperation = "added" 
            } 
            elseif ($_.SideIndicator -eq "<=") 
            { 
                $lineOperation = "deleted" 
            } 
                
            [PSCustomObject] @{
                Line       = [int]$lineNumber 
                Operation  = $lineOperation 
                Text       = $_.InputObject  
            } 
        } 
    } 
}
