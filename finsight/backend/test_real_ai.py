#!/usr/bin/env python3
"""
Test Gemini AI integration to ensure it's generating real responses
"""

import os
import asyncio
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Test Gemini AI directly
async def test_gemini_direct():
    print("🧪 Testing Gemini AI Direct Connection...")
    print("=" * 50)
    
    try:
        import google.generativeai as genai
        
        # Get API key
        api_key = os.getenv('GEMINI_API_KEY')
        print(f"🔑 API Key found: {api_key[:10]}...{api_key[-4:] if api_key else 'None'}")
        
        if not api_key:
            print("❌ No API key found in environment")
            return False
        
        # Configure Gemini
        genai.configure(api_key=api_key)
        
        # Create model
        model = genai.GenerativeModel(
            model_name="gemini-1.5-flash",
            system_instruction="""
            You are FinSight AI, a helpful financial advisor for students and young professionals.
            Provide practical, actionable financial advice in a friendly tone.
            Always mention that you're powered by AI and provide specific, personalized recommendations.
            """
        )
        
        print("✅ Gemini model initialized")
        
        # Test questions
        test_questions = [
            "I'm a college student with $500/month income. How should I budget?",
            "Should I invest $100/month or save it in a bank account?",
            "I have $2000 in credit card debt. What's the best way to pay it off?"
        ]
        
        for i, question in enumerate(test_questions, 1):
            print(f"\n📝 Test {i}: {question}")
            print("-" * 40)
            
            # Generate response using Gemini
            try:
                response = await asyncio.to_thread(model.generate_content, question)
                ai_response = response.text
                
                print(f"🤖 Gemini AI Response:")
                print(ai_response)
                print("-" * 40)
                
                # Check if it's a real AI response
                if len(ai_response) > 100 and "I'm" in ai_response:
                    print("✅ Real AI response detected!")
                else:
                    print("⚠️ Response seems short or generic")
                    
            except Exception as e:
                print(f"❌ Error generating response: {e}")
                return False
        
        print("\n🎉 Gemini AI is working perfectly!")
        return True
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

# Test the service class
async def test_service_class():
    print("\n🔧 Testing GeminiFinancialAdvisor Service...")
    print("=" * 50)
    
    try:
        from gemini_service import GeminiFinancialAdvisor, ChatContext
        
        # Initialize service
        advisor = GeminiFinancialAdvisor()
        print("✅ Service initialized")
        
        # Create test context
        context = ChatContext(
            user_id="test_user",
            monthly_income=1500.0,
            monthly_expenses=1200.0,
            savings_goal=5000.0
        )
        
        # Test message
        test_message = "I want to start investing but I'm a beginner. What should I do?"
        
        print(f"\n📤 Sending: {test_message}")
        
        # Get response
        response = await advisor.get_chat_response(
            message=test_message,
            user_id="test_user",
            context=context
        )
        
        print(f"\n📥 Response:")
        print(f"Success: {response.get('success')}")
        print(f"AI Response: {response.get('response', 'No response')}")
        print(f"Quick Replies: {response.get('quick_replies', [])}")
        print(f"Intent: {response.get('intent')}")
        
        if response.get('success') and len(response.get('response', '')) > 50:
            print("\n✅ Service is generating real AI responses!")
            return True
        else:
            print("\n❌ Service not generating proper responses")
            return False
            
    except Exception as e:
        print(f"❌ Service test failed: {e}")
        return False

async def main():
    print("🚀 FinSight Gemini AI Integration Test")
    print("Testing to ensure real AI responses are generated")
    print("=" * 60)
    
    # Test direct Gemini connection
    direct_success = await test_gemini_direct()
    
    if direct_success:
        # Test service class
        service_success = await test_service_class()
        
        if service_success:
            print("\n" + "=" * 60)
            print("🎉 SUCCESS! Gemini AI is properly integrated!")
            print("Your chatbot will now generate intelligent AI responses.")
            print("\nNext step: Start the Flask server with:")
            print("python app_gemini.py")
        else:
            print("\n❌ Service integration needs fixing")
    else:
        print("\n❌ Gemini API connection failed")
        print("Check your API key and internet connection")

if __name__ == "__main__":
    asyncio.run(main())
