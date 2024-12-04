from flask import Blueprint, render_template, jsonify, g
from flask_login import current_user
from .users import get_users 
import psycopg2
from .anime import get_anime
from datetime import datetime

bp = Blueprint('index', __name__)

@bp.route('/')
def index():
    anime_response = get_anime()
    anime_list = anime_response.json
    
    user_age = None
    if current_user.is_authenticated:
        cursor = g.db.cursor()
        cursor.execute(
            'SELECT birth_date FROM user_profiles WHERE user_id = %s',
            (current_user.id,)
        )
        user_profile = cursor.fetchone()    
        if user_profile and user_profile[0]:
            birth_date = user_profile[0] 
            today = datetime.now().date()
            user_age = today.year - birth_date.year
            if (today.month, today.day) < (birth_date.month, birth_date.day):
                user_age -= 1
    return render_template('index.html', anime=anime_list, user_age=user_age)