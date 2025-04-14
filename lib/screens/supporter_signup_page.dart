import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notiyou/entities/current_participant.dart';
import 'package:notiyou/exceptions/repository_exception.dart';
import 'package:notiyou/models/registration_status.dart';
import 'package:notiyou/screens/home_page.dart';
import 'package:notiyou/services/auth/auth_service.dart';
import 'dart:async';

import 'package:notiyou/exceptions/challenger_code_exception.dart';
import 'package:notiyou/services/challenger_code/challenger_code_service.dart';
import 'package:notiyou/services/challenger_code/challenger_code_service_interface.dart';
import 'package:notiyou/services/challenger_config_service.dart';
import 'package:notiyou/exceptions/challenger_supporter_exception.dart';
import 'package:notiyou/services/participant_service.dart';
import 'package:notiyou/services/user_metadata_service.dart';

class SupporterSignupPage extends StatefulWidget {
  const SupporterSignupPage({
    super.key,
    this.initialChallengerCode,
  });

  static const String routeName = '/signup/supporter';
  final String? initialChallengerCode;

  @override
  State<SupporterSignupPage> createState() => _SupporterSignupPageState();
}

class _SupporterSignupPageState extends State<SupporterSignupPage> {
  final _participantService = ParticipantService.getInstance();

  late final TextEditingController _challengerCodeController;
  final ChallengerCodeService _challengerCodeService =
      ChallengerCodeServiceImpl.instance;
  ChallengerCodeException? _error;
  Timer? _debounceTimer;
  bool _isValidated = false;
  CurrentParticipant? _challengerParticipant;

  void _updateCode(String? code) {
    if (code?.isNotEmpty ?? false) {
      _challengerCodeController.text = code!;
      _validateChallengerCode(code);
    }
  }

  @override
  void initState() {
    super.initState();
    _challengerCodeController = TextEditingController();
    _challengerCodeController.addListener(_onCodeChanged);
    _updateCode(widget.initialChallengerCode);
  }

  @override
  void didUpdateWidget(SupporterSignupPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialChallengerCode != oldWidget.initialChallengerCode) {
      _updateCode(widget.initialChallengerCode);
    }
  }

  @override
  void dispose() {
    _challengerCodeController.removeListener(_onCodeChanged);
    _challengerCodeController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onCodeChanged() {
    setState(() {
      _isValidated = false;
      _error = null;
    });

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final code = _challengerCodeController.text;
      _validateChallengerCode(code);
    });
  }

  Future<bool> _validateChallengerCode(String code) async {
    try {
      final challengerId = await _challengerCodeService.verifyCode(code);

      final challengerParticipant =
          await _participantService.getParticipantById(challengerId);

      setState(() {
        _error = null;
        _isValidated = true;
        _challengerParticipant = challengerParticipant;
      });
      return true;
    } on ChallengerCodeException catch (e) {
      setState(() {
        _error = e;
        _isValidated = false;
      });
      return false;
    } on EntityNotFoundException catch (e) {
      setState(() {
        _error = ChallengerCodeException(
          message: ChallengerCodeExceptionType.notFound.message,
          type: ChallengerCodeExceptionType.notFound,
          details: e.details,
        );
        _isValidated = false;
      });
      return false;
    }
  }

  Future<void> _registerMissionSupporter(String code) async {
    final userId = await AuthService.getUserId();
    final challengerId = await _challengerCodeService.extractUserId(code);
    await ChallengerConfigService.registerSupporter(challengerId);
    await UserMetadataService.setRole(userId, UserRole.supporter);
  }

  void _onNextPressed() async {
    final code = _challengerCodeController.text;
    if (!_isValidated && !await _validateChallengerCode(code)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('도전자의 초대 코드가 유효하지 않습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      await _registerMissionSupporter(code);
      if (mounted) {
        context.go(HomePage.routeName);
      }
    } on ChallengerSupporterException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('조력자 등록 중 오류가 발생했습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('조력자 회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '도전자의 코드를 입력해주세요',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              '도전자의 응원과 격려를 위해 코드가 필요합니다',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _challengerCodeController,
              decoration: InputDecoration(
                labelText: '도전자 코드',
                hintText: '도전자에게 받은 코드를 입력해주세요',
                border: const OutlineInputBorder(),
                errorText: _error?.message,
                suffixIcon: _isValidated
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
              ),
            ),
            if (_isValidated && _challengerParticipant != null) ...[
              const SizedBox(height: 8),
              Text(
                '${_challengerParticipant!.name}님의 초대 코드를 입력했습니다',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onNextPressed,
              child: const Text('다음'),
            ),
          ],
        ),
      ),
    );
  }
}
