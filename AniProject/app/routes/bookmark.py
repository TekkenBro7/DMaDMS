from flask import Blueprint, jsonify, request, g, render_template, flash, redirect, url_for
from flask_login import login_required, current_user
from ..utils.decorators import admin_required
from datetime import datetime

bp = Blueprint('bookmark', __name__, url_prefix='/bookmark')

@bp.route('/<int:anime_id>', methods=['POST'])
@login_required
def update_bookmark(anime_id):
    data = request.get_json()
    status_id = data.get('status_id')
    if not status_id:
        return jsonify({"success": False, "message": "Статус не указан."}), 400
    cursor = g.db.cursor()
    try:
        cursor.execute("""
            DELETE FROM bookmarks
            WHERE user_id = %s AND anime_id = %s
        """, (current_user.id, anime_id))
        cursor.execute("""
            INSERT INTO bookmarks (user_id, anime_id, status_id)
            VALUES (%s, %s, %s)
        """, (current_user.id, anime_id, status_id))
        g.db.commit()
        return jsonify({"success": True})
    finally:
        cursor.close()


def get_user_bookmarks(user_id):
    cursor = g.db.cursor()
    try:
        query = """
        SELECT 
            b.id AS bookmark_id,
            a.title AS anime_title,
            bs.status AS bookmark_status,
            a.id AS anime_id,
            a.poster_url
        FROM bookmarks b
        JOIN anime a ON b.anime_id = a.id
        JOIN bookmark_statuses bs ON b.status_id = bs.id
        WHERE b.user_id = %s
        ORDER BY b.created_at DESC;
        """
        cursor.execute(query, (user_id,))
        bookmarks = cursor.fetchall()
        
        bookmarks_list = []
        for row in bookmarks:
            bookmarks_list.append({
                'bookmark_id': row[0],
                'anime_title': row[1],
                'bookmark_status': row[2],
                'anime_id': row[3],
                'poster_url': row[4]
            })
    finally:
        cursor.close()
    return bookmarks_list