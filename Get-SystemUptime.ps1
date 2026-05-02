$uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
"Uptime: $($uptime.Days) Days, $($uptime.Hours) Hours, $($uptime.Minutes) Minutes"