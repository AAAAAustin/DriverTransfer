@echo off
setlocal EnableDelayedExpansion

:: ===== CONFIGURE THESE PATHS =====
set "ZIP_FOLDER=C:\Zips"
set "OUTPUT_FOLDER=C:\Output"
set "TEMP_FOLDER=%TEMP%\ZipProcessTemp"
:: =================================

if not exist "%OUTPUT_FOLDER%" mkdir "%OUTPUT_FOLDER%"

for %%Z in ("%ZIP_FOLDER%\*.zip") do (
    echo Processing: %%~nxZ

    :: Clean temp folder
    if exist "%TEMP_FOLDER%" rmdir /s /q "%TEMP_FOLDER%"
    mkdir "%TEMP_FOLDER%"

    :: Extract zip
    powershell -NoProfile -Command ^
        "Expand-Archive -Path '%%~fZ' -DestinationPath '%TEMP_FOLDER%' -Force"

    :: Iterate folders in extracted zip
    for /d %%F in ("%TEMP_FOLDER%\*") do (
        echo %%~nxF | findstr /i "installer" >nul
        if errorlevel 1 (
            echo Copying: %%~nxF
            robocopy "%%F" "%OUTPUT_FOLDER%\%%~nxF" /E >nul
        ) else (
            echo Skipping: %%~nxF
        )
    )
)

:: Final cleanup
if exist "%TEMP_FOLDER%" rmdir /s /q "%TEMP_FOLDER%"

echo Done.
pause