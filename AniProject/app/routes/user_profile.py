from flask import Blueprint, render_template, request, redirect, url_for, flash, current_app
from flask_login import login_required, current_user
from ..utils.user_profile import get_user_profile, update_user_profile
from werkzeug.utils import secure_filename
import os
from datetime import datetime
from ..utils.decorators import admin_required
from .bookmark import get_user_bookmarks

bp = Blueprint('profile', __name__)

UPLOAD_FOLDER = 'static/img/users'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@bp.route('/profile', methods=['GET', 'POST'])
@login_required
def profile():
    profile = get_user_profile(current_user.id)
    current_date = datetime.now().date().isoformat()
    avatar_filename = profile.avatar_url

    if request.method == 'POST':
        name = request.form.get('name')
        sirname = request.form.get('sirname')
        gender = request.form.get('gender')
        birth_date = request.form.get('birth_date')
        
        if not birth_date:
            birth_date = None
        
        avatar_file = request.files.get('avatar')
        
        if avatar_file and allowed_file(avatar_file.filename):
            if profile.avatar_url != 'default.png':
                old_avatar_path = os.path.join(current_app.root_path, UPLOAD_FOLDER, profile.avatar_url)
                if os.path.exists(old_avatar_path):
                    os.remove(old_avatar_path)
            filename = secure_filename(f"{current_user.id}_{avatar_file.filename}")
            avatar_path = os.path.join(current_app.root_path, UPLOAD_FOLDER, filename)
            avatar_file.save(avatar_path)
            avatar_filename = filename
        update_user_profile(current_user.id, name, sirname, gender, birth_date, avatar_filename)
        
        flash('Профиль успешно обновлен!', 'success')
        return redirect(url_for('profile.profile'))
    
    bookmarks = get_user_bookmarks(current_user.id)
    
    return render_template('user_profile.html', profile=profile, current_date=current_date, bookmarks=bookmarks)


