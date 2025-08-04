import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/knowledge_models.dart';

// Optimized providers with lazy loading
final knowledgeArticlesProvider =
    StateNotifierProvider<KnowledgeArticlesNotifier, List<KnowledgeArticle>>((
      ref,
    ) {
      return KnowledgeArticlesNotifier();
    });

final quizzesProvider = StateNotifierProvider<QuizzesNotifier, List<Quiz>>((
  ref,
) {
  return QuizzesNotifier();
});

final financialTipsProvider =
    StateNotifierProvider<FinancialTipsNotifier, List<FinancialTip>>((ref) {
      return FinancialTipsNotifier();
    });

final learningProgressProvider =
    StateNotifierProvider<LearningProgressNotifier, LearningProgress>((ref) {
      return LearningProgressNotifier();
    });

// Cached filtered providers for better performance
final filteredArticlesProvider =
    Provider.family<List<KnowledgeArticle>, String>((ref, category) {
      final articles = ref.watch(knowledgeArticlesProvider);
      if (category == 'All') {
        return articles;
      }
      return articles.where((article) => article.category == category).toList();
    });

final bookmarkedArticlesProvider = Provider<List<KnowledgeArticle>>((ref) {
  final articles = ref.watch(knowledgeArticlesProvider);
  return articles.where((article) => article.isBookmarked).toList();
});

final dailyTipProvider = Provider<FinancialTip?>((ref) {
  final tips = ref.watch(financialTipsProvider);
  final unreadTips = tips.where((tip) => !tip.isRead).toList();
  if (unreadTips.isNotEmpty) {
    unreadTips.sort((a, b) => b.priority.compareTo(a.priority));
    return unreadTips.first;
  }
  return null;
});

class KnowledgeArticlesNotifier extends StateNotifier<List<KnowledgeArticle>> {
  KnowledgeArticlesNotifier() : super([]);

  bool _isInitialized = false;

  // Lazy load articles only when needed
  void _initializeIfNeeded() {
    if (!_isInitialized) {
      state = _getSampleArticles();
      _isInitialized = true;
    }
  }

  @override
  List<KnowledgeArticle> get state {
    _initializeIfNeeded();
    return super.state;
  }

  void toggleBookmark(String articleId) {
    _initializeIfNeeded();
    state = state.map((article) {
      if (article.id == articleId) {
        return article.copyWith(isBookmarked: !article.isBookmarked);
      }
      return article;
    }).toList();
  }

  void markAsRead(String articleId) {
    _initializeIfNeeded();
    // This would typically update a separate "read articles" list
    // For now, we'll just trigger a state change
    state = [...state];
  }
}

class QuizzesNotifier extends StateNotifier<List<Quiz>> {
  QuizzesNotifier() : super([]);

  bool _isInitialized = false;

  void _initializeIfNeeded() {
    if (!_isInitialized) {
      state = _getSampleQuizzes();
      _isInitialized = true;
    }
  }

  @override
  List<Quiz> get state {
    _initializeIfNeeded();
    return super.state;
  }

  void completeQuiz(String quizId, int score) {
    _initializeIfNeeded();
    state = state.map((quiz) {
      if (quiz.id == quizId) {
        return quiz.copyWith(
          userScore: score,
          isCompleted: true,
          completedAt: DateTime.now(),
        );
      }
      return quiz;
    }).toList();
  }
}

class FinancialTipsNotifier extends StateNotifier<List<FinancialTip>> {
  FinancialTipsNotifier() : super([]);

  bool _isInitialized = false;

  void _initializeIfNeeded() {
    if (!_isInitialized) {
      state = _getSampleTips();
      _isInitialized = true;
    }
  }

  @override
  List<FinancialTip> get state {
    _initializeIfNeeded();
    return super.state;
  }

  void markTipAsRead(String tipId) {
    _initializeIfNeeded();
    state = state.map((tip) {
      if (tip.id == tipId) {
        return tip.copyWith(isRead: true);
      }
      return tip;
    }).toList();
  }
}

class LearningProgressNotifier extends StateNotifier<LearningProgress> {
  LearningProgressNotifier()
    : super(
        const LearningProgress(
          articlesRead: 0,
          quizzesCompleted: 0,
          totalScore: 0,
          categoryProgress: {},
          earnedBadges: [],
          streak: 0,
        ),
      );

