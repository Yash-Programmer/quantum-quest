import 'package:flutter/material.dart';
import '../../../../shared/widgets/placeholder_page.dart';

class InvestmentHeatmapPage extends StatelessWidget {
  const InvestmentHeatmapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Investment Heatmap',
      description: 'Visualize investment opportunities and risks',
      icon: Icons.trending_up,
    );
  }
}
