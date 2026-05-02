Get-AppxPackage -AllUsers | 
    Where-Object { $_.IsFramework -eq $false } | 
    ForEach-Object {
        $FriendlyName = (Get-AppxPackageManifest $_).Package.Properties.DisplayName
        [PSCustomObject]@{
            FriendlyName    = $FriendlyName
            PackageName     = $_.Name
            PackageFullName = $_.PackageFullName
        }
    } | 
    Sort-Object FriendlyName | 
    Out-GridView -Title "Searchable App List"