if ($disableTelemetry) {
    if (-not $configuration -eq "WORK") {
        Write-Host "Disabling telemetry"
        New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" | Set-ItemProperty -Name "AllowTelemetry" -Value 0
        # Disable and stop telemetry service
        Set-Service -StartupType Disabled DiagTrack
        Stop-Service DiagTrack
    }

    [System.Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', 'true', 'Machine')
    [System.Environment]::SetEnvironmentVariable('DOTNET_CLI_TELEMETRY_OPTOUT', 'true', 'Machine')
}
else {
    if (-not $configuration -eq "WORK") {
        Write-Host "Resetting telemetry to default"
        New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" | Remove-ItemProperty -Name "AllowTelemetry"
        # Reset telemetry service
        Set-Service -StartupType Automatic DiagTrack
    }

    [System.Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', $null, 'Machine')
    [System.Environment]::SetEnvironmentVariable('DOTNET_CLI_TELEMETRY_OPTOUT', $null, 'Machine')
}
Write-Host ""