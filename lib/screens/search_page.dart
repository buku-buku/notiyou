import 'package:flutter/material.dart';
import '../layouts/back_button_layout.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  static const String routeName = '/search';

  Widget _buildWithLayout(Widget content) {
    return BackButtonLayout(
      title: 'Search',
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildWithLayout(
      const Center(child: Text('Search Page')),
    );
  }
}
