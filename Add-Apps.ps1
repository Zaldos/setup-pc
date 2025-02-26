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
    Write-Host "Installing modern powershell"
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
        "File-New-Project.EarTrumpet" # Better volume and audio control
        "emoacht.Monitorian" # Brightness control
        "UderzoSoftware.SpaceSniffer" # Great disk space visualisation tool
        "Python.Python.3.13"
        "OpenJS.NodeJS"
        "Obsidian.Obsidian"
    )

    if ($configuration -eq "WORK") {
        "Microsoft.Sysinternals.RDCMan" # Remote desktop connection manager
    }

    foreach ($id in $machineWideApps) {
        Write-Host "Installing $id machine wide"
        winget install --id "$id" --exact --source winget --scope machine `
            --accept-package-agreements --accept-source-agreements 
    }

    # Remove Voidtools.Everything desktop shortcut and add to right click menu
    if (-not ($null -eq ($everything = (Get-Process -name everything)))) {
        & ($everything[0].Path) -uninstall-desktop-shortcut -install-folder-context-menu
    }

    # https://github.com/microsoft/winget-cli/discussions/1798#discussioncomment-7812764
    # https://github.com/microsoft/vscode/blob/main/build/win32/code.iss#L81
    winget install --id "Microsoft.VisualStudioCode" --override '/VERYSILENT /SP- /MERGETASKS="!runcode,!desktopicon,quicklaunchicon,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath"' --exact --source winget --accept-package-agreements --accept-source-agreements

    # Reload path and call pip to add pre-commit
    if ($configuration -eq "WORK") {
        try {
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User") 
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
        &"C:\Program Files\Git\cmd\git.exe" config --global core.editor "code --wait"
    }
    catch {
        Write-Warning "Failed to set vscode as default editor for git"
    }

    try {
        wsl --install
        Write-Host "wsl installed, you will need to restart"
    }
    catch {
        Write-Host "Unable to install wsl" -ForegroundColor Red
    }

}

if ($configuration -eq "HOME") {
    . .\Download-Module.ps1
    $vsDestination = "$($env:USERPROFILE)\Downloads\VisualStudioCommunity.exe"
    Write-Host "Downloading VS Community installer to <$vsDestination>"
    Download-File "https://aka.ms/vs/17/release/vs_community.exe" -OutFile $vsDestination
    $openDownloads = $true

    $dockerDest = "$($env:USERPROFILE)\Downloads\DockerInstaller (only run after restart to enable wsl).exe"
    Write-Host "Downloading Docker installer to <$dockerDest>"
    Download-File "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe" -OutFile $dockerDest
    $openDownloads = $true
}
if ($configuration -eq "WORK") {
    . .\Download-Module.ps1
    $vsDestination = "$($env:USERPROFILE)\Downloads\VisualStudioProfessional.exe"
    Write-Host "Downloading VS Professional installer to <$vsDestination>"
    Download-File "https://aka.ms/vs/17/release/vs_professional.exe" -OutFile $vsDestination
    $openDownloads = $true
}
if (-not ($configuration -eq "PARENT")) {
    . .\Download-Module.ps1
    $dotUltimateDest = "$($env:USERPROFILE)\Downloads\DotUltimate.exe"
    Write-Host "Downloading DotUltimate installer to <$dotUltimateDest>"
    Download-File "https://download-cdn.jetbrains.com/resharper/dotUltimate.2024.3.5/JetBrains.dotUltimate.2024.3.5.web.exe" -OutFile $dotUltimateDest
    $openDownloads = $true
}