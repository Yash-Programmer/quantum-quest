#!/usr/bin/env python3
"""
Quick setup script to get Gemini AI running with your Flutter chatbot
"""

import os
import sys
import subprocess

def print_banner():
    print("🚀 FinSight Gemini AI Integration Setup")
    print("=" * 50)

def check_python():
    print("📋 Checking Python version...")
    if sys.version_info < (3, 8):
        print("❌ Python 3.8+ required. Current version:", sys.version)
        return False
    print("✅ Python version OK:", sys.version_info[:2])
    return True

def install_packages():
    print("\n📦 Installing required packages...")
    packages = [
        'flask',
        'flask-cors', 
        'google-generativeai',
        'python-dotenv',
        'asyncio'
    ]
    
    for package in packages:
        try:
            print(f"Installing {package}...")
            subprocess.check_call([sys.executable, "-m", "pip", "install", package], 
                                capture_output=True, text=True)
            print(f"✅ {package} installed")
        except subprocess.CalledProcessError as e:
            print(f"❌ Failed to install {package}: {e}")
            return False
    
    return True

def create_env_file():
    print("\n⚙️ Creating environment file...")
    env_content = """# FinSight Gemini AI Configuration
GEMINI_API_KEY=your_gemini_api_key_here
FLASK_ENV=development
SECRET_KEY=finsight-local-secret-key-2025
API_PORT=5000
"""
    
    with open('.env', 'w') as f:
        f.write(env_content)
    
    print("✅ .env file created")
    return True

def get_api_key():
    print("\n🔑 Gemini API Key Setup")
    print("To get your free Gemini API key:")
    print("1. Visit: https://ai.google.dev/")
    print("2. Click 'Get API Key'")
    print("3. Sign in with Google account")
    print("4. Create a new project or select existing")
    print("5. Generate API key")
    
    choice = input("\nDo you have a Gemini API key? (y/n): ").lower().strip()
    
    if choice == 'y':
        api_key = input("Enter your Gemini API key: ").strip()
        if api_key:
            # Update .env file
            with open('.env', 'r') as f:
                content = f.read()
            
            updated_content = content.replace(
                "GEMINI_API_KEY=your_gemini_api_key_here",
                f"GEMINI_API_KEY={api_key}"
            )
            
            with open('.env', 'w') as f:
                f.write(updated_content)
            
            print("✅ API key saved!")
            return True
    
    print("⚠️ You can add the API key later to the .env file")
    return False

def test_setup():
    print("\n🧪 Testing setup...")
    try:
        # Test Flask
        import flask
        print("✅ Flask import OK")
        
        # Test Gemini
        import google.generativeai as genai
        print("✅ Gemini AI import OK")
        
        # Test environment
        from dotenv import load_dotenv
        load_dotenv()
        api_key = os.getenv('GEMINI_API_KEY')
        
        if api_key and api_key != 'your_gemini_api_key_here':
            print("✅ API key found")
            
            # Quick connection test
            try:
                genai.configure(api_key=api_key)
                model = genai.GenerativeModel('gemini-1.5-flash')
                print("✅ Gemini connection successful!")
                return True
            except Exception as e:
                print(f"⚠️ Gemini connection failed: {e}")
                print("The API key might be invalid or there's a network issue")
        else:
            print("⚠️ No API key configured")
        
        return True
        
    except Exception as e:
        print(f"❌ Setup test failed: {e}")
        return False

def show_usage():
    print("\n🎯 Next Steps:")
    print("1. Start the backend server:")
    print("   python app_gemini.py")
    print("\n2. The API will be available at:")
    print("   http://localhost:5000")
    print("\n3. Test the chatbot endpoint:")
    print("   POST http://localhost:5000/api/chatbot/chat")
    print("   Body: {\"message\": \"Hello\", \"user_id\": \"test\"}")
    print("\n4. Update your Flutter app to use the new Gemini service")

def main():
    print_banner()
    
    # Check prerequisites
    if not check_python():
        return
    
    # Install packages
    if not install_packages():
        print("❌ Package installation failed")
        return
    
    # Create environment file
    if not create_env_file():
        print("❌ Environment setup failed")
        return
    
    # Get API key
    has_api_key = get_api_key()
    
    # Test setup
    if test_setup():
        print("\n🎉 Setup completed successfully!")
        show_usage()
    else:
        print("\n⚠️ Setup completed with warnings")
        if not has_api_key:
            print("Don't forget to add your Gemini API key to .env file")
        show_usage()

if __name__ == "__main__":
    main()
