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

[Diagnostics.Process]::Start("http://www.vim.org/download.php#pc")