<#
This script will prompt you to enter the username you're looking for and will report back if that user is logged in and active.
#>

Write-Host "Please enter the username of the user you are trying to find. Enter only the username without quotes"
$user = Read-Host "Username"
$server = "RGSC-VEEAM"
##"RGSC-TS2","RGSC-TS3","RGS-TS4","RGSC-TS5","RGSC-TS6","RGSC-TS7","RGSC-TS8","RGSC-TS9","R2D2"

Write-Host "SERVER: $server"
(((quser) -replace '^>', '') -replace '\s{2,}', ',').Trim() | ForEach-Object {
    If($_.Split(',').Count -eq 5){
        Write-Output ($_ -replace '(^[^,]+)', '$1,')
    }
    Else{
        Write-Output $_
    }
} | ConvertFrom-Csv | Where {$_.Username -eq $user}
