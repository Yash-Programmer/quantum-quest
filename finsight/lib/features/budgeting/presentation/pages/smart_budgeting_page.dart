import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/budget_provider.dart';
import '../../domain/models/budget.dart';
import '../widgets/budget_summary_card.dart';
import '../widgets/budget_category_card.dart';
import '../widgets/budget_alerts_section.dart';
import '../widgets/add_budget_dialog.dart';
import '../../../../core/theme/app_theme.dart';

class SmartBudgetingPage extends ConsumerStatefulWidget {
  const SmartBudgetingPage({super.key});

  @override
  ConsumerState<SmartBudgetingPage> createState() => _SmartBudgetingPageState();
}

class _SmartBudgetingPageState extends ConsumerState<SmartBudgetingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budgets = ref.watch(budgetProvider);
    final budgetSummary = ref.watch(budgetSummaryProvider);
    final budgetAlerts = ref.watch(budgetAlertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Budgeting'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(budgetProvider.notifier).refreshBudgets();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Budgets refreshed!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddBudgetDialog(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Categories', icon: Icon(Icons.category)),
            Tab(text: 'Alerts', icon: Icon(Icons.notifications)),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(budgetSummary, budgets),
            _buildCategoriesTab(budgets),
            _buildAlertsTab(budgetAlerts),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context),
        tooltip: 'Add Budget',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildOverviewTab(Map<String, double> summary, List<Budget> budgets) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(budgetProvider.notifier).refreshBudgets();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Budget Summary Card
            BudgetSummaryCard(summary: summary),
            const SizedBox(height: 24),

            // Quick Stats
            _buildQuickStats(summary),
            const SizedBox(height: 24),

            // Recent Budget Activity
            Text(
              'Budget Performance',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildBudgetPerformanceChart(budgets),
            const SizedBox(height: 24),

            // Top Categories
            _buildTopCategories(budgets),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesTab(List<Budget> budgets) {
    final filteredBudgets = budgets.where((budget) {
      return budget.categoryName.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
    }).toList();

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search categories...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),

        // Categories List
        Expanded(
          child: filteredBudgets.isEmpty
              ? _buildEmptyBudgets()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredBudgets.length,
                  itemBuilder: (context, index) {
                    final budget = filteredBudgets[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: BudgetCategoryCard(
                        budget: budget,
                        onTap: () => _showBudgetDetails(context, budget),
                        onEdit: () => _showEditBudgetDialog(context, budget),
                        onDelete: () => _deleteBudget(budget.id),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAlertsTab(List<Budget> alertBudgets) {
    return alertBudgets.isEmpty
        ? _buildNoAlerts()
        : BudgetAlertsSection(alertBudgets: alertBudgets);
  }

  Widget _buildQuickStats(Map<String, double> summary) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Budget',
            currencyFormat.format(summary['totalBudget']),
            Icons.account_balance_wallet,
            AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Spent',
            currencyFormat.format(summary['totalSpent']),
            Icons.shopping_cart,
            AppTheme.errorColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Remaining',
            currencyFormat.format(summary['totalRemaining']),
            Icons.savings,
            AppTheme.successColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetPerformanceChart(List<Budget> budgets) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: budgets.take(5).map((budget) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(budget.categoryName),
                      Text(
                        '${budget.utilizationPercentage.toStringAsFixed(1)}%',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: budget.utilizationPercentage / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      budget.isOverBudget
                          ? AppTheme.errorColor
                          : budget.utilizationPercentage > 80
                          ? AppTheme.warningColor
                          : AppTheme.successColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTopCategories(List<Budget> budgets) {
    final sortedBudgets = [...budgets]
      ..sort((a, b) => b.spentAmount.compareTo(a.spentAmount));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Spending Categories',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...sortedBudgets.take(3).map((budget) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: budget.isOverBudget
                    ? AppTheme.errorColor
                    : AppTheme.primaryColor,
                child: Text(
                  '${budget.utilizationPercentage.toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              title: Text(budget.categoryName),
              subtitle: Text(
                '₹${budget.spentAmount.toStringAsFixed(0)} of ₹${budget.budgetAmount.toStringAsFixed(0)}',
              ),
              trailing: budget.isOverBudget
                  ? Icon(Icons.warning, color: AppTheme.errorColor)
                  : Icon(Icons.check_circle, color: AppTheme.successColor),
              onTap: () => _showBudgetDetails(context, budget),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyBudgets() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No budgets found',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first budget to start tracking your spending',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddBudgetDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Budget'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoAlerts() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: AppTheme.successColor,
          ),
          const SizedBox(height: 16),
          Text(
            'All Good! 🎉',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.successColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No budget alerts at the moment.\nKeep up the great spending habits!',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddBudgetDialog(
        onBudgetCreated: (budget) {
          ref.read(budgetProvider.notifier).addBudget(budget);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Budget for ${budget.categoryName} created!'),
            ),
          );
        },
      ),
    );
  }

  void _showEditBudgetDialog(BuildContext context, Budget budget) {
    showDialog(
      context: context,
      builder: (context) => AddBudgetDialog(
        budget: budget,
        onBudgetCreated: (updatedBudget) {
          ref.read(budgetProvider.notifier).updateBudget(updatedBudget);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Budget for ${updatedBudget.categoryName} updated!',
              ),
            ),
          );
        },
      ),
    );
  }

  void _showBudgetDetails(BuildContext context, Budget budget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    budget.categoryName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBudgetDetailCard(budget),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBudgetDetailCard(Budget budget) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Budget Amount'),
                Text(
                  currencyFormat.format(budget.budgetAmount),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Spent Amount'),
                Text(
                  currencyFormat.format(budget.spentAmount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: budget.isOverBudget ? AppTheme.errorColor : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Remaining'),
                Text(
                  currencyFormat.format(budget.remainingAmount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: budget.remainingAmount >= 0
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: budget.utilizationPercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                budget.isOverBudget
                    ? AppTheme.errorColor
                    : budget.utilizationPercentage > 80
                    ? AppTheme.warningColor
                    : AppTheme.successColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${budget.utilizationPercentage.toStringAsFixed(1)}% utilized',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  void _deleteBudget(String budgetId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: const Text('Are you sure you want to delete this budget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(budgetProvider.notifier).deleteBudget(budgetId);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Budget deleted!')));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
