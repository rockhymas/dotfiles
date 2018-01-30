function Get-Batchfile ($file) {
    $cmd = "`"$file`" & set"
    cmd /c $cmd | Foreach-Object {
        $p, $v = $_.split('=')
        Set-Item -path env:$p -value $v
    }
}

function VsVars32
{
    if ((Test-Path "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\Common7\Tools\vsdevcmd.bat") -eq $true) {
        Get-BatchFile "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\Common7\Tools\vsdevcmd.bat"
        echo "Using VS tools version 15.0"
        return;
    }

    foreach ($version in "15.0", "14.0", "12.0", "11.0", "10.0", "9.0", "8.0") {

        $key = "HKLM:SOFTWARE\Microsoft\VisualStudio\" + $version
        if ((Test-Path $key) -eq $true) {
            if ((get-itemproperty $key).InstallDir -eq $null) {
                $key = "HKLM:SOFTWARE\Wow6432Node\Microsoft\VisualStudio\" + $version
            }
            if ((Test-Path $key) -eq $true) {
                $VsKey = get-ItemProperty $key
                $VsInstallPath = [System.IO.Path]::GetDirectoryName($VsKey.InstallDir)
                $VsToolsDir = [System.IO.Path]::GetDirectoryName($VsInstallPath)
                $VsToolsDir = [System.IO.Path]::Combine($VsToolsDir, "Tools")
                $BatchFile = [System.IO.Path]::Combine($VsToolsDir, "vsvars32.bat")
                Get-Batchfile $BatchFile
                echo "Using VS tools version $version"
                break;
            }
        }
    }
}

function which($name = "")
{
    where.exe $name
}

function cd.. ([string]$path = ".")
{
    Set-Location "..\$path"
}
Set-Alias ".." "cd.."

function Invoke-Admin() {
    param ( [string]$program = $(throw "Please specify a program" ),
            [string]$argumentString = "",
            [switch]$waitForExit )

    $fullpath = (dir $program).FullName
    $psi = new-object "Diagnostics.ProcessStartInfo"
    $psi.FileName = $fullpath
    $psi.Arguments = $argumentString
    $psi.Verb = "runas"
    $proc = [Diagnostics.Process]::Start($psi)
    if ( $waitForExit ) {
        $proc.WaitForExit();
    }
}

VsVars32
[System.Console]::Title = "Console"
$env:path += ";" + (Get-Item "Env:ProgramFiles(x86)").Value + "\Git\bin"
if (Test-Path "~\local.ps1") {
    . ~\local.ps1
}
