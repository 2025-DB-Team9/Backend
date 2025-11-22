import pymysql

def get_connection():
    return pymysql.connect(
        host='localhost',
        user='root',
        password='root',   # 본인의 db 비밀번호로 변경!
        db='fooddb',
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor
    )