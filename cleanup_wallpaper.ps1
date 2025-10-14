# === cleanup_wallpaper.ps1 ===

# Name of the scheduled task created by the wallpaper script
$taskName = "DannyDeVitoWallpaper"

# Remove the scheduled task if it exists
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    Write-Host "Scheduled task '$taskName' removed."
} else {
    Write-Host "No scheduled task named '$taskName' found."
}

# Remove downloaded wallpaper folder
$destDir = Join-Path $env:APPDATA "DemoWallpaper"
if (Test-Path $destDir) {
    Remove-Item -Path $destDir -Recurse -Force
    Write-Host "Wallpaper folder removed."
} else {
    Write-Host "No wallpaper folder found at $destDir."
}

# Optional: reset wallpaper to default
$defaultWallpaper = (Get-ItemProperty 'HKCU:\Control Panel\Desktop' -Name Wallpaper -ErrorAction SilentlyContinue).Wallpaper
if ($defaultWallpaper -and (Test-Path $defaultWallpaper)) {
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public static class Wallpaper {
    [DllImport("user32.dll", SetLastError=true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@ -PassThru

    [Wallpaper]::SystemParametersInfo(20, 0, $defaultWallpaper, 0x01 -bor 0x02)
    Write-Host "Wallpaper reset to previous setting."
}

Write-Host "Cleanup complete."