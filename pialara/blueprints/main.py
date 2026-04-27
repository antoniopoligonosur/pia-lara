from flask import (
    Blueprint, render_template, session, redirect, request
)
from flask_login import login_required

bp = Blueprint('main', __name__)
@bp.route('/')
@login_required
def index():
    return render_template('main/index.html')

@bp.route('/set_language/<lang>')
def set_language(lang):
    if lang in ['es', 'en']:
        session['lang'] = lang
    return redirect(request.referrer or '/')