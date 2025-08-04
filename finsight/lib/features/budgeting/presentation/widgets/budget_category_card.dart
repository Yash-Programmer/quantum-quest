import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/budget.dart';
import '../../../../core/theme/app_theme.dart';

class BudgetCategoryCard extends StatelessWidget {
  final Budget budget;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BudgetCategoryCard({
    super.key,
    required this.budget,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getCategoryColor().withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getCategoryIcon(),
                            color: _getCategoryColor(),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                budget.categoryName,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                budget.period.displayName,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (budget.shouldAlert || budget.isOverBudget)
                        Icon(
                          Icons.warning,
                          color: budget.isOverBudget
                              ? AppTheme.errorColor
                              : AppTheme.warningColor,
                          size: 20,
                        ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              onEdit?.call();
                              break;
                            case 'delete':
                              onDelete?.call();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Amount information
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spent',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        currencyFormat.format(budget.spentAmount),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: budget.isOverBudget
                                  ? AppTheme.errorColor
                                  : null,
                            ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Budget',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        currencyFormat.format(budget.budgetAmount),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${budget.utilizationPercentage.toStringAsFixed(1)}% used',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        currencyFormat.format(budget.remainingAmount),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: budget.remainingAmount >= 0
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (budget.utilizationPercentage / 100).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      budget.isOverBudget
                          ? AppTheme.errorColor
                          : budget.utilizationPercentage > 80
                          ? AppTheme.warningColor
                          : AppTheme.successColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Status chip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(
                      budget.status.displayName,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: _getStatusColor().withValues(alpha: 0.1),
                    side: BorderSide(color: _getStatusColor()),
                  ),
                  if (budget.alertsEnabled)
                    Icon(
                      Icons.notifications_active,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (budget.categoryId) {
      case 'food':
        return const Color(0xFFFF6B6B);
      case 'entertainment':
        return const Color(0xFF4ECDC4);
      case 'transportation':
        return const Color(0xFF45B7D1);
      case 'shopping':
        return const Color(0xFF96CEB4);
      case 'health':
        return const Color(0xFFFDCB6E);
      case 'education':
        return const Color(0xFFE17055);
      case 'utilities':
        return const Color(0xFFA29BFE);
      case 'subscriptions':
        return const Color(0xFFFF7675);
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getCategoryIcon() {
    switch (budget.categoryId) {
      case 'food':
        return Icons.restaurant;
      case 'entertainment':
        return Icons.movie;
      case 'transportation':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'health':
        return Icons.fitness_center;
      case 'education':
        return Icons.school;
      case 'utilities':
        return Icons.bolt;
      case 'subscriptions':
        return Icons.subscriptions;
      default:
        return Icons.category;
    }
  }

  Color _getStatusColor() {
    switch (budget.status) {
      case BudgetStatus.active:
        return AppTheme.successColor;
      case BudgetStatus.paused:
        return AppTheme.warningColor;
      case BudgetStatus.completed:
        return AppTheme.primaryColor;
      case BudgetStatus.overBudget:
        return AppTheme.errorColor;
    }
  }
}
