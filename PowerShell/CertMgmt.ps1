$SERVER_NAME       = "webfortstg"
$CERT_REMOTE_PATH  = "\\" + $SERVER_NAME + "\C$\Users\Public\Documents\"

Copy-Item "C:\Users\Public\Documents\ansi-wildcard.2019.pfx" $CERT_REMOTE_PATH
Enter-PSSession -ComputerName $SERVER_NAME 

$SITE_FULLADDRESS  = "wsstg.ansi.org"
$SITE_NAME         = "wsstg"
$SITE_IPADDRESS    = "192.168.200.11"

$CERT_PASSPHRASE   = "ansi"
$CERT_FRIENDLYNAME = "ansi-2019"
$CERT_FILENAME     = "C:\Users\Public\Documents\ansi-wildcard.2019.pfx"


# Try to get the AppID (GUID) for the existing website
# If it's not there, generate a new GUID
#
$AppIDStr          = ""
$AppIDObjectByIp   = netsh http show sslcert ipport=${SITE_IPADDRESS}:443         | Select-String "Application ID"
$AppIDObjectByIp
$AppIDObjectByName = netsh http show sslcert hostnameport=${SITE_FULLADDRESS}:443 | Select-String "Application ID"
$AppIDObjectByName
$WebBindingObject  = $null

if ($AppIDObjectByIp) {
    $AppIDUnsplitStr = $AppIDObjectByIp.ToString()
    $AppIDStr        = $AppIDUnsplitStr.Split(":")[1].Trim()

    $WebBindingObject = Get-WebBinding -IPAddress $SITE_IPADDRESS -Port 443

    if ($WebBindingObject) {
        Remove-WebBinding -InputObject $WebBindingObject 
        Write-Output "Existing binding removed"
        netsh  http delete sslcert ipport=${SITE_IPADDRESS}:443
        Write-Output "Existing cert removed for ${SITE_IPADDRESS}:443"
    }
} elseif ($AppIDObjectByName) {
    $AppIDUnsplitStr = $AppIDObjectByName.ToString()
    $AppIDStr        = $AppIDUnsplitStr.Split(":")[1].Trim()

    $WebBindingObject = Get-WebBinding -HostHeader $SITE_FULLADDRESS -Port 443

    if ($WebBindingObject) {
        Remove-WebBinding -InputObject $WebBindingObject 
        Write-Output "Existing binding removed"
        netsh  http delete sslcert hostnameport=${SITE_FULLADDRESS}:443
        Write-Output "Existing cert removed for ${SITE_FULLADDRESS}:443"
    }
} else {
    $AppIDStr = [guid]::NewGuid().ToString("B")
}

$AppIDStr

$CERT_FILENAME
$password            = ConvertTo-SecureString $CERT_PASSPHRASE -AsPlainText -Force
$CertOject           = Import-PfxCertificate -Password $password -FilePath $CERT_FILENAME -CertStoreLocation Cert:\LocalMachine\My

$ExistingCertHashStr = $CertOject.Thumbprint
Write-Output $CERT_FILENAME + " imported. Thumbprint is: " + $ExistingCertHashStr

$CertPath   = "Cert:\LocalMachine\My\" + $ExistingCertHashStr
(Get-ChildItem -Path $CertPath).FriendlyName = $CERT_FRIENDLYNAME

$CertHashStr = ""
$CertHashObj = netsh http show sslcert hostnameport=${SITE_FULLADDRESS}:443 | Select-String "Certificate Hash"
$CertHashObj

if ($CertHashObj) {
    $CertHashUnsplitStr = $CertHashObj.ToString()
    $CertHashStr        = $CertHashUnsplitStr.Split(":")[1].Trim()
    $CertHashStr
}

if ($CertHashStr -ne $ExistingCertHashStr) {
    netsh http add sslcert hostnameport=${SITE_FULLADDRESS}:443 certhash=${ExistingCertHashStr} certstorename=MY appid=${AppIDStr}
}

New-WebBinding -name $SITE_NAME -Protocol https -IPAddress $SITE_IPADDRESS -HostHeader $SITE_FULLADDRESS -Port 443 -SslFlags 1 -Force
