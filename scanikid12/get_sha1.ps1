# PowerShell script to get SHA-1 fingerprint for Google Sign-In debugging
# Run this script from the scanikid12 directory

Write-Host "Getting SHA-1 fingerprint for Google Sign-In..." -ForegroundColor Green
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "android")) {
    Write-Host "Error: Please run this script from the scanikid12 directory" -ForegroundColor Red
    exit 1
}

# Get debug SHA-1
Write-Host "Debug SHA-1 fingerprint:" -ForegroundColor Yellow
try {
    $debugSha1 = & keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android | Select-String "SHA1"
    if ($debugSha1) {
        Write-Host $debugSha1 -ForegroundColor Cyan
    } else {
        Write-Host "Could not get debug SHA-1" -ForegroundColor Red
    }
} catch {
    Write-Host "Error getting debug SHA-1: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Release SHA-1 fingerprint (if you have a release keystore):" -ForegroundColor Yellow
Write-Host "Note: You'll need to provide the path to your release keystore and password" -ForegroundColor Gray
Write-Host ""

Write-Host "Instructions:" -ForegroundColor Green
Write-Host "1. Copy the SHA-1 fingerprint above" -ForegroundColor White
Write-Host "2. Go to Firebase Console > Project Settings > Your Apps > Android app" -ForegroundColor White
Write-Host "3. Click 'Add fingerprint' and paste the SHA-1" -ForegroundColor White
Write-Host "4. Download the updated google-services.json and replace the existing one" -ForegroundColor White
Write-Host "5. Clean and rebuild your project" -ForegroundColor White
Write-Host ""

Write-Host "To clean and rebuild:" -ForegroundColor Yellow
Write-Host "flutter clean" -ForegroundColor Cyan
Write-Host "flutter pub get" -ForegroundColor Cyan
Write-Host "flutter run" -ForegroundColor Cyan
