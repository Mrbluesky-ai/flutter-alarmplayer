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
import java.io.*;
import java.util.Objects;


/** AlarmplayerPlugin */
public class AlarmplayerPlugin implements FlutterPlugin, MethodCallHandler {
  public Context context;
  private MediaPlayer mMediaPlayer;
  private boolean isAlarmPlaying;
  private int originalVolume;
  private MethodChannel channel;
  private FlutterEngine backgroundFlutterEngine;



  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "alarmplayer");
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();
  }


  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
//    System.out.println("\n  **** " + call.method + " **** \n   " + context.getResources().toString());
    switch (call.method) {
      case "play":
        String url = Objects.requireNonNull(call.argument("url")).toString();
        double volume = Objects.requireNonNull(call.argument("volume"));
        play(url, volume);
        result.success(null);
        break;
      case "playing":
        if(mMediaPlayer != null){
          result.success(mMediaPlayer.isPlaying());
        } else{
          result.success(false);
        }
        break;
      case "stop":
        stop();
        result.success(null);
        break;
      default:
        result.notImplemented();
    }
  }




  @SuppressWarnings("deprecation")
  private void play(String url, double volume) {
      if (isAlarmPlaying) {
        return;
      }
      try {
        mMediaPlayer = new MediaPlayer();
        mMediaPlayer.setDataSource(url);

        final AudioManager audioManager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
        int _volume = (int) (Math.round(audioManager.getStreamMaxVolume(AudioManager.STREAM_ALARM) * volume));
        originalVolume = audioManager.getStreamVolume(AudioManager.STREAM_ALARM);

        audioManager.setStreamVolume(AudioManager.STREAM_ALARM, _volume, 0);


        if (audioManager.getStreamVolume(AudioManager.STREAM_ALARM) != 0) {
          if (Build.VERSION.SDK_INT <= 21) {
            mMediaPlayer.setAudioStreamType(AudioManager.STREAM_ALARM);
          } else {
            mMediaPlayer.setAudioAttributes(new AudioAttributes.Builder().setContentType(AudioAttributes.CONTENT_TYPE_MUSIC).setUsage(AudioAttributes.USAGE_ALARM)
                    .build());
          }


          mMediaPlayer.setLooping(true);
          mMediaPlayer.prepare();
          mMediaPlayer.start();
          isAlarmPlaying = true;
        } else{
          System.out.println("couldn't set the volume higher, so no alarm playing");
        }
      } catch (IOException e) {
        e.printStackTrace();
      }
  }


  private void stop(){
    try {
      if (mMediaPlayer != null) {
        mMediaPlayer.stop();
        mMediaPlayer.release();
        mMediaPlayer = null;

        final AudioManager audioManager = (AudioManager)context.getSystemService(Context.AUDIO_SERVICE);
        audioManager.setStreamVolume(AudioManager.STREAM_ALARM, originalVolume, 0);
        isAlarmPlaying = false;
      }
    } catch(Exception e){
      e.printStackTrace();
    }
  }


  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    channel = null;
  }
}
// made by: Mrblueskyai