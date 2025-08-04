"""
Advanced Database Models for FinSight
Comprehensive financial data modeling with relationships
"""

from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime, date
import json
import uuid
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy import event, Index
from decimal import Decimal

db = SQLAlchemy()

class BaseModel(db.Model):
    """Base model with common fields"""
    __abstract__ = True
    
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    is_active = db.Column(db.Boolean, default=True, nullable=False)

class User(BaseModel):
    """User model with enhanced security and preferences"""
    __tablename__ = 'users'
    
    # Basic info
    email = db.Column(db.String(120), unique=True, nullable=False, index=True)
    username = db.Column(db.String(80), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(255), nullable=False)
    
    # Profile info
    full_name = db.Column(db.String(100))
    date_of_birth = db.Column(db.Date)
    phone_number = db.Column(db.String(20))
    avatar_url = db.Column(db.String(255))
    
    # Preferences
    currency = db.Column(db.String(3), default='INR')
    locale = db.Column(db.String(10), default='en_IN')
    timezone = db.Column(db.String(50), default='Asia/Kolkata')
    theme = db.Column(db.String(20), default='light')
    
    # Financial profile
    monthly_income = db.Column(db.Numeric(12, 2))
    risk_tolerance = db.Column(db.String(20), default='moderate')  # conservative, moderate, aggressive
    financial_goals = db.Column(db.Text)  # JSON string
    
    # Security
    last_login = db.Column(db.DateTime)
    login_count = db.Column(db.Integer, default=0)
    is_verified = db.Column(db.Boolean, default=False)
    verification_token = db.Column(db.String(255))
    
    # ML/Analytics flags
    enable_ai_insights = db.Column(db.Boolean, default=True)
    enable_predictive_analytics = db.Column(db.Boolean, default=True)
    data_sharing_consent = db.Column(db.Boolean, default=False)
    
    # Relationships
    transactions = db.relationship('Transaction', backref='user', lazy='dynamic', cascade='all, delete-orphan')
    budgets = db.relationship('Budget', backref='user', lazy='dynamic', cascade='all, delete-orphan')
    goals = db.relationship('Goal', backref='user', lazy='dynamic', cascade='all, delete-orphan')
    insights = db.relationship('AIInsight', backref='user', lazy='dynamic', cascade='all, delete-orphan')
    
    def set_password(self, password):
        """Set password hash"""
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        """Check password"""
        return check_password_hash(self.password_hash, password)
    
    def get_financial_profile(self):
        """Get user's financial profile for ML models"""
        return {
            'monthly_income': float(self.monthly_income or 0),
            'risk_tolerance': self.risk_tolerance,
            'age': self.get_age(),
            'transaction_patterns': self.get_transaction_patterns(),
            'budget_adherence': self.get_budget_adherence()
        }
    
    def get_age(self):
        """Calculate user age"""
        if self.date_of_birth:
            return (date.today() - self.date_of_birth).days // 365
        return None
    
    def get_transaction_patterns(self):
        """Get transaction patterns for analysis"""
        # This will be implemented with ML analytics
        return {}
    
    def get_budget_adherence(self):
        """Calculate budget adherence score"""
        # This will be implemented with analytics
        return 0.8

class Category(BaseModel):
    """Expense/Income categories with hierarchical structure"""
    __tablename__ = 'categories'
    
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)
    icon = db.Column(db.String(50))
    color = db.Column(db.String(7))  # Hex color
    
    # Hierarchy
    parent_id = db.Column(db.String(36), db.ForeignKey('categories.id'))
    children = db.relationship('Category', backref=db.backref('parent', remote_side='Category.id'))
    
    # Type and ML features
    category_type = db.Column(db.String(20), nullable=False)  # income, expense, transfer
    is_essential = db.Column(db.Boolean, default=False)
    is_recurring = db.Column(db.Boolean, default=False)
    
    # ML predictions
    average_amount = db.Column(db.Numeric(12, 2))
    frequency_score = db.Column(db.Float)
    seasonality_pattern = db.Column(db.Text)  # JSON string
    
    # Relationships
    transactions = db.relationship('Transaction', backref='category', lazy='dynamic')
    budget_items = db.relationship('BudgetItem', backref='category', lazy='dynamic')

