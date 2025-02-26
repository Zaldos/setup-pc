. .\Registry-Module.ps1

Write-Host "Attempting to enable hibernate"
try {
    powercfg /hibernate on
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Hibernation enabled"
    }
}
catch {
    Write-Host "Unble to enable hibernation"
    Write-Host $_
}

if ($oldRightClickMenu) {
    Write-Host "Restoring old right click menu"
    New-ItemOrGet -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" | Set-ItemProperty -Name "(Default)" -Value ""
}

Write-Host "Disable 5xshift key for sticky keys"
New-ItemOrGet -Path "HKCU:\Control Panel\Accessibility\StickyKeys" | Set-ItemProperty -Name "Flags" -Value "506"

Write-Host "Disable 8sec of right shift key for filter keys"
New-ItemOrGet -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" | Set-ItemProperty -Name "Flags" -Value "122"

Write-Host "Disabling start menu badgering you for login for everyone"
New-ItemOrGet -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" | Set-ItemProperty -Name "Start_AccountNotifications" -Value 0

Write-Host "Disabling start search searching the web for everyone"
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" | Set-ItemProperty -Name "DisableSearchBoxSuggestions" -Value 1

Write-Host "Removing sponsored link shortcuts in Edge for everyone"
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Set-ItemProperty -Name "NewTabPageHideDefaultTopSites" -Value 1

# Hides the spotlight shortcut on desktop
if ($null -eq (Test-Path -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{2cc5ca98-6485-489a-920e-b3e88a6ccce3}")) {
    Remove-Item "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{2cc5ca98-6485-489a-920e-b3e88a6ccce3}"
}
New-ItemOrGet -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" | Set-ItemProperty -Name "{2cc5ca98-6485-489a-920e-b3e88a6ccce3}" -Value 1

Write-Host "Removing Edge's 'trending' searches"
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Set-ItemProperty -Name "AddressBarTrendingSuggestEnabled" -Value 0

Write-Host "Setting Edge to 'NotDotTrack' for everyone"
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Set-ItemProperty -Name "ConfigureDoNotTrack" -Value 1

Write-Host "Setting Edge to block unwated apps as recommended"
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\Recommended" | Set-ItemProperty -Name "SmartScreenPuaEnabled" -Value 1

Write-Host "Disabling Edge sidebar as recommended"
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\Recommended" | Set-ItemProperty -Name "HubsSidebarEnabled" -Value 0

Write-Host "Disabling Edge's 'shopping assistant' as recommended"
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\Recommended" | Set-ItemProperty -Name "EdgeShoppingAssistantEnabled" -Value 0

Write-Host "Disabling windows feedback suggestions for everyone"
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" | Set-ItemProperty -Name "DoNotShowFeedbackNotifications" -Value 1

Write-Host "Disabling annoying 'suggested' notifications for user"
New-ItemOrGet -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.Suggested" | Set-ItemProperty -Name "Enabled" -Value 0

if ($configuration -eq "HOME" -or $configuration -eq "WORK") {
    Write-Host "Showing file types for user"
    New-ItemOrGet -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" | Set-ItemProperty -Name "HideFileExt" -Value 0
    
    Write-Host "Left aligning taskbar for user"
    New-ItemOrGet -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" | Set-ItemProperty -Name "TaskbarAl" -Value 0

    Write-Host "Hiding task view button (for win + tab shortcut) for user"
    New-ItemOrGet -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" | Set-ItemProperty -Name "ShowTaskViewButton" -Value 0

    Write-Host "Showing hidden files for user"
    New-ItemOrGet -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" | Set-ItemProperty -Name "Hidden" -Value 1

    Write-Host "Hiding taskbar search box for user"
    New-ItemOrGet -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" | Set-ItemProperty -Name "SearchboxTaskbarMode" -Value 0
    
    Write-Host "Setting dark mode in apps and system for user"
    New-ItemOrGet -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" | Set-ItemProperty -Name "AppsUseLightTheme" -Value 0
    New-ItemOrGet -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" | Set-ItemProperty -Name "SystemUsesLightTheme" -Value 0
}

if ($configuration -eq "PARENT" -or $configuration -eq "HOME") {
    Write-Host "Disabling delivery optimization for everyone"
    New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" | Set-ItemProperty -Name "DODownloadMode" -Value 0
}

if ($configuration -eq "HOME") {
    Write-Host "Preventing edge running in background for everyone"
    New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Set-ItemProperty -Name "StartupBoostEnabled" -Value 0
}

if ($hideNewsAndInterests) {
    Write-Host "Hiding news and interests for everyone"
    # News and interests (w10)
    New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds\" | Set-ItemProperty -Name "EnableFeeds" -Value 0

    # Taskbar news (w11)
    New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" | Set-ItemProperty -Name "AllowNewsAndInterests" -Value 0
    Stop-Process -Name Widgets, WidgetService -ErrorAction SilentlyContinue

    # Edge news
    Write-Host "Hiding news and interests in Edge for everyone"
    New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Set-ItemProperty -Name "NewTabPageContentEnabled" -Value 0
}
else {
    Write-Host "Showing news and interests for everyone"
    # All should start after explorer restart
    # News and interests (w10)
    New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds\" | Set-ItemProperty -Name "EnableFeeds" -Value 1

    # Taskbar news (w11)
    New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" | Set-ItemProperty -Name "AllowNewsAndInterests" -Value 1
    
    # Edge news
    Write-Host "Showing news and interests in Edge for everyone"
    Remove-ItemPropertyIfExist -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "NewTabPageContentEnabled"
}

Write-Host "Registry tweaks done!`n"