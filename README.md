# Windows Admin Scripts

A small set of PowerShell utilities for Windows administration.

## Copy/paste commands

### Remove-WindowsBloatware.ps1

> Run PowerShell as Administrator.

```powershell
$u='https://raw.githubusercontent.com/MasonAuchy/windows-admin-scripts/main/Remove-WindowsBloatware.ps1';$p=Join-Path $env:TEMP 'Remove-WindowsBloatware.ps1';iwr $u -UseBasicParsing -OutFile $p;powershell.exe -NoProfile -ExecutionPolicy Bypass -File $p
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
- `Remove-WindowsBloatware.ps1` removes the listed Appx packages one at a time, logs each action to the console, then writes the registry settings.
