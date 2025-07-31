import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../widgets/financial_health_score.dart';
import '../widgets/quick_summary_tiles.dart';
import '../widgets/recent_activity_timeline.dart';
import '../widgets/quick_actions_row.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedIndex = 0;

  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.account_balance_wallet),
      label: 'Budget',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.trending_up),
      label: 'Predictive',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.smart_toy),
      label: 'AI Chat',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.school),
      label: 'Knowledge',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 32,
              width: 32,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.account_balance, size: 32);
              },
            ),
            const SizedBox(width: 8),
            const Text('FinSight'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Show notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _showDrawerMenu(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildDashboardTab(),
            _buildBudgetingTab(),
            _buildPredictiveTab(),
            _buildChatbotTab(),
            _buildKnowledgeTab(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          
          // Navigate to different routes based on index
          switch (index) {
            case 0:
              // Stay on dashboard
              break;
            case 1:
              context.go(AppRouter.budgeting);
              break;
            case 2:
              context.go(AppRouter.predictive);
              break;
            case 3:
              context.go(AppRouter.chatbot);
              break;
            case 4:
              context.go(AppRouter.knowledge);
              break;
          }
        },
        items: _navItems,
      ),
    );
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh dashboard data
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Extra bottom padding to prevent overflow
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Section
            _buildGreetingSection(),
            const SizedBox(height: 24),
            
            // Financial Health Score
            const FinancialHealthScore(),
            const SizedBox(height: 24),
            
            // Quick Summary Tiles
            const QuickSummaryTiles(),
            const SizedBox(height: 24),
            
            // Recent Activity Timeline
            const RecentActivityTimeline(),
            const SizedBox(height: 24),
            
            // Quick Actions
            const QuickActionsRow(),
            const SizedBox(height: 24),
            
            // AI Tip Card
            _buildAITipCard(),
            
            // Extra bottom space to prevent overflow with bottom navigation
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    final hour = DateTime.now().hour;
    String greeting = 'Good morning';
    String emoji = '🌅';
    
    if (hour >= 12 && hour < 17) {
      greeting = 'Good afternoon';
      emoji = '☀️';
    } else if (hour >= 17) {
      greeting = 'Good evening';
      emoji = '🌙';
    }

    return Card(
      elevation: 0,
      color: AppTheme.primaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting, User! $emoji',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Today is ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAITipCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppTheme.accentColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Smart Tip',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '💡 Consider setting up an emergency fund with 3-6 months of expenses. This creates a financial safety net for unexpected situations.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  context.go(AppRouter.chatbot);
                },
                child: const Text('Ask AI More'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetingTab() {
    return const Center(
      child: Text(
        'Smart Budgeting\nComing Soon!',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPredictiveTab() {
    return const Center(
      child: Text(
        'Predictive Finance\nComing Soon!',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildChatbotTab() {
    return const Center(
      child: Text(
        'AI Assistant\nComing Soon!',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildKnowledgeTab() {
    return const Center(
      child: Text(
        'Knowledge Hub\nComing Soon!',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showDrawerMenu(BuildContext context) {
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
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'FinSight Features',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDrawerMenuItem(
                  context,
                  'Goals Planner',
                  Icons.flag,
                  AppRouter.goals,
                ),
                _buildDrawerMenuItem(
                  context,
                  'Loan Planner',
                  Icons.money_off,
                  AppRouter.loan,
                ),
                _buildDrawerMenuItem(
                  context,
                  'FIRE Calculator',
                  Icons.local_fire_department,
                  AppRouter.fire,
                ),
                _buildDrawerMenuItem(
                  context,
                  'Investment Heatmap',
                  Icons.trending_up,
                  AppRouter.investment,
                ),
                _buildDrawerMenuItem(
                  context,
                  'Savings Challenge',
                  Icons.savings,
                  AppRouter.savings,
                ),
                _buildDrawerMenuItem(
                  context,
                  'Passive Income',
                  Icons.attach_money,
                  AppRouter.passiveIncome,
                ),
                _buildDrawerMenuItem(
                  context,
                  'Credit Score',
                  Icons.credit_score,
                  AppRouter.credit,
                ),
                _buildDrawerMenuItem(
                  context,
                  'Tax Planner',
                  Icons.receipt_long,
                  AppRouter.tax,
                ),
                _buildDrawerMenuItem(
                  context,
                  'Settings',
                  Icons.settings,
                  AppRouter.settings,
                ),
                _buildDrawerMenuItem(
                  context,
                  'Export Reports',
                  Icons.file_download,
                  AppRouter.reports,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawerMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}
