import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

/// Shown wherever a repository/service call fails. Per spec section 17,
/// the user only ever sees a calm, plain-language message and a retry
/// affordance — never a stack trace, exception type, or raw error string.
class AppErrorView extends StatelessWidget {
  final String messageKey;
  final VoidCallback? onRetry;

  const AppErrorView({
    super.key,
    this.messageKey = 'somethingWentWrong',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 40,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              context.t(messageKey),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onRetry,
                child: Text(context.t('retry')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Inline banner variant for use above content that otherwise loaded fine
/// (e.g. "couldn't save that change") without replacing the whole screen.
class AppErrorBanner extends StatelessWidget {
  final String messageKey;
  final VoidCallback? onDismiss;

  const AppErrorBanner({
    super.key,
    this.messageKey = 'somethingWentWrong',
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.danger.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.danger,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.t(messageKey),
                style: const TextStyle(color: AppColors.danger),
              ),
            ),
            if (onDismiss != null)
              IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.danger,
                ),
                onPressed: onDismiss,
                tooltip: context.t('ok'),
              ),
          ],
        ),
      ),
    );
  }
}
