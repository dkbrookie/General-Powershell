Remove-Variable * -ErrorAction SilentlyContinue; Remove-Module *; $error.Clear(); Clear-Host

$users = Get-LocalGroupMember -Group Administrators
ForEach($user in $users) {
  $type = $user.ObjectClass
  $name = $user.name
  $source = $user.PrincipalSource
  If($type -eq 'user') {
    If(!$userAdmins) {
      $userAdmins = "[Username: $name /// Source: $source /// Type: $type]"
    } Else {
      $userAdmins = "$userAdmins, [Username: $name /// Source: $source /// Type: $type]"
    }
  } ElseIf ($type -eq 'group'){
    If(!$groupAdmins) {
      $groupAdmins = "[Group: $name /// Source: $source /// Type: $type]"
    } Else {
      $groupAdmins = "$userAdmins, [Group: $name /// Source: $source /// Type: $type]"
    }
  }
}
Write-Output "userAdmins=$userAdmins|groupAdmins=$groupAdmins"
