import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:notiyou/entities/current_participant.dart';
import 'package:notiyou/models/challenger_supporter_model.dart';
import 'package:notiyou/services/auth/auth_service.dart';
import 'package:notiyou/services/challenger_code/challenger_code_service.dart';
import 'package:notiyou/services/invite_deep_link_service.dart';
import 'package:notiyou/services/challenger_config_service.dart';
import 'package:notiyou/services/participant_service.dart';

class SupporterSection extends StatefulWidget {
  const SupporterSection({super.key});

  @override
  State<SupporterSection> createState() => _SupporterSectionState();
}

class _SupporterSectionState extends State<SupporterSection>
    with WidgetsBindingObserver {
  ChallengerSupporter? _challengerSupporterInfo;
  bool _isWaitingForKakaoTalkReturn = false;
  bool _isKakaoTalkReturned = false;

  CurrentParticipant? _participant;
  final _participantService = ParticipantService.getInstance();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadChallengerSupporterInfo();
    _loadParticipant();
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

  Future<void> _loadChallengerSupporterInfo() async {
    try {
      final challengerSupporter = await ChallengerConfigService.getSupporter();

      setState(() {
        _challengerSupporterInfo = challengerSupporter;
      });
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('도전자 정보를 불러오는 도중 오류가 발생했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadParticipant() async {
    try {
      final participant = await _participantService.getCurrentParticipant();
      setState(() {
        _participant = participant;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _deleteSupporter() async {
    if (_challengerSupporterInfo?.id == null) return;

    try {
      final updatedChallengerSupporterInfo =
          await ChallengerConfigService.dismissSupporter();
      setState(() {
        _challengerSupporterInfo = updatedChallengerSupporterInfo;
      });
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('서포터를 삭제하는 도중 오류가 발생했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> shareLinkToSupporter() async {
    try {
      final user = await AuthService.getUserSafe();
      final challengerCode =
          await ChallengerCodeServiceImpl.instance.generateCode(user.id);
      final inviteLink = await InviteDeepLinkService.generateDeepLink(user.id);

      final TextTemplate defaultText = TextTemplate(
        objectType: 'text',
        text: '${_participant?.name}님의 미션 서포터가 되어주시겠습니까?\n\n'
            '${_participant?.name}님의 초대코드\n'
            '━━━━━━━━━━━━━━\n'
            '$challengerCode\n'
            '━━━━━━━━━━━━━━',
        buttonTitle: '서포터 등록하기',
        link: Link(
            mobileWebUrl: Uri.parse(inviteLink),
            androidExecutionParams: {'challenger_code': challengerCode},
            iosExecutionParams: {'challenger_code': challengerCode}),
      );

      bool isKakaoTalkSharingAvailable =
          await ShareClient.instance.isKakaoTalkSharingAvailable();

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
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
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

  Future<void> copyCodeToClipboard() async {
    try {
      final user = await AuthService.getUserSafe();
      final challengerCode =
          await ChallengerCodeServiceImpl.instance.generateCode(user.id);
      await Clipboard.setData(ClipboardData(text: challengerCode));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('초대코드가 클립보드에 복사되었습니다'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('초대코드 복사 중 오류가 발생했습니다'),
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
        if (_challengerSupporterInfo?.supporterId == null) ...[
          Card(
            elevation: 0,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    '서포터 초대하기',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '서포터를 초대하여 알람 공유 기능을 활성화하세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: shareLinkToSupporter,
                      icon: const Icon(Icons.share),
                      label: const Text('카카오톡으로 초대하기'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: const Color(0xFFFEE500), // 카카오톡 색상
                        foregroundColor: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: copyCodeToClipboard,
                      icon: const Icon(Icons.copy),
                      label: const Text('초대코드 복사하기'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isKakaoTalkReturned)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                _participant?.partner?.name ?? '(이름 없음)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _deleteSupporter,
                child: Text(
                  '서포터 해제하기',
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
