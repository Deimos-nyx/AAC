import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../features/profiles/domain/profile_model.dart';
import '../services/tts_service.dart';
import '../services/tts_service_impl.dart';

/// Exposes the app's single [TtsService] instance to the widget tree and
/// keeps its rate/pitch/volume/voice in sync with whichever profile is
/// active. UI never talks to `flutter_tts` directly — only to this.
class TtsProvider extends ChangeNotifier {
  final TtsService _tts;
  StreamSubscription<bool>? _speakingSub;

  bool _isSpeaking = false;
  List<TtsVoice> _availableVoices = [];
  bool _isInitialized = false;

  TtsProvider({TtsService? ttsService}) : _tts = ttsService ?? FlutterTtsService() {
    _speakingSub = _tts.isSpeakingStream.listen((speaking) {
      _isSpeaking = speaking;
      notifyListeners();
    });
  }

  bool get isSpeaking => _isSpeaking;
  bool get isInitialized => _isInitialized;
  List<TtsVoice> get availableVoices => List.unmodifiable(_availableVoices);

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _tts.initialize();
    _isInitialized = true;
  }

  /// Pushes a profile's saved speech preferences down into the engine and
  /// refreshes the voice list for that profile's language. Call this on
  /// app start and every time the active profile changes.
  Future<void> applyProfile(ProfileModel profile) async {
    await initialize();
    await _tts.setRate(profile.ttsRate);
    await _tts.setPitch(profile.ttsPitch);
    await _tts.setVolume(profile.ttsVolume);
    await refreshVoicesFor(profile.localeCode);
    final voiceId = profile.ttsVoiceId;
    if (voiceId != null && _availableVoices.any((v) => v.id == voiceId)) {
      await _tts.setVoice(voiceId);
    }
  }

  Future<void> refreshVoicesFor(String localeCode) async {
    _availableVoices = await _tts.getAvailableVoices(localeCode);
    notifyListeners();
  }

  Future<void> speak(String text, {String? localeCode}) async {
    if (text.trim().isEmpty) return;
    await _tts.speak(text, localeCode: localeCode);
  }

  Future<void> stop() => _tts.stop();

  Future<void> previewVoice(String sampleText, {String? localeCode}) =>
      speak(sampleText, localeCode: localeCode);

  @override
  void dispose() {
    _speakingSub?.cancel();
    _tts.dispose();
    super.dispose();
  }
}
