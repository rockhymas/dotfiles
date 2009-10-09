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
    hg prompt "{status|modified|unknown}" | Set-Variable status
    hg prompt "{root}" | Set-Variable root
    (get-location).Path | Set-Variable path
    if (($root -ne $null) -and ($path.Contains($root))) {
        Write-Host ($root) -nonewline -foregroundcolor Yellow
        Write-Host ($path.Substring($root.Length) + '\') -nonewline -foregroundcolor Green
    }
    else {
        Write-Host ($path + '\') -nonewline -foregroundcolor Yellow
    }
    Write-Host ($status) -foregroundcolor Cyan
    Write-Host ('>') -nonewline -foregroundcolor Yellow
    return " "
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

