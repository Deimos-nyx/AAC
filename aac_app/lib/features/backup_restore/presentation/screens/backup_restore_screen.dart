import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../profiles/presentation/profile_provider.dart';

/// Export/import a profile's vocabulary + settings as a single portable
/// file (spec section 11). Export never touches the network — the file is
/// handed to the OS share sheet so the caregiver decides where it goes
/// (device storage, email, cloud drive, ...).
class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  final _backupService = BackupService();
  bool _isBusy = false;
  String? _statusKey;

  Future<void> _export() async {
    final profileId = context.read<ProfileProvider>().activeProfile?.id;
    if (profileId == null) return;
    setState(() {
      _isBusy = true;
      _statusKey = null;
    });
    final result = await _backupService.exportProfile(profileId);
    if (!mounted) return;
    setState(() => _isBusy = false);
    if (result.isOk) {
      setState(() => _statusKey = 'backupSuccess');
      await Share.shareXFiles([XFile(result.valueOrNull!)]);
    } else {
      setState(() => _statusKey = result.errorOrNull);
    }
  }

  Future<void> _import() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['vpbackup', 'zip'],
    );
    final path = picked?.files.single.path;
    if (path == null) return;
    if (!mounted) return;

    final confirmed = await showConfirmDialog(
      context,
      titleKey: 'importBackup',
      messageKey: 'restoreConfirm',
      isDestructive: false,
      confirmLabelKey: 'ok',
    );
    if (!confirmed) return;

    setState(() {
      _isBusy = true;
      _statusKey = null;
    });
    final result = await _backupService.importBackup(path);
    if (!mounted) return;
    setState(() => _isBusy = false);

    if (result.isOk) {
      setState(() => _statusKey = 'restoreSuccess');
      final profileProvider = context.read<ProfileProvider>();
      await profileProvider.loadProfiles();
      await profileProvider.selectProfile(result.valueOrNull!);
      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
      }
    } else {
      setState(() => _statusKey = result.errorOrNull);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t('backupRestore'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(context.t('exportBackup'), style: AppTextStyles.sectionTitle),
          const SizedBox(height: 8),
          Text(context.t('exportDataDescription'),
              style: AppTextStyles.caption),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _isBusy ? null : _export,
            icon: const Icon(Icons.ios_share_rounded),
            label: Text(context.t('exportBackup')),
          ),
          const Divider(height: 40),
          Text(context.t('importBackup'), style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _isBusy ? null : _import,
            icon: const Icon(Icons.file_open_outlined),
            label: Text(context.t('importBackup')),
          ),
          if (_isBusy) ...[
            const SizedBox(height: 20),
            const Center(child: CircularProgressIndicator()),
          ],
          if (_statusKey != null) ...[
            const SizedBox(height: 20),
            Text(context.t(_statusKey!), textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}
