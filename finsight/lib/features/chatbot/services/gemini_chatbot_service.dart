import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/local_storage_service.dart';
import '../domain/models/chat_models.dart';

class GeminiChatbotService {
  final LocalStorageService _storage = LocalStorageService();
  static const String _messagesKey = 'chat_messages';
  static const String _contextKey = 'user_financial_context';

  // Backend API configuration
  static const String _baseUrl = 'http://localhost:5000/api/chatbot';
  static const Duration _timeout = Duration(seconds: 30);

  // User context for personalized responses
  Map<String, dynamic>? _userContext;
  String? _currentSessionId;

  /// Initialize the service and load user context
  Future<void> initialize() async {
    await _loadUserContext();
    _currentSessionId = await _getCurrentSessionId();
  }

  /// Send a message to Gemini AI and get response
  Future<ChatMessage> sendMessage(String messageText, {String? userId}) async {
    try {
      userId ??= 'user_${DateTime.now().millisecondsSinceEpoch}';

      // Create user message
      final userMessage = ChatMessage(
        id: _generateMessageId(),
        content: messageText,
        type: MessageType.user,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );

      // Save user message locally
      await _saveMessage(userMessage);

      // Prepare request data
      final requestData = {
        'message': messageText,
        'user_id': userId,
        'session_id': _currentSessionId,
        'context': _userContext ?? {},
      };

      // Send request to Gemini backend
      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestData),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          // Update session ID if provided
          if (data['session_id'] != null) {
            _currentSessionId = data['session_id'];
            await _storage.setString('current_session_id', _currentSessionId!);
          }

          // Create AI response message
          final aiMessage = ChatMessage(
            id: _generateMessageId(),
            content:
                data['response'] ??
                'I apologize, but I couldn\'t generate a response.',
            type: MessageType.bot,
            timestamp: DateTime.now(),
            status: MessageStatus.delivered,
            quickReplies: _parseQuickReplies(data['quick_replies']),
            metadata: {
              'suggestions': data['suggestions'] ?? [],
              'session_id': data['session_id'],
              'ai_powered': true,
              'intent': data['intent'],
            },
          );

          // Save AI message locally
          await _saveMessage(aiMessage);

          return aiMessage;
        } else {
          // Handle API error with fallback
          return _createFallbackMessage(
            data['fallback_response'] ??
                'I encountered an error. Please try again.',
          );
        }
      } else {
        // Handle HTTP error
        return _createFallbackMessage(
          'Unable to connect to AI service. Please check your connection.',
        );
      }
    } catch (e) {
      // Debug: 
      // Return fallback response for any error
      return _createFallbackMessage(_getLocalFallbackResponse(messageText));
    }
  }

  /// Update user's financial context for personalized responses
  Future<void> updateUserContext({
    double? monthlyIncome,
    double? monthlyExpenses,
    double? savingsGoal,
    double? debtAmount,
    String? riskTolerance,
    List<String>? financialGoals,
  }) async {
    _userContext = {
      'monthly_income': monthlyIncome,
      'monthly_expenses': monthlyExpenses,
      'savings_goal': savingsGoal,
      'debt_amount': debtAmount,
      'risk_tolerance': riskTolerance,
      'financial_goals': financialGoals,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Save locally
    await _storage.setString(_contextKey, jsonEncode(_userContext));

    // Update backend
    try {
      await http
          .post(
            Uri.parse('$_baseUrl/context'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user_id': 'current_user',
              'context': _userContext,
            }),
          )
          .timeout(_timeout);
    } catch (e) {
      // Debug: 
      // Context is still saved locally, so it's not critical
    }
  }

  /// Get conversation starters from the backend
  Future<List<String>> getConversationStarters() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/suggestions'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<String>.from(data['suggestions'] ?? []);
        }
      }
    } catch (e) {
      // Debug: 
    }

    // Fallback suggestions
    return [
      "How can I create a budget as a student?",
      "What's the best way to start investing with limited money?",
      "How do I build an emergency fund?",
      "What are some tips for paying off student loans?",
      "How much should I save each month?",
    ];
  }

  /// Get chat history for current session
  Future<List<ChatMessage>> getChatHistory([String? sessionId]) async {
    sessionId ??= _currentSessionId;
    if (sessionId == null) return [];

    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/history/$sessionId'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return _parseHistoryMessages(data['history']);
        }
      }
    } catch (e) {
      // Debug: 
    }

    // Fallback to local storage
    return await _getLocalMessages();
  }

  /// Clear current chat session
  Future<void> clearSession() async {
    if (_currentSessionId != null) {
      try {
        await http
            .delete(Uri.parse('$_baseUrl/session/$_currentSessionId'))
            .timeout(_timeout);
      } catch (e) {
        // Debug: 
      }
    }

    // Clear local data
    await _storage.remove(_messagesKey);
    _currentSessionId = null;
    await _storage.remove('current_session_id');
  }

  /// Check if Gemini AI service is available
  Future<bool> isGeminiAvailable() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['gemini_available'] == true;
      }
    } catch (e) {
      // Debug: 
    }
    return false;
  }

  // Private helper methods

  Future<void> _loadUserContext() async {
    try {
      final contextString = await _storage.getString(_contextKey);
      if (contextString != null) {
        _userContext = jsonDecode(contextString);
      }
    } catch (e) {
      // Debug: 
    }
  }

  Future<String?> _getCurrentSessionId() async {
    return await _storage.getString('current_session_id');
  }

  Future<void> _saveMessage(ChatMessage message) async {
    try {
      final messages = await _getLocalMessages();
      messages.add(message);

      // Keep only last 100 messages locally
      if (messages.length > 100) {
        messages.removeRange(0, messages.length - 100);
      }

      final messagesJson = messages.map((m) => m.toJson()).toList();
      await _storage.setString(_messagesKey, jsonEncode(messagesJson));
    } catch (e) {
      // Debug: 
    }
  }

  Future<List<ChatMessage>> _getLocalMessages() async {
    try {
      final messagesString = await _storage.getString(_messagesKey);
      if (messagesString != null) {
        final List<dynamic> messagesJson = jsonDecode(messagesString);
        return messagesJson.map((json) => ChatMessage.fromJson(json)).toList();
      }
    } catch (e) {
      // Debug: 
    }
    return [];
  }

  String _generateMessageId() {
    return 'msg_${DateTime.now().millisecondsSinceEpoch}_${(999 + DateTime.now().microsecond).toString().substring(0, 3)}';
  }

  List<QuickReply> _parseQuickReplies(dynamic quickReplies) {
    if (quickReplies == null) return [];

    try {
      return (quickReplies as List)
          .map(
            (reply) => QuickReply(
              id: _generateMessageId(),
              text: reply.toString(),
              icon: _getIconForQuickReply(reply.toString()),
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  String _getIconForQuickReply(String text) {
    final textLower = text.toLowerCase();
    if (textLower.contains('budget')) return '💰';
    if (textLower.contains('save') || textLower.contains('saving')) return '🏦';
    if (textLower.contains('invest')) return '📈';
    if (textLower.contains('debt')) return '💳';
    if (textLower.contains('goal')) return '🎯';
    if (textLower.contains('emergency')) return '🆘';
    return '💡';
  }

  List<ChatMessage> _parseHistoryMessages(List<dynamic> history) {
    try {
      return history.map((msg) {
        return ChatMessage(
          id: msg['id'] ?? _generateMessageId(),
          content: msg['user_message'] ?? msg['ai_response'] ?? '',
          type: msg['user_message'] != null
              ? MessageType.user
              : MessageType.bot,
          timestamp:
              DateTime.tryParse(msg['timestamp'] ?? '') ?? DateTime.now(),
          status: MessageStatus.delivered,
        );
      }).toList();
    } catch (e) {
      // Debug: 
      return [];
    }
  }

  ChatMessage _createFallbackMessage(String content) {
    return ChatMessage(
      id: _generateMessageId(),
      content: content,
      type: MessageType.bot,
      timestamp: DateTime.now(),
      status: MessageStatus.delivered,
      quickReplies: [
        QuickReply(id: '1', text: 'Try again', icon: '🔄'),
        QuickReply(id: '2', text: 'Get help', icon: '❓'),
      ],
      metadata: {'is_fallback': true},
    );
  }

  String _getLocalFallbackResponse(String message) {
    final messageLower = message.toLowerCase();

    if (messageLower.contains('budget')) {
      return "I'd be happy to help with budgeting! The 50/30/20 rule is a great starting point: 50% for needs, 30% for wants, and 20% for savings. Would you like specific budgeting tips?";
    } else if (messageLower.contains('save') ||
        messageLower.contains('saving')) {
      return "Building savings is crucial! Start with an emergency fund goal of 3-6 months of expenses. Even small amounts like \$25-50 per month make a difference over time.";
    } else if (messageLower.contains('invest')) {
      return "For beginner investing, consider low-cost index funds or ETFs. They provide diversification and typically have lower fees. Start with what you can afford and think long-term!";
    } else if (messageLower.contains('debt')) {
      return "For debt management, try the avalanche method (pay highest interest first) or snowball method (pay smallest balance first). Both work - choose what motivates you most!";
    } else {
      return "I'm here to help with all your personal finance questions! I can assist with budgeting, saving, investing, debt management, and financial planning. What would you like to explore?";
    }
  }

  /// Create a demo conversation for new users
  Future<void> createDemoConversation() async {
    final demoMessages = [
      ChatMessage(
        id: _generateMessageId(),
        content:
            "Welcome to FinSight AI! 🌟 I'm your personal financial advisor, powered by advanced AI to help you make smart money decisions.",
        type: MessageType.bot,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        status: MessageStatus.delivered,
        quickReplies: [
          QuickReply(id: '1', text: 'Create a budget', icon: '💰'),
          QuickReply(id: '2', text: 'Investment tips', icon: '📈'),
          QuickReply(id: '3', text: 'Saving strategies', icon: '🏦'),
        ],
      ),
      ChatMessage(
        id: _generateMessageId(),
        content:
            "I can help you with budgeting, saving, investing, debt management, and achieving your financial goals. What would you like to explore first?",
        type: MessageType.bot,
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        status: MessageStatus.delivered,
      ),
    ];

    for (final message in demoMessages) {
      await _saveMessage(message);
    }
  }
}
