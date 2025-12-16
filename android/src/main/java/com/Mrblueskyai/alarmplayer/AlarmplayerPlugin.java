// made by: Mrblueskyai
package com.Mrblueskyai.alarmplayer;


import androidx.annotation.NonNull;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
// made by: Mrblueskyai
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.media.*;
import android.os.Build;
import android.util.Log;
import java.io.*;
import java.util.Objects;


/** AlarmplayerPlugin */
public class AlarmplayerPlugin implements FlutterPlugin, MethodCallHandler {
  private static final String TAG = "AlarmplayerPlugin";
  
  public Context context;
  private MediaPlayer mediaPlayer;  // Not static - prevents memory leaks
  private boolean isAlarmPlaying;
  private int originalVolume;       // Not static - prevents memory leaks
  private MethodChannel channel;
  private final Object lock = new Object();  // For thread safety



  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "alarmplayer");
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();
  }


  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    try {
      switch (call.method) {
        case "play":
          boolean callback = Boolean.TRUE.equals(call.argument("callback"));
          boolean looping = Boolean.TRUE.equals(call.argument("loop"));
          String url = Objects.requireNonNull(call.argument("url")).toString();
          double volume = Objects.requireNonNull(call.argument("volume"));
          play(url, volume, looping, callback);
          result.success(null);
          break;
        case "playing":
          synchronized (lock) {
            result.success(mediaPlayer != null && mediaPlayer.isPlaying());
          }
          break;
        case "stop":
          stop();
          result.success(null);
          break;
        default:
          result.notImplemented();
      }
    } catch (Exception e) {
      // Proper error handling - propagate errors to Flutter
      Log.e(TAG, "Error in method call: " + call.method, e);
      result.error("PLUGIN_ERROR", e.getMessage(), e.toString());
    }
  }




  private void play(String url, double volume, boolean loop, boolean callback) {
      // Stop any existing playback first (thread-safe)
      synchronized (lock) {
        if (isAlarmPlaying) {
          stopInternal();
        }
      }

      MediaPlayer player = null;
      try {
        player = new MediaPlayer();
        player.setDataSource(url);


        final AudioManager audioManager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
        if (audioManager == null) {
          throw new RuntimeException("AudioManager not available");
        }

        // Save original volume for restoration later
        originalVolume = audioManager.getStreamVolume(AudioManager.STREAM_ALARM);
        Log.d(TAG, "Original volume: " + originalVolume);

        // Calculate and set target volume
        int maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_ALARM);
        int targetVolume = (int) Math.round(maxVolume * volume);
        audioManager.setStreamVolume(AudioManager.STREAM_ALARM, targetVolume, 0);


        // Check if volume was actually set (may be restricted by system)
        if (audioManager.getStreamVolume(AudioManager.STREAM_ALARM) == 0) {
          if (player != null) {
            player.release();
          }
          throw new RuntimeException("Cannot set alarm volume - may be restricted by system settings");
        }

        // Set audio attributes for alarm playback
        player.setAudioAttributes(
          new AudioAttributes.Builder()
            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
            .setUsage(AudioAttributes.USAGE_ALARM)
            .build()
        );


        player.setLooping(loop);

        // Prepare the player
        player.prepare();

        // Set completion listener
        final boolean hasCallback = callback;
        player.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
          @Override
          public void onCompletion(MediaPlayer mp) {
            stop();

            if (hasCallback && channel != null) {
              channel.invokeMethod("callback", null);
            }
          }
        });

        // Start playback
        player.start();

        // Update state (thread-safe)
        synchronized (lock) {
          mediaPlayer = player;
          isAlarmPlaying = true;
        }

      } catch (Exception e) {
        // Cleanup on error
        if (player != null) {
          try {
            player.release();
          } catch (Exception ignored) {
            // Ignore cleanup errors
          }
        }
        
        // Restore volume on error
        restoreVolume();
        
        Log.e(TAG, "Failed to play alarm", e);
        throw new RuntimeException("Failed to play alarm: " + e.getMessage(), e);
      }
  }



  private void stop() {
    synchronized (lock) {
      stopInternal();
    }
  }

  /**
   * Internal stop method - must be called within synchronized block
   */
  private void stopInternal() {
    try {
      if (mediaPlayer != null) {
        if (mediaPlayer.isPlaying()) {
          mediaPlayer.stop();
        }
        mediaPlayer.release();
        mediaPlayer = null;
      }

      restoreVolume();
      isAlarmPlaying = false;
    } catch (Exception e) {
      Log.e(TAG, "Error stopping alarm", e);
    }
  }

  /**
   * Restore the original alarm volume
   */
  private void restoreVolume() {
    try {
      final AudioManager audioManager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
      if (audioManager != null) {
        audioManager.setStreamVolume(AudioManager.STREAM_ALARM, originalVolume, 0);
        Log.d(TAG, "Volume restored to: " + originalVolume);
      }
    } catch (Exception e) {
      Log.e(TAG, "Error restoring volume", e);
    }
  }


  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    // Cleanup resources when plugin is detached
    stop();
    
    if (channel != null) {
      channel.setMethodCallHandler(null);
      channel = null;
    }
  }
}
// made by: Mrblueskyai
