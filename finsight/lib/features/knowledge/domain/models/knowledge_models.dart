class KnowledgeArticle {
  final String id;
  final String title;
  final String content;
  final String category;
  final int readTime; // in minutes
  final List<String> tags;
  final DateTime publishedDate;
  final int difficulty; // 1-3 (Beginner, Intermediate, Advanced)
  final String? imageUrl;
  final bool isBookmarked;

  const KnowledgeArticle({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.readTime,
    required this.tags,
    required this.publishedDate,
    required this.difficulty,
    this.imageUrl,
    this.isBookmarked = false,
  });

  KnowledgeArticle copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    int? readTime,
    List<String>? tags,
    DateTime? publishedDate,
    int? difficulty,
    String? imageUrl,
    bool? isBookmarked,
  }) {
    return KnowledgeArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      readTime: readTime ?? this.readTime,
      tags: tags ?? this.tags,
      publishedDate: publishedDate ?? this.publishedDate,
      difficulty: difficulty ?? this.difficulty,
      imageUrl: imageUrl ?? this.imageUrl,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'readTime': readTime,
      'tags': tags,
      'publishedDate': publishedDate.millisecondsSinceEpoch,
      'difficulty': difficulty,
      'imageUrl': imageUrl,
      'isBookmarked': isBookmarked,
    };
  }

  factory KnowledgeArticle.fromMap(Map<String, dynamic> map) {
    return KnowledgeArticle(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? '',
      readTime: map['readTime']?.toInt() ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
      publishedDate: DateTime.fromMillisecondsSinceEpoch(map['publishedDate']),
      difficulty: map['difficulty']?.toInt() ?? 1,
      imageUrl: map['imageUrl'],
      isBookmarked: map['isBookmarked'] ?? false,
    );
  }
}

class Quiz {
  final String id;
  final String title;
  final String description;
  final String category;
  final List<QuizQuestion> questions;
  final int? userScore;
  final bool isCompleted;
  final DateTime? completedAt;

  const Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.questions,
    this.userScore,
    this.isCompleted = false,
    this.completedAt,
  });

  Quiz copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    List<QuizQuestion>? questions,
    int? userScore,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return Quiz(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      questions: questions ?? this.questions,
      userScore: userScore ?? this.userScore,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });
}

class FinancialTip {
  final String id;
  final String title;
  final String description;
  final String category;
  final int priority; // 1-5, higher is more important
  final bool isRead;

  const FinancialTip({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    this.isRead = false,
  });

  FinancialTip copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? priority,
    bool? isRead,
  }) {
    return FinancialTip(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
    );
  }
}

class LearningProgress {
  final int articlesRead;
  final int quizzesCompleted;
  final int totalScore;
  final Map<String, int> categoryProgress; // category -> articles read
  final List<String> earnedBadges;
  final int streak; // consecutive days with activity

  const LearningProgress({
    required this.articlesRead,
    required this.quizzesCompleted,
    required this.totalScore,
    required this.categoryProgress,
    required this.earnedBadges,
    required this.streak,
  });

  LearningProgress copyWith({
    int? articlesRead,
    int? quizzesCompleted,
    int? totalScore,
    Map<String, int>? categoryProgress,
    List<String>? earnedBadges,
    int? streak,
  }) {
    return LearningProgress(
      articlesRead: articlesRead ?? this.articlesRead,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      totalScore: totalScore ?? this.totalScore,
      categoryProgress: categoryProgress ?? this.categoryProgress,
      earnedBadges: earnedBadges ?? this.earnedBadges,
      streak: streak ?? this.streak,
    );
  }
}
