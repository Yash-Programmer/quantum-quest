import 'dart:convert';
import 'dart:math';
import '../../../core/services/local_storage_service.dart';
import '../domain/models/chat_models.dart';

class ChatbotService {
  final LocalStorageService _storage = LocalStorageService();
  static const String _messagesKey = 'chat_messages';
  static const String _sessionsKey = 'chat_sessions';

  // Financial knowledge base
  final Map<String, List<String>> _financialResponses = {
    'budgeting': [
      "Great question about budgeting! The 50/30/20 rule is a popular approach: 50% for needs, 30% for wants, and 20% for savings and debt repayment.",
      "For budgeting as a student, try the envelope method - allocate specific amounts for different categories like food, entertainment, and books.",
      "Start with tracking your expenses for a week to understand your spending patterns. Then create realistic budget categories based on your actual spending.",
      "Zero-based budgeting can be effective - assign every dollar a purpose before you spend it. This ensures intentional spending decisions.",
    ],
    'saving': [
      "Even small amounts count! Try the 52-week challenge - start with \$1 in week 1, \$2 in week 2, and so on. You'll save \$1,378 by year-end!",
      "Automate your savings by setting up a transfer to savings right after you get paid. Pay yourself first!",
      "Consider high-yield savings accounts or CDs for better interest rates on your emergency fund.",
      "The rule of thumb is to save 3-6 months of expenses for emergencies. Start with just \$500 as your first milestone.",
    ],
    'investing': [
      "As a student, consider starting with index funds - they're diversified and have low fees. Even \$25/month can make a difference over time!",
      "Time is your biggest advantage! Starting to invest in your 20s, even small amounts, can grow significantly due to compound interest.",
      "Learn about dollar-cost averaging - investing the same amount regularly regardless of market conditions reduces risk.",
      "Before investing, make sure you have an emergency fund and no high-interest debt like credit cards.",
    ],
    'debt': [
      "For student loans, explore income-driven repayment plans if you're struggling with payments after graduation.",
      "Credit card debt? Try the avalanche method - pay minimums on all cards, then put extra money toward the highest interest rate card.",
      "The snowball method works too - pay off smallest balances first for psychological wins, then tackle larger debts.",
      "Avoid taking on unnecessary debt. If you must use credit, pay it off in full each month to avoid interest charges.",
    ],
    'goals': [
      "SMART goals work for finances too: Specific, Measurable, Achievable, Relevant, Time-bound. Instead of 'save money,' try 'save \$1,000 for emergency fund by December.'",
      "Break large goals into smaller milestones. Saving \$5,000 feels overwhelming, but \$417/month for a year is manageable!",
      "Track your progress visually - use apps, charts, or even a simple jar to see your savings grow.",
      "Reward yourself for hitting milestones! Not with expensive purchases, but meaningful celebrations that don't derail your progress.",
    ],
    'expenses': [
      "Track everything for a month - you'll be surprised where your money goes! Use apps, spreadsheets, or even just write it down.",
      "Look for subscription services you forgot about. Many people spend \$100+ monthly on subscriptions they rarely use.",
      "Student discounts are everywhere! Always ask and check online - many services offer 50% off for students.",
      "Cook at home more often. Even reducing restaurant meals by half can save hundreds monthly.",
    ],
    'income': [
      "As a student, consider flexible income sources: tutoring, freelancing, part-time remote work, or gig economy jobs.",
      "Develop marketable skills during college. Learn coding, design, writing, or other skills that can earn money online.",
      "Look into work-study programs, research assistant positions, or internships that pay.",
      "Start a small business around your skills - tutoring, pet sitting, social media management for local businesses.",
    ],
  };

  final List<String> _greetings = [
    "Hi there! I'm your personal finance assistant. How can I help you manage your money better today?",
    "Hello! Ready to take control of your finances? What would you like to learn about?",
    "Welcome back! I'm here to help with all your money questions. What's on your mind?",
    "Hey! Let's make your financial goals a reality. What can I help you with?",
  ];

  final List<QuickReply> _defaultQuickReplies = [
    QuickReply(id: '1', text: '💰 Budgeting Tips', payload: 'budgeting'),
    QuickReply(id: '2', text: '🏦 Saving Strategies', payload: 'saving'),
    QuickReply(id: '3', text: '📈 Investment Basics', payload: 'investing'),
    QuickReply(id: '4', text: '💳 Debt Management', payload: 'debt'),
    QuickReply(id: '5', text: '🎯 Financial Goals', payload: 'goals'),
    QuickReply(id: '6', text: '📊 Expense Tracking', payload: 'expenses'),
  ];

