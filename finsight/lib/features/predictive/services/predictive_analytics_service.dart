import 'dart:convert';
import 'dart:math';
import '../../../core/services/local_storage_service.dart';
import '../domain/models/prediction.dart';

class PredictiveAnalyticsService {
  final LocalStorageService _storage = LocalStorageService();
  static const String _predictionsKey = 'predictions';
  static const String _trendsKey = 'financial_trends';

  // Save predictions to local storage
  Future<void> savePredictions(List<Prediction> predictions) async {
    final predictionsJson = predictions.map((p) => p.toJson()).toList();
    await _storage.setStringList(
      _predictionsKey,
      predictionsJson.map(jsonEncode).toList(),
    );
  }

  // Load predictions from local storage
  Future<List<Prediction>> loadPredictions() async {
    final predictionsJson = await _storage.getStringList(_predictionsKey) ?? [];
    return predictionsJson
        .map((jsonStr) => Prediction.fromJson(jsonDecode(jsonStr)))
        .toList();
  }

  // Generate spending prediction using linear regression
  Future<Prediction> generateSpendingPrediction(
    List<DataPoint> historicalData,
  ) async {
    if (historicalData.isEmpty) {
      throw Exception('Insufficient data for prediction');
    }

    final sortedData = List<DataPoint>.from(historicalData)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Simple linear regression
    final regression = _performLinearRegression(sortedData);
    final futureDate = DateTime.now().add(const Duration(days: 30));
    final predictedValue = _predictValue(regression, futureDate);

    // Generate prediction data points
    final predictedData = <DataPoint>[];
    for (int i = 1; i <= 30; i++) {
      final date = DateTime.now().add(Duration(days: i));
      final value = _predictValue(regression, date);
      predictedData.add(DataPoint(date: date, value: value));
    }

    // Calculate confidence based on R-squared
    final confidence = _calculateConfidence(sortedData, regression);

    return Prediction(
      id: _generateId(),
      type: PredictionType.spending,
      title: 'Monthly Spending Forecast',
      description:
          'Predicted spending for the next 30 days based on historical patterns',
      predictedValue: predictedValue,
      confidence: confidence,
      forecastDate: futureDate,
      forecastPeriod: const Duration(days: 30),
      historicalData: sortedData,
      predictedData: predictedData,
      insights: _generateSpendingInsights(sortedData, predictedValue),
      status: PredictionStatus.active,
      createdAt: DateTime.now(),
    );
  }

  // Generate cash flow prediction
  Future<Prediction> generateCashFlowPrediction(
    List<DataPoint> incomeData,
    List<DataPoint> expenseData,
  ) async {
    final incomeRegression = _performLinearRegression(incomeData);
    final expenseRegression = _performLinearRegression(expenseData);

    final predictedData = <DataPoint>[];
    for (int i = 1; i <= 90; i++) {
      final date = DateTime.now().add(Duration(days: i));
      final income = _predictValue(incomeRegression, date);
      final expenses = _predictValue(expenseRegression, date);
      final cashFlow = income - expenses;
      predictedData.add(DataPoint(date: date, value: cashFlow));
    }

    final futureDate = DateTime.now().add(const Duration(days: 90));
    final predictedIncome = _predictValue(incomeRegression, futureDate);
    final predictedExpenses = _predictValue(expenseRegression, futureDate);
    final predictedCashFlow = predictedIncome - predictedExpenses;

    return Prediction(
      id: _generateId(),
      type: PredictionType.cashFlow,
      title: 'Quarterly Cash Flow Forecast',
      description: 'Predicted cash flow for the next 90 days',
      predictedValue: predictedCashFlow,
      confidence:
          (_calculateConfidence(incomeData, incomeRegression) +
              _calculateConfidence(expenseData, expenseRegression)) /
          2,
      forecastDate: futureDate,
      forecastPeriod: const Duration(days: 90),
      historicalData: [...incomeData, ...expenseData],
      predictedData: predictedData,
      insights: _generateCashFlowInsights(predictedCashFlow),
      status: PredictionStatus.active,
      createdAt: DateTime.now(),
    );
  }

  // Analyze financial trends
  Future<List<FinancialTrend>> analyzeFinancialTrends(
    Map<String, List<DataPoint>> categoryData,
  ) async {
    final trends = <FinancialTrend>[];

    for (final entry in categoryData.entries) {
      final category = entry.key;
      final data = entry.value;

      if (data.length < 3) continue;

      final sortedData = List<DataPoint>.from(data)
        ..sort((a, b) => a.date.compareTo(b.date));

      final trend = _analyzeCategoryTrend(category, sortedData);
      trends.add(trend);
    }

    // Save trends to storage
    await _saveTrends(trends);

    return trends;
  }

