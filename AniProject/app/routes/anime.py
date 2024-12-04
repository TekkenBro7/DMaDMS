from flask import Blueprint, jsonify, request, g, render_template, flash, redirect, url_for, current_app
from flask_login import login_required, current_user
from ..utils.decorators import admin_required
from datetime import datetime
import os
from werkzeug.utils import secure_filename


bp = Blueprint('anime', __name__, url_prefix='/anime')

UPLOAD_FOLDER = 'static/img/anime'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def get_anime():
    cursor = g.db.cursor()
    try:
        query = """
        SELECT 
            a.id, a.title, a.description, a.release_date, a.poster_url, a.age_limit,
            p.name AS publisher_name, p.photo_url AS publisher_photo,
            ARRAY_AGG(DISTINCT g.title) AS genres,
            ARRAY_AGG(DISTINCT w.watch_link || ' (' || ap.platform_name || ')') AS watch_links
        FROM anime a
        LEFT JOIN publishers p ON a.publisher_id = p.id
        LEFT JOIN anime_genres ag ON a.id = ag.anime_id
        LEFT JOIN genres g ON ag.genre_id = g.id
        LEFT JOIN watch_links w ON a.id = w.anime_id
        LEFT JOIN anime_platforms ap ON w.platform_id = ap.id
        GROUP BY a.id, p.name, p.photo_url
        ORDER BY a.release_date DESC;
        """
        cursor.execute(query)
        rows = cursor.fetchall()
        anime_list = [
            {
                "id": row[0], 
                "title": row[1],
                "description": row[2],
                "release_date": row[3].strftime('%d %B %Y') if row[3] else None,
                "poster_url": row[4],
                "age_limit": row[5],
                "publisher_name": row[6],
                "publisher_photo": row[7],
                "genres": row[8],
                "watch_links": row[9],
            }
            for row in rows
        ]
        return jsonify(anime_list)
    finally:
        cursor.close()

@bp.route('/<int:anime_id>', methods=['GET'])
@login_required
def anime_detail(anime_id):
    cursor = g.db.cursor()
    try:
        cursor.execute("""
        SELECT 
            a.id, a.title, a.description, a.release_date, a.poster_url, a.age_limit,
            p.name AS publisher_name, p.photo_url AS publisher_photo,
            ARRAY_AGG(DISTINCT g.title) AS genres,
            ARRAY_AGG(DISTINCT w.watch_link || ' (' || ap.platform_name || ')') AS watch_links,
            a.average_rating AS average_rating
        FROM anime a
        LEFT JOIN publishers p ON a.publisher_id = p.id
        LEFT JOIN anime_genres ag ON a.id = ag.anime_id
        LEFT JOIN genres g ON ag.genre_id = g.id
        LEFT JOIN watch_links w ON a.id = w.anime_id
        LEFT JOIN anime_platforms ap ON w.platform_id = ap.id
        WHERE a.id = %s
        GROUP BY a.id, p.name, p.photo_url
        """, (anime_id,))
        row = cursor.fetchone()
        
        anime = {
            "id": row[0], 
            "title": row[1],
            "description": row[2],
            "release_date": row[3],
            "poster_url": row[4] if row[4] else "default.png",
            "age_limit": row[5],
            "publisher_name": row[6],
            "publisher_photo": row[7],
            "genres": row[8],
            "watch_links": row[9],
            "average_rating": row[10],
        }
        
        user_age = None
        if current_user.is_authenticated:
            cursor = g.db.cursor()
            cursor.execute(
                'SELECT birth_date FROM user_profiles WHERE user_id = %s',
                (current_user.id,)
            )
        user_profile = cursor.fetchone()    
        if user_profile and user_profile[0]:
            birth_date = user_profile[0] 
            today = datetime.now().date()
            user_age = today.year - birth_date.year
            if (today.month, today.day) < (birth_date.month, birth_date.day):
                user_age -= 1
                
        if anime and user_age is not None and user_age < row[5]:
            return render_template('age_restricted.html')
        
        cursor.execute("""
        SELECT 
            r.id, r.content, r.rating, r.created_at, 
            u.username,
            COALESCE(SUM(CASE WHEN rl.is_like THEN 1 ELSE 0 END), 0) AS likes,
            COALESCE(SUM(CASE WHEN NOT rl.is_like THEN 1 ELSE 0 END), 0) AS dislikes
        FROM reviews r
        JOIN users u ON r.user_id = u.id
        LEFT JOIN reviews_like rl ON r.id = rl.review_id
        WHERE r.anime_id = %s
        GROUP BY r.id, u.username
        ORDER BY r.created_at DESC
        """, (anime_id,))
        
        comments = [
            {
                "id": row[0],
                "content": row[1],
                "rating": row[2],
                "created_at": row[3],
                "username": row[4],
                "likes": row[5],
                "dislikes": row[6]
            }
            for row in cursor.fetchall()
        ]   
        
        cursor.execute("SELECT id, status FROM bookmark_statuses")
        bookmark_statuses = cursor.fetchall()
        
        cursor.execute("""
            SELECT bs.id, bs.status
            FROM bookmarks b
            JOIN bookmark_statuses bs ON b.status_id = bs.id
            WHERE b.user_id = %s AND b.anime_id = %s
        """, (current_user.id, anime_id))
        current_bookmark = cursor.fetchone()

        return render_template('anime_details.html', anime=anime, comments=comments, bookmark_statuses=bookmark_statuses,
            current_bookmark=current_bookmark)
    finally:
        cursor.close()


