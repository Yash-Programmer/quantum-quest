import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/chat_models.dart';
import '../services/chatbot_service.dart';

final chatbotServiceProvider = Provider<ChatbotService>((ref) {
  return ChatbotService();
});

final chatNotifierProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final service = ref.watch(chatbotServiceProvider);
  return ChatNotifier(service);
});

class ChatState {
  final List<ChatMessage> messages;
  final List<ChatSession> sessions;
  final ChatSession? currentSession;
  final bool isLoading;
  final bool isTyping;
  final String? error;
  final ChatContext? context;

  ChatState({
    this.messages = const [],
    this.sessions = const [],
    this.currentSession,
    this.isLoading = false,
    this.isTyping = false,
    this.error,
    this.context,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    List<ChatSession>? sessions,
    ChatSession? currentSession,
    bool? isLoading,
    bool? isTyping,
    String? error,
    ChatContext? context,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      sessions: sessions ?? this.sessions,
      currentSession: currentSession ?? this.currentSession,
      isLoading: isLoading ?? this.isLoading,
      isTyping: isTyping ?? this.isTyping,
      error: error ?? this.error,
      context: context ?? this.context,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatbotService _service;

  ChatNotifier(this._service) : super(ChatState()) {
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    state = state.copyWith(isLoading: true);
    try {
      final messages = await _service.loadMessages();
      final sessions = await _service.loadSessions();
      
      // Create default context
      final context = ChatContext(
        userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
        userProfile: {},
        recentTopics: [],
        sessionData: {},
        financialContext: _createDemoFinancialContext(),
      );

      ChatSession? currentSession;
      if (sessions.isNotEmpty) {
        currentSession = sessions.first;
      } else {
        // Create first session with welcome message
        currentSession = await _createNewSession();
      }

      state = state.copyWith(
        messages: messages,
        sessions: sessions,
        currentSession: currentSession,
        context: context,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<ChatSession> _createNewSession() async {
    final sessionId = _generateId();
    final now = DateTime.now();
    
    // Create welcome message
    final welcomeMessage = ChatMessage(
      id: _generateId(),
      content: "Hi there! I'm your personal finance assistant. How can I help you manage your money better today? 💰",
      type: MessageType.bot,
      timestamp: now,
      quickReplies: [
        QuickReply(id: '1', text: '💰 Budgeting Tips', payload: 'budgeting'),
        QuickReply(id: '2', text: '🏦 Saving Strategies', payload: 'saving'),
        QuickReply(id: '3', text: '📈 Investment Basics', payload: 'investing'),
        QuickReply(id: '4', text: '🎯 Financial Goals', payload: 'goals'),
      ],
    );

    final session = ChatSession(
      id: sessionId,
      title: 'Financial Chat',
      createdAt: now,
      lastMessageAt: now,
      messages: [welcomeMessage],
      context: state.context ?? ChatContext(
        userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
        userProfile: {},
        recentTopics: [],
        sessionData: {},
      ),
    );

    return session;
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: _generateId(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    // Add user message to state
    final updatedMessages = [...state.messages, userMessage];
    state = state.copyWith(messages: updatedMessages);

    // Save messages
    await _service.saveMessages(updatedMessages);

    // Show typing indicator
    state = state.copyWith(isTyping: true);

    try {
      // Generate bot response
      final response = await _service.generateResponse(content, state.context!);
      
      // Create bot message
      final botMessage = ChatMessage(
        id: _generateId(),
        content: response.text,
        type: MessageType.bot,
        timestamp: DateTime.now(),
        status: MessageStatus.delivered,
        quickReplies: response.quickReplies,
        attachment: response.attachment,
        metadata: response.metadata,
      );

      // Add bot message to state
      final finalMessages = [...updatedMessages, botMessage];
      state = state.copyWith(
        messages: finalMessages,
        isTyping: false,
      );

      // Save updated messages
      await _service.saveMessages(finalMessages);

      // Update session
      if (state.currentSession != null) {
        final updatedSession = ChatSession(
          id: state.currentSession!.id,
          title: state.currentSession!.title,
          createdAt: state.currentSession!.createdAt,
          lastMessageAt: DateTime.now(),
          messages: finalMessages,
          context: state.currentSession!.context,
        );

        final updatedSessions = state.sessions.map((s) => 
          s.id == updatedSession.id ? updatedSession : s).toList();

        state = state.copyWith(
          currentSession: updatedSession,
          sessions: updatedSessions,
        );

        await _service.saveSessions(updatedSessions);
      }

    } catch (e) {
      state = state.copyWith(
        isTyping: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendQuickReply(QuickReply quickReply) async {
    await sendMessage(quickReply.text);
  }

  Future<void> createNewSession() async {
    final newSession = await _createNewSession();
    final updatedSessions = [newSession, ...state.sessions];

    state = state.copyWith(
      currentSession: newSession,
      sessions: updatedSessions,
      messages: newSession.messages,
    );

    await _service.saveSessions(updatedSessions);
  }

  Future<void> loadSession(String sessionId) async {
    final session = state.sessions.firstWhere((s) => s.id == sessionId);
    state = state.copyWith(
      currentSession: session,
      messages: session.messages,
    );
  }

  Future<void> deleteSession(String sessionId) async {
    final updatedSessions = state.sessions.where((s) => s.id != sessionId).toList();
    state = state.copyWith(sessions: updatedSessions);

    if (state.currentSession?.id == sessionId) {
      if (updatedSessions.isNotEmpty) {
        state = state.copyWith(
          currentSession: updatedSessions.first,
          messages: updatedSessions.first.messages,
        );
      } else {
        final newSession = await _createNewSession();
        state = state.copyWith(
          currentSession: newSession,
          messages: newSession.messages,
          sessions: [newSession],
        );
        await _service.saveSessions([newSession]);
        return;
      }
    }

    await _service.saveSessions(updatedSessions);
  }

  Future<void> clearAllMessages() async {
    state = state.copyWith(messages: []);
    await _service.saveMessages([]);
  }

  Future<void> loadDemoConversation() async {
    final demoMessages = await _service.createDemoConversation();
    state = state.copyWith(messages: demoMessages);
    await _service.saveMessages(demoMessages);
  }

  void updateFinancialContext(FinancialContext financialContext) {
    if (state.context != null) {
      final updatedContext = ChatContext(
        userId: state.context!.userId,
        userProfile: state.context!.userProfile,
        recentTopics: state.context!.recentTopics,
        sessionData: state.context!.sessionData,
        financialContext: financialContext,
      );
      state = state.copyWith(context: updatedContext);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  FinancialContext _createDemoFinancialContext() {
    return FinancialContext(
      currentBalance: 1250.0,
      monthlyIncome: 800.0,
      monthlyExpenses: 650.0,
      recentTransactions: [
        'Coffee - \$4.50',
        'Groceries - \$67.23',
        'Gas - \$35.00',
        'Movie tickets - \$24.00',
        'Textbook - \$89.99',
      ],
      budgetCategories: {
        'Food & Dining': 200.0,
        'Transportation': 100.0,
        'Entertainment': 80.0,
        'Education': 150.0,
        'Shopping': 120.0,
      },
      financialGoals: [
        'Build \$1,000 emergency fund',
        'Save for spring break trip',
        'Pay off credit card',
      ],
    );
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(1000).toString();
  }
}

// Specific providers for UI components
final currentMessagesProvider = Provider<List<ChatMessage>>((ref) {
  final state = ref.watch(chatNotifierProvider);
  return state.messages;
});

final chatSessionsProvider = Provider<List<ChatSession>>((ref) {
  final state = ref.watch(chatNotifierProvider);
  return state.sessions;
});

final currentSessionProvider = Provider<ChatSession?>((ref) {
  final state = ref.watch(chatNotifierProvider);
  return state.currentSession;
});

final isTypingProvider = Provider<bool>((ref) {
  final state = ref.watch(chatNotifierProvider);
  return state.isTyping;
});

final chatContextProvider = Provider<ChatContext?>((ref) {
  final state = ref.watch(chatNotifierProvider);
  return state.context;
});
