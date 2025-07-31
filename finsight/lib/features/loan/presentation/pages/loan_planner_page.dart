import 'package:flutter/material.dart';
import '../../../../shared/widgets/placeholder_page.dart';

class LoanPlannerPage extends StatelessWidget {
  const LoanPlannerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Loan Planner',
      description: 'Calculate EMIs and plan your loan repayments efficiently',
      icon: Icons.money_off,
    );
  }
}
