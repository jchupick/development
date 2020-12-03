### One-Time configure (following AZ CLI INstall)
`az configure`

### Login
`az login -u jchupick@kwicommerce.onmicrosoft.com -p XXXXXXXX`

If `-p` not supplied, you will get prompted

### SQL Server INfo
`az sql server list`

### Set the Subscription ID (per session or persistent?)
`az account set --subscription 04518abd-a72a-44d7-af88-a48121fb2439`

### Get a list of DBs on a Server
(Don't fully qualify server name eg. NOT `kwiecom.database.windows.net`)

`az sql db list --resource-group kwiecom --server kwiecom`

### The rest...
```
$connectionString = 'Data Source={0};database={1};User ID={2};Password={3}' -f $ServerName,$DatabaseName,$userName,$password
$sqlConnection = New-Object System.Data.SqlClient.SqlConnection $connectionString
$sqlConnection.Open()
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlQuery = "SELECT * FROM information_schema.tables;"
$SqlCmd.CommandText = $SqlQuery
$SqlCmd.Connection = $sqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet)
$DataSet
$DataSet.Tables

### OR

$reader = $command.ExecuteReader()
$datatable = New-Object System.Data.DataTable
$datatable.Load($reader)
$datatable
```
