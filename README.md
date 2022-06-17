#  alarmplayer

alarmplayer is a very simple plugin to play sounds with their own volume, so that you can play critical alarms also when the phone is on silent mode.


## Getting started
To use this plugin :

Add dependency to your flutter project:

```
$ flutter pub add alarmplayer
```

or

```yaml
dependencies:
  alarmplayer: ^newest
```

Add following import to your code:

```dart
import 'package:alarmplayer/alarmplayer.dart';
```


###  Usage

Instantiate an Alarmplayer instance

```dart
//...
Alarmplayer alarmplayer = Alarmplayer();
//...
```


Play alarm.
```dart
alarmplayer.Alarm(
  url: "assets/alarm.mp3",  // Path of sound file. 
  volume: 0.5,              // optional, set the volume, default 1.
  looping: false,           // optional, looping?, default true.
);
```

Stop alarm.

```dart
alarmplayer.stop();         // Stop alarm.
```

is playing?

```dart
alarmplayer.IsPlaying();    // returning a boolean if the alarm is currently playing.
```

##  Contribution


Of course the project is open source, and you can contribute to it [repository link](https://github.com/Mrbluesky-ai/flutter-alarmplayer.git)

-  If you **found a bug**, open an issue.
-  If you **have a feature request**, open an issue.
-  If you **want to contribute**, submit a pull request.

## Note for ios.
##### currently there is no implementation for ios yet!
&nbsp;
&nbsp;

* * * *
Made by Mrbluesky-ai.