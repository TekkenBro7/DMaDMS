from flask import Blueprint, jsonify, request, g, render_template, flash, redirect, url_for
from flask_login import login_required, current_user
from ..utils.decorators import admin_required
from datetime import datetime

bp = Blueprint('review', __name__, url_prefix='/review')

@bp.route('/<int:anime_id>/comment', methods=['POST'])
@login_required
def add_comment(anime_id):
    content = request.form.get('content')
    rating = request.form.get('rating')
    if not content or not rating:
        return jsonify({'error': 'Пожалуйста, заполните все поля'}), 400
    cursor = g.db.cursor()
    try:
        cursor.execute("""
        INSERT INTO reviews (user_id, anime_id, rating, content) 
        VALUES (%s, %s, %s, %s)
        """, (current_user.id, anime_id, rating, content))
        g.db.commit()
        return redirect(url_for('anime.anime_detail', anime_id=anime_id))
    finally:
        cursor.close()

@bp.route('/anime/<int:anime_id>/comment/<int:comment_id>/delete', methods=['POST'])
@admin_required
@login_required
def delete_comment(anime_id, comment_id):
    cursor = g.db.cursor()
    try:
        cursor.execute("""
        DELETE FROM reviews
        WHERE id = %s AND anime_id = %s
        """, (comment_id, anime_id))
        g.db.commit()
        flash('Комментарий успешно удален.', 'success')
        return redirect(url_for('anime.anime_detail', anime_id=anime_id))
    except Exception as e:
        g.db.rollback()
        flash('Ошибка при удалении комментария.', 'error')
        return redirect(url_for('anime.anime_detail', anime_id=anime_id))
    finally:
        cursor.close()

@bp.route('/<int:anime_id>/comment/<int:review_id>/like', methods=['POST'])
@login_required
def toggle_like(anime_id, review_id):
    is_like = request.json.get('is_like')
    if is_like is None:
        return jsonify({'error': 'Некорректные данные'}), 400
    cursor = g.db.cursor()
    try:
        cursor.execute("""
        SELECT is_like FROM reviews_like 
        WHERE user_id = %s AND review_id = %s
        """, (current_user.id, review_id))
        existing_like = cursor.fetchone()
        if existing_like:
            if existing_like[0] == is_like:
                cursor.execute("""
                DELETE FROM reviews_like 
                WHERE user_id = %s AND review_id = %s
                """, (current_user.id, review_id))
            else:
                cursor.execute("""
                UPDATE reviews_like SET is_like = %s 
                WHERE user_id = %s AND review_id = %s
                """, (is_like, current_user.id, review_id))
        else:
            cursor.execute("""
            INSERT INTO reviews_like (user_id, review_id, is_like) 
            VALUES (%s, %s, %s)
            """, (current_user.id, review_id, is_like))
        g.db.commit()
        cursor.execute("""
        SELECT 
            COALESCE(SUM(CASE WHEN is_like THEN 1 ELSE 0 END), 0) AS likes,
            COALESCE(SUM(CASE WHEN NOT is_like THEN 1 ELSE 0 END), 0) AS dislikes
        FROM reviews_like WHERE review_id = %s
        """, (review_id,))
        counts = cursor.fetchone()
        return jsonify({
            'success': True,
            'likes': counts[0],
            'dislikes': counts[1],
            'is_liked': is_like
        })
    finally:
        cursor.close()