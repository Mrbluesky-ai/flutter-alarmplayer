// made by: Mrblueskyai
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'alarmplayer_exception.dart';
export 'alarmplayer_exception.dart';


class Alarmplayer {
  final methodChannel = const MethodChannel('alarmplayer');
  Function? _callback;
  final Map<String, File> _fileCache = {};  // Cache for audio files

  // Constructor - register method handler once to prevent memory leaks
  Alarmplayer() {
    methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  // Central handler for all method calls from native side
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'callback':
        if (_callback != null) {
          _callback!();
          _callback = null;  // Clear callback after use
        }
        break;
      default:
        throw MissingPluginException('Method ${call.method} not implemented');
    }
  }

  /// Play an alarm sound
  /// 
  /// [url] - Asset path to the audio file (e.g., "assets/alarm.mp3")
  /// [volume] - Volume level from 0.0 to 1.0 (default: 1.0)
  /// [looping] - Whether to loop the alarm continuously (default: true)
  /// [onComplete] - Callback function called when playback completes (non-looping only)
  Future<void> play({
    required String url,
    double volume = 1.0,
    bool looping = true,
    Function? onComplete,
  }) async {
    _callback = onComplete;
    
    // Clamp volume between 0.0 and 1.0
    volume = volume.clamp(0.0, 1.0);
    
    try {
      final filePath = await _getCachedAssetPath(url);
      await methodChannel.invokeMethod('play', {
        'url': filePath,
        'volume': volume,
        'loop': looping,
        'callback': onComplete != null,
      });
    } on PlatformException catch (e) {
      _callback = null;  // Clear callback on error
      throw AlarmplayerException(
        'Failed to play alarm: ${e.message}',
        code: e.code,
        details: e.details,
      );
    } catch (e) {
      _callback = null;
      throw AlarmplayerException('Unexpected error while playing alarm: $e');
    }
  }

  /// Stop the currently playing alarm
  Future<void> stop() async {
    _callback = null;  // Clear callback
    await methodChannel.invokeMethod('stop');
  }

  /// Check if an alarm is currently playing
  /// 
  /// Returns true if playing, false otherwise
  Future<bool> isPlaying() async {
    return await methodChannel.invokeMethod('playing') ?? false;
  }

  /// Get cached file path for an asset, or create and cache it
  /// 
  /// This prevents recreating temp files on every play call
  Future<String> _getCachedAssetPath(String asset) async {
    // Check cache first
    if (_fileCache.containsKey(asset)) {
      final file = _fileCache[asset]!;
      if (await file.exists()) {
        return file.path;
      }
      // File was deleted, remove from cache
      _fileCache.remove(asset);
    }

    // Create new cached file
    if (Platform.isAndroid) {
      final byteData = await rootBundle.load(asset);
      final tempDir = await getTemporaryDirectory();
      
      // Create subdirectory for alarmplayer files
      final alarmDir = Directory('${tempDir.path}/alarmplayer');
      if (!await alarmDir.exists()) {
        await alarmDir.create(recursive: true);
      }
      
      // Use sanitized asset path as filename to avoid conflicts
      final fileName = asset.replaceAll('/', '_');
      final file = File('${alarmDir.path}/$fileName');
      
      await file.writeAsBytes(byteData.buffer.asUint8List());
      _fileCache[asset] = file;
      
      return file.path;
    } else {
      // For other platforms, return asset path as-is
      return asset;
    }
  }

  /// Clean up resources
  /// 
  /// Call this when you're done with the Alarmplayer instance
  Future<void> dispose() async {
    _callback = null;
    
    // Clean up cached files
    for (final file in _fileCache.values) {
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Ignore cleanup errors
      }
    }
    _fileCache.clear();
    
    methodChannel.setMethodCallHandler(null);
  }
}
// made by: Mrblueskyai
