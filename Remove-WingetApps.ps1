if ($configuration -eq "HOME" -or $configuration -eq "PARENT") {
    Remove-WingetIfExists("Microsoft.Teams")
    Remove-WingetIfExists("Microsoft.Teams.Free")
    Remove-WingetIfExists("Microsoft.Teams.Classic")
    Remove-WingetIfExists("Microsoft.OneDrive")
}

if($configuration -eq "WORK"){
    Remove-WingetIfExists("Microsoft.Teams.Classic", "old teams")
}

Remove-WingetIfExists("Microsoft.DevHome")
Write-Host "Winget removals done!`n"