<#
.SYNOPSIS
Finds the current activation status of WIndows

.DESCRIPTION
Uses WMI to get the current licensing status of the machine
#>

[CmdletBinding()]
Param(
[Parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
[string]$DNSHostName = $Env:COMPUTERNAME
)

Process {
 Try {
   $wpa = Get-WmiObject SoftwareLicensingProduct -ComputerName $DNSHostName `
   -Filter "ApplicationID = '55c92734-d682-4d71-983e-d6ec3f16059f'" `
   -Property LicenseStatus -ErrorAction Stop
 } Catch {
   $status = New-Object ComponentModel.Win32Exception ($_.Exception.ErrorCode)
   $wpa = $Null
 }

 $out = New-Object psobject -Property @{
   Status = [string]::Empty;
 }

 If($wpa) {
   :Outer ForEach($item in $wpa) {
     Switch ($item.LicenseStatus) {
       0 {$out.Status = "Unlicensed"}
       1 {$out.Status = "Licensed"; break outer}
       2 {$out.Status = "Out-Of-Box Grace Period"; break outer}
       3 {$out.Status = "Out-Of-Tolerance Grace Period"; break outer}
       4 {$out.Status = "Non-Genuine Grace Period"; break outer}
       5 {$out.Status = "Notification"; break outer}
       6 {$out.Status = "Extended Grace"; break outer}
       default {$out.Status = "Unknown value"}
     }
   }
 } Else {
   $out.Status = $status.Message
 }
 $out.Status
}
