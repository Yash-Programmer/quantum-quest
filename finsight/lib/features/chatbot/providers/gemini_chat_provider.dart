import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/chat_models.dart';
import '../services/chatbot_service.dart';
import '../services/gemini_chat_service.dart';

// Providers
final chatbotServiceProvider = Provider<ChatbotService>((ref) => ChatbotService());
final geminiChatServiceProvider = Provider<GeminiChatService>((ref) => GeminiChatService());

// Enhanced chat provider that can use Gemini AI
final geminiChatNotifierProvider = StateNotifierProvider<GeminiChatNotifier, GeminiChatState>((ref) {
  final geminiService = ref.watch(geminiChatServiceProvider);
  final localService = ref.watch(chatbotServiceProvider);
  return GeminiChatNotifier(geminiService, localService);
});

// Enhanced state for Gemini chat
class GeminiChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isTyping;
  final String? error;
  final bool isGeminiAvailable;
  final bool useGemini;
  final Map<String, dynamic>? financialContext;

  const GeminiChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isTyping = false,
    this.error,
    this.isGeminiAvailable = false,
    this.useGemini = true,
    this.financialContext,
  });

  GeminiChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isTyping,
    String? error,
    bool? isGeminiAvailable,
    bool? useGemini,
    Map<String, dynamic>? financialContext,
  }) {
    return GeminiChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isTyping: isTyping ?? this.isTyping,
      error: error,
      isGeminiAvailable: isGeminiAvailable ?? this.isGeminiAvailable,
      useGemini: useGemini ?? this.useGemini,
      financialContext: financialContext ?? this.financialContext,
    );
  }
}

class GeminiChatNotifier extends StateNotifier<GeminiChatState> {
  final GeminiChatService _geminiService;
  final ChatbotService _localService;

  GeminiChatNotifier(this._geminiService, this._localService) : super(const GeminiChatState()) {
    _initialize();
  }

  /// Initialize the chat service
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Initialize Gemini service
      await _geminiService.initialize();
      
      // Check if Gemini is available
      final isAvailable = await _geminiService.isAvailable();
      print('Gemini availability: $isAvailable');
      
      // Load existing messages
      final messages = await _geminiService.getChatHistory();
      
