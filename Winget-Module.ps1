function Test-WingetExists($id) {
    if ([string]::IsNullOrWhiteSpace($id)) {
        throw "Id cannot be null or empty!"
    }
    
    Write-Host "Checking existence of $id"
    $wingetResult = winget list --id $id
    $exists = -not (($wingetResult -join "") -like "*No installed package found matching input criteria*")

    if ($exists) { Write-Host "Found $id"; return $true }
    else { Write-Host "Not found $id"; return $false }
}

function Remove-WingetIfExists($id) {
    if (Test-WingetExists($id)) {
        Write-Host "Winget uninstalling $id"
        winget uninstall --id $id
        Write-Host "Winget uninstall complete" -ForegroundColor Green
    }
}
