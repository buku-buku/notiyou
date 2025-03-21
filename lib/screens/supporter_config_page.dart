import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notiyou/screens/signup_page.dart';
import 'package:notiyou/services/challenger_config_service.dart';

class SupporterConfigPage extends StatelessWidget {
  const SupporterConfigPage({super.key});

  static const String routeName = '/supporter/config';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Config')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              onPressed: () async {
                final bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('※주의',
                          style: TextStyle(
                            color: Colors.red,
                          )),
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('정말 그만두시겠습니까?'),
                          SizedBox(height: 8),
                          Text(
                            '지금 서포터를 그만두면 다시 초대받기 전까지 미션에 참여할 수 없습니다!',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('확인'),
                        ),
                      ],
                    );
                  },
                );

                if (confirm == true) {
                  await ChallengerConfigService.quitSupporter();
                  if (context.mounted) {
                    context.go(SignupPage.routeName);
                  }
                }
              },
              child: const Text(
                '서포터 그만두기',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
