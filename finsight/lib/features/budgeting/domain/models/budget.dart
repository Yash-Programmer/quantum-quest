class Budget {
  final String id;
  final String categoryId;
  final String categoryName;
  final double budgetAmount;
  final double spentAmount;
  final double remainingAmount;
  final DateTime startDate;
  final DateTime endDate;
  final BudgetPeriod period;
  final BudgetStatus status;
  final bool alertsEnabled;
  final double alertThreshold; // Percentage (e.g., 80 for 80%)
  final DateTime createdAt;
  final DateTime updatedAt;

  Budget({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.budgetAmount,
    required this.spentAmount,
    required this.startDate,
    required this.endDate,
    required this.period,
    required this.status,
    this.alertsEnabled = true,
    this.alertThreshold = 80.0,
    required this.createdAt,
    required this.updatedAt,
  }) : remainingAmount = budgetAmount - spentAmount;

  double get utilizationPercentage => 
      budgetAmount > 0 ? (spentAmount / budgetAmount) * 100 : 0;

  bool get isOverBudget => spentAmount > budgetAmount;

  bool get shouldAlert => 
      alertsEnabled && utilizationPercentage >= alertThreshold;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'budgetAmount': budgetAmount,
      'spentAmount': spentAmount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'period': period.name,
      'status': status.name,
      'alertsEnabled': alertsEnabled,
      'alertThreshold': alertThreshold,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      budgetAmount: json['budgetAmount'].toDouble(),
      spentAmount: json['spentAmount'].toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      period: BudgetPeriod.values.byName(json['period']),
      status: BudgetStatus.values.byName(json['status']),
      alertsEnabled: json['alertsEnabled'] ?? true,
      alertThreshold: json['alertThreshold']?.toDouble() ?? 80.0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Budget copyWith({
    String? id,
    String? categoryId,
    String? categoryName,
    double? budgetAmount,
    double? spentAmount,
    DateTime? startDate,
    DateTime? endDate,
    BudgetPeriod? period,
    BudgetStatus? status,
    bool? alertsEnabled,
    double? alertThreshold,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      period: period ?? this.period,
      status: status ?? this.status,
      alertsEnabled: alertsEnabled ?? this.alertsEnabled,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum BudgetPeriod {
  weekly,
  monthly,
  quarterly,
  yearly,
  custom,
}

extension BudgetPeriodExtension on BudgetPeriod {
  String get displayName {
    switch (this) {
      case BudgetPeriod.weekly:
        return 'Weekly';
      case BudgetPeriod.monthly:
        return 'Monthly';
      case BudgetPeriod.quarterly:
        return 'Quarterly';
      case BudgetPeriod.yearly:
        return 'Yearly';
      case BudgetPeriod.custom:
        return 'Custom';
    }
  }

  Duration get duration {
    switch (this) {
      case BudgetPeriod.weekly:
        return const Duration(days: 7);
      case BudgetPeriod.monthly:
        return const Duration(days: 30);
      case BudgetPeriod.quarterly:
        return const Duration(days: 90);
      case BudgetPeriod.yearly:
        return const Duration(days: 365);
      case BudgetPeriod.custom:
        return const Duration(days: 30); // Default to monthly
    }
  }
}

enum BudgetStatus {
  active,
  paused,
  completed,
  overBudget,
}

extension BudgetStatusExtension on BudgetStatus {
  String get displayName {
    switch (this) {
      case BudgetStatus.active:
        return 'Active';
      case BudgetStatus.paused:
        return 'Paused';
      case BudgetStatus.completed:
        return 'Completed';
      case BudgetStatus.overBudget:
        return 'Over Budget';
    }
  }
}

class BudgetCategory {
  final String id;
  final String name;
  final String icon;
  final String color;
  final bool isDefault;
  final int sortOrder;

  BudgetCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.isDefault = false,
    this.sortOrder = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'isDefault': isDefault,
      'sortOrder': sortOrder,
    };
  }

  factory BudgetCategory.fromJson(Map<String, dynamic> json) {
    return BudgetCategory(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      color: json['color'],
      isDefault: json['isDefault'] ?? false,
      sortOrder: json['sortOrder'] ?? 0,
    );
  }
}
