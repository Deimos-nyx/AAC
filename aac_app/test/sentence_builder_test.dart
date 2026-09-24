import 'package:flutter_test/flutter_test.dart';

import 'package:voicepath/features/board/presentation/sentence_provider.dart';
import 'package:voicepath/features/vocabulary/domain/button_model.dart';

ButtonModel _button(String label, {String? spoken}) {
  final now = DateTime.now();
  return ButtonModel(
    id: label,
    profileId: 'p1',
    label: label,
    spokenPhrase: spoken,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('SentenceProvider', () {
    test('starts empty', () {
      final sentence = SentenceProvider();
      expect(sentence.isEmpty, isTrue);
      expect(sentence.sentenceText, '');
      expect(sentence.lastSpokenText, isNull);
    });

    test('building "I want water" joins words with spaces, in tap order', () {
      final sentence = SentenceProvider();
      sentence.addButton(_button('I'));
      sentence.addButton(_button('want'));
      sentence.addButton(_button('water'));

      expect(sentence.items.map((b) => b.label).toList(), ['I', 'want', 'water']);
      expect(sentence.sentenceText, 'I want water');
    });

    test('a button with a spoken-phrase override speaks that instead of its label', () {
      final sentence = SentenceProvider();
      sentence.addButton(_button('H2O', spoken: 'water'));
      expect(sentence.sentenceText, 'water');
    });

    test('delete removes only the most recently added word', () {
      final sentence = SentenceProvider();
      sentence.addButton(_button('I'));
      sentence.addButton(_button('want'));
      sentence.removeLast();
      expect(sentence.sentenceText, 'I');
    });

    test('delete on an empty sentence is a no-op, not an error', () {
      final sentence = SentenceProvider();
      expect(() => sentence.removeLast(), returnsNormally);
      expect(sentence.isEmpty, isTrue);
    });

    test('clear empties the sentence but keeps the last spoken text for Repeat', () {
      final sentence = SentenceProvider();
      sentence.addButton(_button('help'));
      sentence.markSpoken(sentence.sentenceText);
      sentence.clear();

      expect(sentence.isEmpty, isTrue);
      expect(sentence.lastSpokenText, 'help');
    });

    test('notifies listeners on every mutation', () {
      final sentence = SentenceProvider();
      var notifications = 0;
      sentence.addListener(() => notifications++);

      sentence.addButton(_button('go'));
      sentence.removeLast();
      sentence.addButton(_button('stop'));
      sentence.clear();

      expect(notifications, 4);
    });
  });
}
