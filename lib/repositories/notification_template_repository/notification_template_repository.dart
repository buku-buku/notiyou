import 'package:shared_preferences/shared_preferences.dart';

class NotificationTemplateRepository {
  static SharedPreferences? _prefs;
  static const String _successMessageTemplateKey =
      'notification_success_message_template';
  static const String _failureMessageTemplateKey =
      'notification_failure_message_template';
  static const String defaultSuccessMessageTemplate = '미션을 성공했습니다!';
  static const String defaultFailureMessageTemplate = '미션을 실패했습니다.';

  // SharedPreferences 초기화
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 성공 알림 메시지 템플릿을 조회합니다.
  static Future<String> getSuccessMessageTemplate() async {
    await init();
    return _prefs!.getString(_successMessageTemplateKey) ??
        defaultSuccessMessageTemplate;
  }

  /// 실패 알림 메시지 템플릿을 조회합니다.
  static Future<String> getFailureMessageTemplate() async {
    await init();
    return _prefs!.getString(_failureMessageTemplateKey) ??
        defaultFailureMessageTemplate;
  }

  /// 성공 알림 메시지 템플릿을 저장합니다.
  static Future<bool> setSuccessMessageTemplate(String template) async {
    await init();
    return await _prefs!.setString(_successMessageTemplateKey, template);
  }

  /// 실패 알림 메시지 템플릿을 저장합니다.
  static Future<bool> setFailureMessageTemplate(String template) async {
    await init();
    return await _prefs!.setString(_failureMessageTemplateKey, template);
  }
}
