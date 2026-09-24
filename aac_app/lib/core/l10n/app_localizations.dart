import 'package:flutter/material.dart';

import 'translations/en.dart';
import 'translations/ne.dart';

/// Simple, explicit localization layer.
///
/// We deliberately avoid the `flutter gen-l10n` codegen pipeline: this keeps
/// every UI string in a single reviewable Dart map per language (easy for a
/// translator/SLP to edit) and keeps the build free of a generation step.
/// Adding a language means: add a `translations/xx.dart` map with the same
/// keys, then register it in [_allTranslations] and [AppConstants]/
/// [supportedLocales] below — no other code changes required.
class AppLocalizations {
  final Locale locale;
  final Map<String, String> _strings;

  AppLocalizations(this.locale) : _strings = _allTranslations[locale.languageCode] ?? enStrings;

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ne'),
  ];

  static final Map<String, Map<String, String>> _allTranslations = {
    'en': enStrings,
    'ne': neStrings,
  };

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(localizations != null, 'AppLocalizations not found in context');
    return localizations!;
  }

  /// Looks up [key]. Falls back to the English string, then to the key
  /// itself, so a missing translation never crashes the app or shows a raw
  /// null — it just silently degrades to English, which is safer for AAC
  /// users than an error screen.
  String t(String key) {
    return _strings[key] ?? enStrings[key] ?? key;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Convenience extension so call sites can write `context.t('save')`.
extension LocalizationContext on BuildContext {
  String t(String key) => AppLocalizations.of(this).t(key);
}
