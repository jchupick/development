### Initial Module Install
```
Install-Module VMware.VimAutomation.Core
```

### 
Getting past invalid server certificate

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
