### Initial Module Install
```
Install-Module VMware.VimAutomation.Core
```

### Allow it to run
```
Set-ExecutionPolicy RemoteSigned
```

### Getting past invalid server certificate
```
Set-PowerCLIConfiguration -InvalidCertificateAction Prompt
```

### Basic Commands
Make a connection to a VCenter instance
```
$credential = Get-Credential domain\jchupick
Connect-VIServer -Server vcenter-instance.domain.local -Credential $credential
```

Get Datastores, VM's and Disks
```
$vm = Get-VM -Name vm1
$ds = Get-Datastore -Name datastore1

Get-Datastore -Name datastore1 | Get-VM
Get-Datastore -VM $vm
$vm | Get-Datastore

Get-HardDisk -VM $vm
Get-HardDisk -Datastore $ds

$vm | Get-HardDisk
$ds | Get-HardDisk
```

### Digging Deeper

#### Get a vm object then get all of the Guest details:
```
$vm = Get-VM -Name vm1
$vm.Guest | Select *
```
#### Get a list of all Snapshots and what VM they were created from
```
Get-VM | Get-Snapshot | Select-Object Name,@{l='Date';e={$_.Created}},VM,@{l='SizeGB';e={[math]::round($_.SizeGB, 2)}}
```

### Scripts in this Repo
#### Get-VMDetail.ps1
Wrapper to pull the most usefull info from at ```Get-VM``` call.
You will need to have already made a connection to a VCenter instance for this to work.
