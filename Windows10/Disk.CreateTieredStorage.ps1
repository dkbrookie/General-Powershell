## List all disks that can be pooled and output in table format (format-table)
$physDisks = Get-PhysicalDisk -CanPool $True | ft FriendlyName,OperationalStatus,Size,MediaType
If(!$physDisks) {
  Write-Warning "Unable to find any eligble disks for tiered storage. Please verify the disks you want to use for tiered storage have had all volumes removed."
  Return
}

Write-Warning "All of the disks listed will be put into your new tiered storage volume and have their data wipe! Proceed with caution!"
$answer = Read-Host "Are you sure you want to create tiered storage out of all the drives just listed? (y/n)"
If($answer -eq "y") {
  $ssdSize = Read-Host "How many GBs do you want your SSD pool to be? (enter number only)"
  $hddSize = Read-Host "How many GBs do you want your HDD pool to be? (enter numbers only)"
  If(!$ssdSize) {
    Write-Warning "You have to enter a number for your total SSD size for this script to proceed! Exiting script."
    Return
  } Else {
    $ssdSize = (-Join($ssdSize,"GBs"))
  }
  If(!$hddSize) {
    Write-Warning "You have to enter a number for your total HDD size for this script to proceed! Exiting script."
    Return
  } Else {
    $hddSize = (-Join($hddSize,"GBs"))
  }
  ## Store all physical disks that can be pooled into a variable, $pd
  $pd = (Get-PhysicalDisk -CanPool $True | Where MediaType -NE UnSpecified)
  ## Create a new Storage Pool using the disks in variable $pd with a name of My Storage Pool
  New-StoragePool -PhysicalDisks $pd –StorageSubSystemFriendlyName “Windows Storage*” -FriendlyName “Optane Boosted Storage”
  ## View the disks in the Storage Pool just created
  Get-StoragePool -FriendlyName “Optane Boosted Storage” | Get-PhysicalDisk | Select FriendlyName, MediaType


  ## Create two tiers in the Storage Pool created. One for SSD disks and one for HDD disks
  $ssd_Tier = New-StorageTier -StoragePoolFriendlyName “Optane Boosted Storage” -FriendlyName SSD_Tier -MediaType SSD
  $hdd_Tier = New-StorageTier -StoragePoolFriendlyName “Optane Boosted Storage” -FriendlyName HDD_Tier -MediaType HDD


  ## Create a new virtual disk in the pool with a name of TieredSpace using the SSD (50GB) and HDD (300GB) tiers
  $vd1 = New-VirtualDisk -StoragePoolFriendlyName “Optane Boosted Storage” -FriendlyName TieredSpace -StorageTiers @($ssd_tier, $hdd_tier) -StorageTierSizes @($ssdSize, $hddSize) -ResiliencySettingName Simple -WriteCacheSize 1GB
} Else {
  Write-Output "Exiting script"
}
