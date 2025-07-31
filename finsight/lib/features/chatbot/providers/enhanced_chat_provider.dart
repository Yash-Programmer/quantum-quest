import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/chat_models.dart';
import '../services/chatbot_service.dart';
import '../services/gemini_chatbot_service.dart';

// Providers for both chatbot services
final chatbotServiceProvider = Provider((ref) => ChatbotService());
final geminiChatbotServiceProvider = Provider((ref) => GeminiChatbotService());

// Enhanced chat provider that can use either local or Gemini AI
final enhancedChatProvider = StateNotifierProvider<EnhancedChatNotifier, ChatState>((ref) {
  return EnhancedChatNotifier(
    localChatbot: ref.read(chatbotServiceProvider),
    geminiChatbot: ref.read(geminiChatbotServiceProvider),
  );
});

class ChatState {
  final List<ChatMessage> messages;
  final List<ChatSession> sessions;
  final ChatSession? currentSession;
  final bool isLoading;
  final String? error;
  final bool isTyping;
  final FinancialContext? financialContext;
  final bool isGeminiEnabled;
  final bool isGeminiAvailable;

  const ChatState({
    this.messages = const [],
    this.sessions = const [],
    this.currentSession,
    this.isLoading = false,
    this.error,
    this.isTyping = false,
    this.financialContext,
    this.isGeminiEnabled = false,
    this.isGeminiAvailable = false,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    List<ChatSession>? sessions,
    ChatSession? currentSession,
    bool? isLoading,
    String? error,
    bool? isTyping,
    FinancialContext? financialContext,
    bool? isGeminiEnabled,
    bool? isGeminiAvailable,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      sessions: sessions ?? this.sessions,
      currentSession: currentSession ?? this.currentSession,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isTyping: isTyping ?? this.isTyping,
      financialContext: financialContext ?? this.financialContext,
      isGeminiEnabled: isGeminiEnabled ?? this.isGeminiEnabled,
      isGeminiAvailable: isGeminiAvailable ?? this.isGeminiAvailable,
    );
  }
}

class EnhancedChatNotifier extends StateNotifier<ChatState> {
  final ChatbotService _localChatbot;
  final GeminiChatbotService _geminiChatbot;

