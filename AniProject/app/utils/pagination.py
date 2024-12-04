from flask import g

def paginate_query(query, page, per_page):
    offset = (page - 1) * per_page
    paginated_query = f"{query} LIMIT {per_page} OFFSET {offset}"
    cursor = g.db.cursor()
    try:
        cursor.execute(paginated_query)
        results = cursor.fetchall()
        cursor.execute(f"SELECT COUNT(*) FROM ({query}) AS total")
        total_rows = cursor.fetchone()[0]
        total_pages = (total_rows + per_page - 1) // per_page
        return results, total_pages
    finally:
        cursor.close()