// made by: Mrblueskyai
package com.Mrblueskyai.alarmplayer;


import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
// made by: Mrblueskyai
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import android.content.Context;
import android.media.*;
import java.io.*;
import java.util.Objects;

/** AlarmplayerPlugin */
public class AlarmplayerPlugin implements FlutterPlugin, MethodCallHandler {
  private Context context;
  private static MediaPlayer mMediaPlayer;
  private boolean isAlarmPlaying;
  private int originalVolume;
  private static AudioManager audioManager;
  private MethodChannel channel;



  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "alarmplayer");
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    System.out.println("\n  **** " + call.method + " **** \n   " + context.getResources().toString());
    switch (call.method) {
      case "play":
        String url = Objects.requireNonNull(call.argument("url")).toString();
        double volume = Objects.requireNonNull(call.argument("volume"));
        play(url, volume);
        result.success(null);
        break;
      case "playing":
        result.success(mMediaPlayer.isPlaying());
        break;
      case "stop":
        stop();
        result.success(null);
        break;
      default:
        result.notImplemented();
    }
  }

  private void play(String url, double volume){
    if(isAlarmPlaying){ return;}
    try {
      mMediaPlayer = new MediaPlayer();
      mMediaPlayer.setDataSource("file://" + url);
      audioManager = (AudioManager)context.getSystemService(Context.AUDIO_SERVICE);
      int _volume = (int) (Math.round(audioManager.getStreamMaxVolume(AudioManager.STREAM_ALARM) * volume));
      System.out.println(_volume + "***");
      originalVolume = audioManager.getStreamVolume(AudioManager.STREAM_ALARM);
      audioManager.setStreamVolume(AudioManager.STREAM_ALARM, _volume, 0);
      if (audioManager.getStreamVolume(AudioManager.STREAM_ALARM) != 0) {
          mMediaPlayer.setAudioStreamType(AudioManager.STREAM_ALARM);
          mMediaPlayer.setLooping(true);
          mMediaPlayer.prepare();
          mMediaPlayer.start();
          isAlarmPlaying = true;
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