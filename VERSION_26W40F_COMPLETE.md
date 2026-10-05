# Version 26w40f - Complete

## Changes

### Fixed
1. App crash on startup - FIXED
   - Removed Logger dependency
   - No more Logger.kt calls
   - Simplified MainActivity

2. Permission popups - REMOVED
   - No WRITE_EXTERNAL_STORAGE
   - No READ_EXTERNAL_STORAGE
   - Silent Root check via su command
   - No user permission dialogs

### Root Permission Handling
- Silent Root check on startup
- Uses su command without popup
- If Root granted: Goes to Settings
- If Root denied/unavailable: Shows info page
- User can retry or exit

### Version
- Updated to 26w40f
- Version code: 6
- Clean changelog
- Updated README

## Build Status

GitHub Actions building now.
Check: https://github.com/Aqua110228/AquaHyperOS/actions

One build already succeeded:
https://github.com/Aqua110228/AquaHyperOS/actions/runs/37280383101

Waiting for latest build with 26w40f changes.

## Files Changed
- app/src/main/AndroidManifest.xml (removed permissions, updated version)
- app/src/main/java/com/aqua/hyperos/ui/MainActivity.kt (rewritten)
- README.md (updated, no emoji)
- CHANGELOG.md (updated, no emoji)

## Next
Wait for build to complete, then download APK from Artifacts.
