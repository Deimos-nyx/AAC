/// A single voice option exposed by the underlying speech engine.
class TtsVoice {
  final String id;
  final String displayName;
  final String localeCode;

  const TtsVoice({required this.id, required this.displayName, required this.localeCode});
}

/// Speech-output contract. The app talks to this interface everywhere
/// (board, text mode, settings preview) instead of a concrete TTS package,
/// so a different engine — a neural voice service, a recorded-voice bank
/// for personalized voices, etc. — can be dropped in later by implementing
/// this class, per spec section 6 ("structure the TTS layer so another
/// speech engine can be added later").
abstract class TtsService {
  Future<void> initialize();

  Future<void> speak(String text, {String? localeCode});

  Future<void> stop();

  Future<List<TtsVoice>> getAvailableVoices(String localeCode);

  Future<void> setVoice(String voiceId);

  Future<void> setRate(double rate); // 0.0 - 1.0

  Future<void> setPitch(double pitch); // 0.5 - 2.0

  Future<void> setVolume(double volume); // 0.0 - 1.0

  /// True while actively speaking, exposed so the board UI can show a
  /// visual "speaking" state and swap Speak <-> Stop affordances.
  Stream<bool> get isSpeakingStream;

  void dispose();
}
