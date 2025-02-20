# Allow scripts to run, run it on both pwsh and powershell
# Scoped
<#
# For user
Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force
.\Script.ps1
#>
# Useful
# $all = Get-AppxPackage "*OneDrive*" -allusers; $all | Select-Object -Property Name, InstallLocation | Sort-Object -Property Name

$dryRun = $false
$debug = $true
$devsPc = $false #pwsh 7 + everything search
$disableBackgroundProcesses = $true
$disableHelpPaneF1 = $true
$disableMsAccounts = $true
$disableTelemetry = $true
$disableNewsAndInterests = $true

$installUblock = $true
$installFirefox = $false
$installChrome = $false

$oldRightClickMenu = $true
$removeOneDrive = $true
$removeMsTeams = $true

. .\Debug.ps1
. .\Winget-Module.ps1

try {
    if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
        Write-Host "Not launched as admin, relaunching..."
        Start-Process -FilePath powershell.exe -Verb Runas -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`"  `"$($MyInvocation.MyCommand.UnboundArguments)`""
        exit 0
    }
}
catch {
    Write-Host $_
    Read-Host
}

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
            return $true
        }
    }

    return $false
}

try {
    Write-Host "Starting winget changes"
    # Accepts Terms
    winget list --accept-source-agreements --name "skipthis-asdasdasdadasd" | out-null
    if ($true -eq $devsPc -and $null -eq (Get-Command "pwsh.exe" -ErrorAction SilentlyContinue)) {
        Write-Host "Installing pwsh.exe..."
        winget install --id Microsoft.Powershell --source winget
        Write-Host "Installing everything search..."
        winget install --id voidtools.Everything --source winget
        Write-Host "Installing PowerToys..."
        winget install --id Microsoft.PowerToys --source winget
        Write-Host "Installing VsCode"
        winget install --id Microsoft.VisualStudioCode --source winget
        Write-Host "Installing Git"
        winget install --id Git.Git -e --source winget
        git config --global core.editor "code --wait"
    }

    if ($removeMsTeams) {
        Write-Host "Removing MS Teams"
        Remove-WingetIfExists("Microsoft.Teams")
        Remove-WingetIfExists("Microsoft.Teams.Free")
        Remove-WingetIfExists("Microsoft.Teams.Classic")
    }
    
    if (!$dryRun) {
        Write-Host "Removing DevHome"
        Remove-WingetIfExists("Microsoft.DevHome")
    }
    Write-Host "Winget removals done`n"

    $appsToRemove = @(
        "Clipchamp.Clipchamp"
        "Microsoft.BingNews"
        "Microsoft.BingWeather"
        "Microsoft.BingSearch"
        "Microsoft.Copilot"
        "Microsoft.OutlookForWindows"
        "Microsoft.PowerAutomateDesktop"        
        "Microsoft.Todos"
        "Microsoft.Wallet"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.WindowsMaps"
        "Microsoft.YourPhone"
        "*SolitaireCollection*"
        ## If you dont use MS Office crap
        "Microsoft.MicrosoftOfficeHub"
        ## For My Pc
        # "MicrosoftCorporationII.QuickAssist"
        # "Microsoft.GetHelp"
        # "Microsoft.Windows.NarratorQuickStart"
        # "Microsoft.ZuneMusic"
        # "MicrosoftWindows.Client.WebExperience"
    )
    if ($removeMsTeams) {
        $appsToRemove += @(
            "Microsoft.Teams"
            "MSTeams"
        )
    }

    foreach ($app in $appsToRemove) {
        if ($dryRun) {
            Write-Host "Dry run: checking app '$app' exists"
            $app = Get-AppxPackage "$app" -AllUsers
            if ($null -ne $app) {
                Write-Host "$app exists!"
            }
            else {
                Write-Host "$app does not exist!"
            }
        }
        else {
            Write-Host "Removing $app"
            if ($null -eq (Get-AppxPackage "$app" -AllUsers)) {
                Write-Host "$app not found, skipping" -ForegroundColor DarkGray
            }
            else {
                Get-AppxPackage "$app" -AllUsers | Remove-AppxPackage -AllUsers
                $verify = Get-AppxPackage "$app" -AllUsers
                if ($null -eq $verify) {
                    Write-Host "$app successfully uninstalled" -ForegroundColor Green
                }
                else {
                    Write-Host "Somehow $app remains..." -ForegroundColor Yellow
                }
            }
        }
        Write-Host ""
    }

    if (!$dryRun) {
        # Hides news and interests
        New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds\" | Set-ItemProperty -Name "EnableFeeds" -Value 0

        # Hides the meet now icon on task bar
        New-ItemOrGet -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Set-ItemProperty -Name "HideSCAMeetNow" -Value 1

        # Disable web start menu search
        New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" | Set-ItemProperty -Name "DisableSearchBoxSuggestions" -Value 1

        # Disable delivery optimization
        New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" | Set-ItemProperty -Name "DODownloadMode" -Value 0

        if ($disableNewsAndInterests) {
            # Taskbar news
            New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" | Set-ItemProperty -Name "AllowNewsAndInterests" -Value 0
            Stop-Process -Name Widgets, WidgetService -ErrorAction SilentlyContinue
            # Edge news
            New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Set-ItemProperty -Name "NewTabPageContentEnabled" -Value 0
        }
        else {
            # Should start after explorer restart
            New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" | Set-ItemProperty -Name "AllowNewsAndInterests" -Value 1
            # Edge news
            New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Remove-ItemProperty -Name "NewTabPageContentEnabled"
        }

        # Remove sponsored link shortucts
        New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Set-ItemProperty -Name "NewTabPageHideDefaultTopSites" -Value 1

        if ($installUblock) {
            New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallForcelist" | Set-ItemProperty -Name "1" -Value "odfafepnkmbhccpbejgmiehpchacaeak"
        }
    }

    if ($disableHelpPaneF1) {
        Write-Host "Disabling HelpPane F1 shortcut" -NoNewline
        # taskkill /f /im "HelpPane.exe"
        Stop-Process -Name "HelpPane" -Force -ErrorAction SilentlyContinue
        takeown /f "c:\windows\HelpPane.exe"
        icacls "c:\windows\HelpPane.exe" /deny "Everyone:(X)"
    }
    else {
        Write-Host "Enabling HelpPane F1 shortcut" -NoNewline
        takeown /f "c:\windows\HelpPane.exe"
        icacls "c:\windows\HelpPane.exe" /grant "Everyone:(X)"
        Start-Process "HelpPane.exe" -ErrorAction SilentlyContinue
    }
    Write-Host ""

    if ($disableTelemetry) {
        Write-Host "Disabling telemetry"
        New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" | Set-ItemProperty -Name "AllowTelemetry" -Value 0
        # Disable and stop telemetry service
        Set-Service -StartupType Disabled DiagTrack
        Stop-Service DiagTrack

        [System.Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', 'true', 'Machine')
        [System.Environment]::SetEnvironmentVariable('DOTNET_CLI_TELEMETRY_OPTOUT', 'true', 'Machine')
        
    }
    else {
        Write-Host "Resetting telemetry to default"
        New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" | Remove-ItemProperty -Name "AllowTelemetry"
        # Reset telemetry service
        Set-Service -StartupType Automatic DiagTrack

        [System.Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', $null, 'Machine')
        [System.Environment]::SetEnvironmentVariable('DOTNET_CLI_TELEMETRY_OPTOUT', $null, 'Machine')
    }
    Write-Host ""

    # if ($disableMsAccounts) {
    #     New-ItemOrGet -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | Set-ItemProperty -Name "NoConnectedUser" -Value 3
    #     New-ItemOrGet -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Settings\AllowYourAccount" | Set-ItemProperty -Name "value" -Value 0
    #     New-ItemOrGet -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Settings\AllowSignInOptions" | Set-ItemProperty -Name "value" -Value 0
    # }
    # else {
    #     Remove-ItemPropertyIfExist -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "NoConnectedUser"
    # }

    if ($disableBackgroundProcesses) {
        New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Set-ItemProperty -Name "StartupBoostEnabled" -Value 0
        taskkill /f /im "msedge.exe"
        taskkill /f /im "MicrosoftEdgeUpdate.exe"
    }
    else {
        Remove-ItemPropertyIfExist -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "StartupBoostEnabled"
    }

    if ($installFirefox) {
        Write-Host "Installing Firefox..."
        winget install --id Mozilla.Firefox --exact
        Write-Host "Firefox installed"
        if ($installUblock) {
            # https://mozilla.github.io/policy-templates/#extensionsettings
            New-ItemOrGet -Path "HKLM:\Software\Policies\Mozilla\Firefox" | Set-ItemProperty -Name "ExtensionSettings" -Value @"
{"uBlock0@raymondhill.net": {"installation_mode": "normal_installed", "install_url": "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi" }}
"@
        }
    }

    if($installChrome){
        # Google.Chrome
        Write-Host "Installing Chrome..."
        winget install --id Google.Chrome --exact
        Write-Host "Chrome installed"
    }

    # if($oldRightClickMenu){

    # }

    if ($removeOneDrive) {
        Write-Host "Removing OneDrive..."
        Remove-WingetIfExists "Microsoft.OneDrive"
        Write-Host "OneDrive removed`n"
    }

    Write-Host "Restarting explorer..."
    taskkill /f /im "explorer.exe"
    Start-Process "explorer.exe"
    Write-Host "Explorer restarted"
}
catch {
    Write-Host $_.Exception
}
finally {
    Read-Host -Prompt "Any key to exit"
}
