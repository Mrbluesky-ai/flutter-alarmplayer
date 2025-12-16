# alarmplayer

[![pub package](https://img.shields.io/pub/v/alarmplayer.svg)](https://pub.dev/packages/alarmplayer)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Flutter plugin to play alarm sounds at custom volume levels, overriding silent mode and system volume settings. Perfect for critical notifications and alarm applications.

## Features

- ✅ Play sounds at custom volume levels
- ✅ Override silent/vibrate mode
- ✅ Loop sounds continuously
- ✅ Completion callbacks
- ✅ Thread-safe operations
- ✅ Automatic resource cleanup
- ✅ File caching for better performance
- ✅ Custom exception handling
- ✅ Android support (API 24+)

## Platform Support

| Platform | Status | Minimum Version |
|----------|--------|-----------------|
| Android  | ✅ Supported | API 24 (Android 7.0+) |
| iOS      | ❌ Not supported | - |

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  alarmplayer: ^2.0.0
```

Then run:

```bash
flutter pub get
```

## Android Setup

### 1. Update minSdkVersion

In your `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 24  // Required for alarmplayer 2.0+
    }
}
```

### 2. Add Audio Assets

Add your audio files to `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/alarm.mp3
    - assets/notification.mp3
```

## Usage

### Basic Example

```dart
import 'package:alarmplayer/alarmplayer.dart';

// Create instance
final alarmplayer = Alarmplayer();

// Play alarm
await alarmplayer.play(
  url: "assets/alarm.mp3",
  volume: 0.8,  // 80% of max alarm volume
  looping: true,
);

// Stop alarm
await alarmplayer.stop();

// Check if playing
bool isPlaying = await alarmplayer.isPlaying();

// Clean up when done (IMPORTANT!)
alarmplayer.dispose();
```

### With Completion Callback

```dart
await alarmplayer.play(
  url: "assets/alarm.mp3",
  volume: 1.0,
  looping: false,
  onComplete: () {
    print("Alarm finished playing!");
  },
);
```

### In a Widget

```dart
class AlarmWidget extends StatefulWidget {
  @override
  State<AlarmWidget> createState() => _AlarmWidgetState();
}

class _AlarmWidgetState extends State<AlarmWidget> {
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
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await alarmplayer.play(url: "assets/alarm.mp3");
      },
      child: Text('Play Alarm'),
    );
  }
}
```

### Error Handling

```dart
try {
  await alarmplayer.play(url: "assets/alarm.mp3");
} on AlarmplayerException catch (e) {
  print('Alarm error: ${e.message}');
  print('Error code: ${e.code}');
} catch (e) {
  print('Unexpected error: $e');
}
```

### Foreground Service Usage

```dart
class AlarmService {
  late Alarmplayer alarmplayer;
  
  void start() {
    alarmplayer = Alarmplayer();
  }
  
  Future<void> playAlarm() async {
    await alarmplayer.play(
      url: "assets/alarm.mp3",
      looping: true,
    );
  }
  
  Future<void> stopAlarm() async {
    await alarmplayer.stop();
    // Don't call dispose() if service continues running
  }
  
  void shutdown() {
    alarmplayer.stop();
    alarmplayer.dispose();  // Only on service shutdown
  }
}
```

## API Reference

### Methods

#### `play()`

Plays an alarm sound.

```dart
Future<void> play({
  required String url,      // Asset path or file path
  double volume = 1.0,      // Volume (0.0 to 1.0)
  bool looping = true,      // Loop continuously
  Function? onComplete,     // Called when playback completes (non-looping only)
})
```

**Parameters**:
- `url` (required): Path to the audio file (e.g., "assets/alarm.mp3")
- `volume` (optional): Volume level from 0.0 to 1.0 (default: 1.0)
- `looping` (optional): Whether to loop the alarm continuously (default: true)
- `onComplete` (optional): Callback function called when playback completes (only for non-looping alarms)

**Throws**: `AlarmplayerException` if playback fails

#### `stop()`

Stops the currently playing alarm.

```dart
Future<void> stop()
```

#### `isPlaying()`

Checks if an alarm is currently playing.

```dart
Future<bool> isPlaying()
```

**Returns**: `true` if playing, `false` otherwise

#### `dispose()`

Cleans up resources. **Must be called** when you're done with the Alarmplayer instance.

```dart
void dispose()
```

**Important**: Always call `dispose()` to prevent memory leaks and clean up cached files.

### Exception Handling

The plugin throws `AlarmplayerException` for errors:

```dart
class AlarmplayerException implements Exception {
  final String message;   // Error description
  final String? code;     // Error code (e.g., 'PLUGIN_ERROR')
  final dynamic details;  // Additional error details
}
```

## Important Notes

### Resource Cleanup

**Always call `dispose()`** when you're done with the Alarmplayer instance:

```dart
// In a widget
@override
void dispose() {
  alarmplayer.dispose();
  super.dispose();
}

