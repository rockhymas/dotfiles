elevate-process servermanagercmd -install PowerShell
elevate-process powershell -c "Set-ExecutionPolicy RemoteSigned"
powershell -c "%~dp0\setuptools.ps1"
