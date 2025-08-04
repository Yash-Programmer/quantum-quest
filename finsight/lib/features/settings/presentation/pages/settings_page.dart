import 'package:flutter/material.dart';
import '../../../../shared/widgets/placeholder_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Settings',
      description: 'Customize your FinSight experience',
      icon: Icons.settings,
    );
  }
}