  void incrementArticlesRead(String category) {
    final newCategoryProgress = Map<String, int>.from(state.categoryProgress);
    newCategoryProgress[category] = (newCategoryProgress[category] ?? 0) + 1;

    state = state.copyWith(
      articlesRead: state.articlesRead + 1,
      categoryProgress: newCategoryProgress,
    );

    _checkForNewBadges();
  }

  void addQuizScore(int score) {
    state = state.copyWith(
      quizzesCompleted: state.quizzesCompleted + 1,
      totalScore: state.totalScore + score,
    );

    _checkForNewBadges();
  }

  void _checkForNewBadges() {
    final newBadges = <String>[];

    // Reading badges
    if (state.articlesRead >= 1 &&
        !state.earnedBadges.contains('First Reader')) {
      newBadges.add('First Reader');
    }
    if (state.articlesRead >= 10 &&
        !state.earnedBadges.contains('Knowledge Seeker')) {
      newBadges.add('Knowledge Seeker');
    }
    if (state.articlesRead >= 25 &&
        !state.earnedBadges.contains('Learning Master')) {
      newBadges.add('Learning Master');
    }

    // Quiz badges
    if (state.quizzesCompleted >= 1 &&
        !state.earnedBadges.contains('Quiz Starter')) {
      newBadges.add('Quiz Starter');
    }
    if (state.quizzesCompleted >= 5 &&
        !state.earnedBadges.contains('Quiz Champion')) {
      newBadges.add('Quiz Champion');
    }

    // Perfect score badges
    if (state.totalScore >= 100 &&
        !state.earnedBadges.contains('High Scorer')) {
      newBadges.add('High Scorer');
    }

    if (newBadges.isNotEmpty) {
      state = state.copyWith(
        earnedBadges: [...state.earnedBadges, ...newBadges],
      );
    }
  }
}