  // Save chat messages
  Future<void> saveMessages(List<ChatMessage> messages) async {
    final messagesJson = messages.map((m) => m.toJson()).toList();
    await _storage.setStringList(
      _messagesKey,
      messagesJson.map(jsonEncode).toList(),
    );
  }

  // Load chat messages
  Future<List<ChatMessage>> loadMessages() async {
    final messagesJson = await _storage.getStringList(_messagesKey) ?? [];
    return messagesJson
        .map((jsonStr) => ChatMessage.fromJson(jsonDecode(jsonStr)))
        .toList();
  }

  // Save chat sessions
  Future<void> saveSessions(List<ChatSession> sessions) async {
    final sessionsJson = sessions.map((s) => s.toJson()).toList();
    await _storage.setStringList(
      _sessionsKey,
      sessionsJson.map(jsonEncode).toList(),
    );
  }

  // Load chat sessions
  Future<List<ChatSession>> loadSessions() async {
    final sessionsJson = await _storage.getStringList(_sessionsKey) ?? [];
    return sessionsJson
        .map((jsonStr) => ChatSession.fromJson(jsonDecode(jsonStr)))
        .toList();
  }

  // Generate bot response
  Future<BotResponse> generateResponse(
    String userMessage,
    ChatContext context,
  ) async {
    // Simulate thinking delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Analyze user intent
    final intent = _analyzeIntent(userMessage);

    // Generate contextual response
    String responseText;
    List<QuickReply>? quickReplies;
    ChatAttachment? attachment;

    if (intent.name == 'greeting') {
      responseText = _greetings[Random().nextInt(_greetings.length)];
      quickReplies = _defaultQuickReplies;
    } else if (intent.name == 'help') {
      responseText = _generateHelpResponse();
      quickReplies = _defaultQuickReplies;
    } else if (intent.name == 'financial_advice') {
      responseText = _generateFinancialAdvice(intent, context);
      quickReplies = _getRelatedQuickReplies(intent.entities['category']);
    } else if (intent.name == 'spending_analysis') {
      responseText = _generateSpendingAnalysis(context);
      attachment = _createSpendingChart(context);
    } else if (intent.name == 'budget_help') {
      responseText = _generateBudgetAdvice(context);
      quickReplies = _getBudgetQuickReplies();
    } else if (intent.name == 'goal_setting') {
      responseText = _generateGoalAdvice(intent, context);
      quickReplies = _getGoalQuickReplies();
    } else {
      responseText = _generateGenericResponse(userMessage, context);
      quickReplies = _getContextualQuickReplies(context);
    }

    return BotResponse(
      text: responseText,
      quickReplies: quickReplies,
      attachment: attachment,
      intent: intent,
      metadata: {
        'timestamp': DateTime.now().toIso8601String(),
        'confidence': intent.confidence,
      },
    );
  }

  // Analyze user intent using simple NLP
  BotIntent _analyzeIntent(String message) {
    final lowercaseMessage = message.toLowerCase();
    final entities = <String, dynamic>{};

    // Greeting patterns
    if (_containsAny(lowercaseMessage, [
      'hello',
      'hi',
      'hey',
      'good morning',
      'good afternoon',
    ])) {
      return BotIntent(name: 'greeting', confidence: 0.95, entities: entities);
    }

    // Help patterns
    if (_containsAny(lowercaseMessage, [
      'help',
      'what can you do',
      'commands',
      'options',
    ])) {
      return BotIntent(name: 'help', confidence: 0.90, entities: entities);
    }

    // Financial categories
    for (final category in _financialResponses.keys) {
      if (_containsAny(lowercaseMessage, _getCategoryKeywords(category))) {
        entities['category'] = category;
        return BotIntent(
          name: 'financial_advice',
          confidence: 0.85,
          entities: entities,
        );
      }
    }

    // Spending analysis
    if (_containsAny(lowercaseMessage, [
      'spending',
      'expenses',
      'where is my money',
      'analyze',
    ])) {
      return BotIntent(
        name: 'spending_analysis',
        confidence: 0.80,
        entities: entities,
      );
    }

    // Budget help
    if (_containsAny(lowercaseMessage, [
      'budget',
      'budgeting',
      'plan',
      'allocate',
    ])) {
      return BotIntent(
        name: 'budget_help',
        confidence: 0.85,
        entities: entities,
      );
    }

    // Goal setting
    if (_containsAny(lowercaseMessage, [
      'goal',
      'target',
      'save for',
      'plan for',
    ])) {
      return BotIntent(
        name: 'goal_setting',
        confidence: 0.80,
        entities: entities,
      );
    }

    // Default intent
    return BotIntent(name: 'general', confidence: 0.50, entities: entities);
  }

