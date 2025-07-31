import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/local_storage_service.dart';
import '../domain/models/chat_models.dart';

class GeminiChatService {
  final LocalStorageService _storage = LocalStorageService();
  static const String _baseUrl = 'http://localhost:5000';
  static const String _messagesKey = 'gemini_chat_messages';
  static const String _contextKey = 'user_financial_context';
  
  // Timeout for API calls
  static const Duration _timeout = Duration(seconds: 30);
  
  // User's financial context for personalized responses
  Map<String, dynamic>? _userContext;

  /// Initialize the service
  Future<void> initialize() async {
    await _loadUserContext();
  }

  /// Check if the Gemini backend is available
  Future<bool> isAvailable() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/'))
          .timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['gemini_status'] == 'ready';
      }
      return false;
    } catch (e) {
      print('Gemini service check failed: $e');
      return false;
    }
  }

  /// Send message to Gemini AI and get response
  Future<ChatMessage> sendMessage(String messageText, {String? userId}) async {
    try {
      // Create user message first
      final userMessage = ChatMessage(
        id: _generateMessageId(),
        content: messageText,
        type: MessageType.user,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
        userId: userId,
      );

      // Save user message
      await _saveMessage(userMessage);

      // Prepare request for Gemini AI
      final requestData = {
        'message': messageText,
        'user_id': userId ?? 'flutter_user',
        'context': _userContext ?? {},
      };

      print('Sending to Gemini: $requestData');

      // Send to Gemini backend
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

      print('Gemini response status: ${response.statusCode}');
      print('Gemini response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          // Create AI response message
          final aiMessage = ChatMessage(
            id: _generateMessageId(),
            content: data['response'] ?? 'I apologize, but I couldn\'t generate a response.',
            type: MessageType.bot,
            timestamp: DateTime.now(),
            status: MessageStatus.delivered,
            userId: 'gemini_ai',
            quickReplies: _parseQuickReplies(data['quick_replies']),
            metadata: {
              'ai_powered': data['ai_powered'] ?? true,
              'context_used': data['context_used'] ?? false,
              'gemini_response': true,
            },
          );

          // Save AI message
          await _saveMessage(aiMessage);
          
          return aiMessage;
        } else {
          // Handle API error
          return _createErrorMessage(data['error'] ?? 'Unknown error occurred');
        }
      } else {
        return _createErrorMessage('Failed to connect to AI service');
      }
    } catch (e) {
      print('Error communicating with Gemini: $e');
      return _createErrorMessage('Network error: ${e.toString()}');
    }
  }

  /// Update user's financial context for personalized responses
  Future<void> updateFinancialContext({
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

    // Save context locally
    await _storage.setString(_contextKey, jsonEncode(_userContext));
    print('Financial context updated: $_userContext');
  }

  /// Get chat history
  Future<List<ChatMessage>> getChatHistory() async {
    try {
      final messagesString = await _storage.getString(_messagesKey);
      if (messagesString != null && messagesString.isNotEmpty) {
        final List<dynamic> messagesJson = jsonDecode(messagesString);
        return messagesJson.map((json) => ChatMessage.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading chat history: $e');
    }
    return [];
  }

  /// Clear chat history
  Future<void> clearChatHistory() async {
    try {
      await _storage.setString(_messagesKey, '[]');
    } catch (e) {
      print('Error clearing chat history: $e');
    }
  }

  /// Save a message to local storage
  Future<void> _saveMessage(ChatMessage message) async {
    try {
      final messages = await getChatHistory();
      messages.add(message);
      
      // Keep only last 100 messages
      if (messages.length > 100) {
        messages.removeRange(0, messages.length - 100);
      }
      
      final messagesJson = messages.map((m) => m.toJson()).toList();
      await _storage.setString(_messagesKey, jsonEncode(messagesJson));
    } catch (e) {
      print('Error saving message: $e');
    }
  }

  /// Load user's financial context
  Future<void> _loadUserContext() async {
    try {
      final contextString = await _storage.getString(_contextKey);
      if (contextString != null && contextString.isNotEmpty) {
        _userContext = jsonDecode(contextString);
        print('Loaded financial context: $_userContext');
      }
    } catch (e) {
      print('Error loading financial context: $e');
    }
  }

  /// Generate a unique message ID
  String _generateMessageId() {
    return 'msg_${DateTime.now().millisecondsSinceEpoch}_${(1000 + DateTime.now().microsecond % 1000)}';
  }

  /// Parse quick replies from API response
  List<QuickReply> _parseQuickReplies(dynamic quickReplies) {
    if (quickReplies == null) return [];
    
    try {
      return (quickReplies as List)
          .map((reply) => QuickReply(
                id: _generateMessageId(),
                text: reply.toString(),
                icon: _getIconForQuickReply(reply.toString()),
              ))
          .toList();
    } catch (e) {
      print('Error parsing quick replies: $e');
      return [];
    }
  }

  /// Get appropriate icon for quick reply text
  String _getIconForQuickReply(String text) {
    final textLower = text.toLowerCase();
    if (textLower.contains('budget')) return '💰';
    if (textLower.contains('save') || textLower.contains('saving')) return '🏦';
    if (textLower.contains('invest')) return '📈';
    if (textLower.contains('debt')) return '💳';
    if (textLower.contains('goal')) return '🎯';
    if (textLower.contains('emergency')) return '🆘';
    if (textLower.contains('tip')) return '💡';
    return '🤔';
  }

  /// Create an error message
  ChatMessage _createErrorMessage(String error) {
    return ChatMessage(
      id: _generateMessageId(),
      content: 'I\'m having trouble connecting to the AI service right now. Please check that the backend server is running and try again.\n\nError: $error',
      type: MessageType.bot,
      timestamp: DateTime.now(),
      status: MessageStatus.failed,
      userId: 'system',
      quickReplies: [
        QuickReply(id: '1', text: 'Try again', icon: '🔄'),
        QuickReply(id: '2', text: 'Help', icon: '❓'),
      ],
      metadata: {
        'is_error': true,
        'error_message': error,
      },
    );
  }

  /// Create a demo conversation to show what Gemini can do
  Future<void> createDemoConversation() async {
    final demoMessages = [
      ChatMessage(
        id: _generateMessageId(),
        content: "Welcome to FinSight AI! 🤖✨\n\nI'm now powered by Google's Gemini AI to provide you with intelligent, personalized financial advice. I can help you with:\n\n💰 Budgeting strategies\n📈 Investment guidance\n🏦 Savings plans\n💳 Debt management\n🎯 Financial goal setting\n\nWhat would you like to explore first?",
        type: MessageType.bot,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        status: MessageStatus.delivered,
        userId: 'gemini_ai',
        quickReplies: [
          QuickReply(id: '1', text: 'Create a budget', icon: '💰'),
          QuickReply(id: '2', text: 'Investment tips', icon: '📈'),
          QuickReply(id: '3', text: 'Saving strategies', icon: '🏦'),
        ],
        metadata: {'is_demo': true, 'ai_powered': true},
      ),
    ];

    for (final message in demoMessages) {
      await _saveMessage(message);
    }
  }

  /// Test the Gemini connection
  Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/test'))
          .timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'error': 'Server returned ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