// Lazy loading functions for better performance
List<KnowledgeArticle> _getSampleArticles() {
  return [
    KnowledgeArticle(
      id: '1',
      title: 'Budgeting Basics: Your First Step to Financial Freedom',
      content: '''
# Budgeting Basics: Your First Step to Financial Freedom

## Introduction
Creating a budget is like creating a roadmap for your money. It tells your money where to go instead of wondering where it went.

## The 50/30/20 Rule
A simple budgeting rule to get started:
- **50%** for needs (rent, groceries, utilities)
- **30%** for wants (entertainment, dining out)
- **20%** for savings and debt repayment

## Getting Started
1. **Track your income**: Know exactly how much money comes in each month
2. **List your expenses**: Write down everything you spend money on
3. **Categorize**: Group expenses into needs, wants, and savings
4. **Adjust**: Make sure your expenses don't exceed your income

## Tips for Success
- Start small and be realistic
- Review and adjust monthly
- Use apps or tools to track spending
- Celebrate small wins

## Common Mistakes to Avoid
- Being too restrictive
- Not accounting for irregular expenses
- Giving up after one bad month
- Not having an emergency fund

Remember, budgeting is a skill that improves with practice!
    ''',
      category: 'Budgeting',
      readTime: 5,
      tags: ['beginner', 'budgeting', '50-30-20', 'basics'],
      publishedDate: DateTime.now().subtract(const Duration(days: 7)),
      difficulty: 1,
    ),

    KnowledgeArticle(
      id: '2',
      title: 'Understanding Compound Interest: The 8th Wonder of the World',
      content: '''
# Understanding Compound Interest: The 8th Wonder of the World

## What is Compound Interest?
Compound interest is interest calculated on the initial principal and also on the accumulated interest from previous periods.

## The Power of Starting Early
The earlier you start investing, the more time compound interest has to work its magic.

### Example:
- Person A: Invests ₹5,000 per month starting at age 25
- Person B: Invests ₹10,000 per month starting at age 35
- At 7% annual return, Person A will have more money at retirement!

## The Rule of 72
A quick way to estimate how long it takes for money to double:
**72 ÷ Interest Rate = Years to Double**

Examples:
- At 6% interest: 72 ÷ 6 = 12 years
- At 8% interest: 72 ÷ 8 = 9 years

## Making Compound Interest Work for You
1. Start investing early, even small amounts
2. Be consistent with your investments
3. Reinvest your returns
4. Be patient - compound interest needs time
5. Avoid withdrawing your investments early

## Real-World Applications
- Savings accounts
- Fixed deposits
- Mutual funds
- Stocks
- Retirement accounts

The key is to start now, no matter how small the amount!
    ''',
      category: 'Investing',
      readTime: 7,
      tags: ['investing', 'compound interest', 'rule of 72', 'intermediate'],
      publishedDate: DateTime.now().subtract(const Duration(days: 14)),
      difficulty: 2,
    ),

    KnowledgeArticle(
      id: '3',
      title: 'Building Your Emergency Fund: Financial Security 101',
      content: '''
# Building Your Emergency Fund: Financial Security 101

## Why You Need an Emergency Fund
Life is unpredictable. Job loss, medical emergencies, or major repairs can derail your finances if you're not prepared.

## How Much Should You Save?
**Beginners**: ₹1,000 to ₹5,000
**Intermediate**: 3-6 months of expenses
**Advanced**: 6-12 months of expenses

## Where to Keep Your Emergency Fund
1. **High-yield savings account** - Easy access, earns interest
2. **Money market account** - Higher interest rates
3. **Short-term CDs** - For portion you won't need immediately

### Avoid These Locations:
- Stock market (too volatile)
- Under your mattress (no growth)
- Regular checking account (too tempting to spend)

## Building Your Fund
1. **Start small**: Even ₹500 is better than nothing
2. **Automate**: Set up automatic transfers
3. **Use windfalls**: Tax refunds, bonuses, gifts
4. **Cut expenses temporarily**: Find areas to reduce spending
5. **Earn extra**: Side jobs, selling items

## When to Use Your Emergency Fund
✅ **Use for:**
- Job loss
- Major medical expenses
- Essential home repairs
- Car repairs (if needed for work)

❌ **Don't use for:**
- Vacations
- Shopping sprees
- Known upcoming expenses
- Investments

## Rebuilding After Use
If you use your emergency fund, make rebuilding it your top priority before resuming other financial goals.

Your emergency fund is your financial safety net - build it and protect it!
    ''',
      category: 'Savings',
      readTime: 6,
      tags: ['emergency fund', 'savings', 'financial security', 'beginner'],
      publishedDate: DateTime.now().subtract(const Duration(days: 21)),
      difficulty: 1,
    ),

    KnowledgeArticle(
      id: '4',
      title: 'Credit Cards: Friend or Foe? A Complete Guide',
      content: '''
# Credit Cards: Friend or Foe? A Complete Guide

## Understanding Credit Cards
Credit cards can be powerful financial tools when used responsibly, but dangerous when misused.

## How Credit Cards Work
1. You make purchases using borrowed money
2. The bank pays the merchant
3. You pay the bank back, with or without interest
4. Your payment history affects your credit score

## The Benefits
- **Build credit history**
- **Rewards and cashback**
- **Purchase protection**
- **Convenience and security**
- **Emergency funding**

## The Dangers
- **High interest rates** (18-36% annually)
- **Temptation to overspend**
- **Fees** (annual, late payment, over-limit)
- **Credit score damage** if misused

## Golden Rules for Credit Card Use
1. **Pay in full every month** - Avoid interest completely
2. **Keep utilization low** - Use less than 30% of your limit
3. **Pay on time, every time** - Late payments hurt your credit
4. **Don't cash advance** - Very high fees and interest
5. **Read the fine print** - Understand all terms and fees

## Building Good Credit
- Make payments on time
- Keep old accounts open
- Don't max out your cards
- Monitor your credit report
- Use credit for planned purchases only

## Warning Signs You're in Trouble
- Only making minimum payments
- Using cash advances
- Maxing out cards
- Applying for multiple cards quickly
- Using credit for basic necessities

## Getting Out of Credit Card Debt
1. **Stop using the cards**
2. **List all debts** with balances and rates
3. **Choose a strategy**:
   - Debt avalanche (highest interest first)
   - Debt snowball (smallest balance first)
4. **Pay more than minimum**
5. **Consider balance transfer** if you qualify

Remember: Credit cards are tools. Used wisely, they build wealth. Used poorly, they destroy it.
    ''',
      category: 'Credit',
      readTime: 8,
      tags: ['credit cards', 'credit score', 'debt', 'intermediate'],
      publishedDate: DateTime.now().subtract(const Duration(days: 28)),
      difficulty: 2,
    ),

    KnowledgeArticle(
      id: '5',
      title: 'Investment Options for Beginners in India',
      content: '''
# Investment Options for Beginners in India

## Getting Started with Investing
Investing doesn't require a large amount of money or complex knowledge. Start small and learn as you grow.

## Popular Investment Options

### 1. Mutual Funds
**What**: Pool money with other investors, managed by professionals
**Risk**: Low to High (depending on type)
**Returns**: 8-15% annually
**Best for**: Beginners who want diversification

### 2. SIPs (Systematic Investment Plans)
**What**: Regular monthly investments in mutual funds
**Risk**: Low to Medium
**Returns**: 10-12% long-term
**Best for**: Building discipline and rupee cost averaging

### 3. Fixed Deposits (FDs)
**What**: Lend money to bank for fixed period
**Risk**: Very Low
**Returns**: 5-7% annually
**Best for**: Emergency fund parking

### 4. Public Provident Fund (PPF)
**What**: Government savings scheme with tax benefits
**Risk**: Zero (government guaranteed)
**Returns**: 7-8% annually
**Best for**: Long-term wealth building (15 years)

### 5. ELSS Mutual Funds
**What**: Equity funds with tax benefits under 80C
**Risk**: Medium to High
**Returns**: 10-15% annually
**Best for**: Tax saving + wealth creation

### 6. Gold
**What**: Physical gold, gold ETFs, or digital gold
**Risk**: Medium
**Returns**: 8-10% long-term
**Best for**: Portfolio diversification

## Investment Strategies

### Asset Allocation by Age
**20s**: 80% Equity, 20% Debt
**30s**: 70% Equity, 30% Debt
**40s**: 60% Equity, 40% Debt
**50s**: 50% Equity, 50% Debt

### Dollar Cost Averaging (Rupee Cost Averaging)
Invest a fixed amount regularly regardless of market conditions. This reduces the impact of market volatility.

## Key Principles
1. **Start early** - Time is your biggest ally
2. **Stay consistent** - Regular investments beat timing the market
3. **Diversify** - Don't put all eggs in one basket
4. **Stay invested** - Don't panic during market downturns
5. **Review regularly** - Rebalance your portfolio annually

## Common Mistakes to Avoid
- Trying to time the market
- Putting all money in one investment
- Panicking during market falls
- Not starting because you don't have enough money
- Following tips from friends without research

## Tax Implications
- Equity mutual funds: No tax on returns if held >1 year
- Debt funds: Taxed as per income tax slab
- PPF: Tax-free returns
- FD: Interest taxed as per income slab

Start your investment journey today - even ₹500 per month can create significant wealth over time!
    ''',
      category: 'Investing',
      readTime: 10,
      tags: ['investing', 'mutual funds', 'SIP', 'PPF', 'beginner'],
      publishedDate: DateTime.now().subtract(const Duration(days: 35)),
      difficulty: 2,
    ),
  ];
}

