function Get-Batchfile ($file) {
    $cmd = "`"$file`" & set"
    cmd /c $cmd | Foreach-Object {
        $p, $v = $_.split('=')
        Set-Item -path env:$p -value $v
    }
}

function VsVars32
{
    foreach ($version in "12.0", "11.0", "10.0", "9.0", "8.0") {

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

function e($file = "")
{
    $a = @()
    if ($file -ne "")
    {
        $dir = $null
        if (Test-Path $file) {
            $file = get-item $file
            if (($file -ne $null) -and ($file.Directory -ne $null)) {
                $dir = $file.Directory
            }
        }
        else {
            if(-not (Split-Path $file -IsAbsolute)) {
                $file = join-path $pwd $file
            }
            $dir = new-object System.IO.DirectoryInfo -argumentlist ([System.IO.Path]::GetDirectoryName($file))
        }
        if ($dir -ne $null) {
            $servername = (hg root --cwd $dir.FullName) 2>$null
            if ($servername -ne $null) {
                $a += '--servername'
                $a += $servername
            }
        }
        $a += '--remote-silent'
        $a += $file
    }
    write-host $a
    & 'gvim' $a
}


VsVars32
[System.Console]::Title = "Console"
$env:path += ";" + (Get-Item "Env:ProgramFiles(x86)").Value + "\Git\bin"
if (Test-Path "~\local.ps1") {
    . ~\local.ps1
}
