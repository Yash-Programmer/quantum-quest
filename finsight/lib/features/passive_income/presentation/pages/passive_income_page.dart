import 'package:flutter/material.dart';
import '../../../../shared/widgets/placeholder_page.dart';

class PassiveIncomePage extends StatelessWidget {
  const PassiveIncomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Passive Income Tracker',
      description: 'Track and optimize your passive income streams',
      icon: Icons.attach_money,
    );
  }
}
