import 'package:flutter/material.dart';
import '../../../../shared/widgets/placeholder_page.dart';

class CreditScorePage extends StatelessWidget {
  const CreditScorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Credit Score Tracker',
      description: 'Monitor and improve your credit health',
      icon: Icons.credit_score,
    );
  }
}
