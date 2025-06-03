import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notiyou/screens/signup_page.dart';

class BackButtonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? backRoute;

  const BackButtonAppBar({
    super.key,
    required this.title,
    this.backRoute = SignupPage.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go(backRoute!),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
