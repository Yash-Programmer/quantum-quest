import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';

class RecentActivityTimeline extends StatelessWidget {
  const RecentActivityTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data - would come from providers/API
    final activities = [
      {
        'title': 'You spent ₹220 on Food',
        'subtitle': 'Swiggy order - Lunch',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
        'icon': Icons.restaurant,
        'color': AppTheme.errorColor,
        'amount': -220.0,
      },
      {
        'title': 'Goal progress updated',
        'subtitle': 'Laptop fund - 65% complete',
        'time': DateTime.now().subtract(const Duration(hours: 5)),
        'icon': Icons.flag,
        'color': AppTheme.successColor,
        'amount': 500.0,
      },
      {
        'title': 'Budget alert',
        'subtitle': 'Entertainment budget 90% used',
        'time': DateTime.now().subtract(const Duration(days: 1)),
        'icon': Icons.warning,
        'color': AppTheme.warningColor,
        'amount': null,
      },
      {
        'title': 'You saved ₹150',
        'subtitle': 'Daily savings streak: 5 days',
        'time': DateTime.now().subtract(const Duration(days: 1)),
        'icon': Icons.savings,
        'color': AppTheme.successColor,
        'amount': 150.0,
      },
      {
        'title': 'AI Insight generated',
        'subtitle': 'You\'re spending 12% more on subscriptions',
        'time': DateTime.now().subtract(const Duration(days: 2)),
        'icon': Icons.lightbulb,
        'color': AppTheme.accentColor,
        'amount': null,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // Navigate to full activity log
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('View All Activity - Coming Soon!'),
                  ),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: activities.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return _buildActivityItem(
                context,
                title: activity['title'] as String,
                subtitle: activity['subtitle'] as String,
                time: activity['time'] as DateTime,
                icon: activity['icon'] as IconData,
                color: activity['color'] as Color,
                amount: activity['amount'] as double?,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required DateTime time,
    required IconData icon,
    required Color color,
    double? amount,
  }) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('MMM dd');

    final now = DateTime.now();
    final isToday =
        time.day == now.day && time.month == now.month && time.year == now.year;
    final isYesterday =
        time.day == now.day - 1 &&
        time.month == now.month &&
        time.year == now.year;

    String timeString;
    if (isToday) {
      timeString = timeFormat.format(time);
    } else if (isYesterday) {
      timeString = 'Yesterday';
    } else {
      timeString = dateFormat.format(time);
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 2),
              Text(timeString, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        if (amount != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: amount > 0
                  ? AppTheme.successColor.withValues(alpha: 0.1)
                  : AppTheme.errorColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${amount > 0 ? '+' : ''}₹${amount.abs().toInt()}',
              style: TextStyle(
                color: amount > 0 ? AppTheme.successColor : AppTheme.errorColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
