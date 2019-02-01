<#
.DESCRIPTION
This script is meant for a machine tha tneeds to be completely locked out. This
is generally used for a remote termination to make sure the employee cannot
access company files / systems effective immediately, in case they don't connect
to VPN.

Steps
1) Disables all local user accounts
2) Disables cached credentials for domain accounts-- meaning the machine can no
longer login unless you get on VPN and validate your credentials against the DC.
Assuming the account has now been disabled, that validation would fail.
3) Force logs out all users on the machine
4) Shuts down computer

#>
## Set vars
$registryPath = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon'
$Name = 'CachedLogonsCount'
$value = 0
$lUsers = Get-LocalUser


## Disable all local users
ForEach($user in $lUsers) {
    If($user.Enabled -eq $True) {
        Write-Output "Disabling $user..."
        Disable-LocalUser -Name $user
        Logoff $user
    } Else {
        Write-Output "$user is already disabled!"
    }
}

## Clear all cached credentials via Registry
Set-ItemProperty -Path $registryPath -Name $name -Value $value

## Log off all users from the machine
(gwmi win32_operatingsystem).Win32Shutdown(4)

## Shutdown computer
Stop-Computer
