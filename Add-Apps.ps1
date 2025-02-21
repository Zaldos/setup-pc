# Taskbar pins go here: 
# %AppData%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar

if ($installFirefox) {
    Write-Host "Installing Firefox..."
    winget install --id "Mozilla.Firefox.DeveloperEdition.en-GB" --exact --accept-package-agreements --accept-source-agreements
    # winget install --id Mozilla.Firefox --exact --accept-package-agreements --accept-source-agreements
    Write-Host "Firefox installed"

    # Disable Firefox Pocket
    # Software\Policies\Mozilla\Firefox\DisablePocket
    New-ItemOrGet -Path "HKLM:\Software\Policies\Mozilla\Firefox" | Set-ItemProperty -Name "DisablePocket" -Value 1

    # https://mozilla.github.io/policy-templates/#firefoxhome
    

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

    # Enables Manifest v2 extensions # https://chromeenterprise.google/policies/?policy=ExtensionManifestV2Availability
    New-ItemOrGet -Path "HKLM:\Software\Policies\Google\Chrome\ExtensionManifestV2Availability" | Set-ItemProperty -Name "1" -Value "2"

    if ($installAdblock) {
        Write-Host "Adding Ublock Origin to Chrome"

        # Forced
        New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist" | Set-ItemProperty -Name "1" -Value "cjpalhdlnbpafiamejdnhcphjbkeiagm"

        # Added as recommended
        # New-ItemOrGet -Path "HKLM:\Software\Wow6432Node\Google\Chrome\Extensions\cjpalhdlnbpafiamejdnhcphjbkeiagm" | Set-ItemProperty -Name "update_url" -Value "https://clients2.google.com/service/update2/crx"
    }
}

# Enables Manifest v2 extensions # https://learn.microsoft.com/en-us/DeployEdge/microsoft-edge-policies#extensionmanifestv2availability
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Set-ItemProperty -Name "ExtensionManifestV2Availability" -Value "2"

if ($installAdblock) {
    Write-Host "Adding Ublock Origin to MS Edge"

    # Forced
    New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist" | Set-ItemProperty -Name "1" -Value "odfafepnkmbhccpbejgmiehpchacaeak"

    # Added as recommended
    # New-ItemOrGet -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Edge\Extensions\odfafepnkmbhccpbejgmiehpchacaeak" | Set-ItemProperty -Name "update_url" -Value "https://edge.microsoft.com/extensionwebstorebase/v1/crx"
}

if ($configuration -eq "HOME" -or $configuration -eq "WORK") {
    $apps = @(
        "Microsoft.Powershell" # pwsh 7
        "voidtools.Everything"
        "Microsoft.PowerToys"
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

    # https://github.com/microsoft/winget-cli/discussions/1798#discussioncomment-7812764
    # https://github.com/microsoft/vscode/blob/main/build/win32/code.iss#L81
    winget install --id "Microsoft.VisualStudioCode" --override '/VERYSILENT /SP- /MERGETASKS="!runcode,!desktopicon,quicklaunchicon,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath"' --exact --source winget --accept-package-agreements --accept-source-agreements

    try {
        # Configures git to use VS code as default editor
        &"C:\Program Files\Git\cmd\git.exe" config --global core.editor "code --wait"
    }
    catch {
        Write-Warning "Failed to set vscode as default editor for git"
    }

}

