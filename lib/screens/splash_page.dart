import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notiyou/screens/config_page.dart';
import 'package:notiyou/services/auth/auth_service.dart';

import 'package:notiyou/screens/home_page.dart';
import 'package:notiyou/screens/login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  static const String routeName = '/';

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final user = await AuthService.getUser();
      if (user == null) {
        throw Exception('User not found');
      }

      final registrationStatus = AuthService.getRegistrationStatus(user);
      if (!mounted) {
        return;
      }

      if (registrationStatus['mission_setting'] != true) {
        context.go(ConfigPage.onboardingRouteName);
      } else {
        context.go(HomePage.routeName);
      }
    } catch (error) {
      if (mounted) {
        context.go(LoginPage.routeName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
