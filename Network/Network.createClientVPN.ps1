If(!$vpnName) {
  $vpnName = "Client VPN Tunnel"
}

If(!$address) {
  Write-Error "Unable to create the VPN connection without an IP or hostname specified! Exiting script."
  Break
}

If(!$password) {
  Write-Error "Unable to create the VPN connection without the Client VPN password! Exiting script"
  Break
}

If(!$dnsSuffix) {
  Write-Error "Unable to createt the VPN tunnel without a DNSSuffix specified"
}

Add-VpnConnection -Name $vpnName -ServerAddress $adress -TunnelType L2tp -AllUserConnection -EncryptionLevel Required -L2tpPsk $password -AuthenticationMethod Pap,Chap,MSChapv2 -DnsSuffix $dnsSuffix -Force
