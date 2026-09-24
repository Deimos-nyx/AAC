import '../../vocabulary/domain/button_model.dart';

/// Rule-based prediction for text mode (spec section 5).
///
/// This is intentionally a small heuristic, not a trained language model:
/// it completes the word being typed against the user's own vocabulary, and
/// suggests a next word using a short hand-built list of common AAC
/// sentence starters. That's an honest, working feature at the scope this
/// app needs — swapping in a real n-gram/ML predictor later only requires
/// replacing this one class, since [TextModeScreen] only calls
/// [predictNextWords].
class WordPredictionService {
  static const List<String> _commonWords = [
    'the', 'a', 'is', 'to', 'and', 'my', 'your', 'it', 'please', 'yes', 'no',
    'want', 'like', 'need', 'help', 'more', 'go', 'stop', 'good', 'bad',
  ];

  /// Very short hand-built "what usually comes next" table. Not a trained
  /// model — just enough structure to make sentence-building feel guided
  /// rather than a blank keyboard.
  static const Map<String, List<String>> _followMap = {
    'i': ['want', 'like', "don't", 'need', 'am', 'feel'],
    'you': ['want', 'like', 'are', 'have'],
    'want': ['water', 'more', 'help', 'to', 'food', 'this'],
    'i want': ['water', 'more', 'help', 'to'],
    'more': ['water', 'food', 'please', 'help'],
    'go': ['home', 'outside', 'to', 'school'],
    'i like': ['this', 'that', 'it'],
    "don't": ['like', 'want', 'know'],
    'help': ['me', 'please'],
    'feel': ['happy', 'sad', 'tired', 'sick'],
  };

  List<String> predictNextWords({
    required String typedSoFar,
    required List<ButtonModel> vocabulary,
    int maxResults = 6,
  }) {
    final endsWithSpace = typedSoFar.isEmpty || typedSoFar.endsWith(' ');
    final words =
        typedSoFar.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    if (!endsWithSpace && words.isNotEmpty) {
      return _completeCurrentWord(words.last, vocabulary, maxResults);
    }
    return _predictAfter(words, vocabulary, maxResults);
  }

  List<String> _completeCurrentWord(
    String partial,
    List<ButtonModel> vocabulary,
    int maxResults,
  ) {
    final prefix = partial.toLowerCase();
    final candidates = <String>[];

    for (final button in vocabulary) {
      final label = button.label.toLowerCase();
      if (label.startsWith(prefix) && !candidates.contains(button.label)) {
        candidates.add(button.label);
      }
      if (candidates.length >= maxResults) return candidates;
    }
    for (final word in _commonWords) {
      if (word.startsWith(prefix) && !candidates.any((c) => c.toLowerCase() == word)) {
        candidates.add(word);
      }
      if (candidates.length >= maxResults) break;
    }
    return candidates;
  }

  List<String> _predictAfter(
    List<String> words,
    List<ButtonModel> vocabulary,
    int maxResults,
  ) {
    final suggestions = <String>[];
    if (words.isEmpty) {
      // Nothing typed yet: offer the profile's own core words first.
      for (final button in vocabulary.where((b) => b.isCore)) {
        if (!suggestions.contains(button.label)) suggestions.add(button.label);
        if (suggestions.length >= maxResults) return suggestions;
      }
      return suggestions;
    }

    final lastWord = words.last.toLowerCase();
    final lastTwo = words.length >= 2
        ? '${words[words.length - 2]} ${words.last}'.toLowerCase()
        : '';

    if (_followMap.containsKey(lastTwo)) {
      suggestions.addAll(_followMap[lastTwo]!);
    }
    if (_followMap.containsKey(lastWord)) {
      for (final w in _followMap[lastWord]!) {
        if (!suggestions.contains(w)) suggestions.add(w);
      }
    }
    if (suggestions.length < maxResults) {
      for (final button in vocabulary.where((b) => b.isCore)) {
        final label = button.label.toLowerCase();
        if (!suggestions.contains(label)) suggestions.add(label);
        if (suggestions.length >= maxResults) break;
      }
    }
    return suggestions.take(maxResults).toList();
  }
}
