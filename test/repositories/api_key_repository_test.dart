import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:stork_hub/repositories/api_key_repository.dart';

void main() {
  late ApiKeyRepository repository;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp();
    repository = ApiKeyRepository(directory: tempDir.path);
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  group('ApiKeyRepository', () {
    const testApiKey = 'test-api-key-12345';
    const testPassword = 'test-password';

    test('saves and retrieves API key successfully', () async {
      await repository.saveApiKey(
        apiKey: testApiKey,
        password: testPassword,
      );

      final retrievedKey = await repository.getApiKey(
        password: testPassword,
      );

      expect(retrievedKey, equals(testApiKey));
    });

    test('returns null when retrieving with wrong password', () async {
      await repository.saveApiKey(
        apiKey: testApiKey,
        password: testPassword,
      );

      final retrievedKey = await repository.getApiKey(
        password: 'wrong-password',
      );

      expect(retrievedKey, isNull);
    });

    test('returns null when no API key is saved', () async {
      final retrievedKey = await repository.getApiKey(
        password: testPassword,
      );

      expect(retrievedKey, isNull);
    });

    test('hasApiKey returns correct state', () async {
      expect(await repository.hasApiKey(), isFalse);

      await repository.saveApiKey(
        apiKey: testApiKey,
        password: testPassword,
      );

      expect(await repository.hasApiKey(), isTrue);
    });

    test('deleteApiKey removes the saved key', () async {
      await repository.saveApiKey(
        apiKey: testApiKey,
        password: testPassword,
      );

      expect(await repository.hasApiKey(), isTrue);

      await repository.deleteApiKey();

      expect(await repository.hasApiKey(), isFalse);

      final retrievedKey = await repository.getApiKey(
        password: testPassword,
      );
      expect(retrievedKey, isNull);
    });

    test('saving new API key overwrites the old one', () async {
      const newApiKey = 'new-api-key-67890';

      await repository.saveApiKey(
        apiKey: testApiKey,
        password: testPassword,
      );

      await repository.saveApiKey(
        apiKey: newApiKey,
        password: testPassword,
      );

      final retrievedKey = await repository.getApiKey(
        password: testPassword,
      );

      expect(retrievedKey, equals(newApiKey));
    });
  });
}
