import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/chat_models.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.type == MessageType.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomRight: isUser ? const Radius.circular(4) : null,
                  bottomLeft: !isUser ? const Radius.circular(4) : null,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isUser) _buildBotHeader(theme),
                  _buildMessageContent(theme, isUser),
                  if (message.attachment != null) ...[
                    const SizedBox(height: 8),
                    _buildAttachment(theme),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 4),
            _buildMessageInfo(theme, isUser),
          ],
        ),
      ),
    );
  }

  Widget _buildBotHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            radius: 10,
            child: Icon(
              Icons.smart_toy,
              color: theme.colorScheme.onPrimary,
              size: 12,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'FinSight Assistant',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(ThemeData theme, bool isUser) {
    return SelectableText(
      message.content,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: isUser 
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface,
        height: 1.4,
      ),
    );
  }

  Widget _buildAttachment(ThemeData theme) {
    final attachment = message.attachment!;

    switch (attachment.type) {
      case AttachmentType.chart:
        return _buildChartAttachment(theme, attachment);
      case AttachmentType.image:
        return _buildImageAttachment(theme, attachment);
      case AttachmentType.document:
        return _buildDocumentAttachment(theme, attachment);
      case AttachmentType.link:
        return _buildLinkAttachment(theme, attachment);
      default:
        return _buildGenericAttachment(theme, attachment);
    }
  }

  Widget _buildChartAttachment(ThemeData theme, ChatAttachment attachment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  attachment.title ?? 'Chart',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (attachment.description != null) ...[
            const SizedBox(height: 4),
            Text(
              attachment.description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart,
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Interactive Chart',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageAttachment(ThemeData theme, ChatAttachment attachment) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          attachment.url,
          height: 150,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 150,
              color: theme.colorScheme.surfaceVariant,
              child: Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDocumentAttachment(ThemeData theme, ChatAttachment attachment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.description,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.title ?? 'Document',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (attachment.description != null)
                  Text(
                    attachment.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            Icons.download,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildLinkAttachment(ThemeData theme, ChatAttachment attachment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.link,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              attachment.title ?? attachment.url,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          Icon(
            Icons.open_in_new,
            color: theme.colorScheme.primary,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildGenericAttachment(ThemeData theme, ChatAttachment attachment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.attachment,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              attachment.title ?? 'Attachment',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInfo(ThemeData theme, bool isUser) {
    return Padding(
      padding: EdgeInsets.only(
        left: isUser ? 0 : 8,
        right: isUser ? 8 : 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormat('HH:mm').format(message.timestamp),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 4),
            _buildStatusIcon(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon(ThemeData theme) {
    IconData icon;
    Color color;

    switch (message.status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        color = theme.colorScheme.onSurface.withOpacity(0.3);
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = theme.colorScheme.onSurface.withOpacity(0.5);
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = theme.colorScheme.onSurface.withOpacity(0.5);
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = theme.colorScheme.primary;
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = theme.colorScheme.error;
        break;
    }

    return Icon(
      icon,
      size: 12,
      color: color,
    );
  }
}
