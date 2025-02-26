<# Big list
"Clipchamp.Clipchamp" #video editor requiring MS login
"Microsoft.BingNews" #Junk app (not the task bar widget)
"Microsoft.BingWeather" #Junk app (not the task bar widget)
"Microsoft.BingSearch" #Junk app (not the task bar widget)
"Microsoft.Copilot" # Desktop copilot chat app
"Microsoft.OutlookForWindows" #Email
"Microsoft.PowerAutomateDesktop" #Some automation thing needing MS login
"Microsoft.Todos"
"Microsoft.Wallet"
"Microsoft.WindowsFeedbackHub"
"Microsoft.WindowsMaps"
"Microsoft.YourPhone" # Phone link
"*SolitaireCollection*"
"Microsoft.ZuneMusic" # New Windows Media Player
"MicrosoftWindows.Client.WebExperience" #Taskbar news and weather widget
"Microsoft.MicrosoftOfficeHub" #MS Office
"Microsoft.Teams"
"MSTeams"
"Microsoft.GamingApp" # The XBOX app
"MicrosoftCorporationII.QuickAssist" # Quick assist app
"Microsoft.Xbox.TCUI" # XBOX Live
#>

switch ($configuration) {
    "WORK" {
        $appsToRemove = @(
            "Clipchamp.Clipchamp" #video editor requiring MS login
            "Microsoft.BingNews" #Junk app (not the task bar widget)
            "Microsoft.BingWeather" #Junk app (not the task bar widget)
            "Microsoft.BingSearch" #Junk app (not the task bar widget)
            "Microsoft.Copilot" # Desktop copilot chat app
            "Microsoft.PowerAutomateDesktop" #Some automation thing needing MS login
            "Microsoft.Todos"
            "Microsoft.Wallet"
            "Microsoft.WindowsFeedbackHub"
            "Microsoft.WindowsMaps"
            "Microsoft.YourPhone" # Phone link
            "*SolitaireCollection*"
            "Microsoft.GamingApp" # The XBOX app
            "Microsoft.Xbox.TCUI" # XBOX Live
        )
    }
    "PARENT" {
        $appsToRemove = @(
            "Microsoft.BingNews" #Junk app (not the task bar widget)
            "Microsoft.BingWeather" #Junk app (not the task bar widget)
            "Microsoft.BingSearch" #Junk app (not the task bar widget)
            "Microsoft.Copilot" # Desktop copilot chat app
            "Microsoft.OutlookForWindows" #Email
            "Microsoft.PowerAutomateDesktop" #Some automation thing needing MS login
            "Microsoft.Todos"
            "Microsoft.Wallet"
            "Microsoft.WindowsFeedbackHub"
            "Microsoft.WindowsMaps"
            "Microsoft.YourPhone" # Phone link
            "*SolitaireCollection*"
            "Microsoft.Teams"
            "MSTeams"
        )
    }
    "HOME" {
        $appsToRemove = @(
            "Clipchamp.Clipchamp" #video editor requiring MS login
            "Microsoft.BingNews" #Junk app (not the task bar widget)
            "Microsoft.BingWeather" #Junk app (not the task bar widget)
            "Microsoft.BingSearch" #Junk app (not the task bar widget)
            "Microsoft.Copilot" # Desktop copilot chat app
            "Microsoft.OutlookForWindows" #Email
            "Microsoft.PowerAutomateDesktop" #Some automation thing needing MS login
            "Microsoft.Todos"
            "Microsoft.Wallet"
            "Microsoft.WindowsFeedbackHub"
            "Microsoft.WindowsMaps"
            "Microsoft.YourPhone" # Phone link
            "*SolitaireCollection*"
            "Microsoft.ZuneMusic" # New Windows Media Player
            "Microsoft.MicrosoftOfficeHub" #MS Office
            "Microsoft.Teams"
            "MSTeams"
            "MicrosoftCorporationII.QuickAssist" # Quick assist app
        )
    }
    default {
        $appsToRemove = @()
    }
}

if ($removeNewsAndInterests) {
    $appsToRemove += @(
        "MicrosoftWindows.Client.WebExperience" #Taskbar news and weather widget
    )
}

foreach ($app in $appsToRemove) {
    if ($dryRun) {
        Write-Host "Dry run: checking app '$app' exists"
        $app = Get-AppxPackage "$app" -AllUsers
        if ($null -ne $app) {
            Write-Host "$app exists and wouldve been removed!"
        }
        else {
            Write-Host "$app does not exist!"
        }
    }
    else {
        Write-Host "Looking for and removing $app"
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

if ($appsToRemove.Count -gt 0) {
    Write-Host "Appx removals done!`n"
}