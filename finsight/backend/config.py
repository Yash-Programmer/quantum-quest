"""
Configuration settings for FinSight Backend
"""
import os
from datetime import timedelta

class Config:
    """Base configuration class"""
    
    # App settings
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'finsight-advanced-secret-key-2025'
    
    # Database settings
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or 'sqlite:///finsight_advanced.db'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_ENGINE_OPTIONS = {
        'pool_pre_ping': True,
        'pool_recycle': 3600,
        'connect_args': {'check_same_thread': False}
    }
    
    # JWT settings
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY') or 'jwt-secret-finsight-2025'
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(days=30)
    JWT_REFRESH_TOKEN_EXPIRES = timedelta(days=90)
    
    # AI/ML settings
    GEMINI_API_KEY = os.environ.get('GEMINI_API_KEY')
    ML_MODEL_PATH = 'models/'
    ENABLE_AI_FEATURES = True
    
    # Data science settings
    PREDICTION_WINDOW_DAYS = 90
    MIN_DATA_POINTS = 30
    CONFIDENCE_THRESHOLD = 0.7
    
    # Security settings
    BCRYPT_LOG_ROUNDS = 12
    PASSWORD_MIN_LENGTH = 8
    
    # Analytics settings
    ENABLE_ANALYTICS = True
    ANALYTICS_RETENTION_DAYS = 365
    
    # File upload settings
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 16MB
    UPLOAD_FOLDER = 'uploads'
    
    # Logging
    LOG_LEVEL = 'INFO'
    LOG_FILE = 'logs/finsight.log'
    
    @staticmethod
    def init_app(app):
        """Initialize app-specific configuration"""
        # Create necessary directories
        os.makedirs('models', exist_ok=True)
        os.makedirs('logs', exist_ok=True)
        os.makedirs('uploads', exist_ok=True)

class DevelopmentConfig(Config):
    """Development configuration"""
    DEBUG = True
    LOG_LEVEL = 'DEBUG'

class ProductionConfig(Config):
    """Production configuration"""
    DEBUG = False
    LOG_LEVEL = 'WARNING'

class TestingConfig(Config):
    """Testing configuration"""
    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'
    WTF_CSRF_ENABLED = False

config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig,
    'default': DevelopmentConfig
}
