param(
    [string]$Path,
    # Show the size for each descendant recursively (otherwise, only immediate children)
    [switch]$Recurse
)

function Get-DirectorySize
{
    #.Synopsis
    #  Calculate the size of a folder on disk
    #.Description
    #  Recursively calculate the size of a folder on disk,
    #  outputting it's size, and that of all it's children,
    #  and optionally, all of their children
    param(
        [string]$Path,
        # Show the size for each descendant recursively (otherwise, only immediate children)
        [switch]$Recurse
    )

    if ((-not $Path) -or ($Path.Length -le 0))
    {
        $Path = '.'
    }

    # Get the full canonical FileSystem path:
    if (Test-Path $Path)
    {
        $Path = Convert-Path $Path

        $size     = 0
        $files    = 0
        $folders  = 0

        $items = Get-ChildItem $Path
        foreach ($item in $items)
        {
            if($item.PSIsContainer)
            {
                #Write-Host($item)
                # Call myself recursively to calculate subfolder size
                # Since we're streaming output as we go, 
                #   we only use the last output of a recursive call
                #   because that's the summary object
                if($Recurse)
                {
                    Get-DirectorySize $item.FullName | Tee-Object -Variable subItems
                    if ($subItems) { $subItem = $subItems[-1] }
                }
                else
                {
                    $subItem = Get-DirectorySize $item.FullName | Select -Last 1
                }

                # The (recursive) size of all subfolders gets added
                $size    += $subItem.Size
                $folders += $subItem.Folders + 1
                $files   += $subItem.Files
                Write-Output $subItem
            }
            else
            {
                $files += 1
                $size  += $item.Length
            }
        }
    }

    if ($size -gt 0)
    {
        [PSCustomObject]@{ 
            Folders     = $folders
            Files       = $Files
            Size        = '{0,16}' -f $size
            TotalSizeMB = '{0,11:n1}' -f [single]($size/(1024 * 1024))
            Name        = '{0,-256}'  -f $Path
        }
    }
}

# So when we '. source' it, it won't run
if ($MyInvocation.InvocationName -ne '.')
{
    Get-DirectorySize -Path $Path -Recurse:$Recurse
}
