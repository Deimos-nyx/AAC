import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/l10n/app_localizations.dart';
import 'core/providers/tts_provider.dart';
import 'core/routing/app_router.dart';
import 'core/routing/home_shell.dart';
import 'core/theme/app_theme.dart';
import 'features/board/presentation/sentence_provider.dart';
import 'features/caregiver/presentation/caregiver_provider.dart';
import 'features/profiles/domain/profile_model.dart';
import 'features/profiles/presentation/profile_provider.dart';
import 'features/profiles/presentation/screens/profile_selection_screen.dart';
import 'features/vocabulary/presentation/vocabulary_provider.dart';

/// App root: wires every provider once, then hands off to [_AppView] for
/// theming/localization and [RootGate] for the profile-loading splash.
class VoicePathApp extends StatelessWidget {
  const VoicePathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => VocabularyProvider()),
        ChangeNotifierProvider(create: (_) => SentenceProvider()),
        ChangeNotifierProvider(create: (_) => TtsProvider()),
        ChangeNotifierProvider(create: (_) => CaregiverProvider()),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    final activeProfile = context.select<ProfileProvider, ProfileModel?>((p) => p.activeProfile);

    return MaterialApp(
      title: 'VoicePath',
      debugShowCheckedModeBanner: false,
      theme: (activeProfile?.highContrast ?? false) ? AppTheme.highContrast() : AppTheme.standard(),
      locale: activeProfile != null ? Locale(activeProfile.localeCode) : null,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: const RootGate(),
    );
  }
}

/// Loads the profile list on startup and decides whether to show profile
/// selection or drop straight into the last-used profile's board. Also the
/// single place that reacts to an active-profile *change* by loading that
/// profile's vocabulary, pushing its speech settings into the TTS engine,
/// clearing the in-progress sentence, and re-locking caregiver mode — so
/// none of that state can leak from one person's profile into another's.
class RootGate extends StatefulWidget {
  const RootGate({super.key});

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  String? _appliedForProfileId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfiles();
    });
  }

  void _applySideEffectsFor(ProfileModel profile) {
    if (_appliedForProfileId == profile.id) return;
    _appliedForProfileId = profile.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<VocabularyProvider>().loadForProfile(profile.id);
      context.read<TtsProvider>().applyProfile(profile);
      context.read<SentenceProvider>().clear();
      context.read<CaregiverProvider>().lock();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();

    if (profileProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final profile = profileProvider.activeProfile;
    if (profile == null) {
      _appliedForProfileId = null;
      return const ProfileSelectionScreen();
    }

    _applySideEffectsFor(profile);
    return const HomeShell();
  }
}
