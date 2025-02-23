function Download-File($Uri, $OutFile) {
    $previousPreference = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest "$Uri" -OutFile "$OutFile"
    $ProgressPreference = $previousPreference
}