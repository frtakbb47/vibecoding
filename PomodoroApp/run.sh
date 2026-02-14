#!/bin/bash
# Pomodoro Timer - Setup and Run Script for Linux/Mac

echo "========================================"
echo "  Pomodoro Timer App - Setup & Run"
echo "========================================"
echo ""

# Set Flutter path
export PATH="/c/Projects/flutter-sdk/flutter/bin:$PATH"

echo "[1/4] Checking Flutter installation..."
flutter --version

if [ $? -ne 0 ]; then
    echo "ERROR: Flutter not found!"
    echo "Please install Flutter from: https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo ""
echo "[2/4] Installing dependencies..."
flutter pub get

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to install dependencies!"
    exit 1
fi

echo ""
echo "[3/4] Checking Flutter doctor..."
flutter doctor

echo ""
echo "[4/4] Starting the application..."
echo ""
echo "Choose a platform to run:"
echo "  1. Windows (Desktop)"
echo "  2. Chrome (Web)"
echo "  3. macOS (if on Mac)"
echo "  4. Android (if emulator/device is connected)"
echo ""

read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        echo "Launching on Windows..."
        flutter run -d windows
        ;;
    2)
        echo "Launching in Chrome..."
        flutter run -d chrome
        ;;
    3)
        echo "Launching on macOS..."
        flutter run -d macos
        ;;
    4)
        echo "Launching on Android..."
        flutter run -d android
        ;;
    *)
        echo "Launching on Windows (default)..."
        flutter run -d windows
        ;;
esac
