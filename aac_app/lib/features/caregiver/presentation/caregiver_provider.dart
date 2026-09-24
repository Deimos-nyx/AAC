import 'package:flutter/foundation.dart';

/// Tracks whether caregiver mode is unlocked *for this app session*. The
/// actual PIN/biometric check lives in [PinService] — this class only
/// remembers the outcome so screens don't have to re-authenticate on every
/// navigation within caregiver mode, while still re-locking whenever the
/// app restarts or the caregiver explicitly exits.
class CaregiverProvider extends ChangeNotifier {
  bool _isUnlocked = false;

  bool get isUnlocked => _isUnlocked;

  void unlock() {
    if (_isUnlocked) return;
    _isUnlocked = true;
    notifyListeners();
  }

  void lock() {
    if (!_isUnlocked) return;
    _isUnlocked = false;
    notifyListeners();
  }
}
