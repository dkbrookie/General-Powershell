Remove-Variable * -ErrorAction SilentlyContinue; Remove-Module *; $error.Clear(); Clear-Host

$users = Get-LocalGroupMember -Group Administrators
ForEach($user in $users) {
  $type = $user.ObjectClass
  $name = $user.name
  $source = $user.PrincipalSource
  If(!$typeOut) {
    $typeOut = "[Username: $name /// Source: $source /// Type: $type]"
  } Else {
    $typeOut = "$typeOut, [Username: $name /// Source: $source /// Type: $type]"
  }
}
$typeOut