List<Quiz> _getSampleQuizzes() {
  return [
    Quiz(
      id: '1',
      title: 'Budgeting Basics Quiz',
      description: 'Test your knowledge of fundamental budgeting concepts',
      category: 'Budgeting',
      questions: [
        QuizQuestion(
          id: '1',
          question: 'What is the 50/30/20 budgeting rule?',
          options: [
            '50% needs, 30% wants, 20% savings',
            '50% savings, 30% needs, 20% wants',
            '50% wants, 30% needs, 20% savings',
            '50% taxes, 30% needs, 20% wants',
          ],
          correctAnswerIndex: 0,
          explanation:
              'The 50/30/20 rule allocates 50% for needs, 30% for wants, and 20% for savings and debt repayment.',
        ),
        QuizQuestion(
          id: '2',
          question: 'Which expense category should you prioritize first?',
          options: [
            'Entertainment',
            'Needs (rent, food)',
            'Wants',
            'Luxury items',
          ],
          correctAnswerIndex: 1,
          explanation:
              'Needs like housing, food, and utilities should always be prioritized before wants and entertainment.',
        ),
        QuizQuestion(
          id: '3',
          question: 'How often should you review your budget?',
          options: [
            'Once a year',
            'Monthly',
            'Never',
            'Only when you overspend',
          ],
          correctAnswerIndex: 1,
          explanation:
              'Monthly budget reviews help you stay on track and make necessary adjustments.',
        ),
      ],
    ),

    Quiz(
      id: '2',
      title: 'Investment Fundamentals',
      description: 'Learn the basics of investing and compound interest',
      category: 'Investing',
      questions: [
        QuizQuestion(
          id: '1',
          question: 'What is compound interest?',
          options: [
            'Interest paid only on principal',
            'Interest paid on principal and accumulated interest',
            'A type of loan',
            'A bank fee',
          ],
          correctAnswerIndex: 1,
          explanation:
              'Compound interest is earned on both the principal and previously earned interest.',
        ),
        QuizQuestion(
          id: '2',
          question:
              'According to the Rule of 72, how long will it take for money to double at 8% interest?',
          options: ['8 years', '9 years', '10 years', '12 years'],
          correctAnswerIndex: 1,
          explanation:
              '72 ÷ 8 = 9 years. The Rule of 72 helps estimate doubling time.',
        ),
        QuizQuestion(
          id: '3',
          question:
              'What is the most important factor in building wealth through investing?',
          options: [
            'Large initial investment',
            'Perfect market timing',
            'Time and consistency',
            'Following trends',
          ],
          correctAnswerIndex: 2,
          explanation:
              'Time and consistency allow compound interest to work effectively, more important than timing or large amounts.',
        ),
      ],
    ),

    Quiz(
      id: '3',
      title: 'Emergency Fund Knowledge',
      description:
          'Test your understanding of emergency funds and financial security',
      category: 'Savings',
      questions: [
        QuizQuestion(
          id: '1',
          question:
              'How much should a beginner aim to save in an emergency fund?',
          options: ['₹100', '₹1,000 to ₹5,000', '₹50,000', '₹1,00,000'],
          correctAnswerIndex: 1,
          explanation:
              'Beginners should start with ₹1,000 to ₹5,000 as an initial emergency fund goal.',
        ),
        QuizQuestion(
          id: '2',
          question: 'Where should you keep your emergency fund?',
          options: [
            'Stock market',
            'High-yield savings account',
            'Under mattress',
            'Cryptocurrency',
          ],
          correctAnswerIndex: 1,
          explanation:
              'Emergency funds should be easily accessible and safe, making high-yield savings accounts ideal.',
        ),
        QuizQuestion(
          id: '3',
          question: 'Which is NOT a valid use of emergency funds?',
          options: [
            'Job loss',
            'Medical emergency',
            'Vacation',
            'Car repair for work',
          ],
          correctAnswerIndex: 2,
          explanation:
              'Vacations are planned expenses, not emergencies. Emergency funds are for unexpected situations.',
        ),
      ],
    ),
  ];
}