class Transaction(BaseModel):
    """Enhanced transaction model with ML features"""
    __tablename__ = 'transactions'
    
    user_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=False)
    category_id = db.Column(db.String(36), db.ForeignKey('categories.id'), nullable=False)
    
    # Basic transaction data
    amount = db.Column(db.Numeric(12, 2), nullable=False)
    description = db.Column(db.Text)
    transaction_date = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    
    # Transaction details
    transaction_type = db.Column(db.String(20), nullable=False)  # income, expense, transfer
    payment_method = db.Column(db.String(50))  # cash, card, upi, etc.
    merchant = db.Column(db.String(200))
    location = db.Column(db.String(200))
    
    # ML and analytics features
    is_recurring = db.Column(db.Boolean, default=False)
    is_predicted = db.Column(db.Boolean, default=False)
    confidence_score = db.Column(db.Float)
    anomaly_score = db.Column(db.Float)
    
    # Additional metadata
    tags = db.Column(db.Text)  # JSON array of strings
    notes = db.Column(db.Text)
    receipt_url = db.Column(db.String(255))
    
    # Indexes for performance
    __table_args__ = (
        Index('idx_user_date', 'user_id', 'transaction_date'),
        Index('idx_category_date', 'category_id', 'transaction_date'),
        Index('idx_amount_date', 'amount', 'transaction_date'),
    )
    
    def to_dict(self):
        """Convert to dictionary for API responses"""
        return {
            'id': self.id,
            'amount': float(self.amount),
            'description': self.description,
            'transaction_date': self.transaction_date.isoformat(),
            'transaction_type': self.transaction_type,
            'category': self.category.name if self.category else None,
            'payment_method': self.payment_method,
            'is_recurring': self.is_recurring,
            'tags': json.loads(self.tags) if self.tags else [],
            'notes': self.notes
        }

class Budget(BaseModel):
    """Budget model with advanced tracking"""
    __tablename__ = 'budgets'
    
    user_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=False)
    
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)
    
    # Budget period
    start_date = db.Column(db.Date, nullable=False)
    end_date = db.Column(db.Date, nullable=False)
    budget_type = db.Column(db.String(20), default='monthly')  # monthly, weekly, yearly
    
    # Budget amounts
    total_amount = db.Column(db.Numeric(12, 2), nullable=False)
    spent_amount = db.Column(db.Numeric(12, 2), default=0)
    remaining_amount = db.Column(db.Numeric(12, 2))
    
    # ML predictions
    predicted_spend = db.Column(db.Numeric(12, 2))
    predicted_overrun = db.Column(db.Float)
    risk_score = db.Column(db.Float)
    
    # Settings
    alert_threshold = db.Column(db.Float, default=0.8)  # Alert at 80%
    auto_rollover = db.Column(db.Boolean, default=False)
    
    # Relationships
    budget_items = db.relationship('BudgetItem', backref='budget', lazy='dynamic', cascade='all, delete-orphan')

class BudgetItem(BaseModel):
    """Individual budget category items"""
    __tablename__ = 'budget_items'
    
    budget_id = db.Column(db.String(36), db.ForeignKey('budgets.id'), nullable=False)
    category_id = db.Column(db.String(36), db.ForeignKey('categories.id'), nullable=False)
    
    allocated_amount = db.Column(db.Numeric(12, 2), nullable=False)
    spent_amount = db.Column(db.Numeric(12, 2), default=0)
    
    # ML predictions
    predicted_spend = db.Column(db.Numeric(12, 2))
    variance_score = db.Column(db.Float)

class Goal(BaseModel):
    """Financial goals with progress tracking"""
    __tablename__ = 'goals'
    
    user_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=False)
    
    # Goal details
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text)
    goal_type = db.Column(db.String(50), nullable=False)  # savings, debt_payoff, investment
    
    # Financial targets
    target_amount = db.Column(db.Numeric(12, 2), nullable=False)
    current_amount = db.Column(db.Numeric(12, 2), default=0)
    
    # Timeline
    target_date = db.Column(db.Date, nullable=False)
    start_date = db.Column(db.Date, default=date.today)
    
    # Progress tracking
    monthly_contribution = db.Column(db.Numeric(12, 2))
    progress_percentage = db.Column(db.Float, default=0)
    
    # ML predictions
    predicted_completion_date = db.Column(db.Date)
    success_probability = db.Column(db.Float)
    recommended_contribution = db.Column(db.Numeric(12, 2))
    
    # Settings
    auto_contribution = db.Column(db.Boolean, default=False)
    priority_level = db.Column(db.Integer, default=1)  # 1-5 scale
    
    def calculate_progress(self):
        """Calculate goal progress percentage"""
        if self.target_amount > 0:
            self.progress_percentage = min(float(self.current_amount / self.target_amount * 100), 100)
        return self.progress_percentage

