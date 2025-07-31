#!/usr/bin/env python3
"""
FinSight Backend API Server with Gemini AI Integration
Enhanced with AI-powered financial advisory chatbot
"""

from flask import Flask, jsonify
from flask_cors import CORS
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Initialize Flask app
app = Flask(__name__)
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'finsight-local-secret-key-2025')

# Initialize CORS
CORS(app, origins=['*'])

# Initialize Gemini AI service
try:
    from gemini_service import initialize_gemini_service
    gemini_api_key = os.getenv('GEMINI_API_KEY')
    if gemini_api_key:
        initialize_gemini_service(gemini_api_key)
        print("✅ Gemini AI service initialized successfully")
    else:
        print("⚠️  Warning: GEMINI_API_KEY not found. Chatbot will use fallback responses.")
except Exception as e:
    print(f"❌ Error initializing Gemini service: {e}")

# Register chatbot routes
from chatbot_routes import chatbot_bp
app.register_blueprint(chatbot_bp)

# Basic API routes
@app.route('/', methods=['GET'])
def home():
    """Home endpoint"""
    return jsonify({
        'service': 'FinSight Backend API',
        'version': '1.0.0',
        'description': 'AI-powered personal finance management backend',
        'endpoints': {
            'health': '/api/health',
            'chatbot': '/api/chatbot/chat',
            'chat_history': '/api/chatbot/history/<session_id>',
            'suggestions': '/api/chatbot/suggestions'
        }
    })

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    try:
        from gemini_service import get_gemini_service
        gemini_service = get_gemini_service()
        gemini_status = gemini_service is not None
    except:
        gemini_status = False
    
    return jsonify({
        'status': 'healthy',
        'service': 'FinSight Backend API',
        'gemini_ai': 'available' if gemini_status else 'unavailable',
        'message': 'Server is running successfully'
    })

@app.errorhandler(404)
def not_found(error):
    return jsonify({
        'error': 'Endpoint not found',
        'message': 'The requested endpoint does not exist'
    }), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({
        'error': 'Internal server error',
        'message': 'An unexpected error occurred'
    }), 500

if __name__ == '__main__':
    print("🚀 Starting FinSight Backend API Server with Gemini AI...")
    print("📊 Health Check: http://localhost:5000/api/health")
    print("🤖 Chatbot Endpoint: http://localhost:5000/api/chatbot/chat")
    print("💡 API Documentation: http://localhost:5000/")
    
    app.run(
        debug=True,
        host='0.0.0.0',
        port=int(os.getenv('API_PORT', 5000))
    )
