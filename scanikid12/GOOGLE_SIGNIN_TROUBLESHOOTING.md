# Google Sign-In Troubleshooting Guide

## Error: PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10:, null, null)

This error typically occurs due to configuration mismatches between your app and Firebase/Google Cloud Console.

## What I've Fixed

1. ✅ Added missing `clientId` to `firebase_options.dart` for Android
2. ✅ Enhanced error handling and debugging in the Google Sign-In method
3. ✅ Added proper scopes configuration for Google Sign-In

## Steps to Resolve

### 1. Verify SHA-1 Fingerprint

Run the PowerShell script to get your SHA-1 fingerprint:
```powershell
.\get_sha1.ps1
```

### 2. Update Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `scanikid`
3. Go to Project Settings (gear icon)
4. Select your Android app: `com.example.scanikid12`
5. Click "Add fingerprint" and add the SHA-1 from step 1
6. Download the updated `google-services.json`
7. Replace the existing file in `android/app/`

### 3. Clean and Rebuild

```bash
flutter clean
flutter pub get
flutter run
```

## Common Issues and Solutions

### Issue: SHA-1 Mismatch
- **Symptom**: ApiException: 10
- **Solution**: Update SHA-1 in Firebase Console and redownload google-services.json

### Issue: Package Name Mismatch
- **Symptom**: Various authentication errors
- **Solution**: Ensure package name is consistent across all configuration files

### Issue: Missing OAuth Client ID
- **Symptom**: Sign-in fails immediately
- **Solution**: Verify clientId is present in firebase_options.dart

## Debug Information

The enhanced error handling will now provide detailed debug information in the console. Look for:
- Google Sign-In process steps
- Token availability
- Firebase authentication status
- Detailed error codes and messages
