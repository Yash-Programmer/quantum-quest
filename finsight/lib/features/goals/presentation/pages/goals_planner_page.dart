import 'package:flutter/material.dart';
import '../../../../shared/widgets/placeholder_page.dart';

class GoalsPlannerPage extends StatelessWidget {
  const GoalsPlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Goals Planner',
      description:
          'Set and track your financial goals with smart planning tools',
      icon: Icons.flag,
    );
  }
}
