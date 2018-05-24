### Useful Commands for querying Active Directory

```
FOR %b IN (keawe,berlin,kapoo,pirani,jenkins) DO FOR /F "tokens=*" %a IN ('dsquery user -name *%b*') DO dsquery * %a -attr * | grep -i sama
dsquery * "CN=James Chupick,OU=CC80,OU=Depts,DC=ANSI,DC=org" -attr *
dsquery group -name *workcred* | dsget group -members
FOR /F "tokens=*" %a IN ('dsquery group -name *workcred*') DO dsget group %a -members
```
