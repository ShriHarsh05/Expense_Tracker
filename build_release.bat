@echo off
echo ========================================
echo Smart Expense Tracker - Release Build
echo ========================================
echo.

echo [1/5] Cleaning previous builds...
call flutter clean
if errorlevel 1 goto error

echo.
echo [2/5] Getting dependencies...
call flutter pub get
if errorlevel 1 goto error

echo.
echo [3/5] Running code analysis...
call flutter analyze
if errorlevel 1 (
    echo WARNING: Analysis found issues. Continue anyway? (Y/N)
    set /p continue=
    if /i not "%continue%"=="Y" goto error
)

echo.
echo [4/5] Building App Bundle (AAB) for Play Store...
call flutter build appbundle --release
if errorlevel 1 goto error

echo.
echo [5/5] Building APK for testing...
call flutter build apk --release
if errorlevel 1 goto error

echo.
echo ========================================
echo BUILD SUCCESSFUL!
echo ========================================
echo.
echo Output files:
echo - AAB: build\app\outputs\bundle\release\app-release.aab
echo - APK: build\app\outputs\flutter-apk\app-release.apk
echo.
echo Next steps:
echo 1. Test the APK on your device
echo 2. Upload AAB to Google Play Console
echo 3. Complete store listing
echo 4. Submit for review
echo.
pause
goto end

:error
echo.
echo ========================================
echo BUILD FAILED!
echo ========================================
echo Please fix the errors and try again.
echo.
pause

:end