  List<String> _getCategoryKeywords(String category) {
    switch (category) {
      case 'budgeting':
        return ['budget', 'budgeting', 'plan', 'allocate', 'money plan'];
      case 'saving':
        return ['save', 'saving', 'savings', 'emergency fund', 'rainy day'];
      case 'investing':
        return [
          'invest',
          'investing',
          'investment',
          'stocks',
          'portfolio',
          'returns',
        ];
      case 'debt':
        return ['debt', 'loan', 'credit card', 'owe', 'payment', 'interest'];
      case 'goals':
        return ['goal', 'goals', 'target', 'objective', 'plan', 'achieve'];
      case 'expenses':
        return ['expense', 'expenses', 'spending', 'cost', 'money out'];
      case 'income':
        return [
          'income',
          'money in',
          'earnings',
          'salary',
          'wage',
          'make money',
        ];
      default:
        return [];
    }
  }

  String _generateHelpResponse() {
    return """I'm your AI financial assistant! Here's what I can help you with:

💰 **Budgeting** - Create and manage budgets
🏦 **Saving** - Build emergency funds and savings strategies  
📈 **Investing** - Learn investment basics for beginners
💳 **Debt** - Manage and pay off debts effectively
🎯 **Goals** - Set and achieve financial goals
📊 **Analysis** - Analyze your spending patterns
💡 **Tips** - Get personalized financial advice

Just ask me anything about money management, or use the quick replies below!""";
  }

  String _generateFinancialAdvice(BotIntent intent, ChatContext context) {
    final category = intent.entities['category'] as String?;
    if (category != null && _financialResponses.containsKey(category)) {
      final responses = _financialResponses[category]!;
      final baseResponse = responses[Random().nextInt(responses.length)];

      // Add personalized context if available
      if (context.financialContext != null) {
        return _personalizeResponse(
          baseResponse,
          category,
          context.financialContext!,
        );
      }

      return baseResponse;
    }

    return "I'd be happy to help with your financial question! Could you be more specific about what you'd like to know?";
  }

  String _personalizeResponse(
    String baseResponse,
    String category,
    FinancialContext financial,
  ) {
    String personalized = baseResponse;

    switch (category) {
      case 'budgeting':
        if (financial.monthlyIncome > 0) {
          final disposableIncome =
              financial.monthlyIncome - financial.monthlyExpenses;
          personalized +=
              "\n\nBased on your current income of \$${financial.monthlyIncome.toStringAsFixed(0)}, you have about \$${disposableIncome.toStringAsFixed(0)} in disposable income to work with.";
        }
        break;
      case 'saving':
        if (financial.currentBalance > 0) {
          personalized +=
              "\n\nI see you currently have \$${financial.currentBalance.toStringAsFixed(0)}. Great start! Consider automating your savings to build this even more.";
        }
        break;
      case 'expenses':
        if (financial.monthlyExpenses > 0) {
          personalized +=
              "\n\nYour monthly expenses are around \$${financial.monthlyExpenses.toStringAsFixed(0)}. Let's see if we can optimize some categories!";
        }
        break;
    }

    return personalized;
  }

  String _generateSpendingAnalysis(ChatContext context) {
    if (context.financialContext == null) {
      return """I'd love to analyze your spending, but I need some data first! 

Here's how to get started:
1. 📱 Track your expenses for at least a week
2. 📊 Categorize your spending (food, transport, entertainment, etc.)
3. 🔍 Look for patterns and surprises

Once you have some data, I can provide detailed insights and suggestions for optimization!""";
    }

    final financial = context.financialContext!;
    final savingsRate = financial.monthlyIncome > 0
        ? ((financial.monthlyIncome - financial.monthlyExpenses) /
              financial.monthlyIncome *
              100)
        : 0;

    return """📊 **Your Spending Analysis**

💰 Monthly Income: \$${financial.monthlyIncome.toStringAsFixed(0)}
💸 Monthly Expenses: \$${financial.monthlyExpenses.toStringAsFixed(0)}
💵 Net Savings: \$${(financial.monthlyIncome - financial.monthlyExpenses).toStringAsFixed(0)}
📈 Savings Rate: ${savingsRate.toStringAsFixed(1)}%

${_generateSpendingInsights(financial)}

Want me to dive deeper into any specific category? I can help you optimize your spending!""";
  }

