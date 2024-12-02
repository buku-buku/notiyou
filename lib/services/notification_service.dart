import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'supporter_service.dart';
import 'notification_template_service.dart';

enum NotificationResult { success, partialFailure, error, noReceiver }

class NotificationService {
  static Future<NotificationResult> sendCompleteMessageToSupporter() async {
    final supporter = await SupporterService.getSupporter();
    final successTemplate =
        await NotificationTemplateService.getSuccessMessageTemplate();

    if (supporter?['supporter_kakao_uuid'] == null) {
      return NotificationResult.noReceiver;
    }

    try {
      MessageSendResult result = await TalkApi.instance.sendDefaultMessage(
        receiverUuids: [''], // 조력자의 kakao uuid가 필요하다
        template: TextTemplate(
          text: successTemplate,
          link: Link(
            webUrl: Uri.parse(''),
            mobileWebUrl: Uri.parse(''),
          ),
        ),
      );

      if (result.failureInfos != null) {
        return NotificationResult.partialFailure;
      }

      return NotificationResult.success;
    } catch (error) {
      return NotificationResult.error;
    }
  }
}
