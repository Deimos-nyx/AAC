import 'package:flutter_test/flutter_test.dart';

import 'package:voicepath/core/services/pin_service.dart';
import 'package:voicepath/core/services/secure_storage_service.dart';

void main() {
  late PinService pinService;
  const profileId = 'profile-1';

  setUp(() {
    // A fresh in-memory store per test — see SecureStorageService.inMemoryForTesting.
    pinService = PinService(secureStorage: SecureStorageService.inMemoryForTesting());
  });

  group('PinService', () {
    test('hasPinSet is false before any PIN is set', () async {
      expect(await pinService.hasPinSet(profileId), isFalse);
    });

    test('rejects a PIN shorter than the minimum length', () async {
      final result = await pinService.setPin(profileId, '12');
      expect(result.isError, isTrue);
      expect(result.errorOrNull, 'pinTooShort');
      expect(await pinService.hasPinSet(profileId), isFalse);
    });

    test('setPin then verifyPin with the correct PIN succeeds', () async {
      final setResult = await pinService.setPin(profileId, '4242');
      expect(setResult.isOk, isTrue);

      final verifyResult = await pinService.verifyPin(profileId, '4242');
      expect(verifyResult.valueOrNull, isTrue);
    });

    test('verifyPin with the wrong PIN fails without revealing why', () async {
      await pinService.setPin(profileId, '4242');
      final verifyResult = await pinService.verifyPin(profileId, '0000');
      expect(verifyResult.valueOrNull, isFalse);
    });

    test('verifyPin before any PIN exists returns false, not an error', () async {
      final verifyResult = await pinService.verifyPin(profileId, '4242');
      expect(verifyResult.isOk, isTrue);
      expect(verifyResult.valueOrNull, isFalse);
    });

    test('the raw PIN is never stored — only a salted hash', () async {
      final storage = SecureStorageService.inMemoryForTesting();
      final service = PinService(secureStorage: storage);
      await service.setPin(profileId, '4242');

      final storedHash = await storage.read('pin_hash_$profileId');
      final storedSalt = await storage.read('pin_salt_$profileId');
      expect(storedHash, isNotNull);
      expect(storedSalt, isNotNull);
      expect(storedHash, isNot('4242'));
      expect(storedHash!.contains('4242'), isFalse);
    });

    test('two profiles can have independent, non-interfering PINs', () async {
      await pinService.setPin('profile-a', '1111');
      await pinService.setPin('profile-b', '2222');

      expect((await pinService.verifyPin('profile-a', '1111')).valueOrNull, isTrue);
      expect((await pinService.verifyPin('profile-a', '2222')).valueOrNull, isFalse);
      expect((await pinService.verifyPin('profile-b', '2222')).valueOrNull, isTrue);
    });

    test('clearPin removes the PIN so hasPinSet becomes false again', () async {
      await pinService.setPin(profileId, '4242');
      expect(await pinService.hasPinSet(profileId), isTrue);

      await pinService.clearPin(profileId);
      expect(await pinService.hasPinSet(profileId), isFalse);
      expect((await pinService.verifyPin(profileId, '4242')).valueOrNull, isFalse);
    });

    test('setting a new PIN replaces the old one', () async {
      await pinService.setPin(profileId, '1111');
      await pinService.setPin(profileId, '9999');

      expect((await pinService.verifyPin(profileId, '1111')).valueOrNull, isFalse);
      expect((await pinService.verifyPin(profileId, '9999')).valueOrNull, isTrue);
    });
  });
}
