import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/predictive_provider.dart';
import '../../domain/models/prediction.dart';
import '../widgets/prediction_card.dart';
import '../widgets/trend_analysis_card.dart';
import '../widgets/insights_section.dart';
import '../widgets/forecast_chart.dart';

class PredictiveFinancePage extends ConsumerStatefulWidget {
  const PredictiveFinancePage({super.key});

  @override
  ConsumerState<PredictiveFinancePage> createState() => _PredictiveFinancePageState();
}

class _PredictiveFinancePageState extends ConsumerState<PredictiveFinancePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeframe = '30 days';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final predictiveState = ref.watch(predictiveNotifierProvider);
    final predictions = ref.watch(activePredictionsProvider);
    final insights = ref.watch(actionableInsightsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Predictive Finance',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'demo':
                  ref.read(predictiveNotifierProvider.notifier).generateDemoData();
                  break;
                case 'clear':
                  ref.read(predictiveNotifierProvider.notifier).clearPredictions();
                  break;
                case 'refresh':
                  ref.read(predictiveNotifierProvider.notifier).loadPredictiveData();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'demo',
                child: Row(
                  children: [
                    Icon(Icons.science),
                    SizedBox(width: 8),
                    Text('Generate Demo Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Clear Predictions'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Forecasts', icon: Icon(Icons.trending_up)),
            Tab(text: 'Trends', icon: Icon(Icons.analytics)),
            Tab(text: 'Insights', icon: Icon(Icons.lightbulb)),
          ],
        ),
      ),
      body: predictiveState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : predictiveState.error != null
              ? _buildErrorState(predictiveState.error!)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(predictions, insights),
                    _buildForecastsTab(predictions),
                    _buildTrendsTab(),
                    _buildInsightsTab(insights),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPredictionDialog(context),
        icon: const Icon(Icons.auto_awesome),
        label: const Text('New Prediction'),
      ),
    );
  }

  Widget _buildOverviewTab(List<Prediction> predictions, List<PredictiveInsight> insights) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickStats(predictions),
          const SizedBox(height: 20),
          _buildTimeframeSelector(),
          const SizedBox(height: 20),
          if (predictions.isNotEmpty) ...[
            Text(
              'Recent Predictions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...predictions.take(3).map((prediction) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PredictionCard(prediction: prediction),
            )),
          ],
          const SizedBox(height: 20),
          if (insights.isNotEmpty) ...[
            Text(
              'Key Insights',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            InsightsSection(insights: insights.take(2).toList()),
          ],
        ],
      ),
    );
  }

  Widget _buildForecastsTab(List<Prediction> predictions) {
    final spendingPredictions = predictions
        .where((p) => p.type == PredictionType.spending)
        .toList();
    final cashFlowPredictions = predictions
        .where((p) => p.type == PredictionType.cashFlow)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (spendingPredictions.isNotEmpty) ...[
            Text(
              'Spending Forecasts',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...spendingPredictions.map((prediction) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  PredictionCard(prediction: prediction),
                  const SizedBox(height: 8),
                  ForecastChart(prediction: prediction),
                ],
              ),
            )),
            const SizedBox(height: 20),
          ],
          if (cashFlowPredictions.isNotEmpty) ...[
            Text(
              'Cash Flow Forecasts',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...cashFlowPredictions.map((prediction) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  PredictionCard(prediction: prediction),
                  const SizedBox(height: 8),
                  ForecastChart(prediction: prediction),
                ],
              ),
            )),
          ],
          if (predictions.isEmpty) _buildEmptyState('No forecasts available'),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    final trends = ref.watch(predictiveNotifierProvider).trends;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Trends Analysis',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (trends.isNotEmpty) ...[
            ...trends.map((trend) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TrendAnalysisCard(trend: trend),
            )),
          ] else
            _buildEmptyState('No trend data available'),
        ],
      ),
    );
  }

  Widget _buildInsightsTab(List<PredictiveInsight> insights) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI-Powered Insights',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (insights.isNotEmpty) ...[
            InsightsSection(insights: insights),
          ] else
            _buildEmptyState('No insights available'),
        ],
      ),
    );
  }

  Widget _buildQuickStats(List<Prediction> predictions) {
    final spendingPredictions = predictions
        .where((p) => p.type == PredictionType.spending)
        .toList();
    final cashFlowPredictions = predictions
        .where((p) => p.type == PredictionType.cashFlow)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.dashboard, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Predictive Overview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Active Predictions',
                    predictions.length.toString(),
                    Icons.auto_awesome,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Avg Confidence',
                    predictions.isNotEmpty
                        ? '${(predictions.map((p) => p.confidence).reduce((a, b) => a + b) / predictions.length * 100).toStringAsFixed(0)}%'
                        : '0%',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Next Spending',
                    spendingPredictions.isNotEmpty
                        ? NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                            .format(spendingPredictions.first.predictedValue)
                        : '\$0',
                    Icons.payment,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Cash Flow',
                    cashFlowPredictions.isNotEmpty
                        ? NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                            .format(cashFlowPredictions.first.predictedValue)
                        : '\$0',
                    Icons.account_balance_wallet,
                    cashFlowPredictions.isNotEmpty && cashFlowPredictions.first.predictedValue < 0
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTimeframeSelector() {
    final timeframes = ['7 days', '30 days', '90 days', '1 year'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prediction Timeframe',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: timeframes.map((timeframe) {
                final isSelected = _selectedTimeframe == timeframe;
                return FilterChip(
                  label: Text(timeframe),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedTimeframe = timeframe;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Icon(
            Icons.auto_awesome_outlined,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate demo data or connect your accounts\nto start making predictions',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(predictiveNotifierProvider.notifier).generateDemoData();
            },
            icon: const Icon(Icons.science),
            label: const Text('Generate Demo Data'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Predictions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(predictiveNotifierProvider.notifier).loadPredictiveData();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showPredictionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Prediction'),
        content: const Text('What type of prediction would you like to create?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(predictiveNotifierProvider.notifier).generateDemoData();
            },
            child: const Text('Spending Forecast'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(predictiveNotifierProvider.notifier).generateDemoData();
            },
            child: const Text('Cash Flow'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
