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
    Write-Host ($(get-location)) -nonewline -foregroundcolor Yellow
    Write-Host ($status) -nonewline -foregroundcolor Cyan
    Write-Host ('>') -nonewline -foregroundcolor Yellow
    return " "
}

function cd.. ([string]$path = ".")
{
    Set-Location "..\$path"
}

Set-Alias ".." "cd.."

VsVars32
[System.Console]::Title = "Console"

