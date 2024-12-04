import os
from dotenv import load_dotenv

class Config:
    DB_NAME = os.getenv("DB_NAME", "DB")
    DB_USER = os.getenv("DB_USER", "user")
    DB_PASSWORD = os.getenv("DB_PASSWORD", "password")
    DB_HOST = os.getenv("DB_HOST", "localhost")
    DB_PORT = os.getenv("DB_PORT", "5432")
    SECRET_KEY = os.getenv("SECRET_KEY", "default_secret_key")