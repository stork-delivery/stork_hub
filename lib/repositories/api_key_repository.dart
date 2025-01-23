import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A repository that handles API key storage and retrieval
class ApiKeyRepository {
  ApiKeyRepository();

  static const _iterations = 1000;
  static const _keyLength = 32; // 256 bits
  static const _ivLength = 16; // 128 bits
  static const _salt = 'stork_hub_salt'; // Fixed salt for simplicity
  static const _storageKey = 'encrypted_api_key';

  Uint8List _deriveKey(String password) {
    final params = Pbkdf2Parameters(
      utf8.encode(_salt),
      _iterations,
      _keyLength,
    );

    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))..init(params);
    return pbkdf2.process(utf8.encode(password));
  }

  /// Saves an API key with encryption using the provided password
  Future<void> saveApiKey({
    required String apiKey,
    required String password,
  }) async {
    final derivedKey = _deriveKey(password);
    final key = Key(derivedKey);
    final iv = IV.fromSecureRandom(_ivLength);
    final encrypter = Encrypter(AES(key));

    final encrypted = encrypter.encrypt(apiKey, iv: iv);

    // Store both the IV and encrypted data
    final dataToStore = {
      'iv': iv.bytes,
      'encrypted': encrypted.bytes,
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(dataToStore));
  }

  /// Retrieves a previously saved API key using the provided password
  Future<String?> getApiKey({
    required String password,
  }) async {
    if (!await hasApiKey()) {
      return null;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final content = prefs.getString(_storageKey);
      if (content == null) return null;
      
      final data = jsonDecode(content) as Map<String, dynamic>;

      final derivedKey = _deriveKey(password);
      final key = Key(derivedKey);
      final iv = IV(Uint8List.fromList(List<int>.from(data['iv'] as List)));
      final encrypter = Encrypter(AES(key));

      final encrypted = Encrypted(
        Uint8List.fromList(List<int>.from(data['encrypted'] as List)),
      );

      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      // If decryption fails (wrong password) or data is corrupted
      return null;
    }
  }

  /// Checks if an API key exists
  Future<bool> hasApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_storageKey);
  }

  /// Deletes the saved API key if it exists
  Future<void> deleteApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
