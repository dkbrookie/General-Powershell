param($installer, $appname, $exeurl, $arguements, $pathtoinstaller, $extractarguements )
. C:\Windows\Temp\Function.Install-EXE.ps1

If ($ExtractInstaller -eq 'EMPTY') {
    If ($AppName -eq 'Sentinel Agent') {
        $installHash = @{
            AppName = $appname
            FileDownloadLink = $exeurl
            Arguments = $arguements
            Wait = $false
        }
    } Else {
        $installHash = @{
            FileDownloadLink = $Exeurl
            AppName = $appname
            Arguments = $arguements
            Wait = $true
        }
    }
} Else {
    $installHash = @{
        AppName = $appname
        FileDownloadLink = $exeurl
        ExtractInstaller = $true
        PathToExtractedInstaller = $pathtoinstaller
        ExtractArguments = $extractarguements
        Arguments = $arguements
        Wait = $true
    }
}
Install-EXE @installHash
