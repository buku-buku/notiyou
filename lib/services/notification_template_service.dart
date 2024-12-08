import 'package:notiyou/repositories/notification_template_repository.dart';

class NotificationTemplateService {
  static Future<String> getSuccessMessageTemplate() async {
    return await NotificationTemplateRepository.getSuccessMessageTemplate();
  }

  static Future<String> getFailureMessageTemplate() async {
    return await NotificationTemplateRepository.getFailureMessageTemplate();
  }

  static Future<bool> updateSuccessMessageTemplate(String newTemplate) async {
    if (newTemplate.isEmpty) {
      return false;
    }
    return await NotificationTemplateRepository.setSuccessMessageTemplate(
        newTemplate);
  }

  static Future<bool> updateFailureMessageTemplate(String newTemplate) async {
    if (newTemplate.isEmpty) {
      return false;
    }
    return await NotificationTemplateRepository.setFailureMessageTemplate(
        newTemplate);
  }

  static Future<bool> resetMessageTemplates() async {
    final successReset =
        await NotificationTemplateRepository.setSuccessMessageTemplate(
            NotificationTemplateRepository.defaultSuccessMessageTemplate);
    final failureReset =
        await NotificationTemplateRepository.setFailureMessageTemplate(
            NotificationTemplateRepository.defaultFailureMessageTemplate);

    return successReset && failureReset;
  }
}
