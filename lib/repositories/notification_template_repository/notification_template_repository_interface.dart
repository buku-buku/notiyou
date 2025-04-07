abstract interface class NotificationTemplateRepository {
  Future<void> init();
  Future<String> getSuccessMessageTemplate();
  Future<String> getFailureMessageTemplate();
  Future<bool> setSuccessMessageTemplate(String template);
  Future<bool> setFailureMessageTemplate(String template);
}
