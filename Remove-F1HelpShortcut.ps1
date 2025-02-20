Write-Host "Disabling Explorer HelpPane F1 shortcut (see Remove-F1HelpShortcut.ps1 to revert)" -NoNewline
# taskkill /f /im "HelpPane.exe"
Stop-Process -Name "HelpPane" -Force -ErrorAction SilentlyContinue
takeown /f "c:\windows\HelpPane.exe"
icacls "c:\windows\HelpPane.exe" /deny "Everyone:(X)"
Write-Host ""

# Revert with this:
<#
Write-Host "Enabling HelpPane F1 shortcut" -NoNewline
takeown /f "c:\windows\HelpPane.exe"
icacls "c:\windows\HelpPane.exe" /grant "Everyone:(X)"
Start-Process "HelpPane.exe" -ErrorAction SilentlyContinue
#>