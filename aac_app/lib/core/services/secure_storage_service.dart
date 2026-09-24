import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper around `flutter_secure_storage` (iOS Keychain / Android
/// Keystore-backed EncryptedSharedPreferences). This is the ONLY place PIN
/// hashes or other sensitive values are written — never in the plain
/// sqflite database, and never logged (see logger_service.dart, which never
/// receives raw values, only messages).
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// Non-null only in [SecureStorageService.inMemoryForTesting]. Real builds
  /// always go through the platform Keychain/Keystore above — this exists
  /// purely so PinService's logic can be unit-tested without a device,
  /// since `flutter_secure_storage`'s platform channel isn't available
  /// under plain `flutter test`.
  final Map<String, String>? _testOverrideStore;

  SecureStorageService() : _testOverrideStore = null;

  @visibleForTesting
  SecureStorageService.inMemoryForTesting() : _testOverrideStore = <String, String>{};

  Future<void> write(String key, String value) async {
    final overrideStore = _testOverrideStore;
    if (overrideStore != null) {
      overrideStore[key] = value;
      return;
    }
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    final overrideStore = _testOverrideStore;
    if (overrideStore != null) return overrideStore[key];
    return _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    final overrideStore = _testOverrideStore;
    if (overrideStore != null) {
      overrideStore.remove(key);
      return;
    }
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    final overrideStore = _testOverrideStore;
    if (overrideStore != null) {
      overrideStore.clear();
      return;
    }
    await _storage.deleteAll();
  }
}
