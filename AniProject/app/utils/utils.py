from flask import g
from flask_login import UserMixin

class User(UserMixin):
    def __init__(self, user_id, username=None, email=None, role=None):
        self.id = user_id
        self.username = username
        self.email = email
        self.role = role

def get_user_by_id(user_id):
    cursor = g.db.cursor()
    try:
        cursor.execute("""
            SELECT u.id, u.username, u.email, r.name as role 
            FROM users u
            JOIN roles r ON u.role_id = r.id
            WHERE u.id = %s
        """, (user_id,))
        user = cursor.fetchone()
        if user:
            return User(
                user_id=user[0],
                username=user[1],
                email=user[2],
                role=user[3]
            )
    finally:
        cursor.close()
    return None