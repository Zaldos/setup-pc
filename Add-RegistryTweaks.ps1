. .\Registry-Module.ps1

Write-Host "Disabling start search searching the web for everyone"
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" | Set-ItemProperty -Name "DisableSearchBoxSuggestions" -Value 1

Write-Host "Removing sponsored link shortcuts in Edge for everyone"
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Set-ItemProperty -Name "NewTabPageHideDefaultTopSites" -Value 1

Write-Host "Defaulting to Google search in browser for everyone"
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Set-ItemProperty -Name "DefaultSearchProviderEnabled" -Value 1
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Set-ItemProperty -Name "DefaultSearchProviderName" -Value "Google"
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Set-ItemProperty -Name "DefaultSearchProviderSearchURL" -Value "{google:baseURL}search?q=%s&{google:RLZ}{google:originalQueryForSuggestion}{google:assistedQueryStats}{google:searchFieldtrialParameter}{google:iOSSearchLanguage}{google:searchClient}{google:sourceId}{google:contextualSearchVersion}ie={inputEncoding}"
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Set-ItemProperty -Name "DefaultSearchProviderSuggestURL" -Value "{google:baseURL}complete/search?output=chrome&q={searchTerms}"

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