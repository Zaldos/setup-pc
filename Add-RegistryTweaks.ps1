. .\Registry-Module.ps1

Write-Host "Disabling start search searching the web for everyone"
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" | Set-ItemProperty -Name "DisableSearchBoxSuggestions" -Value 1

Write-Host "Removing sponsored link shortcuts in Edge for everyone"
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Set-ItemProperty -Name "NewTabPageHideDefaultTopSites" -Value 1

Write-Host "Setting Edge to 'NotDotTrack' for everyone"
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Set-ItemProperty -Name "ConfigureDoNotTrack" -Value 1

Write-Host "Setting Edge to block unwated apps as recommended"
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\Recommended" | Set-ItemProperty -Name "SmartScreenPuaEnabled" -Value 1

<#
RestoreOnStartupIsNewTabPage (5) = Open a new tab
RestoreOnStartupIsLastSession (1) = Restore the last session
#>
Write-Host "Edge will restore tabs from last session as recommended"
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\Recommended" | Set-ItemProperty -Name "RestoreOnStartup" -Value 1

Write-Host "Disabling Edge's 'shopping assistant' as recommended"
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\Recommended" | Set-ItemProperty -Name "EdgeShoppingAssistantEnabled" -Value 0

Write-Host "Disabling windows feedback suggestions for everyone"
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" | Set-ItemProperty -Name "DoNotShowFeedbackNotifications" -Value 1

if (-not ($configuration -eq "PARENT")) {
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
}

if (-not ($configuration -eq "WORK")) {
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

Write-Host "Registry tweeaks done!`n"