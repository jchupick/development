## Summary
Module is **ActiveDirectory**

#### Installation

    Install-WindowsFeature -Name RSAT-AD-Tools
(NOTE: this is equivalent to using the **Turn Windows Features on or off** on the Control Panel) 

## Basic Commands
    Get-ADComputer -Filter 'Name -like "edi*"' | Select-Object Name

Same as above, except combine **-like** and **-notlike**, and also remove the **Name** heading from the output using **-ExpandProperty**, creating a plain array of strings.

    Get-ADComputer -Filter ('Name -like "edi*st-*" -and Name -notlike "edi*tst-*"') | Select-Object Name -ExpandProperty Name
