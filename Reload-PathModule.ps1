function Reload-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + `
        ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}