"""
login.py
----------------------------------------
로그인 + 회원가입 페이지 처리:
- /                : 로그인 페이지
- /login           : 학생/사장 로그인 처리
- /register        : 회원가입 페이지 (GET)
- /register        : 회원가입 처리 (POST)
- /admin_login     : 관리자 로그인 처리
----------------------------------------
"""

from flask import Flask, render_template, request
from db import get_connection

app = Flask(__name__)


# ==========================
# 0. 기본 로그인 페이지
# ==========================
@app.route('/')
def login_tab():
    return render_template('login.html')    # ← 기본 로그인 화면


# ==========================
# 1. 학생 / 사장 로그인
# ==========================
@app.route('/login', methods=['GET'])
def login_page():
    return render_template('login.html')    # 직접 URL 입력한 경우 로그인 페이지 유지


@app.route('/login', methods=['POST'])
def login():
    login_id = request.form['login_id']
    pw = request.form['pw']

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT * FROM user WHERE login_id=%s AND pw=%s
    """, (login_id, pw))

    user = cursor.fetchone()
    conn.close()

    if not user:
        return "<h2>로그인 실패: 아이디 또는 비밀번호 오류</h2>"

    # 학생 로그인
    if user['student_id'] is not None:
        return f"<h2>학생 로그인 성공!<br>{user['name']}님 환영합니다.</h2>"

    # 사장 로그인
    if user['pro_id'] is not None:
        return f"<h2>사장 로그인 성공!<br>{user['name']}님 환영합니다.</h2>"

    return "<h2>로그인 실패: 계정 유형 오류</h2>"


# ==========================
# 2. 회원가입 페이지 (GET)
# ==========================
@app.route('/register', methods=['GET'])
def register_page():
    return render_template('register.html')   # ★ register.html 존재해야 함


# ==========================
# 3. 회원가입 처리 (POST)
# ==========================
@app.route('/register', methods=['POST'])
def register():
    login_id = request.form['login_id']
    pw = request.form['pw']
    name = request.form['name']
    student_id = request.form.get('student_id')
    pro_id = request.form.get('pro_id')

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        INSERT INTO user(login_id, pw, name, student_id, pro_id)
        VALUES (%s, %s, %s, %s, %s)
    """, (login_id, pw, name, student_id, pro_id))

    conn.commit()
    conn.close()

    return "<h2>회원가입 완료! 로그인해주세요.</h2>"


# ==========================
# 4. 관리자 로그인
# ==========================
@app.route('/admin_login', methods=['GET'])
def admin_login_page():
    return render_template('admin_login.html')


@app.route('/admin_login', methods=['POST'])
def admin_login():
    login_id = request.form['login_id']
    pw = request.form['pw']

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT * FROM site_admin WHERE login_id=%s AND pw=%s
    """, (login_id, pw))

    admin = cursor.fetchone()
    conn.close()

    if admin:
        return f"<h2>관리자 로그인 성공!<br>{admin['admin_name']}님 환영합니다.</h2>"
    else:
        return "<h2>관리자 로그인 실패: 관리자 계정이 아닙니다.</h2>"


if __name__ == '__main__':
    app.run(port=5001, debug=True)
