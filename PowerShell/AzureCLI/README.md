### One-Time configure (following AZ CLI INstall)
`az configure`


### SQL Server INfo
`az sql server list`

### Set the Subscription ID (per session or persistent?)
`az account set --subscription 04518abd-a72a-44d7-af88-a48121fb2439`

### Get a list of DBs on a Server
(Don't fully qualify server name eg. NOT `kwiecom.database.windows.net`)

`az sql db list --resource-group kwiecom --server kwiecom`
