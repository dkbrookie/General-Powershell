$hosts = "$env:windir\System32\drivers\etc\hosts"
$hostsBackup = "$env:windir\LTsvc\hosts.bak"

If(!(Test-Path $hostsBackup)) {
  Copy-Item $hosts -Destination $hostsBackup
  Write-Output "Created a backup of your hosts file at $hostsBackup"
} Else {
  Write-Output "Verified there is already a backup of the hosts file at $hostsBackup"
}

Try {
  Write-Output "# Copyright (c) 1993-2009 Microsoft Corp.
  #
  # This is a sample HOSTS file used by Microsoft TCP/IP for Windows.
  #
  # This file contains the mappings of IP addresses to host names. Each
  # entry should be kept on an individual line. The IP address should
  # be placed in the first column followed by the corresponding host name.
  # The IP address and the host name should be separated by at least one
  # space.
  #
  # Additionally, comments (such as these) may be inserted on individual
  # lines or following the machine name denoted by a '#' symbol.
  #
  # For example:
  #
  #      102.54.94.97     rhino.acme.com          # source server
  #       38.25.63.10     x.acme.com              # x client host

  # localhost name resolution is handled within DNS itself.
  #	127.0.0.1       localhost
  #	::1             localhost" | Out-File $hosts

  Write-Output "Successfully restored $hosts to the default config"
} Catch {
  Write-Error "Encountered an error when trying to replace the $hosts file with the default config"
}
