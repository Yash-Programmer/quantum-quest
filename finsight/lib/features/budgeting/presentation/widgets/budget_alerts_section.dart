import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/budget.dart';
import '../../../../core/theme/app_theme.dart';

class BudgetAlertsSection extends StatelessWidget {
  final List<Budget> alertBudgets;

  const BudgetAlertsSection({super.key, required this.alertBudgets});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⚠️ Budget Alerts (${alertBudgets.length})',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'These budgets need your attention',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          ...alertBudgets.map((budget) => _buildAlertCard(context, budget)),
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, Budget budget) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    final isOverBudget = budget.isOverBudget;
    final alertColor = isOverBudget
        ? AppTheme.errorColor
        : AppTheme.warningColor;
    final alertIcon = isOverBudget ? Icons.error : Icons.warning;
    final alertTitle = isOverBudget ? 'Over Budget' : 'Budget Alert';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: alertColor.withValues(alpha: 0.3), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Alert header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: alertColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(alertIcon, color: alertColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alertTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: alertColor,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          budget.categoryName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${budget.utilizationPercentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: alertColor,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Budget details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Budget Amount:'),
                        Text(
                          currencyFormat.format(budget.budgetAmount),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Spent Amount:'),
                        Text(
                          currencyFormat.format(budget.spentAmount),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isOverBudget ? AppTheme.errorColor : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Remaining:'),
                        Text(
                          currencyFormat.format(budget.remainingAmount),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: budget.remainingAmount >= 0
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Progress bar
              LinearProgressIndicator(
                value: (budget.utilizationPercentage / 100).clamp(0.0, 1.0),
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(alertColor),
              ),
              const SizedBox(height: 16),

              // Alert message
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: alertColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: alertColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getAlertMessage(budget),
                        style: TextStyle(color: alertColor, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showTransactionHistory(context, budget);
                      },
                      icon: const Icon(Icons.history),
                      label: const Text('View Transactions'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showBudgetAdjustment(context, budget);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Adjust Budget'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getAlertMessage(Budget budget) {
    if (budget.isOverBudget) {
      final overAmount = budget.spentAmount - budget.budgetAmount;
      return 'You\'ve exceeded your budget by ₹${overAmount.toStringAsFixed(0)}. Consider reviewing your recent spending or adjusting your budget.';
    } else if (budget.utilizationPercentage >= 90) {
      return 'You\'ve used 90% of your budget. Only ₹${budget.remainingAmount.toStringAsFixed(0)} remaining for this period.';
    } else {
      return 'You\'ve reached ${budget.alertThreshold.toInt()}% of your budget limit. Time to be more mindful of your spending.';
    }
  }

  void _showTransactionHistory(BuildContext context, Budget budget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${budget.categoryName} Transactions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Mock transaction data
                      _buildTransactionItem(
                        'Coffee at Starbucks',
                        '₹450',
                        '2 hours ago',
                      ),
                      _buildTransactionItem(
                        'Lunch at McDonald\'s',
                        '₹320',
                        'Yesterday',
                      ),
                      _buildTransactionItem(
                        'Grocery shopping',
                        '₹1,200',
                        '2 days ago',
                      ),
                      _buildTransactionItem(
                        'Movie tickets',
                        '₹600',
                        '3 days ago',
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionItem(String title, String amount, String time) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
        child: Icon(
          Icons.shopping_cart,
          color: AppTheme.primaryColor,
          size: 20,
        ),
      ),
      title: Text(title),
      subtitle: Text(time),
      trailing: Text(
        amount,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  void _showBudgetAdjustment(BuildContext context, Budget budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adjust ${budget.categoryName} Budget'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current budget: ₹${budget.budgetAmount.toStringAsFixed(0)}'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'New budget amount',
                prefixText: '₹',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${budget.categoryName} budget updated!'),
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
