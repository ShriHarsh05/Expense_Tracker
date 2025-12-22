# 📱 APK Installation Troubleshooting Guide

## 🚨 **"App not installed" Error Solutions**

### **Available APK Files:**
1. **Debug APK** (for testing): `build\app\outputs\flutter-apk\app-debug.apk`
2. **Release APKs** (architecture-specific):
   - ARM 32-bit: `build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk` (19.6MB)
   - ARM 64-bit: `build\app\outputs\flutter-apk\app-arm64-v8a-release.apk` (22.0MB)
   - x86 64-bit: `build\app\outputs\flutter-apk\app-x86_64-release.apk` (23.2MB)

## 🔧 **Step-by-Step Installation**

### **Method 1: Manual Installation (Recommended)**

1. **First, try the debug APK** (easier to install):
   ```
   File: build\app\outputs\flutter-apk\app-debug.apk
   ```

2. **Enable "Install from Unknown Sources"**:
   - Go to **Settings** > **Security** > **Unknown Sources** (Enable)
   - Or **Settings** > **Apps** > **Special Access** > **Install Unknown Apps**
   - Allow your file manager or browser to install apps

3. **Uninstall existing version** (if any):
   - Go to **Settings** > **Apps** > **Expense Tracker** > **Uninstall**
   - Or long-press the app icon and select **Uninstall**

4. **Install the APK**:
   - Copy APK to your phone
   - Open with file manager
   - Tap **Install**

### **Method 2: ADB Installation (If Available)**

If you have Android SDK installed:

```bash
# Check connected devices
adb devices

# Uninstall existing app
adb uninstall com.example.expensetracker

# Install debug APK
adb install build\app\outputs\flutter-apk\app-debug.apk

# Or install release APK (choose based on your phone's architecture)
adb install build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
```

### **Method 3: Architecture-Specific APK**

Most modern Android phones use **ARM 64-bit**, so try:
```
build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
```

If that doesn't work, try:
```
build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk
```

## 🔍 **Common Issues & Solutions**

### **Issue 1: "App not installed" Error**
**Causes:**
- Existing debug version installed
- Signature mismatch
- Insufficient storage
- Corrupted APK

**Solutions:**
1. Uninstall any existing version first
2. Try the debug APK instead of release
3. Free up storage space (need ~100MB free)
4. Rebuild the APK

### **Issue 2: "Parse Error" or "Invalid APK"**
**Solutions:**
1. Re-download/copy the APK file
2. Try a different APK variant
3. Rebuild with clean:
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --debug
   ```

### **Issue 3: "Installation Blocked"**
**Solutions:**
1. Enable "Install from Unknown Sources"
2. Disable Play Protect temporarily
3. Use a different file manager

### **Issue 4: Signature Verification Failed**
**Solutions:**
1. Uninstall existing app completely
2. Clear app data if uninstall fails
3. Restart phone and try again

## 📋 **Testing Checklist**

After successful installation, test:
- [ ] App opens without crashing
- [ ] Google Sign-In works
- [ ] SMS permissions can be granted
- [ ] Basic expense tracking works
- [ ] Firebase sync works

## 🛠️ **Rebuild Commands (If Needed)**

### **Clean Rebuild:**
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

### **Release Rebuild:**
```bash
flutter clean
flutter pub get
flutter build apk --release --split-per-abi
```

### **Specific Architecture:**
```bash
# For ARM 64-bit (most common)
flutter build apk --release --target-platform android-arm64

# For ARM 32-bit (older phones)
flutter build apk --release --target-platform android-arm
```

## 📱 **Phone Architecture Detection**

To find your phone's architecture:
1. Install **CPU-Z** app from Play Store
2. Check **SoC** tab for architecture
3. Or check phone specifications online

**Common Architectures:**
- **ARM 64-bit (arm64-v8a)**: Most modern phones (2017+)
- **ARM 32-bit (armeabi-v7a)**: Older phones
- **x86_64**: Rare, mostly emulators

## 🚀 **Recommended Installation Order**

1. **First try**: `app-debug.apk` (easiest to install)
2. **If debug works**: Try `app-arm64-v8a-release.apk`
3. **If ARM64 fails**: Try `app-armeabi-v7a-release.apk`
4. **Last resort**: Rebuild with different settings

## 📞 **Still Having Issues?**

If none of the above works:

1. **Check Android version**: App requires Android 5.0+ (API 21+)
2. **Free up space**: Need at least 100MB free storage
3. **Restart phone**: Sometimes helps with installation issues
4. **Try different phone**: Test on another device
5. **Check logs**: Use `flutter logs` while installing

## ✅ **Success Indicators**

You'll know it's working when:
- App installs without errors
- App icon appears in app drawer
- App opens and shows login screen
- No immediate crashes

## 🔄 **Next Steps After Installation**

Once installed successfully:
1. Test all core features
2. Grant necessary permissions (SMS, etc.)
3. Sign in with Google
4. Test expense detection
5. Verify Firebase sync
6. Take screenshots for Play Store

Remember: The debug APK is signed with debug keys and easier to install. Use it for testing, then use the release APK for final validation before Play Store submission.