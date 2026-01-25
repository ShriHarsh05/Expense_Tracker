@echo off
echo ========================================
echo   Smart Expense Tracker - Play Console Upload
echo ========================================
echo.
echo Version: 1.0.0+7
echo Build Date: %date% %time%
echo AAB Size: 45.0MB
echo.
echo AAB File Location:
echo %cd%\build\app\outputs\bundle\release\app-release.aab
echo.
echo ========================================
echo   UPLOAD INSTRUCTIONS
echo ========================================
echo.
echo 1. Go to Google Play Console: https://play.google.com/console
echo 2. Select your app: Smart AI Expense Tracker
echo 3. Go to Release -^> Production
echo 4. Click "Create new release"
echo 5. Upload the AAB file from the location above
echo 6. Add release notes (see below)
echo 7. Review and roll out to production
echo.
echo ========================================
echo   RELEASE NOTES (Copy this)
echo ========================================
echo.
echo Version 1.0.0+7 - Enhanced SMS Processing
echo.
echo ✅ NEW FEATURES:
echo • Enhanced Foursquare API integration for better merchant recognition
echo • Improved Axis Bank credit card SMS format support
echo • Better wallet transaction processing (MobiKwik, Paytm, PhonePe)
echo • Enhanced security validation for banking SMS
echo.
echo 🔧 IMPROVEMENTS:
echo • More accurate expense categorization
echo • Better merchant name extraction
echo • Enhanced duplicate detection
echo • Improved SMS parsing reliability
echo.
echo 🛡️ SECURITY:
echo • Stronger banking SMS sender validation
echo • Enhanced fraud prevention
echo • Improved data privacy protection
echo.
echo ========================================
echo.
echo Press any key to open the AAB file location...
pause >nul
explorer build\app\outputs\bundle\release\
echo.
echo Press any key to open Play Console...
pause >nul
start https://play.google.com/console
echo.
echo Upload completed! Press any key to exit...
pause >nul