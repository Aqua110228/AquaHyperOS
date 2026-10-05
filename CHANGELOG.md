# AquaHyperOS Changelog

## v26w40d (2026-10-05)

### Fixed
- Fixed crash on startup
- Removed unnecessary permission requests
- Added silent root access check
- Show proper error screen when root is not available

### Changed
- App now silently checks for root access on startup
- No more runtime permission dialogs
- Clean loading screen while checking root
- Improved user experience

### Technical
- Removed INTERNET, READ_EXTERNAL_STORAGE, WRITE_EXTERNAL_STORAGE permissions
- Added root check coroutine
- Proper error handling for non-rooted devices

---

## Previous Versions

See git history for older versions.
