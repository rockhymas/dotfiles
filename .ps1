function Get-Batchfile ($file) {
    $cmd = "`"$file`" & set"
    cmd /c $cmd | Foreach-Object {
        $p, $v = $_.split('=')
        Set-Item -path env:$p -value $v
    }
}

function VsVars32
{
    if ((Test-Path "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\Tools\vsdevcmd.bat") -eq $true) {
        Get-BatchFile "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\Tools\vsdevcmd.bat"
        # add a message when this isn't the latest anymore
        return;
    }

    if ((Test-Path "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\Common7\Tools\vsdevcmd.bat") -eq $true) {
        Get-BatchFile "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\Common7\Tools\vsdevcmd.bat"
        echo "Using VS tools version 2019"
        return;
    }

    if ((Test-Path "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\Common7\Tools\vsdevcmd.bat") -eq $true) {
        Get-BatchFile "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\Common7\Tools\vsdevcmd.bat"
        echo "Using VS tools version 2017"
        return;
    }

    echo "No VS tools version found"
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

$env:VSCMD_SKIP_SENDTELEMETRY = 'No way'
VsVars32
[System.Console]::Title = "Console"
oh-my-posh init pwsh --config ~/.rock.omp.json | Invoke-Expression
if (Test-Path "~\local.ps1") {
    . ~\local.ps1
}
