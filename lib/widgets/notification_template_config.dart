import 'package:flutter/material.dart';
import '../services/notification_template_service.dart';

class NotificationTemplateConfig extends StatefulWidget {
  const NotificationTemplateConfig({super.key});

  @override
  State<NotificationTemplateConfig> createState() =>
      _NotificationTemplateConfigState();
}

class _NotificationTemplateConfigState
    extends State<NotificationTemplateConfig> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _successController =
      TextEditingController(text: '');
  final TextEditingController _failureController =
      TextEditingController(text: '');
  bool _isLoadingTemplates = false;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    try {
      setState(() {
        _isLoadingTemplates = true;
      });
      final successTemplate =
          await NotificationTemplateService.getSuccessMessageTemplate();
      final failureTemplate =
          await NotificationTemplateService.getFailureMessageTemplate();

      setState(() {
        _successController.text = successTemplate;
        _failureController.text = failureTemplate;
        _isLoadingTemplates = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTemplates = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('템플릿을 불러오는데 실패했습니다')),
        );
      }
    }
  }

  @override
  void dispose() {
    _successController.dispose();
    _failureController.dispose();
    super.dispose();
  }

  Future<void> _saveTemplates() async {
    if (_formKey.currentState!.validate()) {
      await NotificationTemplateService.updateSuccessMessageTemplate(
          _successController.text);
      await NotificationTemplateService.updateFailureMessageTemplate(
          _failureController.text);

      /**
       * * 위젯의 비동기 메서드에서 context.mounted 여부를 체크하는 이유
       *
       * context.mounted 체크는 Flutter에서 비동기 작업 후 위젯의 상태를 안전하게 처리하기 위해 사용됩니다.
       * 주요 이유는 다음과 같습니다:
       * 1. 비동기 작업 중 위젯이 dispose될 수 있음:
       *  _saveTemplates()는 비동기 함수(async)입니다
       *  템플릿 저장이 완료되기 전에 사용자가 화면을 닫거나 다른 화면으로 이동할 수 있습니다
       *  이때 위젯이 dispose되면서 context가 더 이상 유효하지 않을 수 있습니다
       * 
       * 2. 잠재적인 메모리 누수와 에러 방지:
       *  dispose된 위젯의 context를 사용하면 "setState() or markNeedsBuild() called after dispose" 같은 에러가 발생할 수 있습니다
      */
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('알림 메시지가 저장되었습니다')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _isLoadingTemplates
            ? [const Center(child: CircularProgressIndicator())]
            : [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '알림 메시지 설정',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('미션 성공 알림 메시지'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _successController,
                        enabled: !_isLoadingTemplates,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '미션 성공 시 전송될 알림 메시지를 입력하세요',
                          helperText: '예: [이름]님이 미션을 성공적으로 완료했습니다!',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '알림 메시지를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('미션 실패 알림 메시지'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _failureController,
                        enabled: !_isLoadingTemplates,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '미션 실패 시 전송될 알림 메시지를 입력하세요',
                          helperText: '예: [이름]님이 미션 수행에 실패했습니다.',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '알림 메시지를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoadingTemplates ? null : _saveTemplates,
                  child: const Text('저장'),
                ),
              ],
      ),
    );
  }
}
