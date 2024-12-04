from flask import Blueprint, jsonify, request, g, render_template, flash
import psycopg2
from flask_login import login_required, current_user
from datetime import datetime
from ..utils.decorators import admin_required

bp = Blueprint('users', __name__, url_prefix='/admin')

@bp.route('/users', methods=['GET'])
@login_required
@admin_required
def get_users():
    cursor = g.db.cursor()
    try:
        cursor.execute("""
                       SELECT 
                            users.id, 
                            roles.name, 
                            username, 
                            email, 
                            phone, 
                            TO_CHAR(users.created_at, 'YYYY-MM-DD HH24:MI') AS created_at, 
                            TO_CHAR(users.updated_at, 'YYYY-MM-DD HH24:MI') AS updated_at 
                        FROM users 
                        INNER JOIN 
                            roles ON users.role_id = roles.id
                            """)
        rows = cursor.fetchall()
        users = [
            {"id": row[0], "role": row[1], "username": row[2] ,"email": row[3], "phone": row[4], "created_at": row[5], "updated_at": row[6]}
            for row in rows
        ]
        return render_template('users.html', users=users)
    finally:
        cursor.close()


@bp.route('/users/<int:user_id>', methods=['GET'])
def get_user(user_id):
    cursor = g.db.cursor()
    try:
        cursor.execute("SELECT users.id, roles.name, username, email, phone, created_at FROM users INNER JOIN roles ON users.role_id = roles.id WHERE users.id = %s", (user_id,))
        row = cursor.fetchone()
        if row:
            user = {
                "id": row[0],
                "role": row[1],
                "username": row[2],
                "email": row[3],
                "phone": row[4],
                "created_at": row[5]
            }
            return jsonify(user)
        else:
            return jsonify({"error": "Пользователь не найден"}), 404
    finally:
        cursor.close()

@bp.route('/users/delete/<int:user_id>', methods=['POST'])
@login_required
@admin_required
def delete_user(user_id):
    try:
        query = "DELETE FROM users WHERE id = %s;"
        cursor = g.db.cursor()
        cursor.execute(query, (user_id,))
        g.db.commit()
        flash('Пользователь успешно удалён', 'success')
        cursor.close()
        return jsonify({'message': 'Пользователь успешно удалён'}), 200
    except Exception as e:
        g.db.rollback()
        flash('Ошибка при удалении пользователя: ' + str(e), 'error')
        return jsonify({'error': str(e)}), 500

@bp.route('/users/edit/<int:user_id>', methods=['PUT'])
def update_user(user_id):
    data = request.json
    cursor = g.db.cursor()
    try:
        fields_to_update = []
        values = []
        if 'username' in data:
            fields_to_update.append("username = %s")
            values.append(data['username'])
        if 'email' in data:
            fields_to_update.append("email = %s")
            values.append(data['email'])
        if 'password' in data:
            fields_to_update.append("password = %s")
            values.append(data['password'])
        if 'telephon' in data:
            fields_to_update.append("phone = %s")
            values.append(data['telephon'])
        if 'role_id' in data:
            fields_to_update.append("role_id = %s")
            values.append(data['role_id'])
        if not fields_to_update:
            return jsonify({"error": "Нет полей для изменения"}), 400        
        fields_to_update.append("updated_at = %s")
        values.append(datetime.now())

        query = f"""
        UPDATE users
        SET {', '.join(fields_to_update)}
        WHERE users.id = %s
        RETURNING users.id, (SELECT roles.name FROM roles WHERE roles.id = users.role_id) AS role_name, username, email, phone, created_at, updated_at
        """
        values.append(user_id)
        cursor.execute(query, values)
        g.db.commit()

        updated_user = cursor.fetchone()
        if updated_user:
            user_dict = {
                "id": updated_user[0],
                "role": updated_user[1],
                "username": updated_user[2],
                "email": updated_user[3],
                "phone": updated_user[4],
                "created_at": updated_user[5],
                "updated_at": updated_user[6],
            }
            flash('Пользователь успешно обновлен!', 'success')
            return jsonify({"message": "Пользователь успешно обновлен!", "Пользователь": user_dict})
        else:
            return jsonify({"error": "Пользователь не найден"}), 404
    except psycopg2.Error as e:
        flash('Ошибка при обновлении пользователя: ' + str(e), 'error')
        g.db.rollback()
        return jsonify({"error": str(e)}), 400
    finally:
        cursor.close()
