# Windows Admin Scripts

A small set of PowerShell utilities for Windows administration.

## Included scripts

- `Remove-WindowsBloatware.ps1` — removes selected built-in Appx packages and applies a few consumer-feature hardening settings
- `Get-SystemUptime.ps1` — shows system uptime
- `List-AppxPackages.ps1` — opens a searchable list of installed Appx packages

## Remove Windows bloatware

> Run PowerShell as Administrator.

### Safer copy/paste version

This downloads the script to your temp folder and runs it from there:

```powershell
$url = 'https://raw.githubusercontent.com/MasonAuchy/windows-admin-scripts/main/Remove-WindowsBloatware.ps1'
$path = Join-Path $env:TEMP 'Remove-WindowsBloatware.ps1'
iwr $url -UseBasicParsing -OutFile $path
powershell.exe -NoProfile -ExecutionPolicy Bypass -File $path -Verbose
```

### Dry run first

```powershell
$url = 'https://raw.githubusercontent.com/MasonAuchy/windows-admin-scripts/main/Remove-WindowsBloatware.ps1'
$path = Join-Path $env:TEMP 'Remove-WindowsBloatware.ps1'
iwr $url -UseBasicParsing -OutFile $path
powershell.exe -NoProfile -ExecutionPolicy Bypass -File $path -WhatIf -Verbose
```

### Run with registry hardening skipped

```powershell
$url = 'https://raw.githubusercontent.com/MasonAuchy/windows-admin-scripts/main/Remove-WindowsBloatware.ps1'
$path = Join-Path $env:TEMP 'Remove-WindowsBloatware.ps1'
iwr $url -UseBasicParsing -OutFile $path
powershell.exe -NoProfile -ExecutionPolicy Bypass -File $path -SkipRegistryHardening -Verbose
```

## Other scripts

### System uptime

```powershell
$url = 'https://raw.githubusercontent.com/MasonAuchy/windows-admin-scripts/main/Get-SystemUptime.ps1'
$path = Join-Path $env:TEMP 'Get-SystemUptime.ps1'
iwr $url -UseBasicParsing -OutFile $path
powershell.exe -NoProfile -ExecutionPolicy Bypass -File $path
```

### Appx package browser

```powershell
$url = 'https://raw.githubusercontent.com/MasonAuchy/windows-admin-scripts/main/List-AppxPackages.ps1'
$path = Join-Path $env:TEMP 'List-AppxPackages.ps1'
iwr $url -UseBasicParsing -OutFile $path
powershell.exe -NoProfile -ExecutionPolicy Bypass -File $path
```

## Notes

- These scripts are meant for Windows PowerShell / PowerShell 7 on Windows.
- The debloat script makes system changes, so use `-WhatIf` first if you want to preview actions.
- The registry hardening step can be skipped with `-SkipRegistryHardening`.
