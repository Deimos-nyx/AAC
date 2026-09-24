import 'package:flutter/foundation.dart';

import '../../vocabulary/domain/button_model.dart';

/// Holds the in-progress sentence a user is building by tapping buttons
/// (spec section 1: "I → want → water"). Deliberately in-memory only and
/// reset per app session — an AAC sentence bar is a scratch pad, not
/// something that should reappear from yesterday when the app reopens.
class SentenceProvider extends ChangeNotifier {
  final List<ButtonModel> _items = [];
  String? _lastSpokenText;

  List<ButtonModel> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  /// What TTS should say if "Speak" is pressed right now.
  String get sentenceText => _items.map((b) => b.speechText).join(' ');

  /// What "Repeat" should say — the last thing actually spoken, so Repeat
  /// still works after the user has already cleared or kept building.
  String? get lastSpokenText => _lastSpokenText;

  void addButton(ButtonModel button) {
    _items.add(button);
    notifyListeners();
  }

  void removeLast() {
    if (_items.isEmpty) return;
    _items.removeLast();
    notifyListeners();
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }

  /// Called right after a successful speak so Repeat has something to say.
  void markSpoken(String text) {
    _lastSpokenText = text;
  }
}
