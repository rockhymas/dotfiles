if ($(Get-ExecutionPolicy) -ne "RemoteSigned") {
    Set-ExecutionPolicy RemoteSigned
}

if (!(Test-Path $profile)) {
    $profilepath = Split-Path $profile
    if (!(Test-Path $profilepath)) {
        New-Item $profilepath -type directory
    }
    echo ". `$env:userprofile\.ps1" > $profile
}