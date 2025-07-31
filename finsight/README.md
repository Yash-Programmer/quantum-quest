# FinSight - Personal Finance Management App

FinSight is a comprehensive personal finance management application designed specifically for students and young adults. It combines smart budgeting, AI-powered insights, and predictive finance tools in an offline-first architecture.

## 🌟 Features

### Core Features
- **📊 Dashboard**: Financial health score, quick summary tiles, and activity timeline
- **💰 Smart Budgeting**: Category-wise budget tracking with real-time alerts
- **🔮 Predictive Finance**: AI-powered spending forecasts and financial predictions
- **🤖 AI Assistant**: Gemini-powered chatbot for personalized financial advice
- **📚 Knowledge Hub**: Educational content, tips, and financial literacy resources

### Advanced Tools (10 Pro Features)
1. **🎯 Goals Planner**: SMART goal setting and progress tracking
2. **💸 Loan Planner**: EMI calculator and repayment strategies
3. **🔥 FIRE Calculator**: Financial Independence and Early Retirement planning
4. **🌡️ Investment Heatmap**: Risk vs. return visualization
5. **💪 Savings Challenge**: Gamified savings with streaks and rewards
6. **💼 Passive Income Tracker**: Multiple income stream management
7. **🔍 Credit Score Tracker**: Manual credit health monitoring
8. **🧾 Tax Planner**: Tax optimization and deduction planning
9. **⚙️ App Settings**: Theme, currency, and personalization options
10. **📄 PDF Export**: Monthly financial reports generation

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8 or higher
- Python 3.8 or higher
- VS Code with Flutter/Dart extensions

### Installation

1. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

2. **Set up Python backend**
   ```bash
   cd backend
   pip install -r requirements.txt
   ```

3. **Run the backend server**
   ```bash
   python app.py
   ```

4. **Run the Flutter app**
   ```bash
   flutter run
   ```

## 🏗️ Architecture

### Frontend (Flutter)
- **Framework**: Flutter 3.8+
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Charts**: fl_chart
- **Local Storage**: SQLite + SharedPreferences

### Backend (Flask + Python)
- **API Server**: Flask (local-only for offline-first operation)
- **Database**: SQLite with SQLAlchemy ORM
- **Authentication**: Local authentication with bcrypt
- **AI Integration**: Gemini API (optional, with offline fallbacks)

### Key Technologies
- `riverpod`: State management
- `fl_chart`: Charts and visualizations
- `sqflite`: Local database
- `go_router`: Navigation
- `shared_preferences`: Local storage
- `flask`: Python web framework
- `sqlalchemy`: Database ORM

## 📱 Current Status

The app is currently in development with the following implemented:

✅ **Completed:**
- Project structure and architecture
- Core theming system (light/dark mode)
- Navigation system with bottom tabs and drawer
- Dashboard with financial health score
- Quick summary tiles with spending/income tracking
- Recent activity timeline
- Quick actions (Add Transaction, Calculator, etc.)
- Placeholder pages for all 15+ features
- Flask backend with basic API endpoints
- SQLite database schema
- Responsive UI design

🔄 **In Progress:**
- Smart budgeting implementation
- AI assistant integration
- Predictive finance models
- Goal planning system

📅 **Planned:**
- PDF report generation
- Investment tracking
- Tax planning tools
- Savings challenges

## 🎯 Core Functionality

### Dashboard Features
- **Greeting Section**: Dynamic time-based greetings
- **Financial Health Score**: 0-100 rating with visual gauge
- **Summary Tiles**: Monthly spending, savings, income, budget utilization
- **Activity Timeline**: Recent transactions and AI insights
- **Quick Actions**: Add transactions, access calculator, view reports
- **AI Tips**: Smart financial recommendations

### Navigation Structure
- **Bottom Tabs**: Dashboard, Budget, Predictive, AI Chat, Knowledge
- **Drawer Menu**: 10 advanced features accessible via hamburger menu
- **Deep Linking**: Direct navigation to specific features

## 🔐 Security & Privacy

- **Offline-First**: All core functionality works without internet
- **Local Storage**: SQLite database with optional encryption
- **No Tracking**: Zero third-party analytics by default
- **Data Ownership**: Users control all their financial data

---

**FinSight** - Empowering Students with Smart Financial Management 💰📱✨
