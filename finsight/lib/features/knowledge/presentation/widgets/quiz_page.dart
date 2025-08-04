import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/knowledge_models.dart';
import '../../providers/knowledge_provider.dart';

class QuizPage extends ConsumerStatefulWidget {
  final Quiz quiz;

  const QuizPage({super.key, required this.quiz});

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {
  int currentQuestionIndex = 0;
  List<int> selectedAnswers = [];
  bool showResults = false;
  int totalScore = 0;

  @override
  void initState() {
    super.initState();
    selectedAnswers = List.filled(widget.quiz.questions.length, -1);
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      selectedAnswers[currentQuestionIndex] = answerIndex;
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      _finishQuiz();
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  void _finishQuiz() {
    int score = 0;
    for (int i = 0; i < widget.quiz.questions.length; i++) {
      if (selectedAnswers[i] == widget.quiz.questions[i].correctAnswerIndex) {
        score += 10; // 10 points per correct answer
      }
    }

    setState(() {
      totalScore = score;
      showResults = true;
    });

    // Update quiz completion status
    ref.read(quizzesProvider.notifier).completeQuiz(widget.quiz.id, score);

    // Update learning progress
    ref.read(learningProgressProvider.notifier).addQuizScore(score);
  }

  void _restartQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      selectedAnswers = List.filled(widget.quiz.questions.length, -1);
      showResults = false;
      totalScore = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentQuestion = widget.quiz.questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        backgroundColor: _getCategoryColor(widget.quiz.category),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: showResults
          ? _buildResultsView(theme)
          : _buildQuizView(theme, currentQuestion),
    );
  }

  Widget _buildQuizView(ThemeData theme, QuizQuestion currentQuestion) {
    final progress = (currentQuestionIndex + 1) / widget.quiz.questions.length;

    return Column(
      children: [
        // Progress bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getCategoryColor(widget.quiz.category),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${currentQuestionIndex + 1} of ${widget.quiz.questions.length}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white30,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 4,
              ),
            ],
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Question
                Text(
                  currentQuestion.question,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),

                const SizedBox(height: 30),

                // Answer options
                Expanded(
                  child: ListView.builder(
                    itemCount: currentQuestion.options.length,
                    itemBuilder: (context, index) {
                      final isSelected =
                          selectedAnswers[currentQuestionIndex] == index;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _selectAnswer(index),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _getCategoryColor(
                                        widget.quiz.category,
                                      ).withValues(alpha: 0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? _getCategoryColor(widget.quiz.category)
                                      : Colors.grey.withValues(alpha: 0.3),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? _getCategoryColor(
                                              widget.quiz.category,
                                            )
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected
                                            ? _getCategoryColor(
                                                widget.quiz.category,
                                              )
                                            : Colors.grey,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      currentQuestion.options[index],
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: isSelected
                                            ? _getCategoryColor(
                                                widget.quiz.category,
                                              )
                                            : theme.brightness ==
                                                  Brightness.dark
                                            ? Colors.white
                                            : Colors.black87,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Navigation buttons
                Row(
                  children: [
                    if (currentQuestionIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousQuestion,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: _getCategoryColor(widget.quiz.category),
                            ),
                          ),
                          child: Text(
                            'Previous',
                            style: TextStyle(
                              color: _getCategoryColor(widget.quiz.category),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    if (currentQuestionIndex > 0) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: selectedAnswers[currentQuestionIndex] != -1
                            ? _nextQuestion
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getCategoryColor(
                            widget.quiz.category,
                          ),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          currentQuestionIndex ==
                                  widget.quiz.questions.length - 1
                              ? 'Finish Quiz'
                              : 'Next',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsView(ThemeData theme) {
    final correctAnswers = selectedAnswers
        .asMap()
        .entries
        .where(
          (entry) =>
              entry.value ==
              widget.quiz.questions[entry.key].correctAnswerIndex,
        )
        .length;
    final totalQuestions = widget.quiz.questions.length;
    final percentage = (correctAnswers / totalQuestions * 100).round();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Score circle
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getCategoryColor(
                widget.quiz.category,
              ).withValues(alpha: 0.1),
              border: Border.all(
                color: _getCategoryColor(widget.quiz.category),
                width: 4,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _getCategoryColor(widget.quiz.category),
                  ),
                ),
                Text(
                  'Score',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          Text(
            _getScoreMessage(percentage),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Text(
            'You got $correctAnswers out of $totalQuestions questions correct!',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Detailed results
          Expanded(
            child: ListView.builder(
              itemCount: widget.quiz.questions.length,
              itemBuilder: (context, index) {
                final question = widget.quiz.questions[index];
                final selectedAnswer = selectedAnswers[index];
                final isCorrect = selectedAnswer == question.correctAnswerIndex;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Question ${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isCorrect ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          question.question,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        if (!isCorrect) ...[
                          Text(
                            'Correct answer: ${question.options[question.correctAnswerIndex]}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (question.explanation.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              question.explanation,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _restartQuiz,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: _getCategoryColor(widget.quiz.category),
                    ),
                  ),
                  child: Text(
                    'Retake Quiz',
                    style: TextStyle(
                      color: _getCategoryColor(widget.quiz.category),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getCategoryColor(widget.quiz.category),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue Learning',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'budgeting':
        return Colors.blue;
      case 'investing':
        return Colors.green;
      case 'savings':
        return Colors.orange;
      case 'credit':
        return Colors.purple;
      case 'tax':
        return Colors.red;
      case 'income':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getScoreMessage(int percentage) {
    if (percentage >= 90) {
      return 'Excellent! 🎉';
    } else if (percentage >= 70) {
      return 'Great Job! 👏';
    } else if (percentage >= 50) {
      return 'Good Effort! 👍';
    } else {
      return 'Keep Learning! 📚';
    }
  }
}
