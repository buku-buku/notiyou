import 'package:flutter/material.dart';
import 'dart:async';

import 'package:notiyou/services/challenger_code/challenger_code_exception.dart';

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
  late final TextEditingController _challengerCodeController;
  ChallengerCodeException? _error;
  Timer? _debounceTimer;
  bool _isValidated = false;

  @override
  void initState() {
    super.initState();
    _challengerCodeController =
        TextEditingController(text: widget.initialChallengerCode);
    _challengerCodeController.addListener(_onCodeChanged);

    // 초기 코드가 있는 경우 검증 실행
    if (widget.initialChallengerCode?.isNotEmpty ?? false) {
      _validateChallengerCode(widget.initialChallengerCode!);
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

  // TODO: ChallengerCodeService 클래스 구현 후 해당 클래스의 메서드 사용
  bool _validateChallengerCode(String code) {
    try {
      // TODO: ChallengerCodeService.validate(code) 메서드 호출
      setState(() {
        _error = null;
        _isValidated = true;
      });
      return true;
    } on ChallengerCodeException catch (e) {
      setState(() {
        _error = e;
        _isValidated = false;
      });
      return false;
    }
  }

  void _onNextPressed() async {
    final code = _challengerCodeController.text;
    if (!_isValidated && !await _validateChallengerCode(code)) {
      return;
    }

    // TODO: 도전자의 미션들의 서포터로 해당 유저를 등록

    await AuthService.setRole(UserRole.supporter);

    debugPrint('도전자 코드 입력 완료: $code');
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
