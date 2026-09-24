import 'package:flutter_test/flutter_test.dart';

import 'package:voicepath/features/text_mode/presentation/word_prediction_service.dart';
import 'package:voicepath/features/vocabulary/domain/button_model.dart';

ButtonModel _button(String label, {bool isCore = false}) {
  final now = DateTime.now();
  return ButtonModel(
    id: label,
    profileId: 'p1',
    label: label,
    isCore: isCore,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  final predictor = WordPredictionService();
  final vocabulary = [
    _button('water'),
    _button('want', isCore: true),
    _button('walk'),
    _button('help', isCore: true),
  ];

  group('WordPredictionService', () {
    test('completes a partially-typed word from the user\'s own vocabulary', () {
      final results = predictor.predictNextWords(typedSoFar: 'wa', vocabulary: vocabulary);
      expect(results, containsAll(['water', 'want', 'walk']));
    });

    test('is case-insensitive when completing a word', () {
      final results = predictor.predictNextWords(typedSoFar: 'WA', vocabulary: vocabulary);
      expect(results, isNotEmpty);
    });

    test('suggests a next word once the previous word is finished (trailing space)', () {
      final results = predictor.predictNextWords(typedSoFar: 'I want ', vocabulary: vocabulary);
      expect(results, isNotEmpty);
    });

    test('an empty draft offers the profile\'s own core words first', () {
      final results = predictor.predictNextWords(typedSoFar: '', vocabulary: vocabulary);
      expect(results.first, anyOf('want', 'help'));
    });

    test('never returns more than maxResults suggestions', () {
      final results = predictor.predictNextWords(
        typedSoFar: '',
        vocabulary: vocabulary,
        maxResults: 2,
      );
      expect(results.length, lessThanOrEqualTo(2));
    });
  });
}
