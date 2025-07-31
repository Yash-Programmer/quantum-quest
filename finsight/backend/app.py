#!/usr/bin/env python3
"""
FinSight Backend API Server
A simplified Flask-based local API server for offline-first personal finance management
"""

from flask import Flask, jsonify, request
from flask_cors import CORS
from datetime import datetime, timedelta
import os
import json
import sqlite3
import asyncio
from pathlib import Path
from werkzeug.security import generate_password_hash, check_password_hash
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Import Gemini service
try:
    from gemini_service import initialize_gemini_service, get_gemini_service, ChatContext, ChatMessage
    GEMINI_AVAILABLE = True
except ImportError as e:
    print(f"Warning: Gemini service not available: {e}")
    GEMINI_AVAILABLE = False

# Initialize Flask app
app = Flask(__name__)
app.config['SECRET_KEY'] = 'finsight-local-secret-key-2025'

# Initialize extensions
CORS(app)

# Database setup
DB_PATH = 'finsight.db'

def init_db():
    """Initialize the SQLite database with required tables"""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # Users table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    # Transactions table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            amount REAL NOT NULL,
            category TEXT NOT NULL,
            description TEXT,
            date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            transaction_type TEXT DEFAULT 'expense',
            FOREIGN KEY (user_id) REFERENCES users (id)
        )
    ''')
    
    # Budgets table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS budgets (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            category TEXT NOT NULL,
            amount REAL NOT NULL,
            period TEXT DEFAULT 'monthly',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users (id)
        )
    ''')
    
    # Goals table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS goals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            target_amount REAL NOT NULL,
            current_amount REAL DEFAULT 0,
            target_date TEXT,
            category TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users (id)
        )
    ''')
    
    conn.commit()
    conn.close()

# API Routes

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'message': 'FinSight Backend API is running',
        'timestamp': datetime.now().isoformat()
    })

@app.route('/api/dashboard/summary/<int:user_id>', methods=['GET'])
def get_dashboard_summary(user_id):
    """Get dashboard summary data for a user"""
    try:
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        
        # Get current month's transactions
        current_month = datetime.now().strftime('%Y-%m')
        
        # Total spending this month
        cursor.execute('''
            SELECT SUM(amount) FROM transactions 
            WHERE user_id = ? AND transaction_type = 'expense' 
            AND date LIKE ?
        ''', (user_id, f'{current_month}%'))
        spending = cursor.fetchone()[0] or 0
        
        # Total income this month
        cursor.execute('''
            SELECT SUM(amount) FROM transactions 
            WHERE user_id = ? AND transaction_type = 'income' 
            AND date LIKE ?
        ''', (user_id, f'{current_month}%'))
        income = cursor.fetchone()[0] or 0
        
        # Calculate savings
        savings = income - spending
        
        # Get recent transactions
        cursor.execute('''
            SELECT id, amount, category, description, date, transaction_type
            FROM transactions 
            WHERE user_id = ? 
            ORDER BY date DESC LIMIT 10
        ''', (user_id,))
        
        transactions = []
        for row in cursor.fetchall():
            transactions.append({
                'id': row[0],
                'amount': row[1],
                'category': row[2],
                'description': row[3],
                'date': row[4],
                'type': row[5]
            })
        
        # Calculate financial health score (simplified)
        health_score = min(100, max(0, 60 + (savings / max(income, 1)) * 40))
        
        conn.close()
        
        return jsonify({
            'spending': spending,
            'income': income,
            'savings': savings,
            'health_score': round(health_score),
            'recent_transactions': transactions,
            'budget_utilization': 75  # Mock data for now
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/transactions', methods=['POST'])
def add_transaction():
    """Add a new transaction"""
    try:
        data = request.json
        required_fields = ['user_id', 'amount', 'category', 'transaction_type']
        
        if not all(field in data for field in required_fields):
            return jsonify({'error': 'Missing required fields'}), 400
        
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO transactions (user_id, amount, category, description, transaction_type)
            VALUES (?, ?, ?, ?, ?)
        ''', (
            data['user_id'],
            data['amount'],
            data['category'],
            data.get('description', ''),
            data['transaction_type']
        ))
        
        transaction_id = cursor.lastrowid
        conn.commit()
        conn.close()
        
        return jsonify({
            'message': 'Transaction added successfully',
            'transaction_id': transaction_id
        }), 201
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/financial-tips', methods=['GET'])
def get_financial_tips():
    """Get financial tips and advice"""
    tips = [
        {
            'id': 1,
            'title': 'Emergency Fund',
            'description': 'Build an emergency fund with 3-6 months of expenses',
            'category': 'savings'
        },
        {
            'id': 2,
            'title': '50/30/20 Rule',
            'description': 'Allocate 50% for needs, 30% for wants, 20% for savings',
            'category': 'budgeting'
        },
        {
            'id': 3,
            'title': 'Start Early',
            'description': 'Begin investing early to benefit from compound interest',
            'category': 'investing'
        }
    ]
    
    return jsonify({'tips': tips})

