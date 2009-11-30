function Get-Batchfile ($file) {
    $cmd = "`"$file`" & set"
    cmd /c $cmd | Foreach-Object {
        $p, $v = $_.split('=')
        Set-Item -path env:$p -value $v
    }
}

function VsVars32($version = "9.0")
{
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
        }
    }
}

function prompt
{
    hg prompt "{status|modified|unknown};{root};{root|basename}" | Set-Variable promptstr
    $PWD.Path | Set-Variable path
    if ($promptstr -ne $null) {
        $promptstrarray = $promptstr.Split(';')
        $status = $promptstrarray[0]
        $root = $promptstrarray[1]
        $rootbasename = $promptstrarray[2]
        $rootdir = $root.Remove($root.LastIndexOf($rootbasename))
        Write-Host ($rootdir) -nonewline -foregroundcolor Yellow
        Write-Host ($path.Substring($rootdir.Length)) -nonewline -foregroundcolor Green
        Write-Host ($status) -foregroundcolor Yellow
    }
    else {
        Write-Host ($path) -foregroundcolor Yellow
    }
    Write-Host ('>') -nonewline -foregroundcolor Yellow
    return " "
}

function which($name = "which")
{
    $name = $name + ".*"
    ($Env:Path).Split(";") | Get-ChildItem -filter $name | where {$_.Extension -match "^$|^.exe$|^.bat$|^.com$|^.ps1$"}
}

function cd.. ([string]$path = ".")
{
    Set-Location "..\$path"
}

Set-Alias ".." "cd.."

function elevate-process
{
    $file, [string]$arguments = $args;
    $psi = new-object System.Diagnostics.ProcessStartInfo $file;
    $psi.Arguments = $arguments;
    $psi.Verb = "runas";
    $psi.WorkingDirectory = get-location;
    [System.Diagnostics.Process]::Start($psi);
}


VsVars32
[System.Console]::Title = "Console"

$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
if ((Test-Path "$pwd\profile.ps1") -and ($scriptDirectory -ne $pwd)) {
    . $pwd\profile.ps1
}
