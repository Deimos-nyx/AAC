import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';

import '../constants/app_constants.dart';
import '../utils/result.dart';
import 'logger_service.dart';
import 'secure_storage_service.dart';

/// Handles caregiver-lock authentication (spec section 8): a PIN is always
/// available, biometrics are offered as a faster unlock on devices that
/// support them. The PIN itself is never stored — only a salted SHA-256
/// hash, in the platform secure storage (Keychain/Keystore).
class PinService {
  final SecureStorageService _secureStorage;
  final LocalAuthentication _localAuth;

  PinService({
    SecureStorageService? secureStorage,
    LocalAuthentication? localAuth,
  })  : _secureStorage = secureStorage ?? SecureStorageService(),
        _localAuth = localAuth ?? LocalAuthentication();

  String _pinKey(String profileId) => 'pin_hash_$profileId';
  String _saltKey(String profileId) => 'pin_salt_$profileId';

  Future<bool> hasPinSet(String profileId) async {
    final hash = await _secureStorage.read(_pinKey(profileId));
    return hash != null;
  }

  Future<Result<void>> setPin(String profileId, String pin) async {
    if (pin.length < AppConstants.pinMinLength || pin.length > AppConstants.pinMaxLength) {
      return const Result.error('pinTooShort');
    }
    try {
      final salt = _generateSalt();
      final hash = _hash(pin, salt);
      await _secureStorage.write(_saltKey(profileId), salt);
      await _secureStorage.write(_pinKey(profileId), hash);
      return const Result.ok(null);
    } catch (e, st) {
      AppLogger.error('PinService.setPin', e, st);
      return const Result.error('somethingWentWrong');
    }
  }

  Future<Result<bool>> verifyPin(String profileId, String pin) async {
    try {
      final storedHash = await _secureStorage.read(_pinKey(profileId));
      final salt = await _secureStorage.read(_saltKey(profileId));
      if (storedHash == null || salt == null) return const Result.ok(false);
      final candidate = _hash(pin, salt);
      return Result.ok(candidate == storedHash);
    } catch (e, st) {
      AppLogger.error('PinService.verifyPin', e, st);
      return const Result.error('somethingWentWrong');
    }
  }

  Future<Result<void>> clearPin(String profileId) async {
    try {
      await _secureStorage.delete(_pinKey(profileId));
      await _secureStorage.delete(_saltKey(profileId));
      return const Result.ok(null);
    } catch (e, st) {
      AppLogger.error('PinService.clearPin', e, st);
      return const Result.error('somethingWentWrong');
    }
  }

  Future<bool> isBiometricAvailable() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      return supported && canCheck;
    } catch (e, st) {
      AppLogger.error('PinService.isBiometricAvailable', e, st);
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics(String reason) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
    } catch (e, st) {
      AppLogger.error('PinService.authenticateWithBiometrics', e, st);
      return false;
    }
  }

  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  String _hash(String pin, String salt) {
    final bytes = utf8.encode('$salt::$pin');
    return sha256.convert(bytes).toString();
  }
}
