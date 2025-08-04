import 'package:go_router/go_router.dart';

import '../navigation/main_scaffold.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/budgeting/presentation/pages/smart_budgeting_page.dart';
import '../../features/predictive/presentation/pages/predictive_finance_page.dart';
import '../../features/chatbot/presentation/pages/ai_assistant_page.dart';
import '../../features/knowledge/presentation/pages/knowledge_hub_page.dart';
import '../../features/goals/presentation/pages/goals_planner_page.dart';
import '../../features/loan/presentation/pages/loan_planner_page.dart';
import '../../features/fire/presentation/pages/fire_calculator_page.dart';
import '../../features/investment/presentation/pages/investment_heatmap_page.dart';
import '../../features/savings/presentation/pages/savings_challenge_page.dart';
import '../../features/passive_income/presentation/pages/passive_income_page.dart';
import '../../features/credit/presentation/pages/credit_score_page.dart';
import '../../features/tax/presentation/pages/tax_planner_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/reports/presentation/pages/pdf_export_page.dart';

class AppRouter {
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String budgeting = '/budgeting';
  static const String predictive = '/predictive';
  static const String chatbot = '/chatbot';
  static const String knowledge = '/knowledge';
  static const String goals = '/goals';
  static const String loan = '/loan';
  static const String fire = '/fire';
  static const String investment = '/investment';
  static const String savings = '/savings';
  static const String passiveIncome = '/passive-income';
  static const String credit = '/credit';
  static const String tax = '/tax';
  static const String settings = '/settings';
  static const String reports = '/reports';

  static final GoRouter router = GoRouter(
    initialLocation: dashboard,
    routes: [
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: dashboard,
            name: 'dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: budgeting,
            name: 'budgeting',
            builder: (context, state) => const SmartBudgetingPage(),
          ),
          GoRoute(
            path: predictive,
            name: 'predictive',
            builder: (context, state) => const PredictiveFinancePage(),
          ),
          GoRoute(
            path: chatbot,
            name: 'chatbot',
            builder: (context, state) => const AIAssistantPage(),
          ),
          GoRoute(
            path: knowledge,
            name: 'knowledge',
            builder: (context, state) => const KnowledgeHubPage(),
          ),
        ],
      ),
      // Routes without bottom navigation
      GoRoute(
        path: goals,
        name: 'goals',
        builder: (context, state) => const GoalsPlannerPage(),
      ),
      GoRoute(
        path: loan,
        name: 'loan',
        builder: (context, state) => const LoanPlannerPage(),
      ),
      GoRoute(
        path: fire,
        name: 'fire',
        builder: (context, state) => const FireCalculatorPage(),
      ),
      GoRoute(
        path: investment,
        name: 'investment',
        builder: (context, state) => const InvestmentHeatmapPage(),
      ),
      GoRoute(
        path: savings,
        name: 'savings',
        builder: (context, state) => const SavingsChallengePage(),
      ),
      GoRoute(
        path: passiveIncome,
        name: 'passiveIncome',
        builder: (context, state) => const PassiveIncomePage(),
      ),
      GoRoute(
        path: credit,
        name: 'credit',
        builder: (context, state) => const CreditScorePage(),
      ),
      GoRoute(
        path: tax,
        name: 'tax',
        builder: (context, state) => const TaxPlannerPage(),
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: reports,
        name: 'reports',
        builder: (context, state) => const PDFExportPage(),
      ),
    ],
  );
}
