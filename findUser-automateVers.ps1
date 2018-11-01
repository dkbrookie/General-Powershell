Write-Host "SERVER: $server"
(((quser) -replace '^>', '') -replace '\s{2,}', ',').Trim() | ForEach-Object {
    If($_.Split(',').Count -eq 5){
        Write-Output ($_ -replace '(^[^,]+)', '$1,')
    }
    Else{
        Write-Output $_
    }
} | ConvertFrom-Csv | Where {$_.Username -eq $user}
