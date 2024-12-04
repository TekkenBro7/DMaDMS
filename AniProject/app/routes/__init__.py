from flask import Blueprint
from app.routes.users import bp as users_bp
from app.routes.index import bp as index_bp
from app.routes.auth import bp as auth_bp
from app.routes.user_profile import bp as user_prof_bp
from app.routes.admin import bp as admin_bp
from app.routes.anime import bp as anime_bp
from app.routes.review import bp as review_bp
from app.routes.bookmark import bp as bookmark_bp

def register_routes(app):
    app.register_blueprint(users_bp)
    app.register_blueprint(index_bp)
    app.register_blueprint(auth_bp)
    app.register_blueprint(user_prof_bp)
    app.register_blueprint(admin_bp)
    app.register_blueprint(anime_bp)
    app.register_blueprint(review_bp)
    app.register_blueprint(bookmark_bp)