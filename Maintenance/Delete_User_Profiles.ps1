<#
This script is designed to delete a list of user profiles from a server or workstation
that you specify in a list in a text file. This script checks to see if the file 
"C:\User List.txt" exists and if it doesn't, it creates the file with some example 
users, then opens the text file for you so you can replace the example usernames with
the usernames you want deleted from the machine. Before the user profiles are deleted, 
it will prompt you with a confirmation, showing all user profiles it's about to delete.
#>

$userListFile = "$env:SystemDrive\User List.txt"

If (!(Test-Path $userListFile -PathType Leaf)) {
    Write-Warning 'There were no username file at C:\User List.txt. Please add usernames, line by line, that you wanted removed from this machine in the [User List.txt] file on the C: drive. This script will open that file for you now...'
    Set-Content -Path $userListFile "fakeusername1`nfakeusername2`nfakeusername3`nfakeusername4"
    Invoke-Item -Path $userListFile
}

$userList = Get-Content $userListFile
If (!$userList) {
    Write-Warning 'There were no usernames defined in the .txt file on the public desktop. Please add usernames, line by line, that you wanted removed from this machine. This script just made an example file on the desktop to assist you. This script will open that file for you now...'
    Set-Content -Path $userList "fakeusername1`nfakeusername2`nfakeusername3`nfakeusername4"
    Invoke-Item -Path $userListFile
} Else {
    ForEach ($user in $userList) {
        Write-Output "Prepping to delete the user folder for $user"
    }
    $userAnswer = Read-Host "Does the above list to delete look accurate? (Answer Y/N)"
    If ($userAnswer -eq 'N') {
        Write-Warning 'The folder deletions have been declined, exiting script. To change the list of users to delete, please edit the User List.txt file located at C:\User List.txt. This script will open that file for you now...'
        Invoke-Item -Path $userListFile
        Break
    } ElseIf ($userAnswer -eq 'Y') {
        #start deleting
        ForEach ($user in $userList) {
            $user = "$env:SystemDrive\Users\$user"
            If (!(Test-Path $user)) {
                Write-Warning "The folder $user does not exist!"
            } Else {
                Try {
                    Write-Warning "Removing $user..."
                    Remove-Item $user -Recurse -Force -Confirm:$False
                } Catch {
                    Write-Warning "There was a failure when trying to remove $user"
                }
            }
        }
    } Else {
        Write-Warning 'The answer provided was not Y or N, exiting script'
        Break
    }
}