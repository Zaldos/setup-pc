if ($installFirefox) {
    Write-Host "Installing Firefox Developer..."
    winget install --id "Mozilla.Firefox.DeveloperEdition.en-GB" --exact --accept-package-agreements --accept-source-agreements
    # winget install --id Mozilla.Firefox --exact --accept-package-agreements --accept-source-agreements
    Write-Host "Firefox installed"

    # Disable Firefox Pocket
    # Software\Policies\Mozilla\Firefox\DisablePocket
    Write-Host "Disabling pocket in Firefox"
    New-ItemOrGet -Path "HKLM:\Software\Policies\Mozilla\Firefox" | Set-ItemProperty -Name "DisablePocket" -Value 1

    # https://mozilla.github.io/policy-templates/#homepage
    Write-Host "Making Firefox restore previous sessions"
    New-ItemOrGet -Path "HKLM:\Software\Policies\Mozilla\Firefox\Homepage" | Set-ItemProperty -Name "StartPage" -Value "previous-session"

    # https://mozilla.github.io/policy-templates/#firefoxhome
    Write-Host "Setting up Firefox homepage"
    New-ItemOrGet -Path "HKLM:\Software\Policies\Mozilla\Firefox\FirefoxHome" | Set-ItemProperty -Name "Search" -Value 1
    New-ItemOrGet -Path "HKLM:\Software\Policies\Mozilla\Firefox\FirefoxHome" | Set-ItemProperty -Name "SponsoredTopSites" -Value 0
    New-ItemOrGet -Path "HKLM:\Software\Policies\Mozilla\Firefox\FirefoxHome" | Set-ItemProperty -Name "Highlights" -Value 0
    New-ItemOrGet -Path "HKLM:\Software\Policies\Mozilla\Firefox\FirefoxHome" | Set-ItemProperty -Name "Pocket" -Value 0
    New-ItemOrGet -Path "HKLM:\Software\Policies\Mozilla\Firefox\FirefoxHome" | Set-ItemProperty -Name "SponsoredPocket" -Value 0
    New-ItemOrGet -Path "HKLM:\Software\Policies\Mozilla\Firefox\FirefoxHome" | Set-ItemProperty -Name "Snippets" -Value 0
    New-ItemOrGet -Path "HKLM:\Software\Policies\Mozilla\Firefox" | Set-ItemProperty -Name "NoDefaultBookmarks" -Value 1
    New-ItemOrGet -Path "HKLM:\Software\Policies\Mozilla\Firefox" | Set-ItemProperty -Name "DisplayBookmarksToolbar" -Value "newtab"
    
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

# If custom browser remove Edge from desktop
# One location is C:\Users\Public\Desktop
if ($installFirefox -or $installChrome) {
    $edge = Get-ChildItem "C:\Users\Public\Desktop" | Where-Object -Property Name -like "*Microsoft Edge*"
    if (-not($null -eq $edge)) {
        Remove-Item $edge.FullName
    }
}
else {
    Write-Host "Using edge? Disable copilot here: edge://settings/sidebar/appSettings?hubApp=cd4688a9-e888-48ea-ad81-76193d56b1be"
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
    Write-Host "`nAs set to HOME or WORK, some apps will be installed for Dev work"

    Write-Host "`nInstalling modern powershell"
    # https://github.com/PowerShell/PowerShell/issues/25068
    winget install Microsoft.Powershell --scope machine -a x64  --installer-type wix

    $machineWideApps = @(
        "voidtools.Everything" # Best file search
        "Microsoft.PowerToys"
        "Git.Git"
        "Kubernetes.kubectl" # K8s cli
        "ahmetb.kubectx" # K8s context switching
        "ahmetb.kubens" # K8s namespace switching
        "Derailed.k9s" # K8s Terminal Gui
        "emoacht.Monitorian" # Brightness control
        "UderzoSoftware.SpaceSniffer" # Great disk space visualisation tool
        "OpenJS.NodeJS"
        "Obsidian.Obsidian"
    )

    if ($configuration -eq "WORK") {
        $machineWideApps += @(
            "Microsoft.Sysinternals.RDCMan" # Remote desktop connection manager
            "Microsoft.Teams"
        )
    }

    foreach ($id in $machineWideApps) {
        Write-Host "`nInstalling $id machine wide"
        winget install --id "$id" --exact --source winget --scope machine `
            --accept-package-agreements --accept-source-agreements 
    }

    # This app doesnt like machine wide installation
    Write-Host "`nInstalling EarTrumpet (better audio control)"
    winget install --id "File-New-Project.EarTrumpet" # Better volume and audio control

    # Remove Voidtools.Everything desktop shortcut and add to right click menu
    if (-not ($null -eq ($everything = (Get-Process -name everything)))) {
        & ($everything[0].Path) -uninstall-desktop-shortcut -install-folder-context-menu
    }
    else {
        Write-Warning "Could not add everything search to context menu, you can do it from its options"
    }

    # https://github.com/microsoft/winget-cli/discussions/1798#discussioncomment-7812764
    # https://github.com/microsoft/vscode/blob/main/build/win32/code.iss#L81
    Write-Host "`nInstalling VS Code"
    winget install --id "Microsoft.VisualStudioCode" --override '/VERYSILENT /SP- /MERGETASKS="!runcode,!desktopicon,quicklaunchicon,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath"' --exact --source winget --accept-package-agreements --accept-source-agreements

    Write-Host "`nInstalling python as local to current user"
    winget install --id "Python.Python.3.13" --scope user

    # Reload path and call pip to add pre-commit
    if ($configuration -eq "WORK") {
        try {
            Reload-Path
            Write-Host "`nInstalling pre-commit"
            pip install pre-commit
            if ($LASTEXITCODE -eq 0) {
                Write-Host "pip added pre-commit, maybe check <https://pre-commit.com/#automatically-enabling-pre-commit-on-repositories>" -ForegroundColor Green
            }
            else {
                Write-Host "pip failed to add pre-commit" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "pip failed to add pre-commit" -ForegroundColor Red
            Write-Host $_
        }
    }

    try {
        # Configures git to use VS code as default editor
        Write-Host "`nConfiguring Git's editor as VS Code"
        &"C:\Program Files\Git\cmd\git.exe" config --global core.editor "code --wait"
        Write-Host "`nConfigured Git's editor as VS Code"
    }
    catch {
        Write-Warning "Failed to configure Git's editor as VS Code"
        Write-Warning $_
    }

    try {
        Write-Host "`nInstalling wsl 2 🐧"
        wsl --install
        Write-Host "wsl installed, you will need to restart"
    }
    catch {
        Write-Warning "Unable to install wsl" -ForegroundColor Red
        Write-Warning $_
    }

}

if ($configuration -eq "HOME") {
    . .\Download-Module.ps1
    $vsDestination = "$($env:USERPROFILE)\Downloads\VisualStudioCommunity.exe"
    Write-Host "`nDownloading VS Community installer to <$vsDestination>"
    Download-File "https://aka.ms/vs/17/release/vs_community.exe" -OutFile $vsDestination
    $openDownloads = $true

    $dockerDest = "$($env:USERPROFILE)\Downloads\DockerInstaller (only run after restart to enable wsl).exe"
    Write-Host "`nDownloading Docker installer to <$dockerDest>"
    Download-File "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe" -OutFile $dockerDest
    $openDownloads = $true
}
if ($configuration -eq "WORK") {
    . .\Download-Module.ps1
    $vsDestination = "$($env:USERPROFILE)\Downloads\VisualStudioProfessional.exe"
    Write-Host "`nDownloading VS Professional installer to <$vsDestination>"
    Download-File "https://aka.ms/vs/17/release/vs_professional.exe" -OutFile $vsDestination
    $openDownloads = $true
}
if ($configuration -eq "WORK" -or $configuration -eq "HOME") {
    . .\Download-Module.ps1
    $dotUltimateDest = "$($env:USERPROFILE)\Downloads\DotUltimate.exe"
    Write-Host "`nDownloading DotUltimate installer to <$dotUltimateDest>"
    Download-File "https://download-cdn.jetbrains.com/resharper/dotUltimate.2024.3.5/JetBrains.dotUltimate.2024.3.5.web.exe" -OutFile $dotUltimateDest
    $openDownloads = $true
}