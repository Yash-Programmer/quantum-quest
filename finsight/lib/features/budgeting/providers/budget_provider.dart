import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/budget.dart';
import '../../../core/services/local_storage_service.dart';
import 'dart:convert';

class BudgetNotifier extends StateNotifier<List<Budget>> {
  final LocalStorageService _localStorageService;
  
  BudgetNotifier(this._localStorageService) : super([]) {
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    try {
      final budgetsJson = await _localStorageService.getString('budgets');
      if (budgetsJson != null) {
        final List<dynamic> budgetsList = jsonDecode(budgetsJson);
        final budgets = budgetsList.map((json) => Budget.fromJson(json)).toList();
        state = budgets;
      } else {
        // Load default budgets for first time users
        _loadDefaultBudgets();
      }
    } catch (e) {
      // Handle error - could log or show error message
      _loadDefaultBudgets();
    }
  }

  void _loadDefaultBudgets() {
    final defaultBudgets = [
      Budget(
        id: '1',
        categoryId: 'food',
        categoryName: 'Food & Dining',
        budgetAmount: 8000,
        spentAmount: 5420,
        startDate: DateTime.now().subtract(Duration(days: DateTime.now().day - 1)),
        endDate: DateTime.now().add(Duration(days: 30 - DateTime.now().day)),
        period: BudgetPeriod.monthly,
        status: BudgetStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Budget(
        id: '2',
        categoryId: 'entertainment',
        categoryName: 'Entertainment',
        budgetAmount: 3000,
        spentAmount: 2700,
        startDate: DateTime.now().subtract(Duration(days: DateTime.now().day - 1)),
        endDate: DateTime.now().add(Duration(days: 30 - DateTime.now().day)),
        period: BudgetPeriod.monthly,
        status: BudgetStatus.active,
        alertThreshold: 90.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Budget(
        id: '3',
        categoryId: 'transportation',
        categoryName: 'Transportation',
        budgetAmount: 2500,
        spentAmount: 1200,
        startDate: DateTime.now().subtract(Duration(days: DateTime.now().day - 1)),
        endDate: DateTime.now().add(Duration(days: 30 - DateTime.now().day)),
        period: BudgetPeriod.monthly,
        status: BudgetStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    state = defaultBudgets;
    _saveBudgets();
  }

  Future<void> _saveBudgets() async {
    try {
      final budgetsJson = jsonEncode(state.map((budget) => budget.toJson()).toList());
      await _localStorageService.setString('budgets', budgetsJson);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> addBudget(Budget budget) async {
    state = [...state, budget];
    await _saveBudgets();
  }

  Future<void> updateBudget(Budget updatedBudget) async {
    state = state.map((budget) {
      return budget.id == updatedBudget.id ? updatedBudget : budget;
    }).toList();
    await _saveBudgets();
  }

  Future<void> deleteBudget(String budgetId) async {
    state = state.where((budget) => budget.id != budgetId).toList();
    await _saveBudgets();
  }

  Future<void> updateSpentAmount(String categoryId, double newSpentAmount) async {
    state = state.map((budget) {
      if (budget.categoryId == categoryId) {
        return budget.copyWith(
          spentAmount: newSpentAmount,
          updatedAt: DateTime.now(),
          status: newSpentAmount > budget.budgetAmount 
              ? BudgetStatus.overBudget 
              : BudgetStatus.active,
        );
      }
      return budget;
    }).toList();
    await _saveBudgets();
  }

  List<Budget> getBudgetsWithAlerts() {
    return state.where((budget) => budget.shouldAlert || budget.isOverBudget).toList();
  }

  Budget? getBudgetByCategory(String categoryId) {
    try {
      return state.firstWhere((budget) => budget.categoryId == categoryId);
    } catch (e) {
      return null;
    }
  }

  double getTotalBudgetAmount() {
    return state.fold(0.0, (sum, budget) => sum + budget.budgetAmount);
  }

  double getTotalSpentAmount() {
    return state.fold(0.0, (sum, budget) => sum + budget.spentAmount);
  }

  double getOverallUtilization() {
    final totalBudget = getTotalBudgetAmount();
    return totalBudget > 0 ? (getTotalSpentAmount() / totalBudget) * 100 : 0;
  }

  void refreshBudgets() {
    _loadBudgets();
  }
}

// Providers
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final budgetProvider = StateNotifierProvider<BudgetNotifier, List<Budget>>((ref) {
  final localStorageService = ref.watch(localStorageServiceProvider);
  return BudgetNotifier(localStorageService);
});

final budgetCategoriesProvider = Provider<List<BudgetCategory>>((ref) {
  return [
    BudgetCategory(
      id: 'food',
      name: 'Food & Dining',
      icon: 'restaurant',
      color: '#FF6B6B',
      isDefault: true,
      sortOrder: 1,
    ),
    BudgetCategory(
      id: 'entertainment',
      name: 'Entertainment',
      icon: 'movie',
      color: '#4ECDC4',
      isDefault: true,
      sortOrder: 2,
    ),
    BudgetCategory(
      id: 'transportation',
      name: 'Transportation',
      icon: 'directions_car',
      color: '#45B7D1',
      isDefault: true,
      sortOrder: 3,
    ),
    BudgetCategory(
      id: 'shopping',
      name: 'Shopping',
      icon: 'shopping_bag',
      color: '#96CEB4',
      isDefault: true,
      sortOrder: 4,
    ),
    BudgetCategory(
      id: 'health',
      name: 'Health & Fitness',
      icon: 'fitness_center',
      color: '#FFEAA7',
      isDefault: true,
      sortOrder: 5,
    ),
    BudgetCategory(
      id: 'education',
      name: 'Education',
      icon: 'school',
      color: '#DDA0DD',
      isDefault: true,
      sortOrder: 6,
    ),
    BudgetCategory(
      id: 'utilities',
      name: 'Utilities',
      icon: 'bolt',
      color: '#FD79A8',
      isDefault: true,
      sortOrder: 7,
    ),
    BudgetCategory(
      id: 'subscriptions',
      name: 'Subscriptions',
      icon: 'subscriptions',
      color: '#74B9FF',
      isDefault: true,
      sortOrder: 8,
    ),
  ];
});

final budgetAlertsProvider = Provider<List<Budget>>((ref) {
  final budgets = ref.watch(budgetProvider);
  return budgets.where((budget) => budget.shouldAlert || budget.isOverBudget).toList();
});

final budgetSummaryProvider = Provider<Map<String, double>>((ref) {
  final budgets = ref.watch(budgetProvider);
  final totalBudget = budgets.fold(0.0, (sum, budget) => sum + budget.budgetAmount);
  final totalSpent = budgets.fold(0.0, (sum, budget) => sum + budget.spentAmount);
  final totalRemaining = totalBudget - totalSpent;
  final utilizationPercentage = totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0.0;

  return {
    'totalBudget': totalBudget,
    'totalSpent': totalSpent,
    'totalRemaining': totalRemaining,
    'utilizationPercentage': utilizationPercentage,
  };
});
