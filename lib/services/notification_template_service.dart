import 'package:notiyou/repositories/notification_template_repository/notification_template_repository_remote.dart';

class NotificationTemplateService {
  static final NotificationTemplateRepositoryRemote
      notificationTemplateRepository = NotificationTemplateRepositoryRemote();

  static Future<String> getSuccessMessageTemplate() async {
    return await notificationTemplateRepository.getSuccessMessageTemplate();
  }

  static Future<String> getFailureMessageTemplate() async {
    return await notificationTemplateRepository.getFailureMessageTemplate();
  }

  static Future<bool> updateSuccessMessageTemplate(String newTemplate) async {
    if (newTemplate.isEmpty) {
      return false;
    }

    return await notificationTemplateRepository
        .setSuccessMessageTemplate(newTemplate);
  }

  static Future<bool> updateFailureMessageTemplate(String newTemplate) async {
    if (newTemplate.isEmpty) {
      return false;
    }

    return await notificationTemplateRepository
        .setFailureMessageTemplate(newTemplate);
  }

  static Future<bool> resetMessageTemplates() async {
    final successReset =
        await notificationTemplateRepository.setSuccessMessageTemplate(
            notificationTemplateRepository.defaultSuccessMessageTemplate);
    final failureReset =
        await notificationTemplateRepository.setFailureMessageTemplate(
            notificationTemplateRepository.defaultFailureMessageTemplate);

    return successReset && failureReset;
  }
}
