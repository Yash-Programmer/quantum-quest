#!/usr/bin/env python3
"""
Setup script for FinSight Backend with Gemini AI
"""

import os
import subprocess
import sys
from pathlib import Path

def install_requirements():
    """Install Python requirements"""
    print("📦 Installing Python dependencies...")
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])
        print("✅ Dependencies installed successfully")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Error installing dependencies: {e}")
        return False

def setup_environment():
    """Setup environment file"""
    print("⚙️  Setting up environment configuration...")
    
    env_example_path = Path(".env.example")
    env_path = Path(".env")
    
    if not env_path.exists() and env_example_path.exists():
        # Copy example to .env
        with open(env_example_path, 'r') as f:
            content = f.read()
        
        with open(env_path, 'w') as f:
            f.write(content)
        
        print("📝 Created .env file from template")
        print("🔑 Please edit .env file and add your GEMINI_API_KEY")
        return True
    elif env_path.exists():
        print("✅ Environment file already exists")
        return True
    else:
        print("❌ No environment template found")
        return False

def get_gemini_api_key():
    """Get Gemini API key from user"""
    print("\n🤖 Gemini AI Setup")
    print("To get your Gemini API key:")
    print("1. Go to https://ai.google.dev/")
    print("2. Click 'Get API Key'")
    print("3. Create a new project or use existing")
    print("4. Generate an API key")
    print("5. Copy the key below")
    
    api_key = input("\n🔑 Enter your Gemini API key (or press Enter to skip): ").strip()
    
    if api_key:
        # Update .env file
        env_path = Path(".env")
        if env_path.exists():
            with open(env_path, 'r') as f:
                content = f.read()
            
            # Replace the placeholder
            updated_content = content.replace(
                "GEMINI_API_KEY=your_gemini_api_key_here",
                f"GEMINI_API_KEY={api_key}"
            )
            
            with open(env_path, 'w') as f:
                f.write(updated_content)
            
            print("✅ API key saved to .env file")
            return True
    else:
        print("⚠️  API key skipped. You can add it later to .env file")
        return False

def test_setup():
    """Test the setup"""
    print("\n🧪 Testing setup...")
    
    try:
        # Test imports
        import flask
        import google.generativeai as genai
        from dotenv import load_dotenv
        
        print("✅ All required packages imported successfully")
        
        # Test environment loading
        load_dotenv()
        api_key = os.getenv('GEMINI_API_KEY')
        
        if api_key and api_key != 'your_gemini_api_key_here':
            print("✅ Gemini API key found in environment")
            
            # Test Gemini connection
            try:
                genai.configure(api_key=api_key)
                model = genai.GenerativeModel('gemini-1.5-flash')
                print("✅ Gemini AI connection successful")
            except Exception as e:
                print(f"⚠️  Gemini AI connection failed: {e}")
        else:
            print("⚠️  Gemini API key not configured")
        
        return True
        
    except ImportError as e:
        print(f"❌ Import error: {e}")
        return False
    except Exception as e:
        print(f"❌ Setup test failed: {e}")
        return False

def main():
    """Main setup function"""
    print("🚀 FinSight Backend Setup with Gemini AI")
    print("=" * 50)
    
    # Change to script directory
    script_dir = Path(__file__).parent
    os.chdir(script_dir)
    
    success = True
    
    # Install requirements
    if not install_requirements():
        success = False
    
    # Setup environment
    if not setup_environment():
        success = False
    
    # Get API key
    get_gemini_api_key()
    
    # Test setup
    if not test_setup():
        success = False
    
    print("\n" + "=" * 50)
    if success:
        print("🎉 Setup completed successfully!")
        print("\nTo start the server:")
        print("  python app_gemini.py")
        print("\nAPI will be available at:")
        print("  http://localhost:5000")
    else:
        print("❌ Setup completed with errors")
        print("Please check the error messages above")

if __name__ == "__main__":
    main()