@bp.route('/add', methods=['GET', 'POST'])
@login_required
@admin_required
def add_anime():
    cursor = g.db.cursor()
    if request.method == 'POST':
        title = request.form['title']
        description = request.form['description']
        release_date = request.form['release_date']
        age_limit = request.form['age_limit']
        publisher_id = request.form['publisher_id']
        
        filename = 'default.png'

        if 'poster' in request.files:
            poster_file = request.files['poster']
            if poster_file and allowed_file(poster_file.filename):
                filename = secure_filename(poster_file.filename)
                poster_file.save(os.path.join(current_app.root_path, UPLOAD_FOLDER, filename))
        try:
            cursor.execute("""
                INSERT INTO anime (title, description, release_date, poster_url, age_limit, publisher_id)
                VALUES (%s, %s, %s, %s, %s, %s)
                RETURNING id
            """, (title, description, release_date, filename, age_limit, publisher_id))
            anime_id = cursor.fetchone()[0]
            g.db.commit()
            
            watch_links = request.form.getlist('watch_links[]')
            platform_ids = request.form.getlist('platform_ids[]')

            for link, platform_id in zip(watch_links, platform_ids):
                if link: 
                    cursor.execute("""
                        INSERT INTO watch_links (anime_id, platform_id, watch_link)
                        VALUES (%s, %s, %s)
                    """, (anime_id, platform_id, link))
            g.db.commit()
            
            genre_ids = request.form.getlist('genres[]')
            for genre_id in genre_ids:
                cursor.execute("""
                    INSERT INTO anime_genres (anime_id, genre_id)
                    VALUES (%s, %s)
                """, (anime_id, int(genre_id)))
            g.db.commit()
            
            flash('Аниме успешно добавлено!', 'success')
            return redirect(url_for('index.index'))  
        except Exception as e:
            g.db.rollback()
            flash('Ошибка при добавлении аниме: ' + str(e), 'error')
            return redirect(url_for('anime.add_anime'))
        finally:
            cursor.close()
    cursor.execute("SELECT id, name FROM publishers")
    publishers = cursor.fetchall()
    cursor.execute("SELECT id, platform_name FROM anime_platforms")
    platforms = cursor.fetchall()
    cursor.execute("SELECT id, title FROM genres")
    genres = cursor.fetchall()
    cursor.close()
    return render_template('add_anime.html', publishers=publishers, platforms=platforms, genres=genres)


@bp.route('/delete/<int:anime_id>', methods=['POST'])
@login_required
@admin_required
def delete_anime(anime_id):
    cursor = g.db.cursor()
    try:
        cursor.execute("SELECT poster_url FROM anime WHERE id = %s", (anime_id,))
        poster_url = cursor.fetchone()[0]
        
        cursor.execute("DELETE FROM anime WHERE id = %s", (anime_id,))
        g.db.commit()
        
        if poster_url and poster_url != "default.png":
            poster_path = os.path.join(current_app.root_path, 'static', 'img', 'anime', poster_url)
            if os.path.exists(poster_path):
                os.remove(poster_path)
        
        flash('Аниме успешно удалено!', 'success')
    except Exception as e:
        g.db.rollback()
        flash('Ошибка при удалении аниме: ' + str(e), 'error')
    finally:
        cursor.close()
    return redirect(url_for('index.index'))