@app.route('/api/calculator/emi', methods=['POST'])
def calculate_emi():
    """Calculate EMI for loans"""
    try:
        data = request.json
        principal = float(data['principal'])
        rate = float(data['rate']) / 100 / 12  # Monthly rate
        tenure = int(data['tenure'])  # Months
        
        if rate == 0:
            emi = principal / tenure
        else:
            emi = principal * rate * ((1 + rate) ** tenure) / (((1 + rate) ** tenure) - 1)
        
        total_payment = emi * tenure
        total_interest = total_payment - principal
        
        return jsonify({
            'emi': round(emi, 2),
            'total_payment': round(total_payment, 2),
            'total_interest': round(total_interest, 2)
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/calculator/fire', methods=['POST'])
def calculate_fire():
    """Calculate FIRE (Financial Independence, Retire Early) numbers"""
    try:
        data = request.json
        annual_expenses = float(data['annual_expenses'])
        current_savings = float(data.get('current_savings', 0))
        monthly_savings = float(data.get('monthly_savings', 0))
        expected_return = float(data.get('expected_return', 7)) / 100
        
        # Rule of 25: Need 25x annual expenses
        fire_number = annual_expenses * 25
        remaining_needed = fire_number - current_savings
        
        # Calculate years to FIRE
        if monthly_savings > 0 and expected_return > 0:
            monthly_return = expected_return / 12
            if remaining_needed <= 0:
                years_to_fire = 0
            else:
                months = 0
                balance = current_savings
                while balance < fire_number and months < 600:  # Max 50 years
                    balance = balance * (1 + monthly_return) + monthly_savings
                    months += 1
                years_to_fire = months / 12
        else:
            years_to_fire = remaining_needed / (monthly_savings * 12) if monthly_savings > 0 else float('inf')
        
        return jsonify({
            'fire_number': round(fire_number, 2),
            'current_savings': current_savings,
            'remaining_needed': round(remaining_needed, 2),
            'years_to_fire': round(years_to_fire, 1),
            'monthly_savings_needed': round(remaining_needed / (years_to_fire * 12), 2) if years_to_fire > 0 and years_to_fire != float('inf') else 0
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    # Initialize database on startup
    init_db()
    
    print("🚀 Starting FinSight Backend API Server...")
    print("📊 Dashboard: http://localhost:5000/api/health")
    print("💰 Local SQLite database initialized")
    
    app.run(debug=True, host='0.0.0.0', port=5000)
    transaction_type = db.Column(db.String(20), default='expense')  # income, expense
    is_recurring = db.Column(db.Boolean, default=False)

class Budget(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    category = db.Column(db.String(50), nullable=False)
    limit_amount = db.Column(db.Float, nullable=False)
    period = db.Column(db.String(20), default='monthly')  # weekly, monthly, yearly
    start_date = db.Column(db.DateTime, default=datetime.utcnow)
    is_active = db.Column(db.Boolean, default=True)

class Goal(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    title = db.Column(db.String(100), nullable=False)
    target_amount = db.Column(db.Float, nullable=False)
    current_amount = db.Column(db.Float, default=0.0)
    target_date = db.Column(db.DateTime, nullable=False)
    category = db.Column(db.String(50))
    description = db.Column(db.Text)
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class Loan(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    lender_name = db.Column(db.String(100), nullable=False)
    principal_amount = db.Column(db.Float, nullable=False)
    outstanding_amount = db.Column(db.Float, nullable=False)
    interest_rate = db.Column(db.Float, nullable=False)
    tenure_months = db.Column(db.Integer, nullable=False)
    start_date = db.Column(db.DateTime, default=datetime.utcnow)
    status = db.Column(db.String(20), default='active')

# API Routes
@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'version': '1.0.0'
    })

@app.route('/api/dashboard/<int:user_id>', methods=['GET'])
def get_dashboard_data(user_id):
    """Get dashboard summary data"""
    try:
        # Calculate current month spending
        current_month = datetime.now().replace(day=1)
        spending = db.session.query(db.func.sum(Transaction.amount)).filter(
            Transaction.user_id == user_id,
            Transaction.transaction_type == 'expense',
            Transaction.date >= current_month
        ).scalar() or 0
        
        # Calculate current month income
        income = db.session.query(db.func.sum(Transaction.amount)).filter(
            Transaction.user_id == user_id,
            Transaction.transaction_type == 'income',
            Transaction.date >= current_month
        ).scalar() or 0
        
        # Calculate savings
        savings = income - spending
        
        # Get active goals
        goals = Goal.query.filter_by(user_id=user_id, is_active=True).all()
        
        # Calculate financial health score (simplified)
        health_score = min(100, max(0, (savings / max(income, 1)) * 100))
        
        return jsonify({
            'spending': spending,
            'income': income,
            'savings': savings,
            'health_score': round(health_score, 1),
            'active_goals': len(goals),
            'greeting': f"Good {'morning' if datetime.now().hour < 12 else 'afternoon' if datetime.now().hour < 18 else 'evening'}!"
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/transactions', methods=['GET', 'POST'])
def transactions():
    """Handle transaction operations"""
    if request.method == 'GET':
        user_id = request.args.get('user_id', 1)
        transactions = Transaction.query.filter_by(user_id=user_id).order_by(Transaction.date.desc()).limit(50).all()
        return jsonify([{
            'id': t.id,
            'amount': t.amount,
            'category': t.category,
            'description': t.description,
            'date': t.date.isoformat(),
            'type': t.transaction_type
        } for t in transactions])
    
    elif request.method == 'POST':
        data = request.json
        transaction = Transaction(
            user_id=data.get('user_id', 1),
            amount=data['amount'],
            category=data['category'],
            description=data.get('description', ''),
            transaction_type=data.get('type', 'expense')
        )
        db.session.add(transaction)
        db.session.commit()
        return jsonify({'status': 'success', 'id': transaction.id}), 201

@app.route('/api/budgets', methods=['GET', 'POST'])
def budgets():
    """Handle budget operations"""
    if request.method == 'GET':
        user_id = request.args.get('user_id', 1)
        budgets = Budget.query.filter_by(user_id=user_id, is_active=True).all()
        budget_data = []
        
        for budget in budgets:
            # Calculate spent amount for this category
            current_month = datetime.now().replace(day=1)
            spent = db.session.query(db.func.sum(Transaction.amount)).filter(
                Transaction.user_id == user_id,
                Transaction.category == budget.category,
                Transaction.transaction_type == 'expense',
                Transaction.date >= current_month
            ).scalar() or 0
            
            budget_data.append({
                'id': budget.id,
                'category': budget.category,
                'limit': budget.limit_amount,
                'spent': spent,
                'remaining': budget.limit_amount - spent,
                'percentage': round((spent / budget.limit_amount) * 100, 1) if budget.limit_amount > 0 else 0
            })
        
        return jsonify(budget_data)
    
    elif request.method == 'POST':
        data = request.json
        budget = Budget(
            user_id=data.get('user_id', 1),
            category=data['category'],
            limit_amount=data['limit'],
            period=data.get('period', 'monthly')
        )
        db.session.add(budget)
        db.session.commit()
        return jsonify({'status': 'success', 'id': budget.id}), 201

@app.route('/api/goals', methods=['GET', 'POST'])
def goals():
    """Handle goal operations"""
    if request.method == 'GET':
        user_id = request.args.get('user_id', 1)
        goals = Goal.query.filter_by(user_id=user_id, is_active=True).all()
        return jsonify([{
            'id': g.id,
            'title': g.title,
            'target_amount': g.target_amount,
            'current_amount': g.current_amount,
            'target_date': g.target_date.isoformat(),
            'progress': round((g.current_amount / g.target_amount) * 100, 1) if g.target_amount > 0 else 0,
            'days_remaining': (g.target_date - datetime.now()).days
        } for g in goals])
    
    elif request.method == 'POST':
        data = request.json
        goal = Goal(
            user_id=data.get('user_id', 1),
            title=data['title'],
            target_amount=data['target_amount'],
            target_date=datetime.fromisoformat(data['target_date']),
            category=data.get('category', ''),
            description=data.get('description', '')
        )
        db.session.add(goal)
        db.session.commit()
        return jsonify({'status': 'success', 'id': goal.id}), 201

@app.route('/api/fire/calculate', methods=['POST'])
def calculate_fire():
    """Calculate FIRE (Financial Independence, Retire Early) metrics"""
    data = request.json
    
    current_savings = data.get('current_savings', 0)
    monthly_savings = data.get('monthly_savings', 0)
    annual_return = data.get('annual_return', 7) / 100  # Convert percentage
    annual_expenses = data.get('annual_expenses', 0)
    withdrawal_rate = data.get('withdrawal_rate', 4) / 100  # Convert percentage
    
    # Calculate target corpus (25x annual expenses for 4% rule)
    target_corpus = annual_expenses / withdrawal_rate
    
    # Calculate months needed to reach FIRE
    if monthly_savings <= 0:
        return jsonify({'error': 'Monthly savings must be greater than 0'}), 400
    
    balance = current_savings
    months = 0
    monthly_return = annual_return / 12
    
    while balance < target_corpus and months < 600:  # Cap at 50 years
        balance = balance * (1 + monthly_return) + monthly_savings
        months += 1
    
    fire_date = datetime.now() + timedelta(days=months * 30)
    
    return jsonify({
        'target_corpus': round(target_corpus, 2),
        'months_needed': months,
        'years_needed': round(months / 12, 1),
        'fire_date': fire_date.strftime('%Y-%m-%d'),
        'final_balance': round(balance, 2)
    })

@app.route('/api/loan/emi', methods=['POST'])
def calculate_emi():
    """Calculate EMI for a loan"""
    data = request.json
    
    principal = data.get('principal', 0)
    annual_rate = data.get('annual_rate', 0) / 100
    tenure_months = data.get('tenure_months', 0)
    
    if principal <= 0 or annual_rate <= 0 or tenure_months <= 0:
        return jsonify({'error': 'Invalid input parameters'}), 400
    
    monthly_rate = annual_rate / 12
    
    # EMI formula: P * r * (1+r)^n / ((1+r)^n - 1)
    emi = principal * monthly_rate * (1 + monthly_rate) ** tenure_months / ((1 + monthly_rate) ** tenure_months - 1)
    
    total_amount = emi * tenure_months
    total_interest = total_amount - principal
    
    return jsonify({
        'emi': round(emi, 2),
        'total_amount': round(total_amount, 2),
        'total_interest': round(total_interest, 2)
    })

# Initialize database
@app.before_first_request
def create_tables():
    """Create database tables if they don't exist"""
    db.create_all()
    
    # Create default user if none exists
    if not User.query.first():
        default_user = User(username='demo', email='demo@finsight.app')
        default_user.set_password('demo123')
        db.session.add(default_user)
        db.session.commit()

if __name__ == '__main__':
    # Create tables
    with app.app_context():
        db.create_all()
        
        # Create default user if none exists
        if not User.query.first():
            default_user = User(username='demo', email='demo@finsight.app')
            default_user.set_password('demo123')
            db.session.add(default_user)
            db.session.commit()
            print("Created default user: demo/demo123")
    
    print("Starting FinSight Backend Server...")
    print("Access the API at: http://localhost:5000")
    app.run(debug=True, host='0.0.0.0', port=5000)
