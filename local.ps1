Set-Item -path env:IPPROOT -value "c:\code\storyline\3rd Party\Intel\IPP\ia32"
Set-Item -path env:BUILDROOT -value "C:\Users\Rock\Dropbox\builds"
Set-Item -path env:ARTICULATEDEV -value ARTICULATEDEV

function studio
{
    Invoke-Admin 'C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\devenv.exe' c:\code\studio\studio.sln
}

function Update-Repo($path, $upstream)
{
    pushd $path
    $branch = (git branch | ? {$_.StartsWith("*")} | % {$_.Substring(2)})
    git checkout $upstream
    git pull origin $upstream
    git rebase $upstream $branch
    popd
}

function Update-Studio
{
    Update-Repo c:\code\studio master
    Update-Repo c:\code\studio\common v4.0
    Update-Repo c:\code\studio\bridgewater v3.0
    c:\code\studio\devinstall\install.bat
}

function storyline
{
    Invoke-Admin 'C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\devenv.exe' c:\code\storyline\storyline.sln
}

function Update-Storyline
{
    Update-Repo c:\code\storyline master
}
