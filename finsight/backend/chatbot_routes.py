#!/usr/bin/env python3
"""
Gemini AI Chatbot API Routes for FinSight
Provides RESTful endpoints for AI-powered financial advisory chat
"""

from flask import Blueprint, request, jsonify
import asyncio
import json
from datetime import datetime
from typing import Dict, List, Optional, Any

# Import Gemini service
try:
    from gemini_service import get_gemini_service, ChatContext, ChatMessage
    GEMINI_AVAILABLE = True
except ImportError as e:
    print(f"Warning: Gemini service not available: {e}")
    GEMINI_AVAILABLE = False

# Create blueprint for chatbot routes
chatbot_bp = Blueprint('chatbot', __name__)

# In-memory storage for chat sessions (in production, use a proper database)
chat_sessions: Dict[str, List[Dict]] = {}
user_contexts: Dict[str, Dict] = {}

@chatbot_bp.route('/api/chatbot/chat', methods=['POST'])
def chat_with_ai():
    """Main chat endpoint for AI conversations"""
    try:
        if not GEMINI_AVAILABLE:
            return jsonify({
                'success': False,
                'error': 'Gemini AI service is not available',
                'fallback_response': get_fallback_response(request.json.get('message', ''))
            }), 503
        
        data = request.json
        message = data.get('message', '').strip()
        user_id = data.get('user_id', 'anonymous')
        session_id = data.get('session_id', f"session_{user_id}_{datetime.now().timestamp()}")
        
        if not message:
            return jsonify({
                'success': False,
                'error': 'Message is required'
            }), 400
        
        # Get user's financial context
        context = get_user_context(user_id, data.get('context', {}))
        
        # Get conversation history
        history = get_conversation_history(session_id)
        
        # Get Gemini service
        gemini_service = get_gemini_service()
        if not gemini_service:
            return jsonify({
                'success': False,
                'error': 'Gemini service not initialized',
                'fallback_response': get_fallback_response(message)
            }), 503
        
        # Get AI response (run async function)
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        
        try:
            ai_response = loop.run_until_complete(
                gemini_service.get_chat_response(
                    message=message,
                    user_id=user_id,
                    context=context,
                    conversation_history=history
                )
            )
        finally:
            loop.close()
        
        # Save to conversation history
        save_to_history(session_id, message, ai_response.get('response', ''), user_id)
        
        return jsonify({
            'success': ai_response.get('success', True),
            'response': ai_response.get('response', ''),
            'suggestions': ai_response.get('suggestions', []),
            'quick_replies': ai_response.get('quick_replies', []),
            'intent': ai_response.get('intent', 'general'),
            'session_id': session_id,
            'timestamp': ai_response.get('timestamp', datetime.now().isoformat())
        })
        
    except Exception as e:
        print(f"Error in chat endpoint: {e}")
        return jsonify({
            'success': False,
            'error': 'Internal server error',
            'fallback_response': get_fallback_response(request.json.get('message', ''))
        }), 500

@chatbot_bp.route('/api/chatbot/context', methods=['POST'])
def update_user_context():
    """Update user's financial context for better AI responses"""
    try:
        data = request.json
        user_id = data.get('user_id', 'anonymous')
        context_data = data.get('context', {})
        
        # Update user context
        user_contexts[user_id] = {
            'monthly_income': context_data.get('monthly_income'),
            'monthly_expenses': context_data.get('monthly_expenses'),
            'savings_goal': context_data.get('savings_goal'),
            'debt_amount': context_data.get('debt_amount'),
            'risk_tolerance': context_data.get('risk_tolerance'),
            'financial_goals': context_data.get('financial_goals', []),
            'updated_at': datetime.now().isoformat()
        }
        
        return jsonify({
            'success': True,
            'message': 'Context updated successfully'
        })
        
    except Exception as e:
        print(f"Error updating context: {e}")
        return jsonify({
            'success': False,
            'error': 'Failed to update context'
        }), 500

@chatbot_bp.route('/api/chatbot/history/<session_id>', methods=['GET'])
def get_chat_history(session_id):
    """Get chat history for a session"""
    try:
        history = chat_sessions.get(session_id, [])
        return jsonify({
            'success': True,
            'history': history,
            'session_id': session_id
        })
    except Exception as e:
        print(f"Error getting history: {e}")
        return jsonify({
            'success': False,
            'error': 'Failed to retrieve history'
        }), 500

@chatbot_bp.route('/api/chatbot/sessions/<user_id>', methods=['GET'])
def get_user_sessions(user_id):
    """Get all chat sessions for a user"""
    try:
        user_sessions = []
        for session_id, messages in chat_sessions.items():
            if any(msg.get('user_id') == user_id for msg in messages):
                last_message = messages[-1] if messages else {}
                user_sessions.append({
                    'session_id': session_id,
                    'last_message': last_message.get('user_message', ''),
                    'last_updated': last_message.get('timestamp', ''),
                    'message_count': len(messages)
                })
        
        return jsonify({
            'success': True,
            'sessions': user_sessions
        })
    except Exception as e:
        print(f"Error getting sessions: {e}")
        return jsonify({
            'success': False,
            'error': 'Failed to retrieve sessions'
        }), 500

@chatbot_bp.route('/api/chatbot/session/<session_id>', methods=['DELETE'])
def delete_session(session_id):
    """Delete a chat session"""
    try:
        if session_id in chat_sessions:
            del chat_sessions[session_id]
        
        return jsonify({
            'success': True,
            'message': 'Session deleted successfully'
        })
    except Exception as e:
        print(f"Error deleting session: {e}")
        return jsonify({
            'success': False,
            'error': 'Failed to delete session'
        }), 500

