import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
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

  void switchPlaying(){
    playing = !playing;
    setState(() {});
  }

  // Platform messages are asynchronous, so we initialize in an async method.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
        alignment: Alignment.topCenter,
    // margin: const EdgeInsets.symmetric(horizontal: 30),
    child: SingleChildScrollView(
    child: Column(

    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      Container(
        margin: EdgeInsets.all(25),
        child: playing?
        ElevatedButton(
          child: Text('stop alarm', style: TextStyle(fontSize: 20.0),),
          onPressed: () async {
            alarmplayer.StopAlarm();
            switchPlaying();
            },
        )
        :
        ElevatedButton(
          child: Text('start alarm', style: TextStyle(fontSize: 20.0),),
          onPressed: () async {
            switchPlaying();
            alarmplayer.Alarm(
              url: "assets/2.mp3",
              volume: 0.5,
              looping: false,
              callback: switchPlaying,
            );

            },
        ),
      ),

      // Container(
      //   margin: EdgeInsets.all(25),
      //   child: ElevatedButton(
      //     child: Text('stop alarm', style: TextStyle(fontSize: 20.0),),
      //     onPressed: () async {
      //       alarmplayer.StopAlarm();
      //       },
      //   ),
      // ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}
