import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:voicepath/core/providers/tts_provider.dart';
import 'package:voicepath/core/services/tts_service.dart';
import 'package:voicepath/features/profiles/domain/profile_model.dart';

/// A fake speech engine so this test exercises VoicePath's own logic —
/// "does the right rate/pitch/volume/voice reach the engine, does the
/// speaking-state stream drive isSpeaking" — without needing a real device
/// TTS engine (which isn't available under `flutter test` anyway). This is
/// exactly the seam spec section 6 asked for ("structure the TTS layer so
/// another speech engine can be added later") — a fake is just another
/// implementation of the same interface.
class FakeTtsService implements TtsService {
  final List<String> spoken = [];
  double? lastRate;
  double? lastPitch;
  double? lastVolume;
  String? lastVoiceId;
  bool stopped = false;

  final _speakingController = StreamController<bool>.broadcast();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> speak(String text, {String? localeCode}) async {
    spoken.add(text);
    _speakingController.add(true);
  }

  @override
  Future<void> stop() async {
    stopped = true;
    _speakingController.add(false);
  }

  @override
  Future<List<TtsVoice>> getAvailableVoices(String localeCode) async {
    return [
      TtsVoice(id: 'voice-$localeCode-1', displayName: 'Voice 1', localeCode: localeCode),
      TtsVoice(id: 'voice-$localeCode-2', displayName: 'Voice 2', localeCode: localeCode),
    ];
  }

  @override
  Future<void> setVoice(String voiceId) async => lastVoiceId = voiceId;

  @override
  Future<void> setRate(double rate) async => lastRate = rate;

  @override
  Future<void> setPitch(double pitch) async => lastPitch = pitch;

  @override
  Future<void> setVolume(double volume) async => lastVolume = volume;

  @override
  Stream<bool> get isSpeakingStream => _speakingController.stream;

  @override
  void dispose() => _speakingController.close();
}

ProfileModel _profile({
  String localeCode = 'en',
  double ttsRate = 0.6,
  double ttsPitch = 1.2,
  double ttsVolume = 0.8,
  String? ttsVoiceId,
}) {
  final now = DateTime.now();
  return ProfileModel(
    id: 'p1',
    name: 'Test',
    localeCode: localeCode,
    ttsRate: ttsRate,
    ttsPitch: ttsPitch,
    ttsVolume: ttsVolume,
    ttsVoiceId: ttsVoiceId,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('TtsProvider', () {
    test('applyProfile pushes rate/pitch/volume from the profile into the engine', () async {
      final fake = FakeTtsService();
      final provider = TtsProvider(ttsService: fake);

      await provider.applyProfile(_profile(ttsRate: 0.4, ttsPitch: 1.5, ttsVolume: 0.9));

      expect(fake.lastRate, 0.4);
      expect(fake.lastPitch, 1.5);
      expect(fake.lastVolume, 0.9);
    });

    test('applyProfile only applies a saved voice if it is in the available list', () async {
      final fake = FakeTtsService();
      final provider = TtsProvider(ttsService: fake);

      await provider.applyProfile(_profile(localeCode: 'en', ttsVoiceId: 'voice-en-2'));
      expect(fake.lastVoiceId, 'voice-en-2');

      await provider.applyProfile(_profile(localeCode: 'en', ttsVoiceId: 'nonexistent-voice'));
      // Unrecognized voice id is ignored rather than sent to the engine.
      expect(fake.lastVoiceId, 'voice-en-2');
    });

    test('speak() forwards the exact text (e.g. a built sentence) to the engine', () async {
      final fake = FakeTtsService();
      final provider = TtsProvider(ttsService: fake);

      await provider.speak('I want water');
      expect(fake.spoken, ['I want water']);
    });

    test('speak() with empty/blank text never reaches the engine', () async {
      final fake = FakeTtsService();
      final provider = TtsProvider(ttsService: fake);

      await provider.speak('');
      await provider.speak('   ');
      expect(fake.spoken, isEmpty);
    });

    test('isSpeaking reflects the engine\'s speaking stream', () async {
      final fake = FakeTtsService();
      final provider = TtsProvider(ttsService: fake);

      expect(provider.isSpeaking, isFalse);
      await provider.speak('hello');
      await Future<void>.delayed(Duration.zero);
      expect(provider.isSpeaking, isTrue);

      await provider.stop();
      await Future<void>.delayed(Duration.zero);
      expect(provider.isSpeaking, isFalse);
      expect(fake.stopped, isTrue);
    });

    test('refreshVoicesFor exposes the engine\'s voice list for that language', () async {
      final fake = FakeTtsService();
      final provider = TtsProvider(ttsService: fake);

      await provider.refreshVoicesFor('ne');
      expect(provider.availableVoices.map((v) => v.id), ['voice-ne-1', 'voice-ne-2']);
    });
  });
}
