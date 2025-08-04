import 'package:flutter/material.dart';
import '../../domain/models/chat_models.dart';

class QuickRepliesSection extends StatelessWidget {
  final List<QuickReply> quickReplies;
  final Function(QuickReply) onQuickReplyTap;

  const QuickRepliesSection({
    super.key,
    required this.quickReplies,
    required this.onQuickReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick replies:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: quickReplies.map((quickReply) {
              return QuickReplyChip(
                quickReply: quickReply,
                onTap: () => onQuickReplyTap(quickReply),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class QuickReplyChip extends StatelessWidget {
  final QuickReply quickReply;
  final VoidCallback onTap;

  const QuickReplyChip({
    super.key,
    required this.quickReply,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (quickReply.icon != null) ...[
              _getQuickReplyIcon(quickReply.icon!, theme),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                quickReply.text,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getQuickReplyIcon(String iconName, ThemeData theme) {
    IconData icon;

    switch (iconName) {
      case 'money':
        icon = Icons.attach_money;
        break;
      case 'savings':
        icon = Icons.savings;
        break;
      case 'chart':
        icon = Icons.show_chart;
        break;
      case 'goal':
        icon = Icons.flag;
        break;
      case 'budget':
        icon = Icons.pie_chart;
        break;
      case 'help':
        icon = Icons.help_outline;
        break;
      default:
        icon = Icons.chat_bubble_outline;
    }

    return Icon(icon, size: 14, color: theme.colorScheme.primary);
  }
}
