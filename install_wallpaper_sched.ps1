# --- Wallpaper URL ---
$imageUrl = "https://raw.githubusercontent.com/J0r00-creator/duck-script/main/danny.jpg"

# --- Destination folder ---
$destDir = Join-Path $env:APPDATA "DemoWallpaper"
if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
}

# --- Download wallpaper ---
$destImage = Join-Path $destDir "wallpaper.jpg"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $imageUrl -OutFile "$destImage" -UseBasicParsing

# --- Apply wallpaper immediately ---
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class Wallpaper {
    [DllImport("user32.dll", SetLastError=true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@ -PassThru

[Wallpaper]::SystemParametersInfo(20, 0, "$destImage", 0x01 -bor 0x02)

# --- Create scheduled task to reapply wallpaper every 60 seconds ---
$taskName = "DannyDeVitoWallpaper"

# Command that re-applies wallpaper each run
$psCommand = "Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class Wallpaper {
    [DllImport(`"user32.dll`", SetLastError=true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
'@; [Wallpaper]::SystemParametersInfo(20,0,'$destImage',0x01 -bor 0x02)"

# Hidden PowerShell action
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command `"$psCommand`""

# Trigger every 60s for 1 day
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddSeconds(10) `
    -RepetitionInterval (New-TimeSpan -Seconds 60) `
    -RepetitionDuration (New-TimeSpan -Days 1)

# Register only if not existing
if (-not (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue)) {
    Register-ScheduledTask -Action $action -Trigger $trigger `
        -TaskName $taskName `
        -Description "Reapply Danny DeVito wallpaper every 60 seconds" `
        -User $env:USERNAME -RunLevel Limited -Force
}

Write-Host "Wallpaper applied and scheduled task created."


