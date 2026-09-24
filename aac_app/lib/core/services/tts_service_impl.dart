import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

import 'logger_service.dart';
import 'tts_service.dart';

/// Default [TtsService] backed by the device's native TTS engine via
/// `flutter_tts` (Android TextToSpeech / iOS AVSpeechSynthesizer under the
/// hood). This is what makes on-device, offline speech output possible —
/// no network call is ever made for speech (spec section 9).
class FlutterTtsService implements TtsService {
  final FlutterTts _tts = FlutterTts();
  final StreamController<bool> _speakingController = StreamController<bool>.broadcast();
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await _tts.awaitSpeakCompletion(true);
      _tts.setStartHandler(() => _speakingController.add(true));
      _tts.setCompletionHandler(() => _speakingController.add(false));
      _tts.setCancelHandler(() => _speakingController.add(false));
      _tts.setErrorHandler((msg) {
        AppLogger.warning('TTS engine error: $msg');
        _speakingController.add(false);
      });
      _initialized = true;
    } catch (e, st) {
      // TTS is optional for the app to remain usable (spec section 17): a
      // profile can still build sentences and read them visually even if
      // speech itself is unavailable on this device.
      AppLogger.error('FlutterTtsService.initialize', e, st);
    }
  }

  @override
  Future<void> speak(String text, {String? localeCode}) async {
    if (text.trim().isEmpty) return;
    try {
      if (localeCode != null) {
        await _tts.setLanguage(_toBcp47(localeCode));
      }
      await _tts.speak(text);
    } catch (e, st) {
      AppLogger.error('FlutterTtsService.speak', e, st);
      _speakingController.add(false);
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e, st) {
      AppLogger.error('FlutterTtsService.stop', e, st);
    } finally {
      _speakingController.add(false);
    }
  }

  @override
  Future<List<TtsVoice>> getAvailableVoices(String localeCode) async {
    try {
      final raw = await _tts.getVoices;
      if (raw is! List) return [];
      final targetPrefix = _toBcp47(localeCode).split('-').first.toLowerCase();
      final voices = <TtsVoice>[];
      for (final entry in raw) {
        if (entry is! Map) continue;
        final name = entry['name']?.toString();
        final locale = entry['locale']?.toString();
        if (name == null || locale == null) continue;
        if (!locale.toLowerCase().startsWith(targetPrefix)) continue;
        voices.add(TtsVoice(id: name, displayName: name, localeCode: locale));
      }
      return voices;
    } catch (e, st) {
      AppLogger.error('FlutterTtsService.getAvailableVoices', e, st);
      return [];
    }
  }

  @override
  Future<void> setVoice(String voiceId) async {
    try {
      await _tts.setVoice({'name': voiceId, 'locale': ''});
    } catch (e, st) {
      AppLogger.error('FlutterTtsService.setVoice', e, st);
    }
  }

  @override
  Future<void> setRate(double rate) async {
    try {
      await _tts.setSpeechRate(rate.clamp(0.1, 1.0));
    } catch (e, st) {
      AppLogger.error('FlutterTtsService.setRate', e, st);
    }
  }

  @override
  Future<void> setPitch(double pitch) async {
    try {
      await _tts.setPitch(pitch.clamp(0.5, 2.0));
    } catch (e, st) {
      AppLogger.error('FlutterTtsService.setPitch', e, st);
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    try {
      await _tts.setVolume(volume.clamp(0.0, 1.0));
    } catch (e, st) {
      AppLogger.error('FlutterTtsService.setVolume', e, st);
    }
  }

  @override
  Stream<bool> get isSpeakingStream => _speakingController.stream;

  @override
  void dispose() {
    _speakingController.close();
  }

  String _toBcp47(String localeCode) {
    switch (localeCode) {
      case 'ne':
        return 'ne-NP';
      case 'en':
      default:
        return 'en-US';
    }
  }
}
