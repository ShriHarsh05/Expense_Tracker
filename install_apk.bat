@echo off
echo ========================================
echo Smart Expense Tracker - APK Installer
echo ========================================
echo.

echo Available APK files:
echo.
echo 1. Debug APK (easiest to install)
echo    build\app\outputs\flutter-apk\app-debug.apk
echo.
echo 2. Release APK - ARM 64-bit (most modern phones)
echo    build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
echo.
echo 3. Release APK - ARM 32-bit (older phones)
echo    build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk
echo.
echo 4. Release APK - x86 64-bit (emulators)
echo    build\app\outputs\flutter-apk\app-x86_64-release.apk
echo.

echo Which APK do you want to install?
echo.
echo 1 = Debug APK (recommended for testing)
echo 2 = Release ARM 64-bit
echo 3 = Release ARM 32-bit
echo 4 = Release x86 64-bit
echo 5 = Uninstall existing app first
echo 6 = Exit
echo.

set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" goto debug
if "%choice%"=="2" goto arm64
if "%choice%"=="3" goto arm32
if "%choice%"=="4" goto x86
if "%choice%"=="5" goto uninstall
if "%choice%"=="6" goto end

echo Invalid choice!
pause
goto end

:debug
echo.
echo Installing Debug APK...
adb install -r build\app\outputs\flutter-apk\app-debug.apk
if errorlevel 1 (
    echo.
    echo Installation failed!
    echo.
    echo Possible solutions:
    echo 1. Make sure your phone is connected via USB
    echo 2. Enable USB debugging on your phone
    echo 3. Uninstall existing app first (option 5)
    echo 4. Try manual installation (copy APK to phone)
) else (
    echo.
    echo Installation successful!
)
pause
goto end

:arm64
echo.
echo Installing Release APK (ARM 64-bit)...
adb install -r build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
if errorlevel 1 (
    echo.
    echo Installation failed!
    echo Try option 5 to uninstall first, or use debug APK (option 1)
) else (
    echo.
    echo Installation successful!
)
pause
goto end

:arm32
echo.
echo Installing Release APK (ARM 32-bit)...
adb install -r build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk
if errorlevel 1 (
    echo.
    echo Installation failed!
    echo Try option 5 to uninstall first, or use debug APK (option 1)
) else (
    echo.
    echo Installation successful!
)
pause
goto end

:x86
echo.
echo Installing Release APK (x86 64-bit)...
adb install -r build\app\outputs\flutter-apk\app-x86_64-release.apk
if errorlevel 1 (
    echo.
    echo Installation failed!
    echo Try option 5 to uninstall first, or use debug APK (option 1)
) else (
    echo.
    echo Installation successful!
)
pause
goto end

:uninstall
echo.
echo Uninstalling existing app...
adb uninstall com.example.expensetracker
if errorlevel 1 (
    echo.
    echo Uninstall failed or app not found
    echo You can also uninstall manually from your phone
) else (
    echo.
    echo Uninstall successful!
    echo Now you can install a new version
)
pause
goto end

:end
echo.
echo ========================================
echo.
echo If ADB is not working:
echo 1. Copy the APK file to your phone
echo 2. Open it with file manager
echo 3. Enable "Install from Unknown Sources"
echo 4. Tap Install
echo.
echo APK Location: build\app\outputs\flutter-apk\
echo.
pause