# To Run

```pwsh
ipconfig /flushdns
Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force
Invoke-WebRequest https://github.com/Zaldos/setup-pc/archive/refs/heads/main.zip -OutFile "$($env:TEMP)/pcsetup.zip"
Expand-Archive -LiteralPath "$($env:TEMP)/pcsetup.zip" -DestinationPath "$($env:USERPROFILE)/Downloads" -Force
Set-Location "$($env:USERPROFILE)/Downloads/setup-pc-main" #<repo-name>-<branchname>
.\SetupPc.ps1
```