. .\Debug.ps1

function Test-WingetExists($id) {
    if ([string]::IsNullOrWhiteSpace($id)) {
        throw "Id cannot be null or empty!"
    }
    
    Write-IfDebug "Looking for $id"
    $wingetResult = winget list --id $id
    $exists = -not (($wingetResult -join "") -like "*No installed package found matching input criteria*")

    if ($exists) { Write-IfDebug "$id found"; return $true }
    else { Write-IfDebug "$id not found"; return $false }
}

function Remove-WingetIfExists($id) {
    if (Test-WingetExists($id)) {
        Write-IfDebug "Winget uninstall $id"
        winget uninstall --id $id
    }
}

