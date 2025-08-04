import 'package:flutter/material.dart';
import '../../domain/models/prediction.dart';

class TrendAnalysisCard extends StatelessWidget {
  final FinancialTrend trend;

  const TrendAnalysisCard({super.key, required this.trend});

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
                  _getTrendIcon(trend.direction),
                  color: _getTrendColor(trend.direction),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trend.category,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getTrendColor(
                      trend.direction,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getTrendColor(trend.direction),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    trend.direction.displayName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getTrendColor(trend.direction),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              trend.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildChangeIndicator(context)),
                const SizedBox(width: 16),
                Expanded(child: _buildSignificanceIndicator(context)),
              ],
            ),
            if (trend.factors.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Key Factors:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...trend.factors
                  .take(3)
                  .map(
                    (factor) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 6,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              factor,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChangeIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = trend.changePercentage >= 0;
    final color = _getTrendColor(trend.direction);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Change',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              isPositive ? Icons.arrow_upward : Icons.arrow_downward,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '${trend.changePercentage.abs().toStringAsFixed(1)}%',
              style: theme.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignificanceIndicator(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Significance',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: trend.significance,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getSignificanceColor(trend.significance),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getSignificanceLabel(trend.significance),
          style: theme.textTheme.bodySmall?.copyWith(
            color: _getSignificanceColor(trend.significance),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  IconData _getTrendIcon(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.increasing:
        return Icons.trending_up;
      case TrendDirection.decreasing:
        return Icons.trending_down;
      case TrendDirection.stable:
        return Icons.trending_flat;
      case TrendDirection.volatile:
        return Icons.show_chart;
    }
  }

  Color _getTrendColor(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.increasing:
        return Colors.red;
      case TrendDirection.decreasing:
        return Colors.green;
      case TrendDirection.stable:
        return Colors.blue;
      case TrendDirection.volatile:
        return Colors.orange;
    }
  }

  Color _getSignificanceColor(double significance) {
    if (significance >= 0.7) return Colors.red;
    if (significance >= 0.4) return Colors.orange;
    return Colors.green;
  }

  String _getSignificanceLabel(double significance) {
    if (significance >= 0.7) return 'High';
    if (significance >= 0.4) return 'Medium';
    return 'Low';
  }
}