class AIInsight(BaseModel):
    """AI-generated insights and recommendations"""
    __tablename__ = 'ai_insights'
    
    user_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=False)
    
    # Insight details
    title = db.Column(db.String(200), nullable=False)
    content = db.Column(db.Text, nullable=False)
    insight_type = db.Column(db.String(50), nullable=False)  # spending, saving, investment, etc.
    
    # ML metrics
    confidence_score = db.Column(db.Float, nullable=False)
    importance_score = db.Column(db.Float, default=1.0)
    
    # Context
    data_source = db.Column(db.String(100))  # transaction_analysis, budget_analysis, etc.
    recommendations = db.Column(db.Text)  # JSON array of action items
    
    # User interaction
    is_read = db.Column(db.Boolean, default=False)
    is_dismissed = db.Column(db.Boolean, default=False)
    user_feedback = db.Column(db.String(20))  # helpful, not_helpful, neutral
    
    # Expiry
    expires_at = db.Column(db.DateTime)

class PredictionModel(BaseModel):
    """ML model predictions and metadata"""
    __tablename__ = 'prediction_models'
    
    user_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=False)
    
    model_type = db.Column(db.String(50), nullable=False)  # spending, income, budget
    model_version = db.Column(db.String(20), default='1.0')
    
    # Model performance
    accuracy_score = db.Column(db.Float)
    last_trained = db.Column(db.DateTime, default=datetime.utcnow)
    training_data_size = db.Column(db.Integer)
    
    # Model parameters (JSON)
    parameters = db.Column(db.Text)
    feature_importance = db.Column(db.Text)
    
    # Predictions
    predictions = db.relationship('Prediction', backref='model', lazy='dynamic')

class Prediction(BaseModel):
    """Individual predictions from ML models"""
    __tablename__ = 'predictions'
    
    user_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=False)
    model_id = db.Column(db.String(36), db.ForeignKey('prediction_models.id'), nullable=False)
    category_id = db.Column(db.String(36), db.ForeignKey('categories.id'))
    
    # Prediction details
    prediction_type = db.Column(db.String(50), nullable=False)
    predicted_value = db.Column(db.Numeric(12, 2), nullable=False)
    confidence_interval = db.Column(db.Text)  # JSON with upper/lower bounds
    
    # Time context
    prediction_date = db.Column(db.Date, nullable=False)
    prediction_period = db.Column(db.String(20))  # weekly, monthly, quarterly
    
    # Validation
    actual_value = db.Column(db.Numeric(12, 2))
    accuracy = db.Column(db.Float)
    is_validated = db.Column(db.Boolean, default=False)

class FinancialHealthScore(BaseModel):
    """Financial health scoring system"""
    __tablename__ = 'financial_health_scores'
    
    user_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=False)
    
    # Overall score
    overall_score = db.Column(db.Float, nullable=False)  # 0-100
    score_date = db.Column(db.Date, default=date.today)
    
    # Component scores
    budget_score = db.Column(db.Float)
    savings_score = db.Column(db.Float)
    debt_score = db.Column(db.Float)
    investment_score = db.Column(db.Float)
    emergency_fund_score = db.Column(db.Float)
    
    # Factors
    income_stability = db.Column(db.Float)
    expense_volatility = db.Column(db.Float)
    debt_to_income_ratio = db.Column(db.Float)
    savings_rate = db.Column(db.Float)
    
    # Recommendations
    improvement_areas = db.Column(db.Text)  # JSON array
    next_milestones = db.Column(db.Text)  # JSON array

# Event listeners for automatic calculations
@event.listens_for(Transaction, 'after_insert')
@event.listens_for(Transaction, 'after_update')
def update_budget_spent_amount(mapper, connection, target):
    """Update budget spent amounts when transactions change"""
    # This will be implemented in the analytics module
    pass

@event.listens_for(Goal, 'after_update')
def update_goal_progress(mapper, connection, target):
    """Update goal progress calculations"""
    target.calculate_progress()
