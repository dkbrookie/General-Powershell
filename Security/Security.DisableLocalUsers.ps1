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

Stop-Computer
