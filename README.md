# Windows Admin Scripts

A small set of PowerShell utilities for Windows administration.

## Copy/paste commands

### Remove-WindowsBloatware.ps1

> Run PowerShell as Administrator.

```powershell
$u='https://raw.githubusercontent.com/MasonAuchy/windows-admin-scripts/main/Remove-WindowsBloatware.ps1';$p=Join-Path $env:TEMP 'Remove-WindowsBloatware.ps1';iwr $u -UseBasicParsing -OutFile $p;powershell.exe -NoProfile -ExecutionPolicy Bypass -File $p -Verbose
```

### Get-SystemUptime.ps1

```powershell
$u='https://raw.githubusercontent.com/MasonAuchy/windows-admin-scripts/main/Get-SystemUptime.ps1';$p=Join-Path $env:TEMP 'Get-SystemUptime.ps1';iwr $u -UseBasicParsing -OutFile $p;powershell.exe -NoProfile -ExecutionPolicy Bypass -File $p
```

### List-AppxPackages.ps1

```powershell
$u='https://raw.githubusercontent.com/MasonAuchy/windows-admin-scripts/main/List-AppxPackages.ps1';$p=Join-Path $env:TEMP 'List-AppxPackages.ps1';iwr $u -UseBasicParsing -OutFile $p;powershell.exe -NoProfile -ExecutionPolicy Bypass -File $p
```

## Notes

- These scripts are meant for Windows PowerShell / PowerShell 7 on Windows.
- For `Remove-WindowsBloatware.ps1`, add `-WhatIf` to the final command if you want a dry run, or `-SkipRegistryHardening` if you want to skip the registry changes.
