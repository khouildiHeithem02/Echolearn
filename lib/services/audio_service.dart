import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

enum VoiceGender { male, female }

class AudioService {
  static final AudioService instance = AudioService._init();
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _player = AudioPlayer();
  
  VoiceGender _currentGender = VoiceGender.female;
  Map<String, String>? _maleVoice;
  Map<String, String>? _femaleVoice;

  // Expose player for listening to events (e.g., onPlayerComplete)
  AudioPlayer get player => _player;
  VoiceGender get currentGender => _currentGender;

  AudioService._init() {
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      // Check available engines - Google TTS is usually more human-like
      var engines = await _tts.getEngines;
      if (engines.contains("com.google.android.tts")) {
        await _tts.setEngine("com.google.android.tts");
      }

      bool isAvailable = await _tts.isLanguageAvailable("ar");
      if (isAvailable) {
        await _tts.setLanguage("ar");
        await _tts.setSpeechRate(0.4); // Slightly slower for better clarity
        await _tts.setVolume(1.0);
        await _tts.setPitch(1.0);
        
        // Fetch voices and try to identify the best quality Arabic voices
        List<dynamic> voices = await _tts.getVoices;
        print("EchoLearn: Found ${voices.length} total voices.");
        
        for (var voice in voices) {
          if (voice is Map) {
            String name = voice["name"]?.toString().toLowerCase() ?? "";
            String locale = voice["locale"]?.toString().toLowerCase() ?? "";
            
            if (locale.contains("ar")) {
              // Priority for "natural" or "premium" voices if the engine supports tagging
              bool isHighQuality = name.contains("natural") || name.contains("premium") || name.contains("google");
              
              if (name.contains("male") || name.contains("-m-") || name.contains("ar-xa-x-ard-local")) {
                if (_maleVoice == null || isHighQuality) {
                  _maleVoice = Map<String, String>.from(voice.cast<String, String>());
                }
              } else if (name.contains("female") || name.contains("-f-") || name.contains("ar-xa-x-arc-local")) {
                if (_femaleVoice == null || isHighQuality) {
                  _femaleVoice = Map<String, String>.from(voice.cast<String, String>());
                }
              }
            }
          }
        }
        
        _applyVoice();
        print("EchoLearn: Arabic TTS initialized with Male: ${_maleVoice != null}, Female: ${_femaleVoice != null}");
      }
    } catch (e) {
      print("EchoLearn: Error initializing TTS: $e");
    }
  }

  void _applyVoice() async {
    if (_currentGender == VoiceGender.male) {
      if (_maleVoice != null) {
        await _tts.setVoice(_maleVoice!);
        await _tts.setPitch(0.9);
      } else {
        await _tts.setPitch(0.85);
      }
    } else {
      if (_femaleVoice != null) {
        await _tts.setVoice(_femaleVoice!);
        await _tts.setPitch(1.1);
      } else {
        await _tts.setPitch(1.15);
      }
    }
  }

  Future<void> setVoiceGender(VoiceGender gender) async {
    _currentGender = gender;
    _applyVoice();
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    print("EchoLearn: Attempting to speak text: $text");
    await _tts.stop();
    _applyVoice(); // Ensure correct voice/pitch is applied
    var result = await _tts.speak(text);
    if (result == 1) {
      print("EchoLearn: Speak command accepted by engine.");
    }
  }

  Future<void> speakGentle(String text) async {
    if (text.isEmpty) return;
    print("EchoLearn: Attempting to speak text gently: $text");
    await _tts.stop();
    
    // For gentle voice, we slow down and slightly adjust pitch regardless of gender selection
    await _tts.setSpeechRate(0.35);
    var result = await _tts.speak(text);
    if (result == 1) {
      print("EchoLearn: Speak gentle command accepted by engine.");
    }
  }

  Future<void> playAsset(String path) async {
    if (path.isEmpty) return;
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.stop); // Play once, no loop
      await _player.play(AssetSource(path));
    } catch (e) {
      print("EchoLearn: Error playing asset $path: $e");
    }
  }

  Future<void> stop() async {
    await _tts.stop();
    await _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}
