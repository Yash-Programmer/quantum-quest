#!/usr/bin/env python3
"""
Test your Gemini AI chatbot by sending HTTP requests
"""

import requests
import json

def test_chatbot():
    base_url = "http://localhost:5000"
    
    print("🧪 Testing FinSight AI Chatbot")
    print("=" * 40)
    
    # Test 1: Check if server is running
    try:
        response = requests.get(f"{base_url}/")
        print("✅ Server is running")
        print(f"Status: {response.json()}")
    except Exception as e:
        print(f"❌ Server not running: {e}")
        print("Start the server first: python simple_app.py")
        return
    
    # Test 2: Test Gemini AI
    try:
        response = requests.get(f"{base_url}/test")
        result = response.json()
        print(f"\n🤖 Gemini Test Result:")
        print(f"Ready: {result.get('gemini_ready')}")
        if result.get('test_response'):
            print(f"AI Response: {result['test_response']}")
    except Exception as e:
        print(f"❌ Gemini test failed: {e}")
    
    # Test 3: Chat with financial context
    chat_data = {
        "message": "I'm a college student earning $800/month from a part-time job. How should I manage my money?",
        "context": {
            "monthly_income": 800,
            "monthly_expenses": 600
        }
    }
    
    try:
        print(f"\n📤 Sending chat request:")
        print(f"Message: {chat_data['message']}")
        print(f"Context: Income ${chat_data['context']['monthly_income']}, Expenses ${chat_data['context']['monthly_expenses']}")
        
        response = requests.post(
            f"{base_url}/chat",
            headers={'Content-Type': 'application/json'},
            json=chat_data
        )
        
        result = response.json()
        print(f"\n📥 AI Response:")
        print(f"Success: {result.get('success')}")
        print(f"AI Powered: {result.get('ai_powered')}")
        print(f"Response: {result.get('response', 'No response')}")
        print(f"Quick Replies: {result.get('quick_replies', [])}")
        
        if result.get('success') and len(result.get('response', '')) > 50:
            print("\n🎉 SUCCESS! Gemini AI is generating real responses!")
        else:
            print("\n⚠️ Response seems short or there was an error")
            
    except Exception as e:
        print(f"❌ Chat test failed: {e}")

if __name__ == "__main__":
    test_chatbot()
