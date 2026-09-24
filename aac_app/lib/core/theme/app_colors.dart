import 'package:flutter/material.dart';

/// VoicePath's original color system. Chosen for calm, low-clutter
/// legibility rather than decoration — AAC users scan this UI constantly.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF2F6F6D); // deep teal
  static const Color primaryLight = Color(0xFF5FA19E);
  static const Color secondary = Color(0xFFE8A33D); // warm amber accent

  // Neutrals
  static const Color background = Color(0xFFF7F7F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFDADAD6);
  static const Color textPrimary = Color(0xFF20242A);
  static const Color textSecondary = Color(0xFF565C63);

  // Semantic
  static const Color success = Color(0xFF3C8B5C);
  static const Color danger = Color(0xFFC44536);
  static const Color warning = Color(0xFFE8A33D);

  // Category color-coding (Fitzgerald-key inspired, but original hues):
  // helps users predict where a word lives on the board.
  static const Color catCore = Color(0xFFFFFFFF);
  static const Color catPeople = Color(0xFFFCE7B0);
  static const Color catVerbs = Color(0xFFB9DFC4);
  static const Color catDescriptors = Color(0xFFBFD9F2);
  static const Color catFood = Color(0xFFF6C6C0);
  static const Color catPlaces = Color(0xFFD9C7EC);
  static const Color catSocial = Color(0xFFFFD9A8);
  static const Color catFeelings = Color(0xFFF3B8CE);
  static const Color catQuestions = Color(0xFFC9E4DE);
  static const Color catMisc = Color(0xFFE3E3DD);

  // High-contrast theme overrides
  static const Color hcBackground = Color(0xFF000000);
  static const Color hcSurface = Color(0xFF000000);
  static const Color hcBorder = Color(0xFFFFFFFF);
  static const Color hcText = Color(0xFFFFFFFF);
  static const Color hcPrimary = Color(0xFFFFD400);
}
