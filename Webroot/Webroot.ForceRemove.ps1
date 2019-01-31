$wrUninstall = Get-ChildItem "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | Get-ItemProperty | Where {$_.DisplayName -eq 'Webroot SecureAnywhere'} | Select -ExpandProperty UninstallString
$wrdata = "$env:SystemDrive\ProgramData\WRData"
$wrx86 = "$env:SystemDrive\Program Files (x86)\Webroot"
$wrx64 = "$env:SystemDrive\Program Files\Webroot"

## Attempt an EXE uninstall
If((Test-Path $wrx86)) {
  Start-Process -Wait "$wrx86\wrsa.exe" -ArgumentList 'uninstall'
}
If((Test-Path $wrx64)) {
  Start-Process -Wait "$wrx64\wrsa.exe" -ArgumentList 'uninstall'
}


## Attempt an MSI uninstall, delete installed reg key for Webroot
If($wrUninstall) {
  $wrRemove = ($wrUninstall -Replace "msiexec.exe","" -Replace " /x{","" -Replace "}","").Trim()
  Start-Process -Wait MSIExec.exe -ArgumentList "/x $wrRemove /qn"
  $wrKey = $wrRemove = ($wrUninstall -Replace "msiexec.exe","" -Replace " /x","").Trim()
  Remove-Item "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$wrKey" -Force -Confirm:$False -EA 0
  Remove-Item "HKLM:\SOFTWARE\WOW6432Node\webroot" -Force -Confirm:$False -EA 0
  Remove-Item "HKLM:\SOFTWARE\WOW6432Node\WRData" -Force -Confirm:$False -Recurse -EA 0
  Remove-Item "HKLM:\SYSTEM\ControlSet001\Services\WRSVC" -Force -Confirm:$False -Recurse -EA 0
}


## Stops the Webroot processes so the files can be deleted
Stop-Process -Name '*wrsa*' -Force -EA 0
Stop-Service -Name '*wrsvc*' -Force -EA 0
$procStatus = Get-Process -Name '*wrsa*'
$servStatus = Get-Service -Name '*wrsvc*'
If($procStatus -or (($servStatus).Status) -ne 'Stopped') {
  Write-Warning "Failed to stop Webroot process/service, exiting script"
  Break
}


## Removes the launcher EXEs for Webroot
If((Test-Path $wrx64)) {
  Remove-Item $wrx64 -Recurse -Force
}
If((Test-Path $wrx86)) {
  Remove-Item $wrx86 -Recurse -Force
}


## Removes the temp folder for Webroot
If((Test-Path $wrdata)) {
  Remove-Item $wrdata -Recurse -Force
}


## Remove the startup registry key for Webroot
Remove-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" -Name WRSVC -Force -Confirm:$False -EA 0


## Sometimes after tghe uninstall the Windows installer gets hung, so force stopping it to make sure the next install is successful
Stop-Process -Name msiexec -Force -EA 0

Write-Output "Webroot removal script complete"
