# AquaHyperOS Changelog

## v26w40f (2026-10-05)

### Fixed
- Fixed app crash on startup
- Removed storage permissions (no longer needed)
- Silent Root permission check (automatic, no popup)
- Removed Logger dependency that caused crashes
- Improved app stability

### Changed
- Root permission now obtained silently
- Show Root permission page if Root unavailable
- Simplified permission model
- Version updated to 26w40f

### Technical
- Removed WRITE_EXTERNAL_STORAGE permission
- Removed READ_EXTERNAL_STORAGE permission
- Silent su command execution
- No more permission popups

---

## v26w40e (2026-10-04)

### Added
- Desktop launcher mode
- Full Xposed module support
- LSPosed integration
- Status bar customization
- Control center customization
- Lock screen customization
- Theme blur effects
- Core patches

### Features
- Signature verification bypass
- Permission check bypass
- Custom status bar background
- Large tiles in control center
- Hide fingerprint icon
- Force blur glass effect

### Technical
- Xposed API 93 compatibility
- LSPosed scope configuration
- Shared preferences for settings
- Activity-based UI
