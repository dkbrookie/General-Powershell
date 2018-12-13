## Get the string you want to search for
$string = Read-Host -Prompt "What string do you want to search for?"

## Set the domain to search for GPOs
$DomainName = $env:USERDNSDOMAIN

## Find all GPOs in the current domain
write-host "Finding all the GPOs in $DomainName"
Import-Module grouppolicy
$allGposInDomain = Get-GPO -All -Domain $DomainName
## Look through each GPO's XML for the string
Write-Host "Starting search...."
ForEach ($gpo in $allGposInDomain) {
  $report = Get-GPOReport -Guid $gpo.Id -ReportType Xml
  If ($report -match $string) {
    write-host "********** Match found in: $($gpo.DisplayName) **********"
  } Else {
    Write-Host "No match in: $($gpo.DisplayName)"
  }
}
