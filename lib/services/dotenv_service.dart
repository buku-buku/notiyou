import 'package:flutter_dotenv/flutter_dotenv.dart';

class DotEnvService {
  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
  }

  static String getValue(String key) {
    if (!dotenv.isInitialized) {
      throw Exception('DotEnv is not initialized');
    }
    final value = dotenv.env[key];
    if (value == null) {
      throw Exception('Key $key not found in .env file');
    }
    return value;
  }
}
