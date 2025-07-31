#!/usr/bin/env python3
"""
Simple Flask app to test Gemini AI chatbot
"""

from flask import Flask, jsonify, request
from flask_cors import CORS
import os
import asyncio
from dotenv import load_dotenv

# Load environment
load_dotenv()

app = Flask(__name__)
CORS(app)

# Initialize Gemini
try:
    import google.generativeai as genai
    
    api_key = os.getenv('GEMINI_API_KEY')
    if api_key:
        genai.configure(api_key=api_key)
        model = genai.GenerativeModel(
            model_name="gemini-1.5-flash",
            system_instruction="""
            You are FinSight AI, a helpful financial advisor for students and young professionals.
            Always provide specific, actionable financial advice.
            Be conversational and helpful.
            Include practical tips they can implement immediately.
            """
        )
        GEMINI_READY = True
        print("✅ Gemini AI initialized successfully!")
    else:
        GEMINI_READY = False
        print("❌ No Gemini API key found")
except Exception as e:
    GEMINI_READY = False
    print(f"❌ Gemini initialization failed: {e}")

@app.route('/')
def home():
    return jsonify({
        'service': 'FinSight AI Chatbot',
        'gemini_status': 'ready' if GEMINI_READY else 'not available',
        'test_endpoint': '/test',
        'chat_endpoint': '/chat'
    })

@app.route('/test')
def test():
    if not GEMINI_READY:
        return jsonify({
            'error': 'Gemini AI not available',
            'gemini_ready': False
        })
    
    try:
        # Simple test
        response = model.generate_content("Say hello and give one quick budgeting tip in 2 sentences.")
        return jsonify({
            'gemini_ready': True,
            'test_response': response.text,
            'message': 'Gemini AI is working!'
        })
    except Exception as e:
        return jsonify({
            'error': str(e),
            'gemini_ready': False
        })

@app.route('/chat', methods=['POST'])
def chat():
    if not GEMINI_READY:
        return jsonify({
            'success': False,
            'error': 'Gemini AI not available',
            'fallback': 'Please check your API key configuration'
        })
    
    try:
        data = request.json
        user_message = data.get('message', '')
        
        if not user_message:
            return jsonify({
                'success': False,
                'error': 'Message is required'
            })
        
        # Build financial context prompt
        context_info = ""
        if 'context' in data:
            ctx = data['context']
            if ctx.get('monthly_income'):
                context_info += f"User's monthly income: ${ctx['monthly_income']}. "
            if ctx.get('monthly_expenses'):
                context_info += f"Monthly expenses: ${ctx['monthly_expenses']}. "
            if ctx.get('savings_goal'):
                context_info += f"Savings goal: ${ctx['savings_goal']}. "
        
        # Create full prompt
        full_prompt = f"""
        {context_info}
        
        User question: {user_message}
        
        Please provide specific, actionable financial advice. Be helpful and encouraging.
        """
        
        # Get AI response
        response = model.generate_content(full_prompt)
        ai_response = response.text
        
        # Generate quick replies based on response
        quick_replies = []
        if 'budget' in ai_response.lower():
            quick_replies = ["Show budget templates", "Track expenses", "Savings tips"]
        elif 'invest' in ai_response.lower():
            quick_replies = ["Investment basics", "Best apps", "Risk tolerance"]
        elif 'save' in ai_response.lower():
            quick_replies = ["Emergency fund", "High-yield accounts", "Automatic savings"]
        else:
            quick_replies = ["More tips", "Budget help", "Investment advice"]
        
        return jsonify({
            'success': True,
            'response': ai_response,
            'quick_replies': quick_replies,
            'ai_powered': True,
            'context_used': bool(context_info)
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e),
            'fallback': 'I encountered an error. Please try again.'
        })

if __name__ == '__main__':
    print("🚀 Starting FinSight AI Chatbot Server...")
    print(f"📊 Gemini AI Status: {'Ready' if GEMINI_READY else 'Not Available'}")
    print("🌐 Server will be available at: http://localhost:5000")
    print("🧪 Test endpoint: http://localhost:5000/test")
    print("💬 Chat endpoint: http://localhost:5000/chat")
    
    app.run(debug=True, host='0.0.0.0', port=5000)
