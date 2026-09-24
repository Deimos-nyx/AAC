import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/pin_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../profiles/presentation/profile_provider.dart';
import '../caregiver_provider.dart';

/// Gate in front of every caregiver-only action (spec section 8). Shows a
/// PIN *set-up* flow the first time a profile locks editing, and a PIN
/// *entry* flow (with an optional biometric shortcut) every time after.
class CaregiverLockScreen extends StatefulWidget {
  const CaregiverLockScreen({super.key});

  @override
  State<CaregiverLockScreen> createState() => _CaregiverLockScreenState();
}

class _CaregiverLockScreenState extends State<CaregiverLockScreen> {
  final _pinService = PinService();
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _hasPinSet = true; // optimistic default while loading
  bool _isLoading = true;
  bool _biometricsAvailable = false;
  String? _errorKey;

  String? get _profileId => context.read<ProfileProvider>().activeProfile?.id;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profileId = _profileId;
    if (profileId == null) return;
    final hasPin = await _pinService.hasPinSet(profileId);
    final biometricsAvailable =
        hasPin ? await _pinService.isBiometricAvailable() : false;
    if (!mounted) return;
    setState(() {
      _hasPinSet = hasPin;
      _biometricsAvailable = biometricsAvailable;
      _isLoading = false;
    });
    if (hasPin && biometricsAvailable) {
      _tryBiometrics();
    }
  }

  Future<void> _tryBiometrics() async {
    final success = await _pinService
        .authenticateWithBiometrics(context.t('unlockWithBiometrics'));
    if (success) _unlock();
  }

  void _unlock() {
    context.read<CaregiverProvider>().unlock();
    Navigator.of(context).pushReplacementNamed(AppRoutes.caregiverSettings);
  }

  Future<void> _submitSetup() async {
    final pin = _pinController.text;
    final confirm = _confirmController.text;
    if (pin.length < 4) {
      setState(() => _errorKey = 'pinTooShort');
      return;
    }
    if (pin != confirm) {
      setState(() => _errorKey = 'pinMismatch');
      return;
    }
    final profileId = _profileId;
    if (profileId == null) return;
    final result = await _pinService.setPin(profileId, pin);
    if (result.isError) {
      setState(() => _errorKey = result.errorOrNull);
      return;
    }
    if (!mounted) return;
    await context.read<ProfileProvider>().setEditingLocked(true);
    if (!mounted) return;
    _unlock();
  }

  Future<void> _submitVerify() async {
    final profileId = _profileId;
    if (profileId == null) return;
    final result = await _pinService.verifyPin(profileId, _pinController.text);
    final correct = result.valueOrNull ?? false;
    if (!correct) {
      setState(() => _errorKey = 'pinIncorrect');
      _pinController.clear();
      return;
    }
    _unlock();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar:
          AppBar(title: Text(context.t(_hasPinSet ? 'enterPin' : 'setPin'))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline_rounded,
                    size: 40, color: AppColors.primary),
                const SizedBox(height: 16),
                TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 8,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.screenTitle,
                  decoration: InputDecoration(
                    labelText: context.t(_hasPinSet ? 'enterPin' : 'setPin'),
                    counterText: '',
                  ),
                  onSubmitted: (_) => _hasPinSet ? _submitVerify() : null,
                ),
                if (!_hasPinSet) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirmController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 8,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: context.t('confirmPin'),
                      counterText: '',
                    ),
                  ),
                ],
                if (_errorKey != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    context.t(_errorKey!),
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _hasPinSet ? _submitVerify : _submitSetup,
                    child: Text(context.t('ok')),
                  ),
                ),
                if (_hasPinSet && _biometricsAvailable) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _tryBiometrics,
                    icon: const Icon(Icons.fingerprint),
                    label: Text(context.t('unlockWithBiometrics')),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
