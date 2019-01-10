$hosts = "$env:windir\System32\drivers\etc\hosts"
$hostsBackup = "$env:windir\LTsvc\hosts.bak"

Try {
  $hostsContent = Get-Content $hosts
  $rowCount = $hostsContent.Count

  If($rowCount -ne 21) {
    Write-Host "Hosts file has been altered!"
    If(!(Test-Path $hostsBackup)) {
      Copy-Item $hosts -Destination $hostsBackup
      Write-Output "Created a backup of your hosts file at $hostsBackup"
    } Else {
      Write-Output "Verified there is already a backup of the hosts file at $hostsBackup"
    }
    Write-Host "-----------------------------------"
    Write-Host "------Hosts file output below------"
    Write-Host "-----------------------------------"
    $hostsContent
  } Else  {
    Write-Host "Default hosts file confirmed"
  }
} Catch {
  Write-Error "Encountered an error while trying to verify the hosts file"
}
