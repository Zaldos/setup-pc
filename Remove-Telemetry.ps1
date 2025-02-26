if ($disableTelemetry) {
    if (-not ($configuration -eq "WORK")) {
        Write-Host "Disabling windows telemetry"
        New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" | Set-ItemProperty -Name "AllowTelemetry" -Value 0
        # Disable and stop telemetry service
        Set-Service -StartupType Disabled DiagTrack
        Stop-Service DiagTrack
    }

    Write-Host "Disabling dotnet and powershell telemetry"
    [System.Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', 'true', 'Machine')
    [System.Environment]::SetEnvironmentVariable('DOTNET_CLI_TELEMETRY_OPTOUT', 'true', 'Machine')
}
else {
    if (-not ($configuration -eq "WORK")) {
        Write-Host "Resetting windows telemetry to default"
        New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" | Remove-ItemProperty -Name "AllowTelemetry"
        # Reset telemetry service
        Set-Service -StartupType Automatic DiagTrack
    }

    Write-Host "Resetting dotnet and powershell telemetry"
    [System.Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', $null, 'Machine')
    [System.Environment]::SetEnvironmentVariable('DOTNET_CLI_TELEMETRY_OPTOUT', $null, 'Machine')
}
Write-Host ""