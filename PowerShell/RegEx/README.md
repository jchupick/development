## Examples

Output the contenets of a file, removing all lines commented with the '#' character.

    Get-Content .\SERVERS_STG.txt | Select-String -Pattern '^#' -NotMatch