  // Generate predictive insights
  Future<List<PredictiveInsight>> generateInsights(
    List<Prediction> predictions,
    List<FinancialTrend> trends,
  ) async {
    final insights = <PredictiveInsight>[];

    // Spending insights
    final spendingPredictions = predictions
        .where((p) => p.type == PredictionType.spending)
        .toList();

    for (final prediction in spendingPredictions) {
      if (prediction.confidence > 0.7 && prediction.predictedValue > 0) {
        insights.add(_generateSpendingInsight(prediction));
      }
    }

    // Cash flow insights
    final cashFlowPredictions = predictions
        .where((p) => p.type == PredictionType.cashFlow)
        .toList();

    for (final prediction in cashFlowPredictions) {
      if (prediction.predictedValue < 0) {
        insights.add(_generateCashFlowWarning(prediction));
      }
    }

    // Trend insights
    for (final trend in trends) {
      if (trend.significance > 0.6) {
        insights.add(_generateTrendInsight(trend));
      }
    }

    return insights;
  }

  // Machine learning utilities
  Map<String, double> _performLinearRegression(List<DataPoint> data) {
    final n = data.length;
    if (n < 2) return {'slope': 0, 'intercept': 0};

    double sumX = 0, sumY = 0, sumXY = 0, sumXX = 0;

    for (int i = 0; i < n; i++) {
      final x = i.toDouble(); // Use index as x value
      final y = data[i].value;
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumXX += x * x;
    }

    final slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;

    return {'slope': slope, 'intercept': intercept};
  }

  double _predictValue(Map<String, double> regression, DateTime date) {
    final daysSinceEpoch = date.millisecondsSinceEpoch / (1000 * 60 * 60 * 24);
    return regression['slope']! * daysSinceEpoch + regression['intercept']!;
  }

  double _calculateConfidence(
    List<DataPoint> data,
    Map<String, double> regression,
  ) {
    if (data.length < 2) return 0.5;

    double totalSumSquares = 0;
    double residualSumSquares = 0;
    final mean = data.map((d) => d.value).reduce((a, b) => a + b) / data.length;

    for (int i = 0; i < data.length; i++) {
      final actual = data[i].value;
      final predicted = regression['slope']! * i + regression['intercept']!;

      totalSumSquares += pow(actual - mean, 2);
      residualSumSquares += pow(actual - predicted, 2);
    }

    final rSquared = 1 - (residualSumSquares / totalSumSquares);
    return max(0.1, min(0.95, rSquared));
  }

  FinancialTrend _analyzeCategoryTrend(String category, List<DataPoint> data) {
    final firstValue = data.first.value;
    final lastValue = data.last.value;
    final changePercentage = ((lastValue - firstValue) / firstValue) * 100;

    TrendDirection direction;
    if (changePercentage.abs() < 5) {
      direction = TrendDirection.stable;
    } else if (changePercentage > 0) {
      direction = TrendDirection.increasing;
    } else {
      direction = TrendDirection.decreasing;
    }

    // Calculate volatility
    final variance = _calculateVariance(data);
    if (variance > 1000) {
      direction = TrendDirection.volatile;
    }

    return FinancialTrend(
      category: category,
      direction: direction,
      changePercentage: changePercentage,
      significance: min(1.0, changePercentage.abs() / 100),
      description: _generateTrendDescription(
        category,
        direction,
        changePercentage,
      ),
      factors: _identifyTrendFactors(direction, changePercentage),
    );
  }

  double _calculateVariance(List<DataPoint> data) {
    final mean = data.map((d) => d.value).reduce((a, b) => a + b) / data.length;
    final variance =
        data.map((d) => pow(d.value - mean, 2)).reduce((a, b) => a + b) /
        data.length;
    return variance;
  }

  Map<String, dynamic> _generateSpendingInsights(
    List<DataPoint> data,
    double predicted,
  ) {
    final currentAverage =
        data.map((d) => d.value).reduce((a, b) => a + b) / data.length;
    final change = ((predicted - currentAverage) / currentAverage) * 100;

    return {
      'currentAverage': currentAverage,
      'predictedChange': change,
      'recommendation': change > 10
          ? 'Consider reviewing your budget to control spending'
          : 'Your spending is on track',
      'riskLevel': change > 20
          ? 'High'
          : change > 10
          ? 'Medium'
          : 'Low',
    };
  }

