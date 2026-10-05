# Release Notes - AquaHyperOS 26w40d

## What's Fixed

### Critical Bug Fixes
- Fixed app crash on startup
- Removed unnecessary permission requests
- Added proper root access checking

### User Experience Improvements
- App now silently checks for root on startup
- No permission dialogs - cleaner experience
- Shows loading screen while checking root
- Clear error message if root not available

## Technical Changes

- Removed runtime permissions (INTERNET, READ_EXTERNAL_STORAGE, WRITE_EXTERNAL_STORAGE)
- Added coroutine-based root check
- Proper error handling for non-rooted devices
- Updated to version 26w40d

## Installation

1. Download APK from Actions artifacts
2. Install on device
3. Grant root access when app requests (one-time popup from root manager)
4. Activate in LSPosed
5. Select scopes: android, com.android.systemui, com.miui.home
6. Reboot

## Requirements

- HyperOS/MIUI system
- LSPosed framework
- Root access (Magisk/KernelSU)
- Android 12+

## Download

Get APK from GitHub Actions:
https://github.com/Aqua110228/AquaHyperOS/actions/runs/37279392936

Click "AquaHyperOS-APK" under Artifacts section.

## Notes

This version focuses on stability and user experience.
All features from previous versions are preserved.

---

Version: 26w40d
Date: 2026-10-05
Build: Success (green checkmark)
