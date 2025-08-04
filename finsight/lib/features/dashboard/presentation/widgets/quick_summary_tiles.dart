import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';

class QuickSummaryTiles extends StatelessWidget {
  const QuickSummaryTiles({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data - would come from providers/API
    final summaryData = [
      {
        'title': 'This Month\'s Spending',
        'amount': 15420.50,
        'change': 5.2,
        'icon': Icons.shopping_cart,
        'color': AppTheme.errorColor,
      },
      {
        'title': 'This Month\'s Savings',
        'amount': 8950.00,
        'change': -2.1,
        'icon': Icons.savings,
        'color': AppTheme.successColor,
      },
      {
        'title': 'Total Income',
        'amount': 25000.00,
        'change': 0.0,
        'icon': Icons.account_balance_wallet,
        'color': AppTheme.primaryColor,
      },
      {
        'title': 'Budget Utilization',
        'amount': 76.2,
        'change': 12.3,
        'icon': Icons.pie_chart,
        'color': AppTheme.warningColor,
        'isPercentage': true,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Summary',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemCount: summaryData.length,
          itemBuilder: (context, index) {
            final data = summaryData[index];
            return _buildSummaryTile(
              context,
              title: data['title'] as String,
              amount: data['amount'] as double,
              change: data['change'] as double,
              icon: data['icon'] as IconData,
              color: data['color'] as Color,
              isPercentage: data['isPercentage'] as bool? ?? false,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryTile(
    BuildContext context, {
    required String title,
    required double amount,
    required double change,
    required IconData icon,
    required Color color,
    bool isPercentage = false,
  }) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                if (change != 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: change > 0
                          ? Colors.red.withValues(alpha: 0.1)
                          : Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          change > 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 12,
                          color: change > 0 ? Colors.red : Colors.green,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${change.abs().toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: change > 0 ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isPercentage
                  ? '${amount.toStringAsFixed(1)}%'
                  : currencyFormat.format(amount),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
