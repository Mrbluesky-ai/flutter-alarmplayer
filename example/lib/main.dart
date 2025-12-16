import 'package:flutter/material.dart';

import 'package:alarmplayer/alarmplayer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Alarmplayer alarmplayer = Alarmplayer();
  bool playing = false;

  @override
  void dispose() {
    // Clean up resources when widget is disposed
    alarmplayer.dispose();
    super.dispose();
  }

  void switchPlaying(){
    playing = !playing;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Alarmplayer Example'),
        ),
        body: Container(
        alignment: Alignment.topCenter,
    child: SingleChildScrollView(
    child: Column(

    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      Container(
        margin: const EdgeInsets.all(25),
        child: playing?
        ElevatedButton(
          child: const Text('Stop Alarm', style: TextStyle(fontSize: 20.0),),
          onPressed: () async {
            await alarmplayer.stop();
            switchPlaying();
            },
        )
        :
        ElevatedButton(
          child: const Text('Start Alarm', style: TextStyle(fontSize: 20.0),),
          onPressed: () async {
            switchPlaying();
            try {
              await alarmplayer.play(
                url: "assets/2.mp3",
                volume: 0.5,
                looping: false,
                onComplete: switchPlaying,
              );
            } on AlarmplayerException catch (e) {
              // Handle alarmplayer-specific errors
              switchPlaying();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Alarm error: ${e.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } catch (e) {
              // Handle unexpected errors
              switchPlaying();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Unexpected error: $e')),
                );
              }
            }
            },
        ),
      ),

      Container(
        margin: const EdgeInsets.all(25),
        child: ElevatedButton(
          child: const Text('Check if Playing', style: TextStyle(fontSize: 20.0),),
          onPressed: () async {
            final isPlaying = await alarmplayer.isPlaying();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Is playing: $isPlaying')),
              );
            }
          },
        ),
      ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}
