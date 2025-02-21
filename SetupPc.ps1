# Allow scripts to run, run it on both pwsh and powershell
# Scoped
<#
# For user
Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force
.\Script.ps1
#>
# Useful
# $all = Get-AppxPackage "*OneDrive*" -allusers; $all | Select-Object -Property Name, InstallLocation | Sort-Object -Property Name

# $configuration = "PARENT"
# $configuration = "WORK"
$configuration = "HOME"
Write-Host "Using $configuration configuration"

$disableTelemetry = $true
$resetNewsAndInterestsRegistry = $false #only registry toggles not app removals

$installAdblock = $true # Will force UblockOrigin onto your browser :)
$installFirefox = $false
$installChrome = $false

$oldRightClickMenu = $true #TODO
$disableMsAccounts = $false #TODO

$skipAddingApps = $true

Set-Location "$PSScriptRoot"

. .\Winget-Module.ps1
. .\Registry-Module.ps1

try {
    if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
        Write-Host "Not launched as admin, relaunching..."
        Start-Process -WorkingDirectory "$PSScriptRoot" -FilePath powershell.exe -Verb Runas  -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`"  `"$($MyInvocation.MyCommand.UnboundArguments)`""
        exit 0
    }
}
catch {
    Write-Host $_
    Read-Host
}

function Restart-Processes {
    Write-Host "Restarting explorer..."
    taskkill /f /im "explorer.exe"
    Start-Process "explorer.exe"
    Write-Host "Explorer restarted"

    taskkill /f /im "msedge.exe"
    taskkill /f /im "MicrosoftEdgeUpdate.exe"
}

###########
## START ##
###########

try {
    # Accepts Terms
    winget list --accept-source-agreements --name "skipthis-asdasdasdadasd" | out-null
    . .\Remove-F1HelpShortcut.ps1
    . .\Add-RegistryTweaks.ps1
    . .\Remove-WingetApps.ps1
    . .\Remove-AppxJunk.ps1
    . .\Remove-Telemetry.ps1
  
    if ($resetNewsAndInterestsRegistry) {
        # All should start after explorer restart
        # News and interests (w10)
        New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds\" | Set-ItemProperty -Name "EnableFeeds" -Value 1

        # Taskbar news (w11)
        New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" | Set-ItemProperty -Name "AllowNewsAndInterests" -Value 1
        
        # Edge news
        Remove-ItemPropertyIfExist -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "NewTabPageContentEnabled"
    }
    else {
        # News and interests (w10)
        New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds\" | Set-ItemProperty -Name "EnableFeeds" -Value 0

        # Taskbar news (w11)
        New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" | Set-ItemProperty -Name "AllowNewsAndInterests" -Value 0
        Stop-Process -Name Widgets, WidgetService -ErrorAction SilentlyContinue

        # Edge news
        New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Set-ItemProperty -Name "NewTabPageContentEnabled" -Value 0
    }

    # if ($disableMsAccounts) {
    #     # these three dont do anything, maybe need restart
    #     New-ItemOrGet -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | Set-ItemProperty -Name "NoConnectedUser" -Value 3
    #     New-ItemOrGet -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Settings\AllowYourAccount" | Set-ItemProperty -Name "value" -Value 0
    #     New-ItemOrGet -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Settings\AllowSignInOptions" | Set-ItemProperty -Name "value" -Value 0
    # }
    # else {
    #     Remove-ItemPropertyIfExist -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "NoConnectedUser"
    # }
    
    Restart-Processes

    if (-not $skipAddingApps) {
        . .\Add-Apps.ps1 #should go last? Move out registry toggles}
    }
}
catch {
    Write-Host $_.Exception
}
finally {
    Read-Host -Prompt "Any key to exit"
}
