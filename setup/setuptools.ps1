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

reg import "$(Split-Path $myinvocation.mycommand.path)\consolasfont.reg"
reg import "$(Split-Path $myinvocation.mycommand.path)\capslockisctrl.reg"

$ahklnk = $env:USERPROFILE + "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\.ahk.lnk"
if (!(Test-Path $ahklnk))
{
    $objShell = New-Object -ComObject ("WScript.Shell")
    $objShortCut = $objShell.CreateShortcut($ahklnk)
    $objShortCut.TargetPath = $env:USERPROFILE + "\.ahk"
    $objShortCut.Save()
}
