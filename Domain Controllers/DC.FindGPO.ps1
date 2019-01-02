## Get the string you want to search for
$string = Read-Host -Prompt "What string do you want to search for?"

## Set the domain to search for GPOs
$DomainName = $env:USERDNSDOMAIN

## Find all GPOs in the current domain
write-host "Finding all the GPOs in $DomainName"
Import-Module grouppolicy
$allGposInDomain = Get-GPO -All -Domain $DomainName
## Look through each GPO's XML for the string
Write-Host "Searching...."
ForEach ($gpo in $allGposInDomain) {
  $report = Get-GPOReport -Guid $gpo.Id -ReportType Xml
  If ($report -match $string) {
    $report | Out-File "c:\gpoOut.txt"
    $report = Get-Content "c:\gpoOut.txt"
    Write-Host "**************************************"
    Write-Host "** Match found in GPO"
    Write-Host "    $($gpo.DisplayName)"
    $valuePattern = "<q1:Value>(.*)</q1:Value>"
    $value = [regex]::match($report, $valuePattern).Groups[1].Value
    $linkPattern = "<SOMPath>(.*)</SOMPath>"
    $link = $report | Select-String -Pattern $linkPattern
    $link = $link -replace("<SOMPath>","") -replace ("</SOMPath>?","")
    Write-Host "** Current Linked OUs"
    ForEach($ou in $link) {
        $ou
    }
    Write-Host "**************************************"
  }
}

If((Test-Path C:\gpoOut.txt -PathType Leaf)) {
    Remove-Item -Path C:\gpoOut.txt -Force
}
