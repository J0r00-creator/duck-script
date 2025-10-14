# install_wallpaper_sched.ps1
# Downloads an image, sets it as wallpaper, creates setwallpaper helper, and schedules reapply every 60s.
$imageUrl = "https://i.pinimg.com/236x/ea/d2/cb/ead2cb32fa912c33e2a7f0ecd4b87ff3.jpg"
$destDir = Join-Path $env:APPDATA "DemoWallpaper"
New-Item -Path $destDir -ItemType Directory -Force | Out-Null
$destImage = Join-Path $destDir "wallpaper.jpg"

# Download image
Try {
    Invoke-WebRequest -Uri $imageUrl -OutFile $destImage -UseBasicParsing -ErrorAction Stop
} Catch {
    Write-Error "Failed to download image: $($_.Exception.Message)"
    exit 1
}

# Backup current wallpaper path (if present)
$regPath = 'HKCU:\Control Panel\Desktop'
$prev = (Get-ItemProperty -Path $regPath -Name Wallpaper -ErrorAction SilentlyContinue).Wallpaper
if ($null -eq $prev) { $prev = "" }
Set-Content -Path (Join-Path $destDir "previous_wallpaper.txt") -Value $prev -Force

# Create helper script that actually applies the wallpaper (setwallpaper.ps1)
$setScript = @"
Add-Type -MemberDefinition @'
using System;
using System.Runtime.InteropServices;
public class N {
    [DllImport("user32.dll",SetLastError=true)]
    public static extern bool SystemParametersInfo(int uAction,int uParam,string lpvParam,int fuWinIni);
}
'@ -Name N -Namespace Win32

[Win32.N]::SystemParametersInfo(20,0,""$destImage"",0x01 -bor 0x02) | Out-Null
Set-ItemProperty -Path '$regPath' -Name Wallpaper -Value '$destImage' -ErrorAction SilentlyContinue
"@

$setScriptPath = Join-Path $destDir "setwallpaper.ps1"
Set-Content -Path $setScriptPath -Value $setScript -Force -Encoding UTF8

# Apply immediately
powershell -NoProfile -ExecutionPolicy Bypass -File $setScriptPath

# Create scheduled task to reapply every 1 minute (60 seconds) using schtasks.exe for compatibility
$taskName = "DannyDeVitoWallpaper"
$tr = "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$setScriptPath`""
# Delete any existing task with same name then create new one
schtasks.exe /Delete /TN $taskName /F > $null 2>&1
schtasks.exe /Create /SC MINUTE /MO 1 /TN $taskName /TR $tr /F

Write-Host "Installed wallpaper and scheduled task '$taskName' to run every 1 minute."
