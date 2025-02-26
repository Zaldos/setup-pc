# Allow scripts to run, run it on both pwsh and powershell
# Scoped
<# For user
Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force
.\Script.ps1 #>

##########################################################
<#
 $$$$$$\   $$$$$$\  $$\   $$\ $$$$$$$$\ $$$$$$\  $$$$$$\  
$$  __$$\ $$  __$$\ $$$\  $$ |$$  _____|\_$$  _|$$  __$$\ 
$$ /  \__|$$ /  $$ |$$$$\ $$ |$$ |        $$ |  $$ /  \__|
$$ |      $$ |  $$ |$$ $$\$$ |$$$$$\      $$ |  $$ |$$$$\ 
$$ |      $$ |  $$ |$$ \$$$$ |$$  __|     $$ |  $$ |\_$$ |
$$ |  $$\ $$ |  $$ |$$ |\$$$ |$$ |        $$ |  $$ |  $$ |
\$$$$$$  | $$$$$$  |$$ | \$$ |$$ |      $$$$$$\ \$$$$$$  |
 \______/  \______/ \__|  \__|\__|      \______| \______/ 

Please check config values below
#> #######################################################

# This configures which apps are added removed and some other tweaks.
# Check each file for references to these to see what they effect in detail.
# $configuration = "PARENT"
# $configuration = "WORK" # Main difference is installation of a few specific apps
$configuration = "HOME"

$DebugPreference = "SilentlyContinue" # Debug messages off
# $DebugPreference = "Continue" # Debug messages on

Write-Host "Using $configuration configuration"

$disableTelemetry = $true # (pwsh and dotnet in all configs, home/parent windows telemetry too)

$hideNewsAndInterests = $true # Removes annoying taskbar news widget. Only registry toggles not app removals
$removeNewsAndInterests = $true # Removes the app too in Remove-AppxJunk.ps1

$oldRightClickMenu = $true

$installApps = $true
$installAdblock = $true # Will force UblockOrigin onto your browser :)
$installFirefox = $true
$installChrome = $false

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
    exit -1
}

function Restart-Processes {
    Write-Host "Restarting explorer..."
    taskkill /f /im "explorer.exe" | Write-Debug
    Start-Process "explorer.exe" | Write-Debug
    Write-Host "Explorer restarted"

    taskkill /f /im "msedge.exe" | Write-Debug
    taskkill /f /im "MicrosoftEdgeUpdate.exe" | Write-Debug
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

    if ($installApps) {
        . .\Add-Apps.ps1 #should go last? Move out registry toggles}
    }

    Restart-Processes
    
    Start-Sleep -Seconds 2
    if($true -eq $openDownloads){
        explorer.exe "$($env:USERPROFILE)/Downloads"
    }
}
catch {
    Write-Host $_.Exception
}
finally {
    Read-Host -Prompt "Any key to exit"
}
