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
"Microsoft.YourPhone"
"*SolitaireCollection*"
"Microsoft.ZuneMusic"
"MicrosoftWindows.Client.WebExperience"
"Microsoft.MicrosoftOfficeHub" #MS Office
"Microsoft.Teams"
"MSTeams"
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
            "Microsoft.YourPhone"
            "*SolitaireCollection*"
            "Microsoft.ZuneMusic"
            "MicrosoftWindows.Client.WebExperience"
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
            "Microsoft.YourPhone"
            "*SolitaireCollection*"
            "Microsoft.ZuneMusic"
            "MicrosoftWindows.Client.WebExperience"
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
            "Microsoft.YourPhone"
            "*SolitaireCollection*"
            "Microsoft.ZuneMusic"
            "MicrosoftWindows.Client.WebExperience"
            "Microsoft.MicrosoftOfficeHub" #MS Office
            "Microsoft.Teams"
            "MSTeams"
        )
    }
    default {
        $appsToRemove = @()
    }
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
        Write-Host "Lookign for and removing $app"
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