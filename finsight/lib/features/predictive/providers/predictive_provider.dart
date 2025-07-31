import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/prediction.dart';
import '../services/predictive_analytics_service.dart';

final predictiveAnalyticsServiceProvider = Provider<PredictiveAnalyticsService>((ref) {
  return PredictiveAnalyticsService();
});

final predictiveNotifierProvider = StateNotifierProvider<PredictiveNotifier, PredictiveState>((ref) {
  final service = ref.watch(predictiveAnalyticsServiceProvider);
  return PredictiveNotifier(service);
});

class PredictiveState {
  final List<Prediction> predictions;
  final List<FinancialTrend> trends;
  final List<PredictiveInsight> insights;
  final bool isLoading;
  final String? error;

  PredictiveState({
    this.predictions = const [],
    this.trends = const [],
    this.insights = const [],
    this.isLoading = false,
    this.error,
  });

  PredictiveState copyWith({
    List<Prediction>? predictions,
    List<FinancialTrend>? trends,
    List<PredictiveInsight>? insights,
    bool? isLoading,
    String? error,
  }) {
    return PredictiveState(
      predictions: predictions ?? this.predictions,
      trends: trends ?? this.trends,
      insights: insights ?? this.insights,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class PredictiveNotifier extends StateNotifier<PredictiveState> {
  final PredictiveAnalyticsService _service;

  PredictiveNotifier(this._service) : super(PredictiveState()) {
    loadPredictiveData();
  }

  Future<void> loadPredictiveData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final predictions = await _service.loadPredictions();
      state = state.copyWith(
        predictions: predictions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> generateSpendingForecast(List<DataPoint> historicalData) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final prediction = await _service.generateSpendingPrediction(historicalData);
      final updatedPredictions = [...state.predictions];
      
      // Remove old spending predictions
      updatedPredictions.removeWhere((p) => p.type == PredictionType.spending);
      updatedPredictions.add(prediction);
      
      await _service.savePredictions(updatedPredictions);
      state = state.copyWith(
        predictions: updatedPredictions,
        isLoading: false,
      );
      
      // Generate insights after creating prediction
      await _generateInsights();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> generateCashFlowForecast(
    List<DataPoint> incomeData,
    List<DataPoint> expenseData,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final prediction = await _service.generateCashFlowPrediction(incomeData, expenseData);
      final updatedPredictions = [...state.predictions];
      
      // Remove old cash flow predictions
      updatedPredictions.removeWhere((p) => p.type == PredictionType.cashFlow);
      updatedPredictions.add(prediction);
      
      await _service.savePredictions(updatedPredictions);
      state = state.copyWith(
        predictions: updatedPredictions,
        isLoading: false,
      );
      
      await _generateInsights();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> analyzeTrends(Map<String, List<DataPoint>> categoryData) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final trends = await _service.analyzeFinancialTrends(categoryData);
      state = state.copyWith(
        trends: trends,
        isLoading: false,
      );
      
      await _generateInsights();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> _generateInsights() async {
    try {
      final insights = await _service.generateInsights(state.predictions, state.trends);
      state = state.copyWith(insights: insights);
    } catch (e) {
      // Don't update error state as this is a secondary operation
      print('Error generating insights: $e');
    }
  }

  Future<void> clearPredictions() async {
    await _service.savePredictions([]);
    state = state.copyWith(
      predictions: [],
      trends: [],
      insights: [],
    );
  }

  Future<void> removePrediction(String predictionId) async {
    final updatedPredictions = state.predictions
        .where((p) => p.id != predictionId)
        .toList();
    
    await _service.savePredictions(updatedPredictions);
    state = state.copyWith(predictions: updatedPredictions);
    
    await _generateInsights();
  }

  // Generate demo data for testing
  Future<void> generateDemoData() async {
    final now = DateTime.now();
    final demoSpendingData = <DataPoint>[];
    final demoIncomeData = <DataPoint>[];
    final demoExpenseData = <DataPoint>[];
    
    // Generate 30 days of demo data
    for (int i = 30; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final baseSpending = 50 + (i % 7) * 10; // Weekly pattern
      final randomVariation = (Random().nextDouble() - 0.5) * 20;
      
      demoSpendingData.add(DataPoint(
        date: date,
        value: baseSpending + randomVariation,
        category: 'Food & Dining',
      ));
      
      demoIncomeData.add(DataPoint(
        date: date,
        value: 2000 + randomVariation * 5,
        category: 'Salary',
      ));
      
      demoExpenseData.add(DataPoint(
        date: date,
        value: 1200 + randomVariation * 3,
        category: 'Total Expenses',
      ));
    }
    
    // Generate predictions
    await generateSpendingForecast(demoSpendingData);
    await generateCashFlowForecast(demoIncomeData, demoExpenseData);
    
    // Generate trends
    final categoryData = {
      'Food & Dining': demoSpendingData,
      'Transportation': demoSpendingData.map((d) => DataPoint(
        date: d.date,
        value: d.value * 0.7,
        category: 'Transportation',
      )).toList(),
      'Entertainment': demoSpendingData.map((d) => DataPoint(
        date: d.date,
        value: d.value * 0.5,
        category: 'Entertainment',
      )).toList(),
    };
    
    await analyzeTrends(categoryData);
  }
}

// Providers for specific prediction types
final spendingPredictionsProvider = Provider<List<Prediction>>((ref) {
  final state = ref.watch(predictiveNotifierProvider);
  return state.predictions
      .where((p) => p.type == PredictionType.spending)
      .toList();
});

final cashFlowPredictionsProvider = Provider<List<Prediction>>((ref) {
  final state = ref.watch(predictiveNotifierProvider);
  return state.predictions
      .where((p) => p.type == PredictionType.cashFlow)
      .toList();
});

final activePredictionsProvider = Provider<List<Prediction>>((ref) {
  final state = ref.watch(predictiveNotifierProvider);
  return state.predictions
      .where((p) => p.status == PredictionStatus.active)
      .toList();
});

final highImpactInsightsProvider = Provider<List<PredictiveInsight>>((ref) {
  final state = ref.watch(predictiveNotifierProvider);
  return state.insights
      .where((i) => i.impact > 0.6)
      .toList();
});

final actionableInsightsProvider = Provider<List<PredictiveInsight>>((ref) {
  final state = ref.watch(predictiveNotifierProvider);
  return state.insights
      .where((i) => i.isActionable)
      .toList();
});
