function Test-WingetExists($id) {
    if ([string]::IsNullOrWhiteSpace($id)) {
        throw "Id cannot be null or empty!"
    }
    
    Write-Debug "Checking existence of $id"
    $wingetResult = winget list --id $id
    $exists = -not (($wingetResult -join "") -like "*No installed package found matching input criteria*")

    if ($exists) { Write-Debug "Found $id"; return $true }
    else { Write-Debug "Not found $id"; return $false }
}

function Remove-WingetIfExists($id, $message) {
    if (Test-WingetExists($id)) {
        if ($message) {
            Write-Host "Winget uninstalling $id ($message)"
        }
        else {
            Write-Host "Winget uninstalling $id"
        }
        if ($DebugPreference -eq 'SilentlyContinue') {
            winget uninstall --id $id --silent
        }
        else {
            winget uninstall --id $id
        }
        Write-Host "Winget uninstall complete" -ForegroundColor Green
    }
}
