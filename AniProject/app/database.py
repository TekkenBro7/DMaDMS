from flask import g
import psycopg2


def init_db(app):
    @app.before_request
    def before_request():
        if 'db' not in g:
            g.db = psycopg2.connect(
                dbname=app.config['DB_NAME'],
                user=app.config['DB_USER'],
                password=app.config['DB_PASSWORD'],
                host=app.config['DB_HOST'],
                port=app.config['DB_PORT']
            )
           # print("Инициализировано подключение к базе данных!")

    @app.teardown_appcontext
    def close_db(exception=None):
        db = g.pop('db', None)
        if db is not None:
            db.close()
            # print("Закрыто подключение к базе данных")
