function Write-IfDebug($message) {
    if ($debug) {
        Write-Host $message -ForegroundColor Yellow 
    } 
}