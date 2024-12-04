from flask import Flask, render_template
from app.database import init_db
from app.routes import register_routes
from flask_login import LoginManager
from flask_login import current_user

def create_app():
    app = Flask(__name__)
    app.config.from_object('app.config.Config')
    
    @app.errorhandler(403)
    def forbidden_error(error):
        return render_template('403.html'), 403
    
    @app.errorhandler(404)
    def page_not_found(error):
        return render_template('404.html'), 404
    
    login_manager = LoginManager()
    login_manager.login_view = 'auth.login'
    login_manager.init_app(app)
    
    @login_manager.user_loader
    def load_user(user_id):
        from app.utils.utils import get_user_by_id
        return get_user_by_id(int(user_id))

    @app.context_processor
    def inject_user():
        return dict(user=current_user)
    
    init_db(app)
    register_routes(app)

    return app