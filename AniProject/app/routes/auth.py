from flask import Blueprint, request, redirect, render_template, url_for, flash, g, jsonify, session
from flask_login import login_user, logout_user, login_required, current_user
import app.database
import re

bp = Blueprint('auth', __name__, url_prefix='/auth')

PHONE_REGEX = re.compile(r'^((8|\+374|\+994|\+995|\+375|\+7|\+380|\+38|\+996|\+998|\+993)[\- ]?)?\(?\d{3,5}\)?[\- ]?\d{1}[\- ]?\d{1}[\- ]?\d{1}[\- ]?\d{1}[\- ]?\d{1}(([\- ]?\d{1})?[\- ]?\d{1})?$')
@bp.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form['username']
        email = request.form['email']
        telephon = request.form['telephon']
        password = request.form['password']
        password_confirm = request.form['password-confirm']
        
        if password != password_confirm:
            flash("Пароли не совпадают!", "danger")
            return render_template('register.html')
        
        if not PHONE_REGEX.match(telephon):
            flash("Неверный формат номера телефона!", "danger")
            return render_template('register.html')
        
        cursor = g.db.cursor()
        try:
            cursor.execute("""
                INSERT INTO users (role_id, username, password, email, phone)
                VALUES (
                    (SELECT id FROM roles WHERE name = 'User'),
                    %s, %s, %s, %s
                ) RETURNING id
            """, (username, password, email, telephon))
            user_id = cursor.fetchone()[0]
            g.db.commit()
            cursor.execute("""
                INSERT INTO user_profiles (user_id)
                VALUES (%s)
            """, (user_id,))
            g.db.commit()
            flash("Регистрация успешна! Пожалуйста войдите в аккаунт.", "success")
            return redirect(url_for('auth.login'))
        except Exception as e:
            g.db.rollback()
            flash(f"Ошибка: {e}", "danger")
    return render_template('register.html')

@bp.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        cursor = g.db.cursor()
        try:
            cursor.execute("""
                SELECT id, password 
                FROM users 
                WHERE username = %s
                  AND password = crypt(%s, password)
            """, (username, password))
            user = cursor.fetchone()

            if user:
                from app.utils.utils import User
                login_user(User(user[0]))
                flash("Вы вошли в аккаунт!", "success")
                return redirect(url_for('index.index'))
            else:
                flash("Неверное имя или пароль.", "danger")
        finally:
            cursor.close()
    return render_template('login.html')


@bp.route('/logout')
@login_required
def logout():
    logout_user()
    session.pop('_flashes', None)
    return redirect(url_for('index.index'))