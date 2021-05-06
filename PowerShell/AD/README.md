## Summary
Module is **ActiveDirectory**

#### Installation

    Install-WindowsFeature -Name RSAT-AD-Tools
(NOTE: this is equivalent to using the **Turn Windows Features on or off** on the Control Panel) 

## Basic Commands

### Find a Computer
    Get-ADComputer -Filter 'Name -like "edi*"' | Select-Object Name

Same as above, except combine **-like** and **-notlike**, and also remove the **Name** heading from the output using **-ExpandProperty**, creating a plain array of strings.

    Get-ADComputer -Filter ('Name -like "prd*st-*" -and Name -notlike "prd*tst-*"') | Select-Object Name -ExpandProperty Name

### Find a User
    Get-ADUser -Filter 'Name -like "*miller*"'

### Get Group Membership for User
    Get-ADUser -Filter 'Name -like "*miller*"' | Get-ADPrincipalGroupMembership

### Find a Group

    Get-ADGroup -Filter 'Name -like "*Jenkins*"'

## Find a Group or Groups and Get Members of Those Groups

    Get-ADGroup -Filter 'Name -like "*Cybage*"' | Get-ADGroupMember

## (A little more than) Basic Commands

Query servers, filtering by \*tst\*, grabbing the IP address as well

    Get-ADComputer -Filter 'Name -like "*tst*"' -Properties IPv4Address | Sort-Object -Property DNSHostName | Select-Object DNSHostName,IPv4Address | Format-Table

## AD Search without installing AD Windows Add-On
    $currentuser = 'jchupick'
    (New-Object System.DirectoryServices.DirectorySearcher("(&(objectCategory=User)(samAccountName=$($currentuser)))")).FindOne().GetDirectoryEntry().memberOf
