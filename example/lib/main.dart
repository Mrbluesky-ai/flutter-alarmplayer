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

  String _platformVersion = 'Unknown';
  Alarmplayer alarmplayer = Alarmplayer();


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
        child: FlatButton(
          child: Text('klik ff', style: TextStyle(fontSize: 20.0),),
          color: Colors.blueAccent,
          textColor: Colors.white,
          onPressed: () async {
            alarmplayer.Alarm(
              url: "assets/2.mp3",
              volume: 0.5,
              looping: false,
            );

            },
        ),
      ),

      Container(
        margin: EdgeInsets.all(25),
        child: FlatButton(
          child: Text('klik ff', style: TextStyle(fontSize: 20.0),),
          color: Colors.blueAccent,
          textColor: Colors.white,
          onPressed: () async {
            alarmplayer.IsPlaying();
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
