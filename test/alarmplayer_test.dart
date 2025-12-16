import 'package:flutter_test/flutter_test.dart';
import 'package:alarmplayer/alarmplayer.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Alarmplayer', () {
    late Alarmplayer alarmplayer;
    final List<MethodCall> log = [];

    setUp(() {
      alarmplayer = Alarmplayer();
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('alarmplayer'),
        (MethodCall methodCall) async {
          log.add(methodCall);
          
          switch (methodCall.method) {
            case 'play':
              return null;
            case 'stop':
              return null;
            case 'playing':
              return false;
            default:
              return null;
          }
        },
      );
    });

    tearDown(() {
      log.clear();
      alarmplayer.dispose();
    });

    test('play calls platform method with correct arguments', () async {
      await alarmplayer.play(
        url: 'assets/test.mp3',
        volume: 0.5,
        looping: true,
      );

      expect(log, hasLength(1));
      expect(log.first.method, 'play');
      expect(log.first.arguments['volume'], 0.5);
      expect(log.first.arguments['loop'], true);
      expect(log.first.arguments['callback'], false);
    });

    test('play with callback sets callback flag', () async {
      await alarmplayer.play(
        url: 'assets/test.mp3',
        onComplete: () {},
      );

      expect(log.first.arguments['callback'], true);
    });

    test('volume is clamped between 0 and 1', () async {
      // Test volume > 1
      await alarmplayer.play(url: 'assets/test.mp3', volume: 1.5);
      expect(log.first.arguments['volume'], 1.0);

      log.clear();
      
      // Test volume < 0
      await alarmplayer.play(url: 'assets/test.mp3', volume: -0.5);
      expect(log.first.arguments['volume'], 0.0);
    });

    test('default values are applied correctly', () async {
      await alarmplayer.play(url: 'assets/test.mp3');

      expect(log.first.arguments['volume'], 1.0);
      expect(log.first.arguments['loop'], true);
      expect(log.first.arguments['callback'], false);
    });

    test('stop calls platform method', () async {
      await alarmplayer.stop();
      
      expect(log, hasLength(1));
      expect(log.first.method, 'stop');
    });

    test('isPlaying returns platform result', () async {
      final result = await alarmplayer.isPlaying();
      
      expect(log, hasLength(1));
      expect(log.first.method, 'playing');
      expect(result, false);
    });

    test('isPlaying returns true when platform returns true', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('alarmplayer'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'playing') {
            return true;
          }
          return null;
        },
      );

      final result = await alarmplayer.isPlaying();
      expect(result, true);
    });

    test('dispose clears method handler', () {
      alarmplayer.dispose();
      // No exception should be thrown
      expect(() => alarmplayer.dispose(), returnsNormally);
    });

    test('error from platform is wrapped in AlarmplayerException', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('alarmplayer'),
        (MethodCall methodCall) async {
          throw PlatformException(
            code: 'TEST_ERROR',
            message: 'Test error message',
          );
        },
      );

      expect(
        () => alarmplayer.play(url: 'assets/test.mp3'),
        throwsA(isA<AlarmplayerException>()),
      );
    });

    test('AlarmplayerException contains error details', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('alarmplayer'),
        (MethodCall methodCall) async {
          throw PlatformException(
            code: 'TEST_ERROR',
            message: 'Test error message',
            details: {'key': 'value'},
          );
        },
      );

      try {
        await alarmplayer.play(url: 'assets/test.mp3');
        fail('Should have thrown AlarmplayerException');
      } on AlarmplayerException catch (e) {
        expect(e.code, 'TEST_ERROR');
        expect(e.message, contains('Test error message'));
        expect(e.details, isNotNull);
      }
    });

    test('multiple play calls are handled correctly', () async {
      await alarmplayer.play(url: 'assets/test1.mp3');
      await alarmplayer.play(url: 'assets/test2.mp3');
      await alarmplayer.play(url: 'assets/test3.mp3');

      expect(log, hasLength(3));
      expect(log[0].method, 'play');
      expect(log[1].method, 'play');
      expect(log[2].method, 'play');
    });

    test('play and stop sequence works correctly', () async {
      await alarmplayer.play(url: 'assets/test.mp3');
      await alarmplayer.stop();
      await alarmplayer.play(url: 'assets/test.mp3');
      await alarmplayer.stop();

      expect(log, hasLength(4));
      expect(log[0].method, 'play');
      expect(log[1].method, 'stop');
      expect(log[2].method, 'play');
      expect(log[3].method, 'stop');
    });
  });

  group('AlarmplayerException', () {
    test('toString includes code when provided', () {
      final exception = AlarmplayerException(
        'Test message',
        code: 'TEST_CODE',
      );

      expect(exception.toString(), contains('TEST_CODE'));
      expect(exception.toString(), contains('Test message'));
    });

    test('toString works without code', () {
      final exception = AlarmplayerException('Test message');

      expect(exception.toString(), contains('Test message'));
      expect(exception.toString(), contains('AlarmplayerException'));
    });

    test('details are stored correctly', () {
      final details = {'key': 'value'};
      final exception = AlarmplayerException(
        'Test message',
        details: details,
      );

      expect(exception.details, equals(details));
    });
  });
}
