from flask import Flask, request, jsonify, render_template
from datetime import timedelta
from db import get_connection
import pymysql


app = Flask(__name__)
app.json.ensure_ascii = False  # 한글 깨짐 방지

def serialize_store_row(row: dict) -> dict: # JSON 터짐 방지용 함수
    """DB에서 가져온 매장 정보를 JSON 직렬화 가능하도록 변환."""
    result = dict(row)  # 원본은 건드리지 않게 복사

    # open_time, close_time이 timedelta이면 "HH:MM" 문자열로 변환
    for key in ("open_time", "close_time"):
        value = result.get(key)
        if isinstance(value, timedelta):
            total_seconds = value.seconds
            hours = total_seconds // 3600
            minutes = (total_seconds % 3600) // 60
            result[key] = f"{hours:02d}:{minutes:02d}"

    return result
# =========================================================
# [관리자] 매장 정보 조회 (수정 페이지 진입용)
#  GET /api/stores/<store_id>
# =========================================================
@app.route("/api/stores/<int:store_id>", methods=["GET"])
def get_store(store_id):
    """
    매장 정보 수정 페이지에 들어갈 때,
    선택한 매장의 현재 정보를 조회하여 반환합니다.
    """
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            sql = """
                SELECT
                name,
                address,
                open_time,
                close_time,
                phone,
                distance_km
                FROM store
                WHERE store_id = %s
            """
            cur.execute(sql, (store_id,)) 
            row = cur.fetchone()
    finally:
        conn.close()

    if not row:
        return jsonify({"error": "해당 매장을 찾을 수 없습니다."}), 404

    return jsonify(serialize_store_row(row)), 200


# =========================================================
# [관리자] 매장 정보 수정
#  PUT /api/stores/<store_id>
# =========================================================
@app.route("/api/stores/<int:store_id>", methods=["PUT"])
def update_store(store_id):
    """
    매장 정보 수정 페이지에서 입력값을 수정 후 저장할 때 호출되는 API.
    필수: name, address
    선택: open, close, phone, distance
    """
    data = request.json or {}

    name = data.get("name")
    address = data.get("address")
    open_time = data.get("open_time")
    close_time = data.get("close_time")
    phone = data.get("phone")
    distance_km = data.get("distance_km")

    # 필수 값 체크
    if not name or not address:
        return (
            jsonify({"error": "필수 항목(name, address)이 누락되었습니다."}),
            400,
        )

    conn = get_connection()
    try:
        with conn.cursor() as cur:
            # 매장 존재 여부 확인
            cur.execute("SELECT store_id FROM store WHERE store_id = %s", (store_id,))
            if not cur.fetchone():
                return jsonify({"error": "해당 매장을 찾을 수 없습니다."}), 404

            # 업데이트할 필드 구성
            update_fields = ["name = %s", "address = %s"]
            params = [name, address]

            if open_time is not None:
                update_fields.append("open_time = %s")
                params.append(open_time)

            if close_time is not None:
                update_fields.append("close_time = %s")
                params.append(close_time)

            if phone is not None:
                update_fields.append("phone = %s")
                params.append(phone)

            if distance_km is not None:
                update_fields.append("distance_km = %s")
                params.append(distance_km)

            params.append(store_id)

            sql = f"""
                UPDATE store
                SET {", ".join(update_fields)}
                WHERE store_id = %s
            """
            cur.execute(sql, params)
            conn.commit()

            # 수정된 내용 다시 조회해서 응답
            cur.execute(
                """
                SELECT
                    name,
                    address,
                    open_time,
                    close_time,
                    phone,
                    distance_km
                FROM store
                WHERE store_id = %s
                """, (store_id,))
            updated = cur.fetchone()
            updated = serialize_store_row(updated)
    finally:
        conn.close()

    return jsonify({"message": "매장 정보가 수정되었습니다.", "store": updated}), 200


# =========================================================
# [관리자] 매장 삭제
#  DELETE /api/stores/<store_id>
# =========================================================
@app.route("/api/stores/<int:store_id>", methods=["DELETE"])
def delete_store(store_id):
    """
    매장 정보 수정 페이지에서 삭제 버튼을 눌렀을 때,
    해당 매장을 데이터베이스에서 제거합니다.
    """
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            # 매장 존재 여부 확인
            cur.execute("SELECT store_id FROM store WHERE store_id = %s", (store_id,))
            if not cur.fetchone():
                return jsonify({"error": "해당 매장을 찾을 수 없습니다."}), 404

            # 매장 삭제
            cur.execute("DELETE FROM store WHERE store_id = %s", (store_id,))
            conn.commit()
    finally:
        conn.close()

    return jsonify({"message": "매장이 삭제되었습니다."}), 200


# =========================================================
# [관리자] 매장 검색 페이지
#  GET /admin/store/search
# =========================================================
@app.route('/admin/store/search')
def store_search_page():
    """매장 검색 페이지를 보여줍니다."""
    return render_template('store_search.html')


# =========================================================
# [관리자] 매장 검색 API
#  GET /api/stores/search?q=매장명
# =========================================================
@app.route('/api/stores/search', methods=['GET'])
def search_store():
    """
    매장명으로 매장을 검색합니다.
    검색 결과가 있으면 store_id를 반환합니다.
    """
    query = request.args.get('q', '').strip()
    
    if not query:
        return jsonify({"error": "검색어를 입력해주세요."}), 400
    
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            sql = """
                SELECT store_id, name, address
                FROM store
                WHERE name LIKE %s
                LIMIT 1
            """
            cur.execute(sql, (f'%{query}%',))
            row = cur.fetchone()
    finally:
        conn.close()
    
    if not row:
        return jsonify({"error": "매장을 찾을 수 없습니다."}), 404
    
    return jsonify({
        "store_id": row['store_id'],
        "name": row['name'],
        "address": row['address']
    }), 200


@app.route('/admin/store/<int:store_id>')
def store_admin_edit_page(store_id):
    return render_template('store_admin_edit.html', store_id=store_id)


if __name__ == "__main__":
    # 관리자용 매장 관리 서버 (포트 5000)
    # *기존 inquiry.py와 동시에 실행 시 포트 충돌이 날 수 있으므로, 동시 실행 시에는
    #  한쪽 포트를 변경하거나 각각 다른 터미널에서 순차 실행하세요.
    app.run(debug=True, port=5000)

