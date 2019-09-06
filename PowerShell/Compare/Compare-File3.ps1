param(
    $file1,
    $file2,
    [string]$Match = '', 
    [switch]$IncludeEqual
)
$fnonly1       = (Get-ChildItem $file1).Name
$fnonly2       = (Get-ChildItem $file2).Name
$content1      = Get-Content $file1
$content2      = Get-Content $file2
$comparedLines = Compare-Object $content1 $content2 -IncludeEqual:$IncludeEqual | group { $_.InputObject.ReadCount } | sort Name

$comparedLines | foreach {
    $curr = $_
    if (($Match.Length -le 0) -or ($curr.Group[0].InputObject -match $Match) -or ($curr.Group[1].InputObject -match $Match))
    {
        switch ($_.Group[0].SideIndicator)
        {
            "==" { $right = $left = $curr.Group[0].InputObject; break }
            "=>" { $right,$left   = $curr.Group[0].InputObject, $curr.Group[1].InputObject; break }
            "<=" { $right,$left   = $curr.Group[1].InputObject, $curr.Group[0].InputObject; break }
        }
        [PSCustomObject] @{
            Line     = [int]$_.Name
            $fnonly1 = $left
            $fnonly2 = $right
        }
    }
}
