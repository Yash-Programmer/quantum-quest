#!/usr/bin/env python3
"""
Simple test to verify Gemini AI is working
"""

import os
from dotenv import load_dotenv

# Load environment
load_dotenv()

def quick_test():
    print("🔍 Quick Gemini AI Test")
    print("=" * 30)
    
    try:
        import google.generativeai as genai
        
        api_key = os.getenv('GEMINI_API_KEY')
        print(f"API Key: {api_key[:10]}...{api_key[-4:]}")
        
        # Configure and test
        genai.configure(api_key=api_key)
        model = genai.GenerativeModel('gemini-1.5-flash')
        
        print("🤖 Testing AI response...")
        response = model.generate_content("Say 'Hello from Gemini AI!' and give one budgeting tip.")
        
        print(f"✅ AI Response: {response.text}")
        
        if "Gemini" in response.text or len(response.text) > 20:
            print("🎉 SUCCESS! Gemini AI is working!")
            return True
        else:
            print("❌ Response seems incorrect")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    quick_test()
