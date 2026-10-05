# Release 26w40f

AquaHyperOS Version 26w40f - Stability and Permission Fixes

## What's Fixed

### 1. App Crash Fixed
- Removed Logger dependency that caused crashes on startup
- App now starts normally without errors
- Improved stability

### 2. No More Permission Popups
- Removed WRITE_EXTERNAL_STORAGE permission
- Removed READ_EXTERNAL_STORAGE permission
- Silent Root permission check via su command
- No user permission dialogs

### 3. Root Permission Handling
- Automatic silent Root check on startup
- If Root available: Goes directly to Settings
- If Root unavailable: Shows information page
- User can retry or exit

## Installation

1. Download APK from this release
2. Install on device (allow unknown sources)
3. Grant Root permission when app checks silently
4. Install LSPosed framework if not installed
5. Activate module in LSPosed manager
6. Select scopes: android, com.android.systemui
7. Reboot device

## Requirements

- Root access (checked silently, no popup)
- LSPosed framework
- HyperOS 3.0+ or MIUI based on Android 12+

## Features

- Status bar customization
- Control center customization
- Lock screen customization
- Theme blur effects
- Core system patches
- Signature verification bypass
- Permission management

## Technical Details

- Version: 26w40f
- Version Code: 6
- Xposed API: 93
- Min Android: 12

## Changes from 26w40e

- Fixed app crashes
- Removed storage permissions
- Silent Root check
- Updated documentation
- Improved stability

## Download

APK available in Assets below or from GitHub Actions artifacts.

## Support

Report issues: https://github.com/Aqua110228/AquaHyperOS/issues

---

Build Date: 2026-10-05