  String _generateSpendingInsights(FinancialContext financial) {
    final savingsRate = financial.monthlyIncome > 0
        ? ((financial.monthlyIncome - financial.monthlyExpenses) /
              financial.monthlyIncome *
              100)
        : 0;

    if (savingsRate >= 20) {
      return "🎉 Excellent! You're saving ${savingsRate.toStringAsFixed(1)}% of your income. You're on track for strong financial health!";
    } else if (savingsRate >= 10) {
      return "👍 Good job! You're saving ${savingsRate.toStringAsFixed(1)}% of your income. Try to gradually increase this to 20% if possible.";
    } else if (savingsRate > 0) {
      return "👌 You're saving ${savingsRate.toStringAsFixed(1)}% of your income. Consider looking for areas to cut expenses to boost your savings rate.";
    } else {
      return "⚠️ Your expenses equal or exceed your income. Let's work on creating a budget to ensure you're saving for the future.";
    }
  }

  String _generateBudgetAdvice(ChatContext context) {
    return """🗂️ **Budget Creation Guide**

Let's create a budget that works for you! Here's my recommended approach:

**1. Track First (1 week minimum)**
- Record every expense, no matter how small
- Use apps, receipts, or a simple notebook

**2. Categorize Everything**
- Fixed: Rent, insurance, subscriptions
- Variable: Food, gas, entertainment
- Savings: Emergency fund, goals

**3. Apply the 50/30/20 Rule**
- 50% Needs (rent, groceries, utilities)
- 30% Wants (dining out, entertainment)
- 20% Savings (emergency + goals)

**4. Use the Envelope Method**
- Allocate specific amounts to each category
- Stop spending when the "envelope" is empty

Want help setting up any of these steps? I can guide you through the process!""";
  }

  String _generateGoalAdvice(BotIntent intent, ChatContext context) {
    return """🎯 **Smart Financial Goal Setting**

Here's how to set goals you'll actually achieve:

**1. Make Them SMART**
- Specific: "Save \$1,000" not "save money"
- Measurable: Track progress weekly
- Achievable: Start small and build up
- Relevant: Align with your priorities
- Time-bound: Set a clear deadline

**2. Popular Student Goals**
- Emergency fund: \$500-1,000 to start
- Graduation trip: \$2,000-3,000
- Car down payment: \$2,000-5,000
- Post-graduation fund: 3 months expenses

**3. Break It Down**
- \$1,000 goal = \$84/month for 1 year
- \$2,500 goal = \$208/month for 1 year
- Find your monthly target and automate it!

**4. Track Progress**
- Visual progress bars
- Milestone celebrations
- Regular check-ins

What goal would you like to work on first? I can help you create a specific plan!""";
  }

  String _generateGenericResponse(String userMessage, ChatContext context) {
    final responses = [
      "That's a great question! I'm here to help with your finances. Could you tell me more about what you're looking for?",
      "I want to make sure I give you the best advice. Can you provide more details about your financial situation or question?",
      "Let me help you with that! What specific aspect of personal finance would you like to explore?",
      "I'm your personal finance assistant! I can help with budgeting, saving, investing, debt management, and more. What interests you most?",
    ];

    return responses[Random().nextInt(responses.length)];
  }

  List<QuickReply> _getRelatedQuickReplies(String? category) {
    switch (category) {
      case 'budgeting':
        return [
          QuickReply(
            id: 'b1',
            text: '📊 Create Budget',
            payload: 'create_budget',
          ),
          QuickReply(
            id: 'b2',
            text: '🎯 50/30/20 Rule',
            payload: 'budget_rule',
          ),
          QuickReply(id: 'b3', text: '📱 Budget Apps', payload: 'budget_apps'),
        ];
      case 'saving':
        return [
          QuickReply(
            id: 's1',
            text: '🚨 Emergency Fund',
            payload: 'emergency_fund',
          ),
          QuickReply(
            id: 's2',
            text: '🏦 High-Yield Accounts',
            payload: 'savings_accounts',
          ),
          QuickReply(
            id: 's3',
            text: '🎯 Savings Goals',
            payload: 'savings_goals',
          ),
        ];
      case 'investing':
        return [
          QuickReply(id: 'i1', text: '📈 Index Funds', payload: 'index_funds'),
          QuickReply(
            id: 'i2',
            text: '💰 Dollar-Cost Averaging',
            payload: 'dca',
          ),
          QuickReply(
            id: 'i3',
            text: '🎓 Student Investing',
            payload: 'student_investing',
          ),
        ];
      default:
        return _defaultQuickReplies;
    }
  }

