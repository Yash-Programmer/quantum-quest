import 'package:flutter/material.dart';
import '../../../../shared/widgets/placeholder_page.dart';

class FireCalculatorPage extends StatelessWidget {
  const FireCalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'FIRE Calculator',
      description:
          'Plan your path to Financial Independence and Early Retirement',
      icon: Icons.local_fire_department,
    );
  }
}
