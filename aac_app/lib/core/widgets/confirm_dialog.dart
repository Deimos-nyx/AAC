import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Standard yes/no confirmation used before destructive actions (delete
/// profile, delete button, delete all data, ...). Centralized so every
/// destructive action in the app looks and behaves the same way.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String titleKey,
  required String messageKey,
  String? confirmLabelKey,
  bool isDestructive = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(dialogContext.t(titleKey)),
        content: Text(dialogContext.t(messageKey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: isDestructive
                ? TextButton.styleFrom(foregroundColor: Theme.of(dialogContext).colorScheme.error)
                : null,
            child: Text(dialogContext.t(confirmLabelKey ?? 'delete')),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
