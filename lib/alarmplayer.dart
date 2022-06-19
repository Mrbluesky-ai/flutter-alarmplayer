// made by: Mrblueskyai
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';


class Alarmplayer {
  final methodChannel = const MethodChannel('alarmplayer');

  Future<void> Alarm({required String url, double? volume}) async {
    volume = volume?? 1;
    if(volume > 1){
      volume = 1;
    } else if(volume < 0){
      volume = 0;
    }
    print(volume);
    await methodChannel.invokeMethod('play', {'url': await generateAssetUri(url), 'volume': volume});
  }

  Future<void> StopAlarm() async {
    await methodChannel.invokeMethod('stop');
  }

  Future<bool> IsPlaying() async {
    return await methodChannel.invokeMethod('playing');
  }

  static Future<String> generateAssetUri(String asset) async {
    if (Platform.isAndroid) {
      // read local asset from rootBundle
      final byteData = await rootBundle.load(asset);

      // create a temporary file on the device to be read by the native side
      final file = File('${(await getTemporaryDirectory()).path}/$asset');
      await file.create(recursive: true);
      await file.writeAsBytes(byteData.buffer.asUint8List());
      return file.uri.path;
    } else if (Platform.isIOS) {
      if (!['wav', 'mp3', 'aiff', 'caf']
          .contains(asset.split('.').last.toLowerCase())) {
        throw 'Format not supported for iOS. Only mp3, wav, aiff and caf formats are supported.';
      }
      return asset;
    } else {
      return asset;
    }
  }

}
// made by: Mrblueskyai