  List<QuickReply> _getBudgetQuickReplies() {
    return [
      QuickReply(
        id: 'budget1',
        text: '📊 Create Budget',
        payload: 'create_budget',
      ),
      QuickReply(
        id: 'budget2',
        text: '🔍 Track Expenses',
        payload: 'track_expenses',
      ),
      QuickReply(
        id: 'budget3',
        text: '✂️ Cut Expenses',
        payload: 'cut_expenses',
      ),
      QuickReply(id: 'budget4', text: '📱 Budget Apps', payload: 'budget_apps'),
    ];
  }

  List<QuickReply> _getGoalQuickReplies() {
    return [
      QuickReply(
        id: 'goal1',
        text: '🚨 Emergency Fund',
        payload: 'emergency_fund',
      ),
      QuickReply(
        id: 'goal2',
        text: '🎓 Graduation Trip',
        payload: 'graduation_trip',
      ),
      QuickReply(id: 'goal3', text: '🚗 Car Fund', payload: 'car_fund'),
      QuickReply(id: 'goal4', text: '🏠 Moving Fund', payload: 'moving_fund'),
    ];
  }

  List<QuickReply> _getContextualQuickReplies(ChatContext context) {
    // Return contextual quick replies based on user's financial situation
    if (context.financialContext?.currentBalance != null &&
        context.financialContext!.currentBalance < 500) {
      return [
        QuickReply(
          id: 'c1',
          text: '🚨 Build Emergency Fund',
          payload: 'emergency_fund',
        ),
        QuickReply(
          id: 'c2',
          text: '💰 Increase Income',
          payload: 'increase_income',
        ),
        QuickReply(id: 'c3', text: '✂️ Cut Expenses', payload: 'cut_expenses'),
      ];
    }

    return _defaultQuickReplies;
  }

  ChatAttachment? _createSpendingChart(ChatContext context) {
    if (context.financialContext == null) return null;

    return ChatAttachment(
      id: 'spending_chart_${DateTime.now().millisecondsSinceEpoch}',
      type: AttachmentType.chart,
      url: 'chart://spending_breakdown',
      title: 'Your Spending Breakdown',
      description: 'Visual analysis of your monthly expenses by category',
      data: {
        'chartType': 'pie',
        'categories': context.financialContext!.budgetCategories,
        'total': context.financialContext!.monthlyExpenses,
      },
    );
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  // Create demo conversation
  Future<List<ChatMessage>> createDemoConversation() async {
    final now = DateTime.now();
    return [
      ChatMessage(
        id: '1',
        content:
            "Hi! I'm new to managing money as a college student. Can you help me get started?",
        type: MessageType.user,
        timestamp: now.subtract(const Duration(minutes: 10)),
      ),
      ChatMessage(
        id: '2',
        content:
            "Absolutely! Welcome to your financial journey! 🎉 As a college student, you're already ahead by thinking about money management early. Let's start with the basics - do you currently have any income (part-time job, allowance, etc.) and are you tracking your expenses?",
        type: MessageType.bot,
        timestamp: now.subtract(const Duration(minutes: 9)),
        quickReplies: [
          QuickReply(
            id: 'q1',
            text: '💰 I have some income',
            payload: 'has_income',
          ),
          QuickReply(
            id: 'q2',
            text: '📊 Help me track expenses',
            payload: 'track_expenses',
          ),
          QuickReply(
            id: 'q3',
            text: '🎯 Set financial goals',
            payload: 'set_goals',
          ),
        ],
      ),
      ChatMessage(
        id: '3',
        content:
            "I work part-time and get about \$800/month. I don't really track expenses though.",
        type: MessageType.user,
        timestamp: now.subtract(const Duration(minutes: 8)),
      ),
      ChatMessage(
        id: '4',
        content:
            "Perfect! \$800/month is a great start. Here's my recommendation for you:\n\n**Step 1: Track for 1 week** 📱\nWrite down every expense, no matter how small\n\n**Step 2: Create a simple budget** 💰\n- \$400 for needs (food, transport, books)\n- \$240 for wants (entertainment, eating out)\n- \$160 for savings (20% is ideal!)\n\n**Step 3: Build an emergency fund** 🚨\nAim for \$500 first, then work toward \$1,000\n\nWant me to help you get started with any of these steps?",
        type: MessageType.bot,
        timestamp: now.subtract(const Duration(minutes: 7)),
        quickReplies: [
          QuickReply(
            id: 'b1',
            text: '📊 Start tracking',
            payload: 'start_tracking',
          ),
          QuickReply(
            id: 'b2',
            text: '💰 Create budget',
            payload: 'create_budget',
          ),
          QuickReply(
            id: 'b3',
            text: '🏦 Emergency fund tips',
            payload: 'emergency_fund',
          ),
        ],
      ),
    ];
  }
}
