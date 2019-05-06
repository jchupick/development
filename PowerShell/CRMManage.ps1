param
(
	[string]$user,
	[string]$pw,
	[string]$url,
	[string]$org,
	[string]$solution,
	[string]$zipfile
)

## Make SolutionPackager.exe available in PATH
$Env:Path += ";C:\Program Files\Microsoft Dynamics CRM SDK\Bin"

$password	= ConvertTo-SecureString $pw -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($user, $password)

$CrmConnection	= Get-CrmConnection -ServerUrl $url -OrganizationName $org -Credential $credential

Export-CrmSolution -conn $CrmConnection -SolutionName $solution -SolutionZipFileName $zipfile
