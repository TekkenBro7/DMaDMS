from flask import abort
from flask_login import current_user
from functools import wraps

def admin_required(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        if not current_user.is_authenticated or current_user.role != 'Admin':
            abort(403) 
        return func(*args, **kwargs)
    return wrapper
