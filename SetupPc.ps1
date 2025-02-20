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

$disableTelemetry = $true
$disableNewsAndInterests = $false #only registry toggles not app removals

$installAdblock = $true # Will force UblockOrigin onto your browser :)
$installFirefox = $false
$installChrome = $false

$oldRightClickMenu = $true #TODO
$disableMsAccounts = $false #TODO

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

###########
## START ##
###########

try {
    # Accepts Terms
    winget list --accept-source-agreements --name "skipthis-asdasdasdadasd" | out-null
    . .\Remove-F1HelpShortcut.ps1
    . .\Remove-WingetApps.ps1
    . .\Remove-Telemetry.ps1
  
    # Disables the start menu searching the web
    New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" | Set-ItemProperty -Name "DisableSearchBoxSuggestions" -Value 1

    # Remove sponsored link shortucts in Edge
    New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Set-ItemProperty -Name "NewTabPageHideDefaultTopSites" -Value 1

    # Hides the meet now icon on task bar (w10)
    New-ItemOrGet -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Set-ItemProperty -Name "HideSCAMeetNow" -Value 1

    if (-not $configuration -eq "WORK") {
        Write-Host "Disabling delivery optimization"
        New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" | Set-ItemProperty -Name "DODownloadMode" -Value 0
    }

    if ($disableNewsAndInterests) {
        # News and interests (w10)
        New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds\" | Set-ItemProperty -Name "EnableFeeds" -Value 0

        # Taskbar news (w11)
        New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" | Set-ItemProperty -Name "AllowNewsAndInterests" -Value 0
        Stop-Process -Name Widgets, WidgetService -ErrorAction SilentlyContinue

        # Edge news
        New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Set-ItemProperty -Name "NewTabPageContentEnabled" -Value 0
    }
    else {
        # All should start after explorer restart
        # News and interests (w10)
        New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds\" | Set-ItemProperty -Name "EnableFeeds" -Value 1

        # Taskbar news (w11)

        New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" | Set-ItemProperty -Name "AllowNewsAndInterests" -Value 1
        # Edge news
        New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Remove-ItemProperty -Name "NewTabPageContentEnabled"
    }

    # if ($disableMsAccounts) {
    #     New-ItemOrGet -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" | Set-ItemProperty -Name "NoConnectedUser" -Value 3
    #     New-ItemOrGet -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Settings\AllowYourAccount" | Set-ItemProperty -Name "value" -Value 0
    #     New-ItemOrGet -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Settings\AllowSignInOptions" | Set-ItemProperty -Name "value" -Value 0
    # }
    # else {
    #     Remove-ItemPropertyIfExist -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "NoConnectedUser"
    # }

    # Stops edge running in background
    if ($configuration -eq "HOME") {
        New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Set-ItemProperty -Name "StartupBoostEnabled" -Value 0
        taskkill /f /im "msedge.exe"
        taskkill /f /im "MicrosoftEdgeUpdate.exe"
    }
    
    
    Write-Host "Restarting explorer..."
    taskkill /f /im "explorer.exe"
    Start-Process "explorer.exe"
    Write-Host "Explorer restarted"

    . .\Add-Apps.ps1 #should go last? Move out registry toggles
}
catch {
    Write-Host $_.Exception
}
finally {
    Read-Host -Prompt "Any key to exit"
}