@chatbot_bp.route('/api/chatbot/suggestions', methods=['GET'])
def get_conversation_starters():
    """Get suggested conversation starters"""
    suggestions = [
        "How can I create a budget as a student?",
        "What's the best way to start investing with limited money?",
        "How do I build an emergency fund?",
        "What are some tips for paying off student loans?",
        "How much should I save each month?",
        "What investment apps are good for beginners?",
        "How can I improve my credit score?",
        "What's the 50/30/20 budgeting rule?",
        "Should I invest or pay off debt first?",
        "How do I set financial goals?"
    ]
    
    return jsonify({
        'success': True,
        'suggestions': suggestions
    })

@chatbot_bp.route('/api/chatbot/health', methods=['GET'])
def chatbot_health():
    """Health check for chatbot service"""
    gemini_service = get_gemini_service()
    
    return jsonify({
        'success': True,
        'gemini_available': GEMINI_AVAILABLE,
        'service_initialized': gemini_service is not None,
        'active_sessions': len(chat_sessions),
        'timestamp': datetime.now().isoformat()
    })

# Helper functions

def get_user_context(user_id: str, context_data: Dict) -> Optional[ChatContext]:
    """Get or create user context"""
    try:
        if not GEMINI_AVAILABLE:
            return None
            
        # Merge existing context with new data
        existing_context = user_contexts.get(user_id, {})
        merged_context = {**existing_context, **context_data}
        
        # Create ChatContext object
        from gemini_service import ChatContext
        return ChatContext(
            user_id=user_id,
            monthly_income=merged_context.get('monthly_income'),
            monthly_expenses=merged_context.get('monthly_expenses'),
            savings_goal=merged_context.get('savings_goal'),
            debt_amount=merged_context.get('debt_amount'),
            risk_tolerance=merged_context.get('risk_tolerance'),
            financial_goals=merged_context.get('financial_goals', [])
        )
    except Exception as e:
        print(f"Error creating context: {e}")
        return None

def get_conversation_history(session_id: str) -> List[ChatMessage]:
    """Get conversation history as ChatMessage objects"""
    try:
        if not GEMINI_AVAILABLE:
            return []
            
        messages = chat_sessions.get(session_id, [])
        history = []
        
        from gemini_service import ChatMessage
        for msg in messages[-10:]:  # Last 10 messages for context
            # Add user message
            if msg.get('user_message'):
                history.append(ChatMessage(
                    content=msg['user_message'],
                    role='user',
                    timestamp=datetime.fromisoformat(msg.get('timestamp', datetime.now().isoformat()))
                ))
            
            # Add assistant message
            if msg.get('ai_response'):
                history.append(ChatMessage(
                    content=msg['ai_response'],
                    role='assistant',
                    timestamp=datetime.fromisoformat(msg.get('timestamp', datetime.now().isoformat()))
                ))
        
        return history
    except Exception as e:
        print(f"Error getting history: {e}")
        return []

def save_to_history(session_id: str, user_message: str, ai_response: str, user_id: str):
    """Save conversation to history"""
    try:
        if session_id not in chat_sessions:
            chat_sessions[session_id] = []
        
        chat_sessions[session_id].append({
            'user_id': user_id,
            'user_message': user_message,
            'ai_response': ai_response,
            'timestamp': datetime.now().isoformat()
        })
        
        # Keep only last 50 messages per session
        if len(chat_sessions[session_id]) > 50:
            chat_sessions[session_id] = chat_sessions[session_id][-50:]
            
    except Exception as e:
        print(f"Error saving to history: {e}")

def get_fallback_response(message: str) -> str:
    """Get a fallback response when Gemini is not available"""
    message_lower = message.lower()
    
    if any(word in message_lower for word in ['budget', 'expense', 'spending']):
        return """I'd be happy to help with budgeting! Here are some key tips:

• Follow the 50/30/20 rule: 50% for needs, 30% for wants, 20% for savings
• Track all expenses for at least a month to understand your spending patterns
• Use apps like Mint, YNAB, or even a simple spreadsheet
• Set specific spending limits for each category
• Review and adjust your budget monthly

Would you like specific advice on any particular aspect of budgeting?"""

    elif any(word in message_lower for word in ['save', 'saving', 'emergency']):
        return """Building savings is crucial for financial security! Here's how to start:

• Start with an emergency fund of 3-6 months of expenses
• Save even small amounts - $25-50/month adds up over time
• Automate your savings to make it effortless
• Look for high-yield savings accounts (currently 4-5% APY)
• Consider the "pay yourself first" approach

What's your current savings goal? I can help you create a plan to reach it."""

    elif any(word in message_lower for word in ['invest', 'investment', 'stocks']):
        return """Investing can help your money grow over time! For beginners:

• Start with low-cost index funds or ETFs
• Consider apps like Acorns, Robinhood, or Fidelity for easy investing
• Diversify your investments across different sectors
• Think long-term (5+ years) for better returns
• Only invest money you won't need soon

How much are you thinking of investing, and what's your timeline?"""

    elif any(word in message_lower for word in ['debt', 'loan', 'credit']):
        return """Managing debt effectively is key to financial health:

• List all debts with balances, interest rates, and minimum payments
• Consider the debt avalanche (highest interest first) or snowball (smallest balance first) method
• Look into refinancing or consolidation options
• Always pay more than the minimum when possible
• Avoid taking on new debt while paying off existing debt

What type of debt are you dealing with? I can provide more specific guidance."""

    else:
        return """Hello! I'm your AI financial advisor, here to help with all your personal finance questions.

I can assist you with:
• Creating and managing budgets
• Building savings and emergency funds
• Investment strategies for beginners
• Debt management and payoff plans
• Financial goal setting and planning
• Student finance tips

What financial topic would you like to explore today?"""
