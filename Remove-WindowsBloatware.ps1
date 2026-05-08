<#
.SYNOPSIS
    Removes selected built-in Appx packages and writes Windows consumer-feature registry settings.
#>

$packages = @(
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
    '*LinkedIn*',
    '*Todos*',
    '*Wallet*',
    '*Maps*',
    '*People*',
    '*News*',
    '*Weather*',
    '*XboxApp*',
    '*GamingApp*',
    'Microsoft.XboxGamingOverlay*',
    'Microsoft.XboxGameOverlay*',
    '*microsoft.windowscommunicationsapps*',
    '*FamilyFeatures*',
    '*Bing*'
)

$registryValues = @(
    @{
        Path  = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'
        Name  = 'DisableWindowsConsumerFeatures'
        Value = 1
    },
    @{
        Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
        Name  = 'ContentDeliveryAllowed'
        Value = 0
    },
    @{
        Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
        Name  = 'OemPreInstalledAppsEnabled'
        Value = 0
    },
    @{
        Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
        Name  = 'PreInstalledAppsEnabled'
        Value = 0
    },
    @{
        Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
        Name  = 'SilentInstalledAppsEnabled'
        Value = 0
    }
)

foreach ($package in $packages) {
    Write-Host "Removing packages matching $package"

    foreach ($installedPackage in Get-AppxPackage -AllUsers -Name $package) {
        Write-Host "Removing installed package $($installedPackage.Name)"

        try {
            Remove-AppxPackage -Package $installedPackage.PackageFullName -AllUsers -ErrorAction Stop
            Write-Host "Removed installed package $($installedPackage.Name)"
        }
        catch {
            Write-Host "Could not remove installed package $($installedPackage.Name): $($_.Exception.Message)"
        }
    }

    $provisionedPackages = Get-AppxProvisionedPackage -Online | Where-Object {
        $_.DisplayName -like $package -or $_.PackageName -like $package
    }

    foreach ($provisionedPackage in $provisionedPackages) {
        Write-Host "Removing provisioned package $($provisionedPackage.DisplayName)"

        try {
            Remove-AppxProvisionedPackage -Online -PackageName $provisionedPackage.PackageName -ErrorAction Stop | Out-Null
            Write-Host "Removed provisioned package $($provisionedPackage.DisplayName)"
        }
        catch {
            Write-Host "Could not remove provisioned package $($provisionedPackage.DisplayName): $($_.Exception.Message)"
        }
    }
}

foreach ($registryValue in $registryValues) {
    Write-Host "Writing $($registryValue.Path)\$($registryValue.Name) = $($registryValue.Value)"

    New-Item -Path $registryValue.Path -Force | Out-Null
    New-ItemProperty `
        -Path $registryValue.Path `
        -Name $registryValue.Name `
        -PropertyType DWord `
        -Value $registryValue.Value `
        -Force | Out-Null
}
