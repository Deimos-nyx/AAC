import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/tts_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profiles/presentation/profile_provider.dart';
import '../../../vocabulary/data/vocabulary_repository.dart';
import '../../../vocabulary/domain/button_model.dart';
import '../word_prediction_service.dart';

/// Keyboard-based communication for literate users (spec section 5): type,
/// see live word/sentence suggestions drawn from the user's own vocabulary,
/// then Speak / Delete / Clear / Repeat exactly like the symbol board does.
class TextModeScreen extends StatefulWidget {
  const TextModeScreen({super.key});

  @override
  State<TextModeScreen> createState() => _TextModeScreenState();
}

class _TextModeScreenState extends State<TextModeScreen> {
  final _controller = TextEditingController();
  final _predictor = WordPredictionService();
  final _repository = VocabularyRepository();

  List<ButtonModel> _vocabulary = [];
  List<String> _suggestions = [];
  String? _lastSpoken;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _loadVocabulary();
  }

  Future<void> _loadVocabulary() async {
    final profile = context.read<ProfileProvider>().activeProfile;
    if (profile == null) return;
    final result = await _repository.getAllButtons(profile.id);
    if (!mounted) return;
    setState(() {
      _vocabulary = result.valueOrNull ?? [];
      _suggestions = _predictor.predictNextWords(
        typedSoFar: _controller.text,
        vocabulary: _vocabulary,
      );
    });
  }

  void _onTextChanged() {
    setState(() {
      _suggestions = _predictor.predictNextWords(
        typedSoFar: _controller.text,
        vocabulary: _vocabulary,
      );
    });
  }

  void _applySuggestion(String word) {
    final text = _controller.text;
    final endsWithSpace = text.isEmpty || text.endsWith(' ');
    String newText;
    if (endsWithSpace) {
      newText = '$text$word ';
    } else {
      final lastSpaceIndex = text.lastIndexOf(' ');
      final prefix =
          lastSpaceIndex == -1 ? '' : text.substring(0, lastSpaceIndex + 1);
      newText = '$prefix$word ';
    }
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  Future<void> _speak() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final profile = context.read<ProfileProvider>().activeProfile;
    await context.read<TtsProvider>().speak(
          text,
          localeCode: profile?.localeCode,
        );
    _lastSpoken = text;
  }

  Future<void> _repeat() async {
    final text = _lastSpoken ?? _controller.text.trim();
    if (text.isEmpty) return;
    final profile = context.read<ProfileProvider>().activeProfile;
    await context.read<TtsProvider>().speak(
          text,
          localeCode: profile?.localeCode,
        );
  }

  void _delete() {
    final text = _controller.text;
    if (text.isEmpty) return;
    final trimmed =
        text.endsWith(' ') ? text.substring(0, text.length - 1) : text;
    final lastSpaceIndex = trimmed.lastIndexOf(' ');
    final newText =
        lastSpaceIndex == -1 ? '' : trimmed.substring(0, lastSpaceIndex + 1);
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  void _clear() {
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSpeaking = context.watch<TtsProvider>().isSpeaking;
    final profile = context.watch<ProfileProvider>().activeProfile;
    final highContrast = profile?.highContrast ?? false;

    return Scaffold(
      backgroundColor: highContrast ? Colors.black : AppColors.background,
      appBar: AppBar(title: Text(context.t('textMode'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controller,
                autofocus: true,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(fontSize: 18 * (profile?.fontScale ?? 1.0)),
                decoration: InputDecoration(
                  hintText: context.t('typeMessage'),
                  filled: true,
                  fillColor: highContrast ? Colors.black : AppColors.surface,
                ),
              ),
              const SizedBox(height: 12),
              if (_suggestions.isNotEmpty)
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _suggestions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final word = _suggestions[index];
                      return ActionChip(
                        label: Text(word),
                        onPressed: () => _applySuggestion(word),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isSpeaking
                          ? () => context.read<TtsProvider>().stop()
                          : _speak,
                      icon: Icon(
                        isSpeaking
                            ? Icons.stop_circle_outlined
                            : Icons.volume_up_rounded,
                      ),
                      label: Text(context.t(isSpeaking ? 'stop' : 'speak')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _delete,
                      icon: const Icon(Icons.backspace_outlined),
                      label: Text(context.t('delete')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _repeat,
                      icon: const Icon(Icons.replay_rounded),
                      label: Text(context.t('repeat')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _clear,
                      icon: const Icon(Icons.clear_all_rounded),
                      label: Text(context.t('clear')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
