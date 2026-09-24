import 'package:flutter/material.dart';

import '../../features/board/presentation/screens/aac_board_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/text_mode/presentation/screens/text_mode_screen.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

/// Hosts the three top-level destinations (spec section 16: Board, Text
/// mode, Settings — Categories live inside the Board screen itself, and
/// Caregiver settings live inside Settings, both per their own screens'
/// doc comments). An [IndexedStack] keeps each tab's state alive across
/// switches, which matters most for the sentence bar and text-mode draft.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _screens = [
    AacBoardScreen(),
    TextModeScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AppColors.surface,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.grid_view_rounded),
            label: context.t('board'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.keyboard_alt_outlined),
            label: context.t('textMode'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            label: context.t('settings'),
          ),
        ],
      ),
    );
  }
}
