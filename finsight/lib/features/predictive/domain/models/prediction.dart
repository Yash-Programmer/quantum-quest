class PredictiveModel {
  final String id;
  final String name;
  final String description;
  final PredictionType type;
  final double accuracy;
  final DateTime lastTrained;
  final Map<String, dynamic> parameters;

  PredictiveModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.accuracy,
    required this.lastTrained,
    required this.parameters,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'accuracy': accuracy,
      'lastTrained': lastTrained.toIso8601String(),
      'parameters': parameters,
    };
  }

  factory PredictiveModel.fromJson(Map<String, dynamic> json) {
    return PredictiveModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: PredictionType.values.byName(json['type']),
      accuracy: json['accuracy'].toDouble(),
      lastTrained: DateTime.parse(json['lastTrained']),
      parameters: json['parameters'],
    );
  }
}

enum PredictionType {
  spending,
  income,
  cashFlow,
  budgetUtilization,
  goalAchievement,
  marketTrend,
}

extension PredictionTypeExtension on PredictionType {
  String get displayName {
    switch (this) {
      case PredictionType.spending:
        return 'Spending Prediction';
      case PredictionType.income:
        return 'Income Forecast';
      case PredictionType.cashFlow:
        return 'Cash Flow Analysis';
      case PredictionType.budgetUtilization:
        return 'Budget Utilization';
      case PredictionType.goalAchievement:
        return 'Goal Achievement';
      case PredictionType.marketTrend:
        return 'Market Trends';
    }
  }

  String get icon {
    switch (this) {
      case PredictionType.spending:
        return 'trending_down';
      case PredictionType.income:
        return 'trending_up';
      case PredictionType.cashFlow:
        return 'water_drop';
      case PredictionType.budgetUtilization:
        return 'pie_chart';
      case PredictionType.goalAchievement:
        return 'flag';
      case PredictionType.marketTrend:
        return 'show_chart';
    }
  }
}

class Prediction {
  final String id;
  final PredictionType type;
  final String title;
  final String description;
  final double predictedValue;
  final double confidence;
  final DateTime forecastDate;
  final Duration forecastPeriod;
  final List<DataPoint> historicalData;
  final List<DataPoint> predictedData;
  final Map<String, dynamic> insights;
  final PredictionStatus status;
  final DateTime createdAt;

  Prediction({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.predictedValue,
    required this.confidence,
    required this.forecastDate,
    required this.forecastPeriod,
    required this.historicalData,
    required this.predictedData,
    required this.insights,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'predictedValue': predictedValue,
      'confidence': confidence,
      'forecastDate': forecastDate.toIso8601String(),
      'forecastPeriod': forecastPeriod.inDays,
      'historicalData': historicalData.map((d) => d.toJson()).toList(),
      'predictedData': predictedData.map((d) => d.toJson()).toList(),
      'insights': insights,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      id: json['id'],
      type: PredictionType.values.byName(json['type']),
      title: json['title'],
      description: json['description'],
      predictedValue: json['predictedValue'].toDouble(),
      confidence: json['confidence'].toDouble(),
      forecastDate: DateTime.parse(json['forecastDate']),
      forecastPeriod: Duration(days: json['forecastPeriod']),
      historicalData: (json['historicalData'] as List)
          .map((d) => DataPoint.fromJson(d))
          .toList(),
      predictedData: (json['predictedData'] as List)
          .map((d) => DataPoint.fromJson(d))
          .toList(),
      insights: json['insights'],
      status: PredictionStatus.values.byName(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

enum PredictionStatus { active, completed, outdated, failed }

class DataPoint {
  final DateTime date;
  final double value;
  final String? category;
  final Map<String, dynamic>? metadata;

  DataPoint({
    required this.date,
    required this.value,
    this.category,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
      'category': category,
      'metadata': metadata,
    };
  }

  factory DataPoint.fromJson(Map<String, dynamic> json) {
    return DataPoint(
      date: DateTime.parse(json['date']),
      value: json['value'].toDouble(),
      category: json['category'],
      metadata: json['metadata'],
    );
  }
}

class FinancialTrend {
  final String category;
  final TrendDirection direction;
  final double changePercentage;
  final double significance;
  final String description;
  final List<String> factors;

  FinancialTrend({
    required this.category,
    required this.direction,
    required this.changePercentage,
    required this.significance,
    required this.description,
    required this.factors,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'direction': direction.name,
      'changePercentage': changePercentage,
      'significance': significance,
      'description': description,
      'factors': factors,
    };
  }

  factory FinancialTrend.fromJson(Map<String, dynamic> json) {
    return FinancialTrend(
      category: json['category'],
      direction: TrendDirection.values.byName(json['direction']),
      changePercentage: json['changePercentage'].toDouble(),
      significance: json['significance'].toDouble(),
      description: json['description'],
      factors: List<String>.from(json['factors']),
    );
  }
}

enum TrendDirection { increasing, decreasing, stable, volatile }

extension TrendDirectionExtension on TrendDirection {
  String get displayName {
    switch (this) {
      case TrendDirection.increasing:
        return 'Increasing';
      case TrendDirection.decreasing:
        return 'Decreasing';
      case TrendDirection.stable:
        return 'Stable';
      case TrendDirection.volatile:
        return 'Volatile';
    }
  }

  String get icon {
    switch (this) {
      case TrendDirection.increasing:
        return 'trending_up';
      case TrendDirection.decreasing:
        return 'trending_down';
      case TrendDirection.stable:
        return 'trending_flat';
      case TrendDirection.volatile:
        return 'show_chart';
    }
  }
}

class PredictiveInsight {
  final String id;
  final String title;
  final String description;
  final InsightType type;
  final double impact;
  final List<String> recommendations;
  final DateTime createdAt;
  final bool isActionable;

  PredictiveInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.impact,
    required this.recommendations,
    required this.createdAt,
    required this.isActionable,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'impact': impact,
      'recommendations': recommendations,
      'createdAt': createdAt.toIso8601String(),
      'isActionable': isActionable,
    };
  }

  factory PredictiveInsight.fromJson(Map<String, dynamic> json) {
    return PredictiveInsight(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: InsightType.values.byName(json['type']),
      impact: json['impact'].toDouble(),
      recommendations: List<String>.from(json['recommendations']),
      createdAt: DateTime.parse(json['createdAt']),
      isActionable: json['isActionable'],
    );
  }
}

enum InsightType { opportunity, warning, trend, anomaly, recommendation }

extension InsightTypeExtension on InsightType {
  String get displayName {
    switch (this) {
      case InsightType.opportunity:
        return 'Opportunity';
      case InsightType.warning:
        return 'Warning';
      case InsightType.trend:
        return 'Trend';
      case InsightType.anomaly:
        return 'Anomaly';
      case InsightType.recommendation:
        return 'Recommendation';
    }
  }
}
