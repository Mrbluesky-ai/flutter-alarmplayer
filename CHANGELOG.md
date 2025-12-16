# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-12-15

### Breaking Changes
- Minimum Android SDK raised from 16 to 24 (Android 7.0+)
- Removed support for Android versions below 7.0
- `dispose()` method must now be called when done with the Alarmplayer instance

### Added
- Custom `AlarmplayerException` class for better error handling
- File caching system to improve performance and reduce disk usage
- Comprehensive unit test suite
- Proper resource cleanup via `dispose()` method
- Thread-safe operations with synchronized blocks
- Automatic cleanup when plugin is detached

### Fixed
- **Critical**: Fixed memory leak from static MediaPlayer instance
- **Critical**: Fixed callback handler memory leak (handler was registered multiple times)
- **Critical**: Fixed race conditions in play/stop methods
- **Critical**: Fixed resource cleanup - MediaPlayer and volume are now properly restored
- **Critical**: Fixed file cleanup - temporary files are now cached and cleaned up
- Fixed error handling - errors are now properly propagated to Flutter
- Fixed volume restoration on app crash or plugin detach
- Fixed concurrent access issues with proper synchronization

### Changed
- Improved error handling with custom exceptions and error codes
- Updated dependencies
- Removed deprecated `setAudioStreamType()` API (API 21)
- Removed `@SuppressWarnings("deprecation")` annotation

### Removed
- Support for Android API levels below 24
- Deprecated audio stream type API
- Unused imports and code

### Security
- Improved resource management to prevent memory leaks

## [1.1.1] - Previous Release

### Fixed
- Fixed bug where volume was not restored after alarm completion

## [1.1.0] - Previous Release

### Added
- Possibility to toggle looping
- Callback when music is done playing
- Updated to newest Flutter version

## [1.0.5] - Previous Release

### Fixed
- Bug fixes

## [1.0.4] - Previous Release

### Fixed
- Fixed deprecation warning

## [1.0.2] - Previous Release

### Fixed
- Fixed some bugs

## [1.0.0] - Initial Release

### Added
- Initial release with Android implementation
- Basic alarm playback functionality
- Volume control
- Looping support

---

## Migration Guide from v1.x to v2.0

### Required Changes

1. **Call dispose() when done**:
```dart
// Old (v1.x) - no cleanup needed
final alarmplayer = Alarmplayer();
alarmplayer.Alarm(url: "assets/alarm.mp3");

// New (v2.0) - must call dispose()
final alarmplayer = Alarmplayer();
await alarmplayer.play(url: "assets/alarm.mp3");
// ... later
alarmplayer.dispose();  // Required!
```

2. **Handle AlarmplayerException**:
```dart
// Old (v1.x) - generic exceptions
try {
  alarmplayer.Alarm(url: "assets/alarm.mp3");
} catch (e) {
  print('Error: $e');
}

// New (v2.0) - specific exception type
try {
  await alarmplayer.play(url: "assets/alarm.mp3");
} on AlarmplayerException catch (e) {
  print('Alarm error: ${e.message} (${e.code})');
}
```

3. **Update Android minSdkVersion**:
```gradle
// In android/app/build.gradle
android {
    defaultConfig {
        minSdkVersion 24  // Was 16, now 24
    }
}
```

### Optional Improvements

1. **Use new error handling**:
```dart
try {
  await alarmplayer.play(url: "assets/alarm.mp3");
} on AlarmplayerException catch (e) {
  // Handle alarmplayer-specific errors
  if (e.code == 'PLUGIN_ERROR') {
    // Handle plugin errors
  }
} catch (e) {
  // Handle unexpected errors
}
```

2. **Proper cleanup in widgets**:
```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late Alarmplayer alarmplayer;
  
  @override
  void initState() {
    super.initState();
    alarmplayer = Alarmplayer();
  }
  
  @override
  void dispose() {
    alarmplayer.dispose();  // Clean up resources
    super.dispose();
  }
}
```

### What Stays the Same

- API method names (play, stop, isPlaying)
- Method parameters and return types
- Basic functionality and behavior
- Asset loading mechanism

### Benefits of Upgrading

- ✅ No more memory leaks
- ✅ Better error messages
- ✅ Improved performance (file caching)
- ✅ Thread-safe operations
- ✅ Modern Android support
- ✅ Better resource management
- ✅ Comprehensive test coverage

[2.0.0]: https://github.com/Mrbluesky-ai/flutter-alarmplayer/compare/v1.1.1...v2.0.0
[1.1.1]: https://github.com/Mrbluesky-ai/flutter-alarmplayer/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/Mrbluesky-ai/flutter-alarmplayer/compare/v1.0.5...v1.1.0
[1.0.5]: https://github.com/Mrbluesky-ai/flutter-alarmplayer/compare/v1.0.4...v1.0.5
[1.0.4]: https://github.com/Mrbluesky-ai/flutter-alarmplayer/compare/v1.0.2...v1.0.4
[1.0.2]: https://github.com/Mrbluesky-ai/flutter-alarmplayer/compare/v1.0.0...v1.0.2
[1.0.0]: https://github.com/Mrbluesky-ai/flutter-alarmplayer/releases/tag/v1.0.0
