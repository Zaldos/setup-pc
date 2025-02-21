. .\Registry-Module.ps1

Write-Host "Disabling start search searching the web for everyone"
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" | Set-ItemProperty -Name "DisableSearchBoxSuggestions" -Value 1

Write-Host "Removing sponsored link shortcuts in Edge for everyone"
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Set-ItemProperty -Name "NewTabPageHideDefaultTopSites" -Value 1

Write-Host "Setting Edge to 'NotDotTrack'"
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Set-ItemProperty -Name "ConfigureDoNotTrack" -Value 1

Write-Host "Setting Edge to block unwated apps"
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\Recommended" | Set-ItemProperty -Name "SmartScreenPuaEnabled" -Value 1

<#
RestoreOnStartupIsNewTabPage (5) = Open a new tab
RestoreOnStartupIsLastSession (1) = Restore the last session
#>
Write-Host "Edge will restore tabs from last session"
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\Recommended" | Set-ItemProperty -Name "RestoreOnStartup" -Value 1

Write-Host "Disabling Edge's 'shopping assistant'"
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge\Recommended" | Set-ItemProperty -Name "EdgeShoppingAssistantEnabled" -Value 0

Write-Host "Disabling windows feedback suggestions"
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