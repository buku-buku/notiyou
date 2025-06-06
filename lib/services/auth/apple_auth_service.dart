import 'package:notiyou/services/dotenv_service.dart';
import 'package:notiyou/services/supabase_service.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:jose/jose.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class AppleAuthService {
  static Future<void> unregister() async {
    final rawNonce = SupabaseService.client.auth.generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );
    final authorizationCode = credential.authorizationCode;

    await _revokeToken(authorizationCode);
  }

  static Future<String> _generateJWT() async {
    final builder = JsonWebSignatureBuilder();
    builder.jsonContent = {
      'iss': DotEnvService.getValue('APPLE_TEAM_ID'),
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().add(const Duration(days: 180)))
              .millisecondsSinceEpoch ~/
          1000,
      'aud': 'https://appleid.apple.com',
      'sub': DotEnvService.getValue('APPLE_BUNDLE_IDENTIFIER')
    };

    final key = JsonWebKey.fromPem(DotEnvService.getValue('APPLE_PRIVATE_KEY'));
    builder.addRecipient(key, algorithm: 'ES256');

    final token = builder.build().toCompactSerialization();
    return token;
  }

  static Future<String> _getAccessToken(
      String authorizationCode, String clientSecretJWT) async {
    final response = await http.post(
      Uri.parse('https://appleid.apple.com/auth/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'client_id': DotEnvService.getValue('APPLE_BUNDLE_IDENTIFIER'),
        'client_secret': clientSecretJWT,
        'code': authorizationCode,
        'grant_type': 'authorization_code',
      },
    );

    return jsonDecode(response.body)['access_token'];
  }

  static Future<void> _revokeToken(String authorizationCode) async {
    final clientSecretJWT = await _generateJWT();
    final accessToken =
        await _getAccessToken(authorizationCode, clientSecretJWT);

    final response = await http.post(
      Uri.parse('https://appleid.apple.com/auth/revoke'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'client_id': DotEnvService.getValue('APPLE_BUNDLE_IDENTIFIER'),
        'client_secret': clientSecretJWT,
        'token': accessToken,
        'token_type_hint': 'access_token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)["error"]);
    }
  }
}
