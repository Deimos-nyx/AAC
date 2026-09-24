import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/tts_provider.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../caregiver/presentation/caregiver_provider.dart';
import '../../../profiles/domain/profile_model.dart';
import '../../../profiles/presentation/profile_provider.dart';
import '../../../vocabulary/domain/button_model.dart';
import '../../../vocabulary/presentation/vocabulary_provider.dart';
import '../../presentation/sentence_provider.dart';
import '../widgets/aac_button_widget.dart';
import '../widgets/category_tab_bar.dart';
import '../widgets/communication_grid.dart';
import '../widgets/sentence_bar.dart';
import '../../../vocabulary_editor/presentation/screens/button_edit_screen.dart';

/// The core screen (spec section 16): sentence bar + core vocabulary strip
/// + category tabs + fringe vocabulary grid. This is where a user spends
/// nearly all their time, so speed and predictability trump everything
/// else here.
class AacBoardScreen extends StatelessWidget {
  const AacBoardScreen({super.key});

  bool _editingAllowed(BuildContext context) {
    final profile = context.watch<ProfileProvider>().activeProfile;
    if (profile == null) return false;
    if (!profile.editingLocked) return true;
    return context.watch<CaregiverProvider>().isUnlocked;
  }

  Future<void> _handleTap(BuildContext context, ButtonModel button) async {
    final profile = context.read<ProfileProvider>().activeProfile;
    context.read<SentenceProvider>().addButton(button);
    await context.read<TtsProvider>().speak(
          button.speechText,
          localeCode: profile?.localeCode,
        );
  }

  Future<void> _handleLongPress(
    BuildContext context,
    ButtonModel button,
  ) async {
    if (!_editingAllowed(context)) return;
    await Navigator.of(context).pushNamed(
      AppRoutes.buttonEdit,
      arguments: ButtonEditArgs(existing: button),
    );
  }

  Future<void> _speakSentence(BuildContext context) async {
    final sentence = context.read<SentenceProvider>();
    final profile = context.read<ProfileProvider>().activeProfile;
    final text = sentence.sentenceText;
    if (text.trim().isEmpty) return;
    await context.read<TtsProvider>().speak(
          text,
          localeCode: profile?.localeCode,
        );
    sentence.markSpoken(text);
  }

  Future<void> _repeat(BuildContext context) async {
    final sentence = context.read<SentenceProvider>();
    final profile = context.read<ProfileProvider>().activeProfile;
    final text = sentence.lastSpokenText ?? sentence.sentenceText;
    if (text.trim().isEmpty) return;
    await context.read<TtsProvider>().speak(
          text,
          localeCode: profile?.localeCode,
        );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().activeProfile;
    if (profile == null) return const SizedBox.shrink();

    final vocabulary = context.watch<VocabularyProvider>();
    final sentence = context.watch<SentenceProvider>();
    final ttsSpeaking = context.watch<TtsProvider>().isSpeaking;
    final editingAllowed = _editingAllowed(context);

    return Scaffold(
      backgroundColor:
          profile.highContrast ? Colors.black : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            SentenceBar(
              items: sentence.items,
              isSpeaking: ttsSpeaking,
              highContrast: profile.highContrast,
              fontScale: profile.fontScale,
              onSpeak: () => _speakSentence(context),
              onStop: () => context.read<TtsProvider>().stop(),
              onDelete: () => sentence.removeLast(),
              onClear: () => sentence.clear(),
              onRepeat: () => _repeat(context),
            ),
            if (vocabulary.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (vocabulary.lastError != null &&
                !vocabulary.hasAnyVocabulary)
              Expanded(
                child: AppErrorView(
                  onRetry: () => vocabulary.loadForProfile(profile.id),
                ),
              )
            else ...[
              if (vocabulary.coreButtons.isNotEmpty)
                _CoreRow(
                  buttons: vocabulary.coreButtons,
                  profile: profile,
                  editingAllowed: editingAllowed,
                  onTap: (b) => _handleTap(context, b),
                  onLongPress: (b) => _handleLongPress(context, b),
                ),
              CategoryTabBar(
                categories: vocabulary.categories,
                selectedCategoryId: vocabulary.selectedCategoryId,
                highContrast: profile.highContrast,
                onSelected: vocabulary.selectCategory,
              ),
              Expanded(
                child: vocabulary.categoryButtons.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            context.t('noVocabularyYet'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: profile.highContrast
                                  ? AppColors.hcText
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    : CommunicationGrid(
                        buttons: vocabulary.categoryButtons,
                        gridSize: profile.gridSize,
                        buttonSizeScale: profile.buttonSizeScale,
                        spacingScale: profile.buttonSpacingScale,
                        fontScale: profile.fontScale,
                        reducedAnimation: profile.reducedAnimation,
                        highContrast: profile.highContrast,
                        onButtonTap: (b) => _handleTap(context, b),
                        onButtonLongPress: editingAllowed
                            ? (b) => _handleLongPress(context, b)
                            : null,
                      ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: (editingAllowed && !vocabulary.isLoading)
          ? FloatingActionButton(
              tooltip: context.t('addButton'),
              onPressed: () => Navigator.of(context).pushNamed(
                AppRoutes.buttonEdit,
                arguments: ButtonEditArgs(
                  categoryId: vocabulary.selectedCategoryId,
                ),
              ),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

/// The always-visible strip of core vocabulary above the category grid.
class _CoreRow extends StatelessWidget {
  final List<ButtonModel> buttons;
  final ProfileModel profile;
  final bool editingAllowed;
  final void Function(ButtonModel) onTap;
  final void Function(ButtonModel) onLongPress;

  const _CoreRow({
    required this.buttons,
    required this.profile,
    required this.editingAllowed,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: profile.highContrast ? AppColors.hcBorder : AppColors.border,
          ),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        itemCount: buttons.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final button = buttons[index];
          return SizedBox(
            width: 88,
            child: AacButtonWidget(
              key: ValueKey(button.id),
              button: button,
              fontScale: profile.fontScale,
              reducedAnimation: profile.reducedAnimation,
              highContrast: profile.highContrast,
              onTap: () => onTap(button),
              onLongPress: editingAllowed ? () => onLongPress(button) : null,
            ),
          );
        },
      ),
    );
  }
}