  EnhancedChatNotifier({
    required ChatbotService localChatbot,
    required GeminiChatbotService geminiChatbot,
  })  : _localChatbot = localChatbot,
        _geminiChatbot = geminiChatbot,
        super(const ChatState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Initialize Gemini service
      await _geminiChatbot.initialize();
      
      // Check if Gemini is available
      final isGeminiAvailable = await _geminiChatbot.isGeminiAvailable();
      
      // Load existing messages
      List<ChatMessage> messages;
      if (isGeminiAvailable) {
        messages = await _geminiChatbot.getChatHistory();
        if (messages.isEmpty) {
          await _geminiChatbot.createDemoConversation();
          messages = await _geminiChatbot.getChatHistory();
        }
      } else {
        messages = await _localChatbot.getChatHistory();
        if (messages.isEmpty) {
          await _localChatbot.createDemoConversation();
          messages = await _localChatbot.getChatHistory();
        }
      }

      state = state.copyWith(
        messages: messages,
        isLoading: false,
        isGeminiAvailable: isGeminiAvailable,
        isGeminiEnabled: isGeminiAvailable, // Auto-enable if available
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize chat: $e',
      );
    }
  }

  /// Send a message using the appropriate service
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    state = state.copyWith(isTyping: true, error: null);

    try {
      ChatMessage response;
      
      if (state.isGeminiEnabled && state.isGeminiAvailable) {
        // Use Gemini AI
        response = await _geminiChatbot.sendMessage(content);
      } else {
        // Use local chatbot
        response = await _localChatbot.sendMessage(content);
      }

      // Update messages list
      final updatedMessages = [...state.messages, response];

      state = state.copyWith(
        messages: updatedMessages,
        isTyping: false,
      );

      // Update financial context if response contains relevant info
      await _updateFinancialContextFromResponse(response);

    } catch (e) {
      state = state.copyWith(
        isTyping: false,
        error: 'Failed to send message: $e',
      );
    }
  }

  /// Update user's financial context
  Future<void> updateFinancialContext({
    double? monthlyIncome,
    double? monthlyExpenses,
    double? savingsGoal,
    double? debtAmount,
    String? riskTolerance,
    List<String>? financialGoals,
  }) async {
    try {
      // Update context in both services
      if (state.isGeminiEnabled && state.isGeminiAvailable) {
        await _geminiChatbot.updateUserContext(
          monthlyIncome: monthlyIncome,
          monthlyExpenses: monthlyExpenses,
          savingsGoal: savingsGoal,
          debtAmount: debtAmount,
          riskTolerance: riskTolerance,
          financialGoals: financialGoals,
        );
      }

      // Update local context
      final updatedContext = FinancialContext(
        monthlyIncome: monthlyIncome ?? state.financialContext?.monthlyIncome,
        monthlyExpenses: monthlyExpenses ?? state.financialContext?.monthlyExpenses,
        savingsGoal: savingsGoal ?? state.financialContext?.savingsGoal,
        currentDebt: debtAmount ?? state.financialContext?.currentDebt,
        riskTolerance: riskTolerance ?? state.financialContext?.riskTolerance,
        financialGoals: financialGoals ?? state.financialContext?.financialGoals,
      );

      state = state.copyWith(financialContext: updatedContext);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update financial context: $e');
    }
  }

  /// Toggle between Gemini AI and local chatbot
  Future<void> toggleGeminiMode(bool enabled) async {
    if (!state.isGeminiAvailable && enabled) {
      state = state.copyWith(error: 'Gemini AI is not available');
      return;
    }

    state = state.copyWith(isGeminiEnabled: enabled);

    // Optionally reload messages from the newly selected service
    await _reloadMessages();
  }

  /// Get conversation starters
  Future<List<String>> getConversationStarters() async {
    try {
      if (state.isGeminiEnabled && state.isGeminiAvailable) {
        return await _geminiChatbot.getConversationStarters();
      } else {
        return _localChatbot.getConversationStarters();
      }
    } catch (e) {
      // Return fallback starters
      return [
        "How can I create a budget?",
        "What's the best way to start investing?",
        "How do I build an emergency fund?",
        "Tips for paying off debt?",
        "How much should I save each month?",
      ];
    }
  }

  /// Clear current chat session
  Future<void> clearSession() async {
    state = state.copyWith(isLoading: true);

    try {
      if (state.isGeminiEnabled && state.isGeminiAvailable) {
        await _geminiChatbot.clearSession();
      } else {
        await _localChatbot.clearChatHistory();
      }

      state = state.copyWith(
        messages: [],
        currentSession: null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to clear session: $e',
      );
    }
  }

  /// Handle quick reply selection
  Future<void> handleQuickReply(QuickReply quickReply) async {
    await sendMessage(quickReply.text);
  }

  /// Refresh Gemini availability status
  Future<void> refreshGeminiStatus() async {
    try {
      final isAvailable = await _geminiChatbot.isGeminiAvailable();
      state = state.copyWith(
        isGeminiAvailable: isAvailable,
        isGeminiEnabled: isAvailable && state.isGeminiEnabled,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to check Gemini status: $e');
    }
  }

  // Private helper methods

  Future<void> _reloadMessages() async {
    state = state.copyWith(isLoading: true);

    try {
      List<ChatMessage> messages;
      
      if (state.isGeminiEnabled && state.isGeminiAvailable) {
        messages = await _geminiChatbot.getChatHistory();
      } else {
        messages = await _localChatbot.getChatHistory();
      }

      state = state.copyWith(
        messages: messages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to reload messages: $e',
      );
    }
  }

  Future<void> _updateFinancialContextFromResponse(ChatMessage response) async {
    // Extract financial insights from AI response
    try {
      final metadata = response.metadata;
      if (metadata != null && metadata['suggestions'] != null) {
        final suggestions = metadata['suggestions'] as List;
        
        // Look for specific financial context updates in suggestions
        for (final suggestion in suggestions) {
          final suggestionText = suggestion.toString().toLowerCase();
          
          // Example: Parse budget recommendations
          if (suggestionText.contains('budget') && suggestionText.contains('\$')) {
            // Extract budget amounts if mentioned
            // This could be enhanced with more sophisticated parsing
          }
        }
      }
    } catch (e) {
      // Silently fail - context updates are not critical
    }
  }

  /// Create a new session
  Future<void> createNewSession(String title) async {
    try {
      final newSession = ChatSession(
        id: 'session_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        createdAt: DateTime.now(),
        lastMessageAt: DateTime.now(),
        messageCount: 0,
      );

      final updatedSessions = [...state.sessions, newSession];
      
      state = state.copyWith(
        sessions: updatedSessions,
        currentSession: newSession,
        messages: [],
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to create new session: $e');
    }
  }

  /// Export chat history
  Map<String, dynamic> exportChatHistory() {
    return {
      'export_date': DateTime.now().toIso8601String(),
      'service_used': state.isGeminiEnabled ? 'gemini' : 'local',
      'total_messages': state.messages.length,
      'messages': state.messages.map((m) => m.toJson()).toList(),
      'financial_context': state.financialContext?.toJson(),
    };
  }
}
