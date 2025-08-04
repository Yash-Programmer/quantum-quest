import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';

class BudgetSummaryCard extends StatelessWidget {
  final Map<String, double> summary;

  const BudgetSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    final utilizationPercentage = summary['utilizationPercentage'] ?? 0.0;
    final totalBudget = summary['totalBudget'] ?? 0.0;
    final totalSpent = summary['totalSpent'] ?? 0.0;
    final totalRemaining = summary['totalRemaining'] ?? 0.0;

    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monthly Budget Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Progress Circle
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: utilizationPercentage / 100,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        utilizationPercentage > 100
                            ? AppTheme.errorColor
                            : utilizationPercentage > 80
                            ? AppTheme.warningColor
                            : Colors.white,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${utilizationPercentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Used',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Summary Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Budget',
                  currencyFormat.format(totalBudget),
                  Icons.account_balance_wallet,
                ),
                _buildSummaryItem(
                  'Spent',
                  currencyFormat.format(totalSpent),
                  Icons.shopping_cart,
                ),
                _buildSummaryItem(
                  'Remaining',
                  currencyFormat.format(totalRemaining),
                  Icons.savings,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    utilizationPercentage > 100
                        ? Icons.warning
                        : utilizationPercentage > 80
                        ? Icons.info
                        : Icons.check_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getStatusMessage(utilizationPercentage),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getStatusMessage(double utilizationPercentage) {
    if (utilizationPercentage > 100) {
      return 'Over budget! Consider reviewing your spending.';
    } else if (utilizationPercentage > 80) {
      return 'Approaching budget limit. Be mindful of spending.';
    } else if (utilizationPercentage > 50) {
      return 'On track with your budget goals.';
    } else {
      return 'Great job! You\'re well within your budget.';
    }
  }
}
