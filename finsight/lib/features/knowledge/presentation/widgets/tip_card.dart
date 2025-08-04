import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/knowledge_models.dart';
import '../../providers/knowledge_provider.dart';

class TipCard extends ConsumerWidget {
  final FinancialTip tip;

  const TipCard({super.key, required this.tip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              _getCategoryColor(tip.category).withValues(alpha: 0.05),
              _getCategoryColor(tip.category).withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
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
                      color: _getCategoryColor(
                        tip.category,
                      ).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(tip.category),
                      color: _getCategoryColor(tip.category),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(
                        tip.priority,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.priority_high,
                          size: 12,
                          color: _getPriorityColor(tip.priority),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${tip.priority}',
                          style: TextStyle(
                            fontSize: 11,
                            color: _getPriorityColor(tip.priority),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                tip.description,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.8)
                      : Colors.black87,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(
                        tip.category,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tip.category,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getCategoryColor(tip.category),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (!tip.isRead)
                    TextButton.icon(
                      onPressed: () {
                        ref
                            .read(financialTipsProvider.notifier)
                            .markTipAsRead(tip.id);
                      },
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Mark as Read'),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.primaryColor,
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 12,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Read',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'budgeting':
        return Colors.blue;
      case 'investing':
        return Colors.green;
      case 'savings':
        return Colors.orange;
      case 'credit':
        return Colors.purple;
      case 'tax':
        return Colors.red;
      case 'income':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'budgeting':
        return Icons.account_balance_wallet;
      case 'investing':
        return Icons.trending_up;
      case 'savings':
        return Icons.savings;
      case 'credit':
        return Icons.credit_card;
      case 'tax':
        return Icons.receipt_long;
      case 'income':
        return Icons.attach_money;
      default:
        return Icons.lightbulb;
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 5:
        return Colors.red;
      case 4:
        return Colors.deepOrange;
      case 3:
        return Colors.orange;
      case 2:
        return Colors.amber;
      case 1:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
