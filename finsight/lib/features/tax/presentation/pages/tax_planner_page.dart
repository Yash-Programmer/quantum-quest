import 'package:flutter/material.dart';
import '../../../../shared/widgets/placeholder_page.dart';

class TaxPlannerPage extends StatelessWidget {
  const TaxPlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Tax Planner',
      description: 'Optimize your tax planning and deductions',
      icon: Icons.receipt_long,
    );
  }
}
