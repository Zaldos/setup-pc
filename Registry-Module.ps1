function New-ItemOrGet($Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) {
        throw "Path cannot be null or empty!"
    }
    
    if (Test-Path -Path $Path) {
        return Get-Item -Path $Path
    }
    else {
        return New-Item -Path $Path -Force
    }
}

function Remove-ItemPropertyIfExist($Path, $Name) {
    if ([string]::IsNullOrWhiteSpace($Path) -or [string]::IsNullOrWhiteSpace($Name)) {
        throw "Args cannot be null or empty!"
    }

    if (Test-Path -Path $Path) {
        $pathItem = Get-Item -Path $Path
        if ($pathItem.Property -contains "$Name") {
            Remove-ItemProperty -Path $Path -Name $Name
        }
    }
}