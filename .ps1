function Get-Batchfile ($file) {
    $cmd = "`"$file`" & set"
    cmd /c $cmd | Foreach-Object {
        $p, $v = $_.split('=')
        Set-Item -path env:$p -value $v
    }
}

function VsVars32
{
    foreach ($version in "10.0", "9.0", "8.0") {

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

    $psi = new-object "Diagnostics.ProcessStartInfo"
    $psi.FileName = $program 
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

function Write-HgStatus($path = $PWD.Path)
{
    hg prompt "{branch}{ {status|modified|unknown}}" | Set-Variable promptstr
    if ($promptstr -ne $null) {
        $status = $promptstr
        Write-Host " [" -foregroundcolor Yellow -nonewline
        Write-Host "$status" -foregroundcolor Magenta -nonewline
        Write-Host "]" -foregroundcolor Yellow -nonewline
    }
}


VsVars32
[System.Console]::Title = "Console"

#
# Git prompt and posh-git
#

. $env:LOCALAPPDATA\GitHub\shell.ps1

# Load posh-git module
Push-Location $env:github_posh_git
Import-Module .\posh-git
Pop-Location

# Set up a simple prompt, adding the git prompt parts inside git repos
function prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    # Reset color, which can be messed up by Enable-GitColors
    $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor

    Write-Host($pwd.ProviderPath) -nonewline

    Write-VcsStatus

    Write-Host(">") -nonewline

    $global:LASTEXITCODE = $realLASTEXITCODE
    $Host.UI.RawUI.ForegroundColor = "Gray"

    return " "
}

$VcsPromptStatuses += {Write-HgStatus}
$GitPromptSettings.DefaultForegroundColor = "Yellow"
Enable-GitColors
Start-SshAgent -Quiet

if (Test-Path "~\local.ps1") {
    . ~\local.ps1
}
