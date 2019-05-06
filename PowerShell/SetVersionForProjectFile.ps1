Param([string]$filename, [string]$major, [string]$minor, [string]$build, [string]$patch)

Remove-Item 'temp0.txt' -ErrorAction silentlycontinue
Remove-Item 'temp1.txt' -ErrorAction silentlycontinue

[System.IO.File]::WriteAllText('temp0.txt', [System.IO.File]::ReadAllText($filename))

if ($major)
{ 
	[System.IO.File]::WriteAllText('temp1.txt', ([System.IO.File]::ReadAllText('temp0.txt') -replace '(<FileVersion>)(\d+)[.](\d+)[.](\d+)[.](\d+)(</FileVersion>)', ('$1' + '$2.' + '$3.' + '$4.' + '$5' + '$6 ')))
	[System.IO.File]::WriteAllText('temp0.txt',  [System.IO.File]::ReadAllText('temp1.txt'))
}

if ($minor)
{
	[System.IO.File]::WriteAllText('temp1.txt', ([System.IO.File]::ReadAllText('temp0.txt') -replace '(<FileVersion>)(\d+)[.](\d+)[.](\d+)[.](\d+)(</FileVersion>)', ('$1' + '$2.' + $minor + '.$4.' + '$5' + '$6 ')))
	[System.IO.File]::WriteAllText('temp0.txt',  [System.IO.File]::ReadAllText('temp1.txt'))
}

if ($build)
{
	[System.IO.File]::WriteAllText('temp1.txt', ([System.IO.File]::ReadAllText('temp0.txt') -replace '(<FileVersion>)(\d+)[.](\d+)[.](\d+)[.](\d+)(</FileVersion>)', ('$1' + '$2.' + '$3.' + $build + '.$5' + '$6 ')))
	[System.IO.File]::WriteAllText('temp0.txt',  [System.IO.File]::ReadAllText('temp1.txt'))
}

if ($patch)
{
	[System.IO.File]::WriteAllText('temp1.txt', ([System.IO.File]::ReadAllText('temp0.txt') -replace '(<FileVersion>)(\d+)[.](\d+)[.](\d+)[.](\d+)(</FileVersion>)', ('$1' + '$2.' + '$3.' + '$4.' + $patch + '$6 ')))
	[System.IO.File]::WriteAllText('temp0.txt',  [System.IO.File]::ReadAllText('temp1.txt'))
}

[System.IO.File]::ReadAllText('temp0.txt')

Remove-Item 'temp0.txt' -ErrorAction silentlycontinue
Remove-Item 'temp1.txt' -ErrorAction silentlycontinue
