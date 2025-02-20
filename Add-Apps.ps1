if ($installFirefox) {
    Write-Host "Installing Firefox..."
    winget install --id "Mozilla.Firefox.DeveloperEdition.en-GB" --exact --accept-package-agreements --accept-source-agreements
    # winget install --id Mozilla.Firefox --exact --accept-package-agreements --accept-source-agreements
    Write-Host "Firefox installed"

    if ($installAdblock) {
        Write-Host "Adding Ublock Origin to Firefox"
        # https://mozilla.github.io/policy-templates/#extensionsettings
        New-ItemOrGet -Path "HKLM:\Software\Policies\Mozilla\Firefox" | Set-ItemProperty -Name "ExtensionSettings" -Value @"
{"uBlock0@raymondhill.net": {"installation_mode": "normal_installed", "install_url": "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi" }}
"@
    }
}

if ($installChrome) {
    # Google.Chrome
    Write-Host "Installing Chrome..."
    winget install --id Google.Chrome --exact --accept-package-agreements --accept-source-agreements
    Write-Host "Chrome installed"
}

if ($installAdblock) {
    Write-Host "Adding Ublock Origin to MS Edge"
    New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist" | Set-ItemProperty -Name "1" -Value "odfafepnkmbhccpbejgmiehpchacaeak"
}

if ($configuration -eq "HOME" -or $configuration -eq "WORK") {
    $apps = @(
        "Microsoft.Powershell" # pwsh 7
        "voidtools.Everything"
        "Microsoft.PowerToys"
        "Microsoft.VisualStudioCode"
        "Git.Git"
        "Kubernetes.kubectl"
        "ahmetb.kubectx"
        "ahmetb.kubens"
        "Derailed.k9s"
    )

    foreach ($id in $apps) {
        Write-Host "Installing $id"
        winget install --id "$id" --exact --source winget --accept-package-agreements --accept-source-agreements
    }

    # Configures git to use VS code as default editor
    git config --global core.editor "code --wait"

}

