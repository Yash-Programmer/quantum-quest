import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/knowledge_provider.dart';
import '../../domain/models/knowledge_models.dart';
import '../widgets/article_card.dart';
import '../widgets/quiz_card.dart';
import '../widgets/tip_card.dart';
import '../widgets/progress_card.dart';
import '../widgets/category_tabs.dart';
import '../widgets/article_detail_page.dart';
import '../widgets/quiz_page.dart';

class KnowledgeHubPage extends ConsumerStatefulWidget {
  const KnowledgeHubPage({super.key});

  @override
  ConsumerState<KnowledgeHubPage> createState() => _KnowledgeHubPageState();
}

class _KnowledgeHubPageState extends ConsumerState<KnowledgeHubPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Budgeting',
    'Investing',
    'Savings',
    'Credit',
    'Tax',
    'Income',
  ];

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
    final progress = ref.watch(learningProgressProvider);
    final dailyTip = ref.watch(dailyTipProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Knowledge Hub',
          style: TextStyle(
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.brightness == Brightness.dark
            ? const Color(0xFF1a1a1a)
            : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: theme.brightness == Brightness.dark
              ? Colors.white
              : Colors.black87,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () => _showBookmarkedArticles(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: theme.primaryColor,
          tabs: const [
            Tab(text: 'Learn', icon: Icon(Icons.school)),
            Tab(text: 'Articles', icon: Icon(Icons.article)),
            Tab(text: 'Quizzes', icon: Icon(Icons.quiz)),
            Tab(text: 'Tips', icon: Icon(Icons.lightbulb)),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(progress, dailyTip),
            _buildArticlesTab(),
            _buildQuizzesTab(),
            _buildTipsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(LearningProgress progress, FinancialTip? dailyTip) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withValues(alpha: 0.8),
                  Theme.of(context).primaryColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Your Learning Journey! 🎓',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Master personal finance with expert articles, interactive quizzes, and daily tips.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Progress Card
          ProgressCard(progress: progress),

          const SizedBox(height: 20),

          // Daily Tip
          if (dailyTip != null) ...[
            Text(
              '💡 Daily Financial Tip',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            TipCard(tip: dailyTip),
            const SizedBox(height: 20),
          ],

          // Featured Content
          Text(
            '🌟 Featured Articles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          Consumer(
            builder: (context, ref, child) {
              final articles = ref.watch(knowledgeArticlesProvider);
              final featuredArticles = articles.take(3).toList();

              return Column(
                children: featuredArticles.map((article) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ArticleCard(
                      article: article,
                      onTap: () => _openArticle(article),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesTab() {
    return Column(
      children: [
        // Category filter
        CategoryTabs(
          categories: _categories,
          selectedCategory: _selectedCategory,
          onCategorySelected: (category) {
            setState(() {
              _selectedCategory = category;
            });
          },
        ),

        // Articles list
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final articles = ref.watch(
                filteredArticlesProvider(_selectedCategory),
              );
              final filteredArticles = articles.where((article) {
                if (_searchQuery.isEmpty) return true;
                return article.title.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    article.tags.any(
                      (tag) => tag.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    );
              }).toList();

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredArticles.length,
                itemBuilder: (context, index) {
                  final article = filteredArticles[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ArticleCard(
                      article: article,
                      onTap: () => _openArticle(article),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuizzesTab() {
    return Consumer(
      builder: (context, ref, child) {
        final quizzes = ref.watch(quizzesProvider);

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: QuizCard(quiz: quiz, onTap: () => _openQuiz(quiz)),
            );
          },
        );
      },
    );
  }

  Widget _buildTipsTab() {
    return Consumer(
      builder: (context, ref, child) {
        final tips = ref.watch(financialTipsProvider);

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tips.length,
          itemBuilder: (context, index) {
            final tip = tips[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TipCard(tip: tip),
            );
          },
        );
      },
    );
  }

  void _openArticle(KnowledgeArticle article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailPage(article: article),
      ),
    ).then((_) {
      // Mark as read and update progress
      ref
          .read(learningProgressProvider.notifier)
          .incrementArticlesRead(article.category);
    });
  }

  void _openQuiz(Quiz quiz) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuizPage(quiz: quiz)),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Articles'),
        content: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: const InputDecoration(
            hintText: 'Search by title or tags...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _searchQuery = '';
              });
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showBookmarkedArticles() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _BookmarkedArticlesPage()),
    );
  }
}

class _BookmarkedArticlesPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkedArticles = ref.watch(bookmarkedArticlesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarked Articles')),
      body: bookmarkedArticles.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No bookmarked articles yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the bookmark icon on articles to save them here',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookmarkedArticles.length,
              itemBuilder: (context, index) {
                final article = bookmarkedArticles[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ArticleCard(
                    article: article,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ArticleDetailPage(article: article),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
