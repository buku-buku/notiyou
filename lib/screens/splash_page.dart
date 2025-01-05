import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:notiyou/screens/home_page.dart';
import 'package:notiyou/screens/login_page.dart';
import 'package:notiyou/screens/signup_page.dart';
import 'package:notiyou/services/auth/auth_service.dart';

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

      final isRegistrationComplete = AuthService.isRegistrationCompleted(user);
      if (!mounted) {
        return;
      }

      if (isRegistrationComplete) {
        context.go(HomePage.routeName);
      } else {
        context.go(SignupPage.routeName);
      }
    } catch (error) {
      if (mounted) {
        context.go(LoginPage.routeName);
      }
    }

    FlutterNativeSplash.remove();
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
