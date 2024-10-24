import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _soundPlayer = AudioPlayer();
  bool _isMusicEnabled = true;
  bool _isSoundEnabled = true;

  Future<void> initAudio() async {
    final prefs = await SharedPreferences.getInstance();
    _isMusicEnabled = prefs.getBool('isMusic') ?? true;
    _isSoundEnabled = prefs.getBool('isSound') ?? true;

    if (_isMusicEnabled) {
      await playBackgroundMusic();
    }
  }

  Future<void> playBackgroundMusic() async {
    if (!_isMusicEnabled) return;

    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(0.2);
      await Future.delayed(const Duration(seconds: 1));
      await _musicPlayer.play(AssetSource('music/music.mp3'));
    } catch (e) {
      print('Error playing background music: $e');
    }
  }

  Future<void> playSound(String soundAsset) async {
    if (!_isSoundEnabled) return;

    try {
      await _soundPlayer.play(AssetSource(soundAsset));
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  Future<void> toggleMusic(bool isEnabled) async {
    _isMusicEnabled = isEnabled;

    if (_isMusicEnabled) {
      await playBackgroundMusic();
    } else {
      await _musicPlayer.stop();
    }
  }

  Future<void> toggleSound(bool isEnabled) async {
    _isSoundEnabled = isEnabled;
  }

  Future<void> dispose() async {
    await _musicPlayer.dispose();
    await _soundPlayer.dispose();
  }
}
