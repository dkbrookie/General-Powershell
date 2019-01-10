If(!(Test-Path "$env:SystemDrive\ProgramData\WRDATA")) {
    Write-Host "0"
} Else {
    "{0:N2}" -f ((Get-ChildItem "$env:SystemDrive\ProgramData\WRData" -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)
}
