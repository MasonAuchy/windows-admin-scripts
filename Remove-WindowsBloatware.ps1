<#
.SYNOPSIS
    Removes selected built-in Appx packages and applies a few Windows consumer-feature hardening settings.

.DESCRIPTION
    This script targets commonly unwanted preinstalled Windows apps, removes matching installed packages,
    removes matching provisioned packages where possible, and sets a small set of registry values that help
    reduce consumer app reinstallation and suggestions.

    The script supports -WhatIf and -Confirm, writes a structured summary object, and skips the registry hardening
    step when -SkipRegistryHardening is used.

.EXAMPLE
    .\Remove-WindowsBloatware.ps1 -WhatIf -Verbose

.EXAMPLE
    .\Remove-WindowsBloatware.ps1
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [string[]]
    $PackagePatterns = @(
        '*Solitaire*',
        '*3DViewer*',
        '*MixedReality.Portal*',
        '*Paint3D*',
        'Microsoft.MSPaint*',
        '*SkypeApp*',
        '*ZuneVideo*',
        '*ZuneMusic*',
        '*WindowsFeedbackHub*',
        '*StickyNote*',
        '*OutlookForWindows*',
        '*Copilot*',
        '*Ai.Copilot.Provider*',
        '*OfficeHub*',
        '*Clipchamp*',
        '*Todos*',
        '*Wallet*',
        '*Maps*',
        '*XboxApp*',
        '*GamingApp*',
        'Microsoft.XboxGamingOverlay*',
        'Microsoft.XboxGameOverlay*',
        '*microsoft.windowscommunicationsapps*',
        '*FamilyFeatures*',
        '*Bing*'
    ),

    [switch]
    $SkipRegistryHardening
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-IsAdministrator {
    try {
        $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = [Security.Principal.WindowsPrincipal]::new($currentIdentity)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    catch {
        return $false
    }
}

function Set-RegistryDwordValue {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [int]$Value
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }

    if ($PSCmdlet.ShouldProcess($Path, "Set DWORD value '$Name' to $Value")) {
        New-ItemProperty -Path $Path -Name $Name -PropertyType DWord -Value $Value -Force | Out-Null
    }
}

function Get-MatchingItems {
    param(
        [Parameter(Mandatory)]
        [object[]]$Items,

        [Parameter(Mandatory)]
        [string]$Pattern,

        [Parameter(Mandatory)]
        [string[]]$PropertyNames
    )

    foreach ($item in $Items) {
        foreach ($propertyName in $PropertyNames) {
            $propertyValue = $item.$propertyName
            if ($null -ne $propertyValue -and $propertyValue -like $Pattern) {
                $item
                break
            }
        }
    }
}

if (-not $WhatIfPreference -and -not (Test-IsAdministrator)) {
    throw 'Administrator privileges are required to remove Appx packages and update the targeted registry settings.'
}

Write-Verbose 'Collecting installed Appx packages.'
$installedPackages = Get-AppxPackage -AllUsers |
    Where-Object { -not $_.IsFramework }

Write-Verbose 'Collecting provisioned Appx packages.'
$provisionedPackages = Get-AppxProvisionedPackage -Online

$removedInstalled = New-Object System.Collections.Generic.List[object]
$removedProvisioned = New-Object System.Collections.Generic.List[object]
$skippedPatterns = New-Object System.Collections.Generic.List[string]
$failedItems = New-Object System.Collections.Generic.List[object]

foreach ($pattern in $PackagePatterns) {
    Write-Verbose "Processing pattern: $pattern"

    $matchedInstalled = @(Get-MatchingItems -Items $installedPackages -Pattern $pattern -PropertyNames @('Name', 'PackageFullName', 'PackageFamilyName'))
    $matchedProvisioned = @(Get-MatchingItems -Items $provisionedPackages -Pattern $pattern -PropertyNames @('DisplayName', 'PackageName'))

    if (-not $matchedInstalled -and -not $matchedProvisioned) {
        Write-Verbose "No matches found for pattern: $pattern"
        $skippedPatterns.Add($pattern)
        continue
    }

    foreach ($package in $matchedInstalled) {
        $target = "$($package.Name) ($($package.PackageFullName))"
        if ($PSCmdlet.ShouldProcess($target, 'Remove installed Appx package')) {
            try {
                Remove-AppxPackage -Package $package.PackageFullName -AllUsers -ErrorAction Stop
                $removedInstalled.Add($package)
                Write-Verbose "Removed installed package: $target"
            }
            catch {
                $failedItems.Add([PSCustomObject]@{
                        Pattern = $pattern
                        Target  = $target
                        Action  = 'Remove-AppxPackage'
                        Error   = $_.Exception.Message
                    })
                Write-Warning "Failed to remove installed package '$target': $($_.Exception.Message)"
            }
        }
    }

    foreach ($package in $matchedProvisioned) {
        $target = "$($package.DisplayName) ($($package.PackageName))"
        if ($PSCmdlet.ShouldProcess($target, 'Remove provisioned Appx package')) {
            try {
                Remove-AppxProvisionedPackage -Online -PackageName $package.PackageName -ErrorAction Stop | Out-Null
                $removedProvisioned.Add($package)
                Write-Verbose "Removed provisioned package: $target"
            }
            catch {
                $failedItems.Add([PSCustomObject]@{
                        Pattern = $pattern
                        Target  = $target
                        Action  = 'Remove-AppxProvisionedPackage'
                        Error   = $_.Exception.Message
                    })
                Write-Warning "Failed to remove provisioned package '$target': $($_.Exception.Message)"
            }
        }
    }
}

if (-not $SkipRegistryHardening) {
    Write-Verbose 'Applying registry hardening settings.'

    Set-RegistryDwordValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' -Name 'DisableWindowsConsumerFeatures' -Value 1
    Set-RegistryDwordValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'ContentDeliveryAllowed' -Value 0
    Set-RegistryDwordValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'OemPreInstalledAppsEnabled' -Value 0
    Set-RegistryDwordValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'PreInstalledAppsEnabled' -Value 0
    Set-RegistryDwordValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'SilentInstalledAppsEnabled' -Value 0
}

$summary = [PSCustomObject]@{
    InstalledPackagesRemoved  = $removedInstalled.Count
    ProvisionedPackagesRemoved = $removedProvisioned.Count
    PatternsSkipped           = $skippedPatterns.ToArray()
    Failures                  = $failedItems.ToArray()
    RegistryHardeningApplied  = -not $SkipRegistryHardening
}

$summary

if ($failedItems.Count -gt 0) {
    Write-Warning "Completed with $($failedItems.Count) failure(s). Review the Failures property in the output summary."
}
