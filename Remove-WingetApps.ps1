if ($configuration -eq "HOME" -or $configuration -eq "PARENT") {
    Write-Host "Removing MS Teams..."
    Remove-WingetIfExists("Microsoft.Teams")
    Remove-WingetIfExists("Microsoft.Teams.Free")
    Remove-WingetIfExists("Microsoft.Teams.Classic")
    Write-Host "MS Teams removed`n"

    Write-Host "Removing OneDrive..."
    Remove-WingetIfExists "Microsoft.OneDrive"
    Write-Host "OneDrive removed`n"
}

Write-Host "Removing DevHome"
Remove-WingetIfExists("Microsoft.DevHome")

Write-Host "Winget removals done`n"