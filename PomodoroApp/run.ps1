# Pomodoro Timer - Setup and Run Script for Windows

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Pomodoro Timer App - Setup & Run" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Set Flutter path
$FlutterPath = "C:\Projects\flutter-sdk\flutter\bin"
$env:PATH = "$FlutterPath;$env:PATH"

Write-Host "[1/4] Checking Flutter installation..." -ForegroundColor Yellow
flutter --version

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Flutter not found!" -ForegroundColor Red
    Write-Host "Please run the setup script first." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[2/4] Installing dependencies..." -ForegroundColor Yellow
flutter pub get

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to install dependencies!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[3/4] Checking Flutter doctor..." -ForegroundColor Yellow
flutter doctor

Write-Host ""
Write-Host "[4/4] Starting the application..." -ForegroundColor Green
Write-Host ""
Write-Host "Choose a platform to run:" -ForegroundColor Cyan
Write-Host "  1. Windows (Desktop)" -ForegroundColor White
Write-Host "  2. Chrome (Web)" -ForegroundColor White
Write-Host "  3. Android (if emulator/device is connected)" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter your choice (1-3)"

switch ($choice) {
    "1" {
        Write-Host "Launching on Windows..." -ForegroundColor Green
        flutter run -d windows
    }
    "2" {
        Write-Host "Launching in Chrome..." -ForegroundColor Green
        flutter run -d chrome
    }
    "3" {
        Write-Host "Launching on Android..." -ForegroundColor Green
        flutter run -d android
    }
    default {
        Write-Host "Launching on Windows (default)..." -ForegroundColor Green
        flutter run -d windows
    }
}
