## Querying Active Directory

### 
Find a User
```
dsquery user -name *chupick*
```
###
Find a Computer
```
dsquery computer -name *ops*
```

###
Find a Group
```
dsquery group -name Development
```

### Get all Attributes for a given User (Use full AD string)
```
dsquery * "CN=James Chupick,OU=CC80,OU=Depts,DC=ANSI,DC=org" -attr *
```

### Get all Users in a Group
```
dsquery group -name *Development* | dsget group -members
```
### Do the same, but wrap in Windows `For` to get the individual commands
```
FOR /F "tokens=*" %a IN ('dsquery group -name *Development*') DO dsget group %a -members
```
### Nested `For` loops plus `grep` to pull specific Attr values for multiple Users
```
FOR %b IN (jenkins,chupick) DO FOR /F "tokens=*" %a IN ('dsquery user -name *%b*') DO dsquery * %a -attr * | grep -i sAMAccount
```