@bp.route('/edit/<int:anime_id>', methods=['GET', 'POST'])
@login_required
@admin_required
def edit_anime(anime_id):
    cursor = g.db.cursor()
    if request.method == 'POST':
        title = request.form['title']
        description = request.form['description']
        release_date = request.form['release_date']
        age_limit = request.form['age_limit']
        publisher_id = request.form['publisher_id']
        genres = request.form.getlist('genres[]')
        watch_links = request.form.getlist('watch_links[]')
        platform_ids = request.form.getlist('platform_ids[]')

        cursor.execute("SELECT poster_url FROM anime WHERE id = %s", (anime_id,))
        old_poster = cursor.fetchone()[0]

        poster = request.files.get('poster')
        new_poster_url = old_poster
        if poster and poster.filename:
            if old_poster != 'default.png':
                old_poster_path = os.path.join(current_app.root_path, 'static', 'img', 'anime', old_poster)
                if os.path.exists(old_poster_path):
                    os.remove(old_poster_path)
            poster_filename = secure_filename(poster.filename)
            poster_path = os.path.join(current_app.root_path, 'static', 'img', 'anime', poster_filename)
            poster.save(poster_path)
            new_poster_url = poster_filename

        try:
            cursor.execute("""
                UPDATE anime
                SET title = %s, description = %s, release_date = %s, poster_url = %s, age_limit = %s, publisher_id = %s
                WHERE id = %s
            """, (title, description, release_date, new_poster_url, age_limit, publisher_id, anime_id))

            cursor.execute("DELETE FROM anime_genres WHERE anime_id = %s", (anime_id,))
            for genre_id in genres:
                cursor.execute("INSERT INTO anime_genres (anime_id, genre_id) VALUES (%s, %s)", (anime_id, genre_id))
            cursor.execute("DELETE FROM watch_links WHERE anime_id = %s", (anime_id,))
            for link, platform_id in zip(watch_links, platform_ids):
                cursor.execute("INSERT INTO watch_links (anime_id, watch_link, platform_id) VALUES (%s, %s, %s)",
                               (anime_id, link, platform_id))

            g.db.commit()
            flash('Изменения успешно сохранены!', 'success')
        except Exception as e:
            g.db.rollback()
            flash('Ошибка при сохранении изменений: ' + str(e), 'error')
        finally:
            cursor.close()
        return redirect(url_for('index.index'))

    cursor.execute("SELECT * FROM anime WHERE id = %s", (anime_id,))
    anime = cursor.fetchone()
    anime_data = {
    'id': anime[0],
    'title': anime[1],
    'description': anime[2],
    'release_date': anime[3],
    'poster_url': anime[4] if anime[4] else "default.png",
    'age_limit': anime[5],
    'publisher_id': anime[6],
}
    cursor.execute("SELECT genre_id FROM anime_genres WHERE anime_id = %s", (anime_id,))
    genres = cursor.fetchall()
    # print("Genres:", genres)
    cursor.execute("SELECT watch_link, platform_id FROM watch_links WHERE anime_id = %s", (anime_id,))
    watch_links = cursor.fetchall()
    # print("Watch Links:", watch_links) 
    cursor.execute("SELECT id, name FROM publishers")
    publishers = cursor.fetchall()
    cursor.execute("SELECT id, title FROM genres")
    all_genres = cursor.fetchall()
    cursor.execute("SELECT id, platform_name FROM anime_platforms")
    platforms = cursor.fetchall()
    
    cursor.execute("SELECT genre_id FROM anime_genres WHERE anime_id = %s", (anime_id,))
    anime_genres = cursor.fetchall()  
    anime_genre_ids = {genre[0] for genre in anime_genres}
    # print(anime_genre_ids)
    
    cursor.close()
    return render_template('edit_anime.html', anime=anime_data, all_genres=all_genres, 
                       anime_genre_ids=anime_genre_ids, watch_links=watch_links, 
                       publishers=publishers, platforms=platforms)