from flask import Blueprint, render_template, request, jsonify, flash, g, redirect, url_for
from flask_login import login_required, current_user
from ..utils.decorators import admin_required
from ..utils.pagination import paginate_query

bp = Blueprint('admin', __name__, url_prefix='/admin')

@bp.route('/actions', methods=['GET'])
@login_required
@admin_required
def user_actions():
    sort_by = request.args.get('sort_by', 'action_time')
    order = request.args.get('order', 'asc')  
    page = int(request.args.get('page', 1)) 
    per_page = int(request.args.get('per_page', 10))
    query = f"""
    SELECT log.id, u.username, log.action_text, TO_CHAR(log.action_time, 'YYYY-MM-DD HH24:MI') AS formatted_action_time
    FROM user_actions_log log
    JOIN users u ON log.user_id = u.id
    ORDER BY {sort_by} {order}
    """
    results, total_pages = paginate_query(query, page, per_page)
    return render_template(
        'user_actions.html',
        logs=results,
        page=page,
        total_pages=total_pages,
        sort_by=sort_by,
        order=order
    )

@bp.route('/actions/delete_logs', methods=['POST'])
@login_required
@admin_required
def delete_old_logs():
    try:
        days = int(request.form.get('days', 0))
        if days <= 0:
            return jsonify({'error': 'Некорректное количество дней'}), 400
        query = "CALL delete_old_logs(%s);"
        cursor = g.db.cursor()
        cursor.execute(query, (days,))
        g.db.commit()
        cursor.close()
        flash(f'Логи старше {days} дней успешно удалены.', 'success')
    except Exception as e:
        g.db.rollback()
        flash(f'Ошибка удаления логов: {e}', 'danger')
    return redirect(url_for('admin.user_actions'))