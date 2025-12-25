@echo off
echo ========================================
echo Testing Release APK on Device
echo ========================================
echo.

echo Step 1: Checking device connection...
flutter devices | findstr "CPH2649"
if errorlevel 1 (
    echo ERROR: Device not connected!
    pause
    exit /b 1
)
echo Device connected: CPH2649
echo.

echo Step 2: Launching release app...
echo Please open the Smart Expense Tracker app on your phone now.
echo.

echo Step 3: Monitoring device logs...
echo Press Ctrl+C to stop monitoring
echo.
flutter logs -d CPH2649

pause