List<FinancialTip> _getSampleTips() {
  return [
    FinancialTip(
      id: '1',
      title: 'Track Every Expense for One Week',
      description:
          'Write down every rupee you spend for a week. This simple exercise reveals spending patterns and helps identify areas to cut back.',
      category: 'Budgeting',
      priority: 5,
    ),
    FinancialTip(
      id: '2',
      title: 'Automate Your Savings',
      description:
          'Set up automatic transfers to your savings account. Pay yourself first, even if it\'s just ₹500 per month.',
      category: 'Savings',
      priority: 4,
    ),
    FinancialTip(
      id: '3',
      title: 'Start a SIP with Just ₹500',
      description:
          'You don\'t need thousands to start investing. Begin a SIP with ₹500 per month and increase gradually.',
      category: 'Investing',
      priority: 4,
    ),
    FinancialTip(
      id: '4',
      title: 'Use the 24-Hour Rule',
      description:
          'Before making any non-essential purchase over ₹1,000, wait 24 hours. This reduces impulse buying.',
      category: 'Budgeting',
      priority: 3,
    ),
    FinancialTip(
      id: '5',
      title: 'Review Your Credit Report',
      description:
          'Check your credit report once a year for free. Look for errors and understand what affects your credit score.',
      category: 'Credit',
      priority: 3,
    ),
    FinancialTip(
      id: '6',
      title: 'Build Multiple Income Sources',
      description:
          'Don\'t rely on just one income source. Consider freelancing, part-time work, or passive income streams.',
      category: 'Income',
      priority: 3,
    ),
    FinancialTip(
      id: '7',
      title: 'Learn to Cook Basic Meals',
      description:
          'Cooking at home can save ₹200-500 per day compared to eating out. It\'s also healthier!',
      category: 'Budgeting',
      priority: 2,
    ),
    FinancialTip(
      id: '8',
      title: 'Understand Tax Saving Options',
      description:
          'Learn about 80C deductions, ELSS funds, and PPF to legally reduce your tax burden.',
      category: 'Tax',
      priority: 2,
    ),
  ];
}
