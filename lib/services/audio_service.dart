import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService instance = AudioService._init();
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();

  // Expose player for listening to events (e.g., onPlayerComplete)
  AudioPlayer get player => _player;

  AudioService._init() {
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      // Check available engines
      var engines = await _tts.getEngines;
      if (engines.contains("com.google.android.tts")) {
        await _tts.setEngine("com.google.android.tts");
      }

      bool isAvailable = await _tts.isLanguageAvailable("ar");
      if (isAvailable) {
        await _tts.setLanguage("ar");
        await _tts.setSpeechRate(0.5);
        await _tts.setVolume(1.0);
        await _tts.setPitch(1.0);
        
        _tts.setCompletionHandler(() {
          print("EchoLearn: TTS finished speaking.");
        });
        
        _tts.setErrorHandler((msg) {
          print("EchoLearn: TTS Error: $msg");
        });

        print("EchoLearn: Arabic TTS is ready using ${engines.isNotEmpty ? engines.first : 'default'} engine.");
      } else {
        print("EchoLearn: Arabic TTS not available on this device.");
      }
    } catch (e) {
      print("EchoLearn: Error initializing TTS: $e");
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    print("EchoLearn: Attempting to speak text: $text");
    await _tts.stop();
    var result = await _tts.speak(text);
    if (result == 1) {
      print("EchoLearn: Speak command accepted by engine.");
    } else {
      print("EchoLearn: Speak command rejected by engine (Result: $result).");
    }
  }

  Future<void> playAsset(String path) async {
    if (path.isEmpty) return;
    await _player.stop();
    await _player.setReleaseMode(ReleaseMode.stop); // Play once, no loop
    await _player.play(AssetSource(path));
  }

  Future<void> stop() async {
    await _tts.stop();
    await _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}
