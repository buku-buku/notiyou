import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notiyou/screens/home_page.dart';

class BackButtonLayout extends StatelessWidget {
  final Widget child;
  final String title;

  const BackButtonLayout({
    super.key,
    required this.child,
    this.title = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(HomePage.routeName);
            }
          },
        ),
        title: Text(title),
      ),
      body: child,
    );
  }
}
