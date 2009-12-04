function elevate-process
{
    $file, [string]$arguments = $args;
    $psi = new-object System.Diagnostics.ProcessStartInfo $file;
    $psi.Arguments = $arguments;
    $psi.Verb = "runas";
    $psi.WorkingDirectory = get-location;
    [System.Diagnostics.Process]::Start($psi);
}

if ($(Get-ExecutionPolicy) -ne "RemoteSigned") {
    elevate-process powershell -c "Set-ExecutionPolicy RemoteSigned"
}
$profilepath = (new-object System.IO.FileInfo $profile).Directory.FullName
if (!(Test-Path $profilepath)) {
    New-Item (new-object System.IO.FileInfo $profile).Directory.FullName -type directory
}
Copy-Item $env:userprofile\bin\profileredirect.ps1 $profile

& ".\consolasfont.reg"
& ".\capslockisctrl.reg"

[Diagnostics.Process]::Start("http://cache.gawker.com/assets/images/lifehacker/2009/02/Windows_7_Shortcuts_0.4_02.zip")
[Diagnostics.Process]::Start("ftp://ftp.vim.org/pub/vim/pc/gvim72.exe")