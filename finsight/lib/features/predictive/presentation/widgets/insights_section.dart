import 'package:flutter/material.dart';
import '../../domain/models/prediction.dart';

class InsightsSection extends StatelessWidget {
  final List<PredictiveInsight> insights;

  const InsightsSection({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: insights
          .map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InsightCard(insight: insight),
            ),
          )
          .toList(),
    );
  }
}

class InsightCard extends StatelessWidget {
  final PredictiveInsight insight;

  const InsightCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getInsightIcon(insight.type),
                  color: _getInsightColor(insight.type),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    insight.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (insight.isActionable)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue, width: 1),
                    ),
                    child: Text(
                      'Actionable',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              insight.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildImpactIndicator(context)),
                const SizedBox(width: 16),
                Expanded(child: _buildInsightType(context)),
              ],
            ),
            if (insight.recommendations.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Recommendations:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...insight.recommendations
                  .take(3)
                  .map(
                    (recommendation) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              recommendation,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              if (insight.isActionable) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showActionDialog(context),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Take Action'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getInsightColor(insight.type),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImpactIndicator(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Impact Level',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: insight.impact,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getImpactColor(insight.impact),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getImpactLabel(insight.impact),
          style: theme.textTheme.bodySmall?.copyWith(
            color: _getImpactColor(insight.impact),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightType(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getInsightColor(insight.type).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _getInsightColor(insight.type), width: 1),
          ),
          child: Text(
            insight.type.displayName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: _getInsightColor(insight.type),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getInsightIcon(InsightType type) {
    switch (type) {
      case InsightType.opportunity:
        return Icons.trending_up;
      case InsightType.warning:
        return Icons.warning;
      case InsightType.trend:
        return Icons.show_chart;
      case InsightType.anomaly:
        return Icons.error_outline;
      case InsightType.recommendation:
        return Icons.lightbulb;
    }
  }

  Color _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.opportunity:
        return Colors.green;
      case InsightType.warning:
        return Colors.red;
      case InsightType.trend:
        return Colors.blue;
      case InsightType.anomaly:
        return Colors.orange;
      case InsightType.recommendation:
        return Colors.purple;
    }
  }

  Color _getImpactColor(double impact) {
    if (impact >= 0.7) return Colors.red;
    if (impact >= 0.4) return Colors.orange;
    return Colors.green;
  }

  String _getImpactLabel(double impact) {
    if (impact >= 0.7) return 'High';
    if (impact >= 0.4) return 'Medium';
    return 'Low';
  }

  void _showActionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Take Action: ${insight.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(insight.description),
            const SizedBox(height: 16),
            Text(
              'Available Actions:',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...insight.recommendations.map(
              (rec) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(rec)),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Action plan created successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Create Action Plan'),
          ),
        ],
      ),
    );
  }
}
