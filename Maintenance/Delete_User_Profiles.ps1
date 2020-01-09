<#
This script is designed to delete a list of user profiles from a server or workstation
that you specify in a list in a text file. This script checks to see if the file 
"C:\User List.txt" exists and if it doesn't, it creates the file with some example 
users, then opens the text file for you so you can replace the example usernames with
the usernames you want deleted from the machine. Before the user profiles are deleted, 
it will prompt you with a confirmation, showing all user profiles it's about to delete.
#>

$userListFile = "$env:SystemDrive\User List.txt"

## If the text file doesn't exist, create oen and put in some example usernames to delete
If (!(Test-Path $userListFile -PathType Leaf)) {
    Write-Warning 'There were no username file at C:\User List.txt. Please add usernames, line by line, that you wanted removed from this machine in the [User List.txt] file on the C: drive. This script will open that file for you now...'
    Set-Content -Path $userListFile "fakeusername1`nfakeusername2`nfakeusername3`nfakeusername4"
    ## Open the file for the tech so they can add the usernames they need to delete
    Invoke-Item -Path $userListFile
}

## Grab the content of the text file to see what users we need to delete
$userList = Get-Content $userListFile -EA 0
## If the text file is empty, add some example users to it and open the file for the tech so
## they can edit it to the users they want to delete
If (!$userList) {
    Write-Warning 'There were no usernames defined in the .txt file on the public desktop. Please add usernames, line by line, that you wanted removed from this machine. This script just made an example file on the desktop to assist you. This script will open that file for you now...'
    Set-Content -Path $userList "fakeusername1`nfakeusername2`nfakeusername3`nfakeusername4"
    ## Open the file for the tech so they can add the usernames they need to delete
    Invoke-Item -Path $userListFile
} Else {
    ## Write the list of users we're about to delete so the tech can confirm this is accurate
    ForEach ($user in $userList) {
        Write-Output "Prepping to delete the user folder for $user"
    }
    ## Prompt the tech for Y or N to confirm the deletion of the usernames listed above
    $userAnswer = Read-Host "Does the above list to delete look accurate? (Answer Y/N)"
    ## If the answer was N, open the file so the tech can edit the usernames, save it, and try again
    If ($userAnswer -eq 'N') {
        Write-Warning 'The folder deletions have been declined, exiting script. To change the list of users to delete, please edit the User List.txt file located at C:\User List.txt. This script will open that file for you now...'
        Invoke-Item -Path $userListFile
        Break
    ## If the answer was Y, time to start deleting profiles
    } ElseIf ($userAnswer -eq 'Y') {
        #start deleting
        ForEach ($user in $userList) {
            Try {
                Write-Warning "Removing the user profile for $user..."
                ## First try to delete the account with the standard powershell built in modules
                $localUser = Get-LocalUser -Name $user -EA 0
                If ($localUser) {
                    Remove-LocalUser -Name $user -Confirm:$False
                    ## Note here that the profile was successfully removed so we know to now remove additional files in the next
                    ## steps if any additional files still exist
                    $profDelete = $True
                }
                ## Just in case the above built in modules failed, try to delete them again with straight WMI
                $profileDelete = Get-WmiObject Win32_UserProfile -Filter "localpath='$env:SystemDrive\\Users\\$user'"
                If ($profileDelete) {
                    $profileDelete.Delete()
                    ## Note here that the profile was successfully removed so we know to now remove additional files in the next
                    ## steps if any additional files still exist
                    $profDelete = $True
                }
                Write-Output "User profile for $user successfully removed"
            } Catch {
                Write-Warning "Failed to delete the Windows user profile for $user"
                ## Note here that the profile removal FAILED so we don't want to just go delete folders for the user in the next
                ## steps
                $profDelete = $False
            }
            $user = "$env:SystemDrive\Users\$user"
            If ((Test-Path $user)) {
                Try {
                    ## Make sure the profile was deleted successfully
                    If ($profDelete -eq $True) {
                        ## Delete all additional user directories and files that may be lingering after the above commands ran
                        Write-Warning "Removing additional directories and files for $user..."
                        Remove-Item $user -Recurse -Force -Confirm:$False
                        Write-Output "Removed all remaining directories and files for the user $user, removal complete!"
                    }
                } Catch {
                    Write-Warning "There was a failure when trying to remove $user directories and files"
                }
            } Else {
                Write-Output "No additional directories or files were found for the user $user, removal complete!"
            }
        }
    } Else {
        Write-Warning 'The answer provided was not Y or N, exiting script'
        Break
    }
}

Write-Warning 'It is recommended to perform a reboot after removing accounts but is not required'