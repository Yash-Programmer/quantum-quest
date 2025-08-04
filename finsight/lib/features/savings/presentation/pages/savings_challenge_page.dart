import 'package:flutter/material.dart';
import '../../../../shared/widgets/placeholder_page.dart';

class SavingsChallengePage extends StatelessWidget {
  const SavingsChallengePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Savings Challenge',
      description: 'Gamify your savings with fun challenges and rewards',
      icon: Icons.savings,
    );
  }
}
