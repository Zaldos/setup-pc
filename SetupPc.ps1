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

$DebugPreference = "SilentlyContinue" # Debug messages off
# $DebugPreference = "Continue" # Debug messages on

Write-Host "Using $configuration configuration"

$disableTelemetry = $true
$hideNewsAndInterests = $true # Only registry toggles not app removals
$removeNewsAndInterests = $true # Removes the app too in Remove-AppxJunk.ps1

$oldRightClickMenu = $true #TODO
$disableMsAccounts = $false #TODO

$installApps = $false
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

    if ($installApps) {
        . .\Add-Apps.ps1 #should go last? Move out registry toggles}
    }
}
catch {
    Write-Host $_.Exception
}
finally {
    Read-Host -Prompt "Any key to exit"
}
