from flask import g

class UserProfile:
    def __init__(self, user_id, name=None, sirname=None, gender=None, birth_date=None, avatar_url=None):
        self.user_id = user_id
        self.name = name
        self.sirname = sirname
        self.gender = gender
        self.birth_date = birth_date
        self.avatar_url = avatar_url

def get_user_profile(user_id):
    cursor = g.db.cursor()
    try:
        cursor.execute("""
            SELECT user_id, name, sirname, gender, birth_date, avatar_url
            FROM user_profiles WHERE user_id = %s
        """, (user_id,))
        profile = cursor.fetchone()
        if profile:
            return UserProfile(
                user_id=profile[0],
                name=profile[1],
                sirname=profile[2],
                gender=profile[3],
                birth_date=profile[4],
                avatar_url=profile[5]
            )
    finally:
        cursor.close()
    return None

def update_user_profile(user_id, name, sirname, gender, birth_date, avatar_url):
    cursor = g.db.cursor()
    try:
        cursor.execute("""
            UPDATE user_profiles
            SET name = %s, sirname = %s, gender = %s, birth_date = %s, avatar_url = %s
            WHERE user_id = %s
        """, (name, sirname, gender, birth_date, avatar_url, user_id))
        g.db.commit()
    finally:
        cursor.close()
