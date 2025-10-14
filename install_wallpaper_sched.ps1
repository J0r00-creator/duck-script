# install_wallpaper_sched.ps1
# Downloads an image, sets it as wallpaper, creates setwallpaper helper, and schedules reapply every 60s.
# URL of your wallpaper image (raw GitHub link)
$imageUrl = "https://raw.githubusercontent.com/J0r00-creator/duck-script/main/danny.jpg"

# Destination folder for the wallpaper
$destDir = Join-Path $env:APPDATA "DemoWallpaper"
if(-not (Test-Path $destDir)){ New-Item -Path $destDir -ItemType Directory -Force | Out-Null }

# Destination image path
$destImage = Join-Path $destDir "wallpaper.jpg"

# Download the image
Invoke-WebRequest -Uri $imageUrl -OutFile $destImage -UseBasicParsing

# Function to set wallpaper
Add-Type -MemberDefinition @"
using System;
using System.Runtime.InteropServices;
public class N {
    [DllImport("user32.dll",SetLastError=true)]
    public static extern bool SystemParametersInfo(int uAction,int uParam,string lpvParam,int fuWinIni);
}
"@ -Name N -Namespace Win32

# Apply wallpaper immediately
[Win32.N]::SystemParametersInfo(20,0,$destImage,0x01 -bor 0x02)

# Optional: Create scheduled task to reapply every 60 seconds
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$destImage`""
$trigger = New-ScheduledTaskTrigger -RepetitionInterval (New-TimeSpan -Seconds 60) -RepeatIndefinitely -At (Get-Date)
$taskName = "DannyDeVitoWallpaper"
if(-not (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue)){
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Description "Reapply Danny DeVito wallpaper every 60 seconds" -User $env:USERNAME -RunLevel Highest -Force
}

Write-Host "Wallpaper installed and scheduled task created."
