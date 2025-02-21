. .\Registry-Module.ps1

# Disables the start menu searching the web
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" | Set-ItemProperty -Name "DisableSearchBoxSuggestions" -Value 1

# Remove sponsored link shortucts in Edge
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Set-ItemProperty -Name "NewTabPageHideDefaultTopSites" -Value 1

# Default to Google search
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Set-ItemProperty -Name "DefaultSearchProviderEnabled" -Value 1
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Set-ItemProperty -Name "DefaultSearchProviderName" -Value "Google"
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Set-ItemProperty -Name "DefaultSearchProviderSearchURL" -Value "{google:baseURL}search?q=%s&{google:RLZ}{google:originalQueryForSuggestion}{google:assistedQueryStats}{google:searchFieldtrialParameter}{google:iOSSearchLanguage}{google:searchClient}{google:sourceId}{google:contextualSearchVersion}ie={inputEncoding}"
New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Set-ItemProperty -Name "DefaultSearchProviderSuggestURL" -Value "{google:baseURL}complete/search?output=chrome&q={searchTerms}"

if (-not $configuration -eq "PARENT") {
    # Show file types
    New-ItemOrGet -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" | Set-ItemProperty -Name "HideFileExt" -Value 0
    
    # Left align taskbar
    New-ItemOrGet -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" | Set-ItemProperty -Name "TaskbarAl" -Value 0

    # Hide task view button (for win + tab shortcut)
    New-ItemOrGet -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" | Set-ItemProperty -Name "ShowTaskViewButton" -Value 0

    # Show hidden files
    New-ItemOrGet -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" | Set-ItemProperty -Name "Hidden" -Value 1

    # Hide taskbar search box
    New-ItemOrGet -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" | Set-ItemProperty -Name "SearchboxTaskbarMode" -Value 0   
}

if (-not $configuration -eq "WORK") {
    Write-Host "Disabling delivery optimization"
    New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" | Set-ItemProperty -Name "DODownloadMode" -Value 0
}

# Stops edge running in background
if ($configuration -eq "HOME") {
    New-ItemOrGet -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" | Set-ItemProperty -Name "StartupBoostEnabled" -Value 0
}