import 'package:flutter/material.dart';
import '../layouts/back_button_layout.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const String routeName = '/profile';

  Widget _buildWithLayout(Widget content) {
    return BackButtonLayout(
      title: 'Profile',
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildWithLayout(
      const Center(child: Text('Profile Page')),
    );
  }
} 
