import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A profile's avatar: the caregiver-picked photo if one exists, otherwise
/// a calm initials circle. Never blocks on a missing/corrupted file (spec
/// section 17) — falls back to initials instead of a broken-image icon.
class ProfileAvatar extends StatelessWidget {
  final String name;
  final String? avatarPath;
  final double size;

  const ProfileAvatar({
    super.key,
    required this.name,
    this.avatarPath,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    final path = avatarPath;
    if (path != null && File(path).existsSync()) {
      return ClipOval(
        child: Image.file(
          File(path),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _initials(),
        ),
      );
    }
    return _initials();
  }

  Widget _initials() {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