// In a service
void shutdown() {
  alarmplayer.dispose();
}
```

### Foreground Services

When using in a foreground service:
- ✅ `dispose()` is **optional** during normal operation
- ✅ Android automatically cleans up when service is killed
- ✅ Call `dispose()` only when explicitly stopping the service

### File Caching

The plugin automatically caches audio files for better performance:
- First play: File is copied to cache
- Subsequent plays: Cached file is reused (faster!)
- Cleanup: Cached files are removed on `dispose()`

### Thread Safety

All operations are thread-safe. Multiple rapid play/stop calls are handled correctly without crashes.

## Troubleshooting

### Alarm doesn't play

1. **Check audio file exists** in your assets
2. **Verify permissions** are in AndroidManifest.xml
3. **Check device volume** isn't at 0
4. **Test on real device** (emulator may have audio issues)

### Memory leaks

Make sure you call `dispose()` when done:

```dart
alarmplayer.dispose();
```

### File not found errors

Ensure assets are properly configured in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/
    - assets/alarms/
```

### Volume not working

On some devices, the system may restrict alarm volume changes. This is a system limitation and cannot be bypassed.

### Do Not Disturb mode

The plugin uses `USAGE_ALARM` which should bypass Do Not Disturb on most devices. However, user settings may still block alarms.

## Migration from v1.x

### Breaking Changes

1. **Minimum Android version**: API 16 → API 24 (Android 7.0+)
2. **dispose() required**: Must call `dispose()` when done
3. **Error handling**: Use `AlarmplayerException` instead of generic `Exception`

### Migration Steps

1. **Update minSdkVersion**:
```gradle
android {
    defaultConfig {
        minSdkVersion 24  // Was 16
    }
}
```

2. **Add dispose() calls**:
```dart
// Old (v1.x)
final alarmplayer = Alarmplayer();
alarmplayer.Alarm(url: "assets/alarm.mp3");

// New (v2.0)
final alarmplayer = Alarmplayer();
await alarmplayer.play(url: "assets/alarm.mp3");
alarmplayer.dispose();  // Required!
```

3. **Update error handling**:
```dart
// Old (v1.x)
try {
  alarmplayer.Alarm(url: "assets/alarm.mp3");
} catch (e) {
  print('Error: $e');
}

// New (v2.0)
try {
  await alarmplayer.play(url: "assets/alarm.mp3");
} on AlarmplayerException catch (e) {
  print('Error: ${e.message} (${e.code})');
}
```

### What's Improved in v2.0

- ✅ No more memory leaks
- ✅ Better error messages
- ✅ Improved performance (file caching)
- ✅ Thread-safe operations
- ✅ Modern Android support
- ✅ Better resource management
- ✅ Comprehensive test coverage

## Example App

See the [example](example/) directory for a complete working example.

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md).

- If you **found a bug**, open an issue
- If you **have a feature request**, open an issue
- If you **want to contribute**, submit a pull request

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Credits

Made by [Mrbluesky-ai](https://github.com/Mrbluesky-ai)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed list of changes.

## Support

For issues and questions:
- 📝 [GitHub Issues](https://github.com/Mrbluesky-ai/flutter-alarmplayer/issues)

---

**Note**: This plugin is Android-only. iOS support is not planned at this time.
