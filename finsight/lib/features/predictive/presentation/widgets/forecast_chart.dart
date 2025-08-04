import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../domain/models/prediction.dart';

class ForecastChart extends StatelessWidget {
  final Prediction prediction;

  const ForecastChart({super.key, required this.prediction});

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
                  Icons.show_chart,
                  color: _getTypeColor(prediction.type),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Forecast Chart',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getTypeColor(
                      prediction.type,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getTypeColor(prediction.type),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${prediction.forecastPeriod.inDays} days',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getTypeColor(prediction.type),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(height: 200, child: LineChart(_buildChartData(context))),
            const SizedBox(height: 16),
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  LineChartData _buildChartData(BuildContext context) {
    final theme = Theme.of(context);
    final historicalSpots = <FlSpot>[];
    final predictedSpots = <FlSpot>[];

    // Convert historical data to chart spots
    for (int i = 0; i < prediction.historicalData.length; i++) {
      historicalSpots.add(
        FlSpot(i.toDouble(), prediction.historicalData[i].value),
      );
    }

    // Convert predicted data to chart spots
    final startIndex = prediction.historicalData.length;
    for (int i = 0; i < prediction.predictedData.length; i++) {
      predictedSpots.add(
        FlSpot((startIndex + i).toDouble(), prediction.predictedData[i].value),
      );
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: true,
        horizontalInterval: _calculateInterval(
          prediction.historicalData,
          prediction.predictedData,
        ),
        verticalInterval: 5,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 5,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < prediction.historicalData.length) {
                return Text(
                  DateFormat(
                    'M/d',
                  ).format(prediction.historicalData[index].date),
                  style: theme.textTheme.bodySmall,
                );
              } else if (index - prediction.historicalData.length <
                  prediction.predictedData.length) {
                return Text(
                  DateFormat('M/d').format(
                    prediction
                        .predictedData[index - prediction.historicalData.length]
                        .date,
                  ),
                  style: theme.textTheme.bodySmall,
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 60,
            getTitlesWidget: (value, meta) {
              return Text(
                NumberFormat.compact().format(value),
                style: theme.textTheme.bodySmall,
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      lineBarsData: [
        // Historical data line
        LineChartBarData(
          spots: historicalSpots,
          isCurved: true,
          color: _getTypeColor(prediction.type),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: _getTypeColor(prediction.type),
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: _getTypeColor(prediction.type).withValues(alpha: 0.1),
          ),
        ),
        // Predicted data line
        LineChartBarData(
          spots: predictedSpots,
          isCurved: true,
          color: _getTypeColor(prediction.type).withValues(alpha: 0.7),
          barWidth: 3,
          isStrokeCapRound: true,
          dashArray: [5, 5], // Dashed line for predictions
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: _getTypeColor(prediction.type).withValues(alpha: 0.7),
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: _getTypeColor(prediction.type).withValues(alpha: 0.05),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final isHistorical = spot.x < prediction.historicalData.length;
              final label = isHistorical ? 'Historical' : 'Predicted';
              return LineTooltipItem(
                '$label\n${NumberFormat.currency(symbol: '\$').format(spot.y)}',
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          context,
          'Historical Data',
          _getTypeColor(prediction.type),
          isStrokeCapRound: false,
        ),
        const SizedBox(width: 24),
        _buildLegendItem(
          context,
          'Predicted Data',
          _getTypeColor(prediction.type).withValues(alpha: 0.7),
          isDashed: true,
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color, {
    bool isDashed = false,
    bool isStrokeCapRound = true,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: isDashed ? Colors.transparent : color,
            borderRadius: isStrokeCapRound ? BorderRadius.circular(2) : null,
          ),
          child: isDashed
              ? CustomPaint(
                  painter: DashedLinePainter(color: color),
                  child: Container(),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  double _calculateInterval(
    List<DataPoint> historical,
    List<DataPoint> predicted,
  ) {
    final allValues = [
      ...historical.map((d) => d.value),
      ...predicted.map((d) => d.value),
    ];

    if (allValues.isEmpty) return 100;

    final min = allValues.reduce((a, b) => a < b ? a : b);
    final max = allValues.reduce((a, b) => a > b ? a : b);
    final range = max - min;

    return range / 5; // Divide into 5 intervals
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
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  DashedLinePainter({required this.color, this.strokeWidth = 3});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const dashWidth = 3.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
