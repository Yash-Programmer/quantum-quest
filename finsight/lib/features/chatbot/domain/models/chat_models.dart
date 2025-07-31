class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final MessageStatus status;
  final String? userId;
  final Map<String, dynamic>? metadata;
  final List<QuickReply>? quickReplies;
  final ChatAttachment? attachment;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.userId,
    this.metadata,
    this.quickReplies,
    this.attachment,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'userId': userId,
      'metadata': metadata,
      'quickReplies': quickReplies?.map((q) => q.toJson()).toList(),
      'attachment': attachment?.toJson(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      type: MessageType.values.byName(json['type']),
      timestamp: DateTime.parse(json['timestamp']),
      status: MessageStatus.values.byName(json['status']),
      userId: json['userId'],
      metadata: json['metadata'],
      quickReplies: (json['quickReplies'] as List?)
          ?.map((q) => QuickReply.fromJson(q))
          .toList(),
      attachment: json['attachment'] != null
          ? ChatAttachment.fromJson(json['attachment'])
          : null,
    );
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    MessageStatus? status,
    String? userId,
    Map<String, dynamic>? metadata,
    List<QuickReply>? quickReplies,
    ChatAttachment? attachment,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      metadata: metadata ?? this.metadata,
      quickReplies: quickReplies ?? this.quickReplies,
      attachment: attachment ?? this.attachment,
    );
  }
}

enum MessageType {
  user,
  bot,
  system,
  typing,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class QuickReply {
  final String id;
  final String text;
  final String? payload;
  final String? icon;

  QuickReply({
    required this.id,
    required this.text,
    this.payload,
    this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'payload': payload,
      'icon': icon,
    };
  }

  factory QuickReply.fromJson(Map<String, dynamic> json) {
    return QuickReply(
      id: json['id'],
      text: json['text'],
      payload: json['payload'],
      icon: json['icon'],
    );
  }
}

class ChatAttachment {
  final String id;
  final AttachmentType type;
  final String url;
  final String? title;
  final String? description;
  final Map<String, dynamic>? data;

  ChatAttachment({
    required this.id,
    required this.type,
    required this.url,
    this.title,
    this.description,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'url': url,
      'title': title,
      'description': description,
      'data': data,
    };
  }

  factory ChatAttachment.fromJson(Map<String, dynamic> json) {
    return ChatAttachment(
      id: json['id'],
      type: AttachmentType.values.byName(json['type']),
      url: json['url'],
      title: json['title'],
      description: json['description'],
      data: json['data'],
    );
  }
}

enum AttachmentType {
  image,
  chart,
  document,
  link,
  audio,
}

class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final List<ChatMessage> messages;
  final ChatContext context;
  final bool isActive;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.lastMessageAt,
    required this.messages,
    required this.context,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'context': context.toJson(),
      'isActive': isActive,
    };
  }

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['createdAt']),
      lastMessageAt: DateTime.parse(json['lastMessageAt']),
      messages: (json['messages'] as List)
          .map((m) => ChatMessage.fromJson(m))
          .toList(),
      context: ChatContext.fromJson(json['context']),
      isActive: json['isActive'],
    );
  }
}

class ChatContext {
  final String userId;
  final Map<String, dynamic> userProfile;
  final List<String> recentTopics;
  final Map<String, dynamic> sessionData;
  final FinancialContext? financialContext;

  ChatContext({
    required this.userId,
    required this.userProfile,
    required this.recentTopics,
    required this.sessionData,
    this.financialContext,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userProfile': userProfile,
      'recentTopics': recentTopics,
      'sessionData': sessionData,
      'financialContext': financialContext?.toJson(),
    };
  }

  factory ChatContext.fromJson(Map<String, dynamic> json) {
    return ChatContext(
      userId: json['userId'],
      userProfile: json['userProfile'],
      recentTopics: List<String>.from(json['recentTopics']),
      sessionData: json['sessionData'],
      financialContext: json['financialContext'] != null
          ? FinancialContext.fromJson(json['financialContext'])
          : null,
    );
  }
}

class FinancialContext {
  final double currentBalance;
  final double monthlyIncome;
  final double monthlyExpenses;
  final List<String> recentTransactions;
  final Map<String, double> budgetCategories;
  final List<String> financialGoals;

  FinancialContext({
    required this.currentBalance,
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.recentTransactions,
    required this.budgetCategories,
    required this.financialGoals,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentBalance': currentBalance,
      'monthlyIncome': monthlyIncome,
      'monthlyExpenses': monthlyExpenses,
      'recentTransactions': recentTransactions,
      'budgetCategories': budgetCategories,
      'financialGoals': financialGoals,
    };
  }

  factory FinancialContext.fromJson(Map<String, dynamic> json) {
    return FinancialContext(
      currentBalance: json['currentBalance'].toDouble(),
      monthlyIncome: json['monthlyIncome'].toDouble(),
      monthlyExpenses: json['monthlyExpenses'].toDouble(),
      recentTransactions: List<String>.from(json['recentTransactions']),
      budgetCategories: Map<String, double>.from(json['budgetCategories']),
      financialGoals: List<String>.from(json['financialGoals']),
    );
  }
}

class BotIntent {
  final String name;
  final double confidence;
  final Map<String, dynamic> entities;
  final String? action;

  BotIntent({
    required this.name,
    required this.confidence,
    required this.entities,
    this.action,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'confidence': confidence,
      'entities': entities,
      'action': action,
    };
  }

  factory BotIntent.fromJson(Map<String, dynamic> json) {
    return BotIntent(
      name: json['name'],
      confidence: json['confidence'].toDouble(),
      entities: json['entities'],
      action: json['action'],
    );
  }
}

class BotResponse {
  final String text;
  final List<QuickReply>? quickReplies;
  final ChatAttachment? attachment;
  final BotIntent? intent;
  final Map<String, dynamic>? metadata;

  BotResponse({
    required this.text,
    this.quickReplies,
    this.attachment,
    this.intent,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'quickReplies': quickReplies?.map((q) => q.toJson()).toList(),
      'attachment': attachment?.toJson(),
      'intent': intent?.toJson(),
      'metadata': metadata,
    };
  }

  factory BotResponse.fromJson(Map<String, dynamic> json) {
    return BotResponse(
      text: json['text'],
      quickReplies: (json['quickReplies'] as List?)
          ?.map((q) => QuickReply.fromJson(q))
          .toList(),
      attachment: json['attachment'] != null
          ? ChatAttachment.fromJson(json['attachment'])
          : null,
      intent: json['intent'] != null
          ? BotIntent.fromJson(json['intent'])
          : null,
      metadata: json['metadata'],
    );
  }
}
