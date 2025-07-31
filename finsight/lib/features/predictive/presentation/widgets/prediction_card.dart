import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/prediction.dart';

class PredictionCard extends StatelessWidget {
  final Prediction prediction;

  const PredictionCard({
    super.key,
    required this.prediction,
  });

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
                  _getTypeIcon(prediction.type),
                  color: _getTypeColor(prediction.type),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    prediction.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(prediction.confidence).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getConfidenceColor(prediction.confidence),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${(prediction.confidence * 100).toStringAsFixed(0)}% confidence',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getConfidenceColor(prediction.confidence),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              prediction.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPredictionValue(context),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildForecastDate(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildProgressIndicator(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionValue(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = prediction.predictedValue >= 0;
    final color = isPositive ? Colors.green : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Predicted Value',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              isPositive ? Icons.trending_up : Icons.trending_down,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                  .format(prediction.predictedValue.abs()),
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

  Widget _buildForecastDate(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Forecast Date',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('MMM dd, yyyy').format(prediction.forecastDate),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final confidence = prediction.confidence;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Prediction Confidence',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              _getConfidenceLabel(confidence),
              style: theme.textTheme.bodySmall?.copyWith(
                color: _getConfidenceColor(confidence),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: confidence,
          backgroundColor: theme.colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getConfidenceColor(confidence),
          ),
        ),
      ],
    );
  }

  IconData _getTypeIcon(PredictionType type) {
    switch (type) {
      case PredictionType.spending:
        return Icons.shopping_cart;
      case PredictionType.income:
        return Icons.attach_money;
      case PredictionType.cashFlow:
        return Icons.water_drop;
      case PredictionType.budgetUtilization:
        return Icons.pie_chart;
      case PredictionType.goalAchievement:
        return Icons.flag;
      case PredictionType.marketTrend:
        return Icons.show_chart;
    }
  }

  Color _getTypeColor(PredictionType type) {
    switch (type) {
      case PredictionType.spending:
        return Colors.orange;
      case PredictionType.income:
        return Colors.green;
      case PredictionType.cashFlow:
        return Colors.blue;
      case PredictionType.budgetUtilization:
        return Colors.purple;
      case PredictionType.goalAchievement:
        return Colors.amber;
      case PredictionType.marketTrend:
        return Colors.teal;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _getConfidenceLabel(double confidence) {
    if (confidence >= 0.8) return 'High';
    if (confidence >= 0.6) return 'Medium';
    return 'Low';
  }
}