      // Create demo conversation if no messages exist
      if (messages.isEmpty) {
        await _geminiService.createDemoConversation();
        final demoMessages = await _geminiService.getChatHistory();
        
        state = state.copyWith(
          messages: demoMessages,
          isLoading: false,
          isGeminiAvailable: isAvailable,
        );
      } else {
        state = state.copyWith(
          messages: messages,
          isLoading: false,
          isGeminiAvailable: isAvailable,
        );
      }
      
    } catch (e) {
      print('Initialization error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize: $e',
        isGeminiAvailable: false,
      );
    }
  }

  /// Send a message
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Add user message immediately to UI
    final userMessage = ChatMessage(
      id: _generateMessageId(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isTyping: true,
      error: null,
    );

    try {
      ChatMessage response;
      
      if (state.useGemini && state.isGeminiAvailable) {
        print('Using Gemini AI for response');
        // Use Gemini AI
        response = await _geminiService.sendMessage(content);
      } else {
        print('Using local chatbot for response');
        // Use local chatbot as fallback
        final botResponse = await _localService.generateResponse(
          content, 
          ChatContext(
            userId: 'default_user',
            userProfile: {},
            recentTopics: [],
            sessionData: {},
            financialContext: FinancialContext(
              currentBalance: 0,
              monthlyIncome: 0,
              monthlyExpenses: 0,
              recentTransactions: [],
              budgetCategories: {},
              financialGoals: [],
            ),
          )
        );
        
        response = ChatMessage(
          id: _generateMessageId(),
          content: botResponse.text,
          type: MessageType.bot,
          timestamp: DateTime.now(),
          status: MessageStatus.delivered,
          quickReplies: botResponse.quickReplies,
        );
      }

      // Update the user message status to sent
      final updatedMessages = state.messages.map((msg) {
        if (msg.id == userMessage.id) {
          return msg.copyWith(status: MessageStatus.sent);
        }
        return msg;
      }).toList();

      // Add the response
      updatedMessages.add(response);

      state = state.copyWith(
        messages: updatedMessages,
        isTyping: false,
      );

    } catch (e) {
      print('Error sending message: $e');
      
      // Update user message to failed
      final updatedMessages = state.messages.map((msg) {
        if (msg.id == userMessage.id) {
          return msg.copyWith(status: MessageStatus.failed);
        }
        return msg;
      }).toList();

      state = state.copyWith(
        messages: updatedMessages,
        isTyping: false,
        error: 'Failed to send message: $e',
      );
    }
  }

  /// Update financial context for personalized responses
  Future<void> updateFinancialContext({
    double? monthlyIncome,
    double? monthlyExpenses,
    double? savingsGoal,
    double? debtAmount,
    String? riskTolerance,
    List<String>? financialGoals,
  }) async {
    try {
      await _geminiService.updateFinancialContext(
        monthlyIncome: monthlyIncome,
        monthlyExpenses: monthlyExpenses,
        savingsGoal: savingsGoal,
        debtAmount: debtAmount,
        riskTolerance: riskTolerance,
        financialGoals: financialGoals,
      );

      final context = {
        'monthly_income': monthlyIncome,
        'monthly_expenses': monthlyExpenses,
        'savings_goal': savingsGoal,
        'debt_amount': debtAmount,
        'risk_tolerance': riskTolerance,
        'financial_goals': financialGoals,
      };

      state = state.copyWith(financialContext: context);
      
      print('Financial context updated in provider');
    } catch (e) {
      print('Error updating financial context: $e');
      state = state.copyWith(error: 'Failed to update context: $e');
    }
  }

  /// Handle quick reply selection
  Future<void> handleQuickReply(QuickReply quickReply) async {
    await sendMessage(quickReply.text);
  }

  /// Clear chat history
  Future<void> clearChat() async {
    try {
      await _geminiService.clearChatHistory();
      state = state.copyWith(messages: []);
    } catch (e) {
      print('Error clearing chat: $e');
      state = state.copyWith(error: 'Failed to clear chat: $e');
    }
  }

  /// Toggle between Gemini and local chatbot
  void toggleGeminiMode(bool useGemini) {
    state = state.copyWith(useGemini: useGemini);
    print('Switched to ${useGemini ? 'Gemini AI' : 'Local'} mode');
  }

  /// Refresh Gemini availability
  Future<void> refreshGeminiStatus() async {
    try {
      final isAvailable = await _geminiService.isAvailable();
      state = state.copyWith(isGeminiAvailable: isAvailable);
      print('Gemini status refreshed: $isAvailable');
    } catch (e) {
      print('Error refreshing Gemini status: $e');
      state = state.copyWith(isGeminiAvailable: false);
    }
  }

  /// Test Gemini connection
  Future<void> testGeminiConnection() async {
    try {
      final result = await _geminiService.testConnection();
      if (result['success'] == true) {
        state = state.copyWith(
          isGeminiAvailable: true,
          error: null,
        );
        print('Gemini connection test successful');
      } else {
        state = state.copyWith(
          isGeminiAvailable: false,
          error: 'Gemini test failed: ${result['error']}',
        );
        print('Gemini connection test failed: ${result['error']}');
      }
    } catch (e) {
      print('Error testing Gemini connection: $e');
      state = state.copyWith(
        isGeminiAvailable: false,
        error: 'Connection test error: $e',
      );
    }
  }

  String _generateMessageId() {
    return 'msg_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond % 1000}';
  }
}

// Convenience providers for easy access
final geminiMessagesProvider = Provider<List<ChatMessage>>((ref) {
  return ref.watch(geminiChatNotifierProvider).messages;
});

final geminiIsTypingProvider = Provider<bool>((ref) {
  return ref.watch(geminiChatNotifierProvider).isTyping;
});

final geminiIsAvailableProvider = Provider<bool>((ref) {
  return ref.watch(geminiChatNotifierProvider).isGeminiAvailable;
});

final geminiErrorProvider = Provider<String?>((ref) {
  return ref.watch(geminiChatNotifierProvider).error;
});
