import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notiyou/screens/signup_page.dart';
import 'package:notiyou/services/auth/auth_service.dart';
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
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('서포터를 그만두었습니다.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  context.go(SignupPage.routeName);
                }
              },
              child: const Text(
                '서포터 그만두기',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              onPressed: () async {
                final bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('※주의',
                          style: TextStyle(color: Colors.red)),
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('정말 회원탈퇴 하시겠습니까?'),
                          SizedBox(height: 8),
                          Text(
                            '회원탈퇴 시 모든 데이터가 삭제되며 복구할 수 없습니다.',
                            style: TextStyle(color: Colors.red, fontSize: 12),
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
                  try {
                    await AuthService.deleteAccount();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('회원탈퇴가 완료되었습니다.'),
                          duration: Duration(seconds: 2)),
                    );
                    context.go('/login');
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('회원탈퇴 중 오류가 발생했습니다: \n$e')),
                    );
                  }
                }
              },
              child: const Text('회원탈퇴', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