  Map<String, dynamic> _generateCashFlowInsights(double predictedCashFlow) {
    return {
      'predictedCashFlow': predictedCashFlow,
      'status': predictedCashFlow > 0 ? 'Positive' : 'Negative',
      'recommendation': predictedCashFlow < 0
          ? 'Consider reducing expenses or increasing income'
          : 'Your cash flow looks healthy',
      'urgency': predictedCashFlow < -500 ? 'High' : 'Low',
    };
  }

  PredictiveInsight _generateSpendingInsight(Prediction prediction) {
    final change = prediction.insights['predictedChange'] as double;

    return PredictiveInsight(
      id: _generateId(),
      title: change > 0
          ? 'Spending Increase Expected'
          : 'Spending Optimization Opportunity',
      description:
          'Based on your spending patterns, we predict a ${change.toStringAsFixed(1)}% change in spending',
      type: change > 15 ? InsightType.warning : InsightType.opportunity,
      impact: change.abs() / 100,
      recommendations: _getSpendingRecommendations(change),
      createdAt: DateTime.now(),
      isActionable: true,
    );
  }

  PredictiveInsight _generateCashFlowWarning(Prediction prediction) {
    return PredictiveInsight(
      id: _generateId(),
      title: 'Negative Cash Flow Alert',
      description:
          'Your predicted cash flow shows a deficit of \$${prediction.predictedValue.abs().toStringAsFixed(2)}',
      type: InsightType.warning,
      impact: 0.8,
      recommendations: [
        'Review and reduce unnecessary expenses',
        'Consider additional income sources',
        'Create an emergency fund',
        'Optimize your budget allocation',
      ],
      createdAt: DateTime.now(),
      isActionable: true,
    );
  }

  PredictiveInsight _generateTrendInsight(FinancialTrend trend) {
    return PredictiveInsight(
      id: _generateId(),
      title: '${trend.category} Trend: ${trend.direction.displayName}',
      description: trend.description,
      type: InsightType.trend,
      impact: trend.significance,
      recommendations: trend.factors,
      createdAt: DateTime.now(),
      isActionable: trend.direction != TrendDirection.stable,
    );
  }

  List<String> _getSpendingRecommendations(double change) {
    if (change > 15) {
      return [
        'Review your recent transactions for unusual expenses',
        'Set stricter budget limits for discretionary spending',
        'Consider using the envelope budgeting method',
        'Track daily expenses more closely',
      ];
    } else if (change < -10) {
      return [
        'Great job on reducing spending!',
        'Consider investing the saved money',
        'Build your emergency fund',
        'Reward yourself for good financial habits',
      ];
    } else {
      return [
        'Your spending is stable',
        'Continue monitoring your expenses',
        'Look for optimization opportunities',
      ];
    }
  }

  String _generateTrendDescription(
    String category,
    TrendDirection direction,
    double change,
  ) {
    switch (direction) {
      case TrendDirection.increasing:
        return '$category spending has increased by ${change.toStringAsFixed(1)}%';
      case TrendDirection.decreasing:
        return '$category spending has decreased by ${change.abs().toStringAsFixed(1)}%';
      case TrendDirection.stable:
        return '$category spending remains stable';
      case TrendDirection.volatile:
        return '$category spending shows high volatility';
    }
  }

  List<String> _identifyTrendFactors(TrendDirection direction, double change) {
    switch (direction) {
      case TrendDirection.increasing:
        return [
          'Review recent purchases in this category',
          'Set spending alerts',
          'Consider alternatives or substitutes',
        ];
      case TrendDirection.decreasing:
        return [
          'Excellent cost control',
          'Consider reallocating savings',
          'Maintain current strategies',
        ];
      case TrendDirection.volatile:
        return [
          'Create more consistent spending habits',
          'Use budget planning tools',
          'Set weekly spending targets',
        ];
      default:
        return ['Continue current spending patterns'];
    }
  }

  Future<void> _saveTrends(List<FinancialTrend> trends) async {
    final trendsJson = trends.map((t) => t.toJson()).toList();
    await _storage.setStringList(
      _trendsKey,
      trendsJson.map(jsonEncode).toList(),
    );
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(1000).toString();
  }
}
