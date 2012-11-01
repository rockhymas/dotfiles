function Get-Batchfile ($file) {
    $cmd = "`"$file`" & set"
    cmd /c $cmd | Foreach-Object {
        $p, $v = $_.split('=')
        Set-Item -path env:$p -value $v
    }
}

function vpn($vpn)
{
    switch ($vpn)
    {
        "prax" 
        {
            mw-vpn disconnect
            lw-vpn disconnect
            prax-vpn
        }
        "mw" 
        {
            lw-vpn disconnect
            prax-vpn disconnect
            mw-vpn
        }
        "lw"
        {
            mw-vpn disconnect
            prax-vpn disconnect
            lw-vpn
        }
        default { echo "unknown vpn" }
    }
}

function mw-vpn($disconnect = $false)
{
    if ($disconnect)
    {
        rasdial MetroPlex /disconnect
    }
    else
    {
        rasdial MetroPlex trackabout *
    }
}

function prax-vpn($disconnect = $false)
{
    if ($disconnect)
    {
        rasdial Praxair /disconnect
    }
    else
    {
        rasdial Praxair praxair-usa\USASXT8 *
        route add 167.22.144.0 mask 255.255.255.0 10.32.244.1
        route add 167.22.144.0 mask 255.255.255.0 10.32.245.1
        route add 167.22.145.0 mask 255.255.255.0 10.32.244.1
        route add 167.22.145.0 mask 255.255.255.0 10.32.245.1
        route add 167.22.148.0 mask 255.255.255.0 10.32.244.1
        route add 167.22.148.0 mask 255.255.255.0 10.32.245.1
        route add 10.172.3.0  mask 255.255.255.0 10.32.244.1
        route add 10.172.3.0  mask 255.255.255.0 10.32.245.1
        route add 167.22.144.0 mask 255.255.255.0 10.40.244.1
        route add 167.22.144.0 mask 255.255.255.0 10.40.245.1
        route add 167.22.145.0 mask 255.255.255.0 10.40.244.1
        route add 167.22.145.0 mask 255.255.255.0 10.40.245.1
        route add 167.22.148.0 mask 255.255.255.0 10.40.244.1
        route add 167.22.148.0 mask 255.255.255.0 10.40.245.1
        route add 10.172.3.0  mask 255.255.255.0 10.40.244.1
        route add 10.172.3.0  mask 255.255.255.0 10.40.245.1
    }
}

function lw-vpn($disconnect = $false)
{
    if ($disconnect)
    {
        & 'C:\Program Files (x86)\Cisco Systems\VPN Client\vpnclient.exe' disconnect
    }
    else
    {
        & 'C:\Program Files (x86)\Cisco Systems\VPN Client\vpnclient.exe' connect "Logicworks VPN" cliauth
    }
}

function ta-db
{
    runas /noprofile /netonly /user:trackabout\rhymas "C:\Program Files (x86)\Microsoft SQL Server\100\Tools\Binn\VSShell\Common7\IDE\ssms.exe"
}

function prax-db($network)
{
    runas /noprofile /netonly /user:praxair-$network\USAXNTS1190 "C:\Program Files (x86)\Microsoft SQL Server\100\Tools\Binn\VSShell\Common7\IDE\ssms.exe"
}

function prax-ps($network)
{
    runas /noprofile /netonly /user:praxair-$network\USAXNTS1190  "c:\windows\system32\WindowsPowerShell\v1.0\powershell.exe"
}

function ta-ps
{
    runas /noprofile /netonly /user:TRACKABOUT\rhymas "c:\windows\system32\WindowsPowerShell\v1.0\powershell.exe"
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

function Write-HgInfo($path = $PWD.Path)
{
    hg prompt "{status|modified|unknown};{root};{root|basename};" | Set-Variable promptstr
    svn info $path.Replace("\", "/") | Set-Variable svninfo
    if ($promptstr -ne $null) {
        $promptstrarray = $promptstr.Split(';')
        $status = $promptstrarray[0]
        $root = $promptstrarray[1]
        $rootbasename = $promptstrarray[2]
        $rootdir = $root.Remove($root.LastIndexOf($rootbasename))
    }
    elseif ($svninfo -ne $null) {
        $root = $svninfo[1].split(":", 2)[1].Trim()
        $rootbasename = $root.Substring($root.LastIndexOf("\") + 1)
        $rootdir = $root.Remove($root.LastIndexOf($rootbasename))
    }
    else {
        $rootdir = $path
        $status = ""
    }
    Write-Host $rootdir -nonewline -foregroundcolor Yellow
    Write-Host $path.Substring($rootdir.Length) -nonewline -foregroundcolor Green
    Write-Host "$status" -foregroundcolor Yellow
}

function prompt
{
    Write-HgInfo
    Write-Host ('>') -nonewline -foregroundcolor Yellow
    return " "
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
