#!/usr/bin/env python3
"""
Gemini AI Service for FinSight Chatbot
Integrates Google's Gemini AI for advanced financial advisory conversations
"""

import os
import json
import asyncio
from typing import Dict, List, Optional, Any
from datetime import datetime
import google.generativeai as genai
from dataclasses import dataclass

@dataclass
class ChatContext:
    """Represents the financial context for the conversation"""
    user_id: Optional[str] = None
    monthly_income: Optional[float] = None
    monthly_expenses: Optional[float] = None
    savings_goal: Optional[float] = None
    debt_amount: Optional[float] = None
    risk_tolerance: Optional[str] = None
    financial_goals: Optional[List[str]] = None
    recent_transactions: Optional[List[Dict]] = None

@dataclass
class ChatMessage:
    """Represents a chat message"""
    content: str
    role: str  # 'user' or 'assistant'
    timestamp: datetime
    context: Optional[Dict] = None

class GeminiFinancialAdvisor:
    """
    Advanced Financial Advisory Chatbot powered by Google Gemini AI
    """
    
    def __init__(self, api_key: str = None):
        """Initialize Gemini AI service"""
        self.api_key = api_key or os.getenv('GEMINI_API_KEY')
        if not self.api_key:
            raise ValueError("Gemini API key is required. Set GEMINI_API_KEY environment variable.")
        
        # Configure Gemini AI
        genai.configure(api_key=self.api_key)
        
        # Initialize the model with financial expertise
        self.model = genai.GenerativeModel(
            model_name="gemini-1.5-flash",
            generation_config=genai.types.GenerationConfig(
                temperature=0.7,
                top_p=0.8,
                top_k=40,
                max_output_tokens=1000,
            ),
            system_instruction=self._get_system_prompt()
        )
        
        # Chat sessions storage
        self.chat_sessions: Dict[str, Any] = {}
        
    def _get_system_prompt(self) -> str:
        """Get the system prompt for financial advisory"""
        return """
        You are FinSight AI, an expert financial advisor specializing in personal finance for students and young professionals.
        
        Your expertise includes:
        - Personal budgeting and expense tracking
        - Savings strategies and emergency funds
        - Student loans and debt management
        - Investment basics and portfolio building
        - Financial goal setting and planning
        - Credit building and management
        - Insurance needs assessment
        - Tax planning basics
        
        Guidelines:
        1. Always provide practical, actionable advice
        2. Explain financial concepts in simple, easy-to-understand terms
        3. Consider the user's specific financial situation and context
        4. Prioritize building good financial habits
        5. Be encouraging and supportive
        6. Suggest specific tools, apps, or strategies when appropriate
        7. Always emphasize the importance of emergency funds and avoiding debt
        8. Keep responses concise but comprehensive (under 1000 tokens)
        
        When providing advice:
        - Use bullet points for clarity
        - Include specific numbers or percentages when relevant
        - Suggest next steps the user can take immediately
        - Reference popular financial principles (50/30/20 rule, etc.)
        
        Remember: You're helping students and young professionals build a strong financial foundation.
        """
    
    async def get_chat_response(
        self, 
        message: str, 
        user_id: str,
        context: Optional[ChatContext] = None,
        conversation_history: Optional[List[ChatMessage]] = None
    ) -> Dict[str, Any]:
        """
        Get AI response for a chat message with financial context
        """
        try:
            # Build the conversation prompt with context
            prompt = self._build_contextual_prompt(message, context, conversation_history)
            
            # Get or create chat session
            if user_id not in self.chat_sessions:
                self.chat_sessions[user_id] = self.model.start_chat(history=[])
            
            chat_session = self.chat_sessions[user_id]
            
            # Generate response
            response = await asyncio.to_thread(chat_session.send_message, prompt)
            
            # Process response
            processed_response = self._process_response(response.text, context)
            
            return {
                'success': True,
                'response': processed_response['content'],
                'suggestions': processed_response.get('suggestions', []),
                'quick_replies': processed_response.get('quick_replies', []),
                'intent': self._detect_intent(message),
                'timestamp': datetime.now().isoformat()
            }
            
        except Exception as e:
            return {
                'success': False,
                'error': str(e),
                'fallback_response': self._get_fallback_response(message),
                'timestamp': datetime.now().isoformat()
            }
    
    def _build_contextual_prompt(
        self, 
        message: str, 
        context: Optional[ChatContext],
        history: Optional[List[ChatMessage]]
    ) -> str:
        """Build a contextual prompt with user's financial information"""
        
        prompt_parts = []
        
        # Add context if available
        if context:
            context_info = []
            if context.monthly_income:
                context_info.append(f"Monthly Income: ${context.monthly_income:,.2f}")
            if context.monthly_expenses:
                context_info.append(f"Monthly Expenses: ${context.monthly_expenses:,.2f}")
            if context.savings_goal:
                context_info.append(f"Savings Goal: ${context.savings_goal:,.2f}")
            if context.debt_amount:
                context_info.append(f"Current Debt: ${context.debt_amount:,.2f}")
            if context.risk_tolerance:
                context_info.append(f"Risk Tolerance: {context.risk_tolerance}")
            if context.financial_goals:
                context_info.append(f"Goals: {', '.join(context.financial_goals)}")
            
            if context_info:
                prompt_parts.append(f"User's Financial Context: {' | '.join(context_info)}")
        
        # Add conversation history (last 3 messages for context)
        if history and len(history) > 1:
            recent_history = history[-3:]
            history_text = []
            for msg in recent_history:
                role = "User" if msg.role == "user" else "Assistant"
                history_text.append(f"{role}: {msg.content[:100]}...")
            prompt_parts.append(f"Recent Conversation: {' || '.join(history_text)}")
        
        # Add the current message
        prompt_parts.append(f"Current Question: {message}")
        
        return "\n\n".join(prompt_parts)
    
    def _process_response(self, response_text: str, context: Optional[ChatContext]) -> Dict[str, Any]:
        """Process and enhance the AI response"""
        
        processed = {
            'content': response_text,
            'suggestions': [],
            'quick_replies': []
        }
        
        # Generate contextual quick replies based on the response
        if any(keyword in response_text.lower() for keyword in ['budget', 'budgeting']):
            processed['quick_replies'] = [
                "Show me budget templates",
                "How to track expenses?",
                "50/30/20 rule explanation"
            ]
        elif any(keyword in response_text.lower() for keyword in ['save', 'saving', 'savings']):
            processed['quick_replies'] = [
                "Emergency fund tips",
                "High-yield savings accounts",
                "Automatic savings strategies"
            ]
        elif any(keyword in response_text.lower() for keyword in ['invest', 'investment']):
            processed['quick_replies'] = [
                "Investment basics for beginners",
                "Index funds vs ETFs",
                "How much should I invest?"
            ]
        elif any(keyword in response_text.lower() for keyword in ['debt', 'loan']):
            processed['quick_replies'] = [
                "Debt payoff strategies",
                "Student loan options",
                "Debt consolidation advice"
            ]
        else:
            processed['quick_replies'] = [
                "Create a budget plan",
                "Investment advice",
                "Debt management tips",
                "Savings strategies"
            ]
        
        # Generate suggestions based on context
        if context:
            if context.monthly_income and context.monthly_expenses:
                surplus = context.monthly_income - context.monthly_expenses
                if surplus > 0:
                    processed['suggestions'].append(f"You have ${surplus:,.2f} monthly surplus - consider increasing savings or investments")
                elif surplus < 0:
                    processed['suggestions'].append("Your expenses exceed income - let's work on budget optimization")
        
        return processed
    
    def _detect_intent(self, message: str) -> str:
        """Detect the intent of the user's message"""
        message_lower = message.lower()
        
        intent_keywords = {
            'budgeting': ['budget', 'expense', 'spending', 'track', 'money management'],
            'saving': ['save', 'savings', 'emergency fund', 'goal'],
            'investing': ['invest', 'investment', 'stocks', 'portfolio', 'etf', 'index fund'],
            'debt': ['debt', 'loan', 'credit', 'payment', 'payoff'],
            'planning': ['plan', 'goal', 'future', 'retirement', 'financial plan'],
            'income': ['income', 'salary', 'job', 'career', 'money'],
            'education': ['learn', 'explain', 'what is', 'how does', 'help me understand'],
            'general': ['hello', 'hi', 'help', 'advice', 'recommendation']
        }
        
        for intent, keywords in intent_keywords.items():
            if any(keyword in message_lower for keyword in keywords):
                return intent
        
        return 'general'
    
    def _get_fallback_response(self, message: str) -> str:
        """Get a fallback response when AI fails"""
        intent = self._detect_intent(message)
        
        fallback_responses = {
            'budgeting': "I'd be happy to help you with budgeting! A good starting point is the 50/30/20 rule: 50% for needs, 30% for wants, and 20% for savings. Would you like me to explain how to set this up?",
            'saving': "Building savings is crucial! Start with an emergency fund of 3-6 months of expenses. Even saving $25-50 per month makes a difference. What's your current savings goal?",
            'investing': "Investing can help grow your wealth over time. For beginners, I recommend starting with low-cost index funds or ETFs. Would you like to know more about getting started?",
            'debt': "Managing debt is important for financial health. Focus on high-interest debt first, consider the debt avalanche or snowball method. What type of debt are you dealing with?",
            'planning': "Financial planning starts with setting clear goals. Whether it's an emergency fund, vacation, or retirement - having specific targets helps. What's your main financial goal?",
            'general': "I'm here to help with all your personal finance questions! I can assist with budgeting, saving, investing, debt management, and financial planning. What would you like to explore?"
        }
        
        return fallback_responses.get(intent, fallback_responses['general'])
    
    def clear_chat_session(self, user_id: str):
        """Clear chat session for a user"""
        if user_id in self.chat_sessions:
            del self.chat_sessions[user_id]
    
    def get_session_info(self, user_id: str) -> Dict[str, Any]:
        """Get information about the chat session"""
        return {
            'session_exists': user_id in self.chat_sessions,
            'session_id': user_id,
            'created_at': datetime.now().isoformat()
        }

# Global instance
gemini_advisor = None

def initialize_gemini_service(api_key: str = None) -> GeminiFinancialAdvisor:
    """Initialize the global Gemini service instance"""
    global gemini_advisor
    if gemini_advisor is None:
        gemini_advisor = GeminiFinancialAdvisor(api_key)
    return gemini_advisor

def get_gemini_service() -> Optional[GeminiFinancialAdvisor]:
    """Get the global Gemini service instance"""
    return gemini_advisor
