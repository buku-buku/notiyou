import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import '../services/auth/auth_service.dart';
import '../services/supporter_service.dart';

class SupporterSection extends StatefulWidget {
  const SupporterSection({super.key});

  @override
  State<SupporterSection> createState() => _SupporterSectionState();
}

class _SupporterSectionState extends State<SupporterSection>
    with WidgetsBindingObserver {
  Map<String, dynamic>? _supporterInfo;
  bool _isWaitingForKakaoTalkReturn = false;
  bool _isKakaoTalkReturned = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSupporterInfo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed && _isWaitingForKakaoTalkReturn) {
      setState(() {
        _isWaitingForKakaoTalkReturn = false;
      });

      if (mounted) {
        setState(() {
          _isKakaoTalkReturned = true;
        });
      }
    }
  }

  Future<void> _loadSupporterInfo() async {
    final supporter = await SupporterService.getSupporter();

    if (supporter != null) {
      setState(() {
        _supporterInfo = supporter;
      });
    }
  }

  Future<void> _deleteSupporter() async {
    final user = await AuthService.getUser();
    if (user != null) {
      final isDeleted = await SupporterService.deleteSupporter(user.id);

      if (isDeleted) {
        setState(() {
          _supporterInfo = null;
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('서포터를 삭제하는 도중 오류가 발생했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareLinkToSupporter() async {
    try {
      final user = await AuthService.getUser();
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('사용자 정보를 가져올 수 없습니다.')),
          );
        }
        return;
      }

      bool isKakaoTalkSharingAvailable =
          await ShareClient.instance.isKakaoTalkSharingAvailable();
      final TextTemplate defaultText = TextTemplate(
        objectType: 'text',
        text: '${user.id}님의 미션 서포터가 되어주시겠습니까?',
        buttonTitle: '동의하러 가기',
        link: Link(
          webUrl: Uri.parse(''),
          mobileWebUrl: Uri.parse(''),
        ),
      );

      if (isKakaoTalkSharingAvailable) {
        try {
          Uri uri =
              await ShareClient.instance.shareDefault(template: defaultText);
          if (mounted) {
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('서포터 동의 구하기'),
                  content: const Text('메시지 전송 후 상단의 돌아가기를 터치하여 앱으로 돌아와주세요.'),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        setState(() {
                          _isWaitingForKakaoTalkReturn = true;
                        });
                        await ShareClient.instance.launchKakaoTalk(uri);
                      },
                      child: const Text('카카오톡으로 이동하기'),
                    ),
                  ],
                );
              },
            );
          }
        } catch (e) {
          if (mounted) {
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('공유 실패'),
                  content: const Text('카카오톡 공유 중 오류가 발생했습니다.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('확인'),
                    ),
                  ],
                );
              },
            );
          }
        }
      } else {
        try {
          Uri shareUrl = await WebSharerClient.instance
              .makeDefaultUrl(template: defaultText);
          await launchBrowserTab(shareUrl, popupOpen: true);
        } catch (error) {
          if (mounted) {
            setState(() {
              _isKakaoTalkReturned = true;
            });
          }
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('예상치 못한 오류가 발생했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        if (_supporterInfo == null) ...[
          ElevatedButton(
            onPressed: _shareLinkToSupporter,
            child: const Text('서포터 초대하기'),
          ),
          if (_isKakaoTalkReturned)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '서포터가 초대를 수락해야 알람 공유 기능이 활성화 됩니다.\n올바른 상대에게 초대 링크가 전송되었는지 정확하게 확인해 주세요',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ] else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _supporterInfo?['supporter_name'] ?? '(이름 없음)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _deleteSupporter,
                child: Text(
                  '교체하기',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red[400],
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}