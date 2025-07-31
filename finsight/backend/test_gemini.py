#!/usr/bin/env python3
"""
Simple test script to verify Gemini AI integration works
"""

import os
import json
import asyncio
from datetime import datetime

# Check if packages are available
try:
    import google.generativeai as genai
    from dotenv import load_dotenv
    GEMINI_AVAILABLE = True
except ImportError as e:
    print(f"Missing packages: {e}")
    print("Run: pip install google-generativeai python-dotenv")
    GEMINI_AVAILABLE = False
    exit(1)

# Load environment
load_dotenv()

async def test_gemini():
    """Test Gemini AI with a financial question"""
    
    api_key = os.getenv('GEMINI_API_KEY')
    if not api_key or api_key == 'your_gemini_api_key_here':
        print("❌ No Gemini API key found in .env file")
        print("Please add your API key to the .env file")
        return False
    
    try:
        # Configure Gemini
        genai.configure(api_key=api_key)
        
        # Create model with financial advisor prompt
        model = genai.GenerativeModel(
            model_name="gemini-1.5-flash",
            system_instruction="""
            You are a helpful financial advisor for students and young professionals.
            Provide practical, actionable advice in a friendly tone.
            Keep responses concise but informative.
            """
        )
        
        # Test questions
        test_questions = [
            "How can I start budgeting as a college student?",
            "What's the best way to build an emergency fund?",
            "Should I invest or pay off student loans first?",
        ]
        
        print("🤖 Testing Gemini AI Financial Advisor...")
        print("=" * 50)
        
        for i, question in enumerate(test_questions, 1):
            print(f"\n📝 Test {i}: {question}")
            print("-" * 30)
            
            # Generate response
            response = await asyncio.to_thread(model.generate_content, question)
            
            print(f"🤖 AI Response:")
            print(response.text)
            print("-" * 30)
        
        print("\n✅ Gemini AI is working perfectly!")
        return True
        
    except Exception as e:
        print(f"❌ Gemini test failed: {e}")
        return False

async def test_api_format():
    """Test the API response format that Flutter will receive"""
    
    print("\n🔧 Testing API Response Format...")
    
    # Simulate API response
    api_response = {
        'success': True,
        'response': "Great question! Here's how to start budgeting as a student:\n\n• Track your income and expenses for a week\n• Use the 50/30/20 rule: 50% needs, 30% wants, 20% savings\n• Start with simple apps like Mint or even a spreadsheet\n• Set realistic spending limits for each category\n\nWould you like specific tips for any category?",
        'suggestions': [
            "You might want to track expenses for a few weeks to understand your spending patterns",
            "Consider using the envelope method for cash expenses"
        ],
        'quick_replies': [
            "Show me budget templates",
            "How to track expenses?", 
            "Savings tips for students"
        ],
        'intent': 'budgeting',
        'session_id': f"session_{datetime.now().timestamp()}",
        'timestamp': datetime.now().isoformat()
    }
    
    print("📱 Flutter will receive this JSON:")
    print(json.dumps(api_response, indent=2))
    
    return True

def main():
    print("🚀 FinSight Gemini AI Test")
    print("=" * 50)
    
    # Run async tests
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    
    try:
        # Test Gemini AI
        success = loop.run_until_complete(test_gemini())
        
        if success:
            # Test API format
            loop.run_until_complete(test_api_format())
            
            print("\n🎉 All tests passed!")
            print("\nNext steps:")
            print("1. Run the backend: python app_gemini.py")
            print("2. Update your Flutter app to use the new Gemini service")
            print("3. Test the complete integration")
        
    finally:
        loop.close()

if __name__ == "__main__":
    main()
