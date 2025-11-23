import sys, io
import pymysql
from db import get_connection  

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
else:
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8")


from db import get_connection

def get_rank(limit=20, offset=0, min_reviews=0, use_adv=True):
    score_expr = "bayes_score" if use_adv else "avg_rating"

    sql = f"""
        SELECT
            store_id,
            name,
            distance_km,
            review_cnt,
            avg_rating,
            {score_expr} AS score
        FROM v_store_ranking
        WHERE review_cnt >= %s
        ORDER BY score DESC, review_cnt DESC
        LIMIT 20 OFFSET %s
    """

    
    params = (min_reviews, offset)

    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(sql, params)
            rows = cursor.fetchall()
        return rows
    finally:
        conn.close()


# 터미널에서 단독 실행 테스트용
if __name__ == "__main__":
    rows = get_rank(limit=10, min_reviews=0, use_adv=True)
    for r in rows:
        print(f"{r['name']} | 점수 {float(r['score']):.3f} | "
              f"평점 {float(r['avg_rating']):.2f} | 리뷰 {r['review_cnt']} | 거리 {r['distance_km']}")
