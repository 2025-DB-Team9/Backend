SET NAMES utf8mb4;



USE `fooddb`;

-- =========================================================
-- 최소 의존성 테이블: category, a
-- =========================================================
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
  `category_id` INT NOT NULL AUTO_INCREMENT,
  `name`        VARCHAR(30) NOT NULL,
  PRIMARY KEY (`category_id`),
  UNIQUE KEY `uq_category_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `category` (`name`)
VALUES ('한식'), ('중식'), ('양식'), ('일식'), ('분식'), ('카페'), ('디저트');

-- INSERT INTO category (category_id, name)
-- VALUES (1, '한식'),(2,'중식'),(3,'양식'),(4,'일식'),(5,'분식'),(6,'카페'),(7,'디저트');



-- =========================================================
-- 핵심 1) store
-- =========================================================
DROP TABLE IF EXISTS `store`;
CREATE TABLE `store` (
  `store_id`     INT NOT NULL AUTO_INCREMENT COMMENT '매장의 id',
  `name`         VARCHAR(60) NOT NULL,
  `address`      VARCHAR(150),
  `open_time`    TIME,
  `close_time`   TIME,
  `phone`        VARCHAR(30),
  `distance_km`  DECIMAL(6,2),
  `category_id`  INT,
  PRIMARY KEY (`store_id`),
  KEY `idx_store_category` (`category_id`),
  CONSTRAINT `fk_store_category`
    FOREIGN KEY (`category_id`) REFERENCES `category`(`category_id`)
    ON UPDATE RESTRICT ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 샘플 매장(선택)
INSERT INTO store (name, address, open_time, close_time, phone, distance_km, category_id)
VALUES ('금성이네', '경기 시흥시 정왕동 ', '16:00','01:00','010-9092-4992', 0.5, 1),
		( '쭈꾸미삼겹살', '경기 시흥시 정왕동 ', '11:00','01:00','050-4110-8859', 0.6, 1   ),
        ( '24시 수육국밥', '경기 시흥시 정왕동 ', '00:00','24:00','031-319-8676', 0.9, 1   ),
         ( '고향 칼국수', '경기 시흥시 정왕동 ', '11:00','20:00','031-499-7374', 1.0, 1   ),
           ( '국민 낙곱새', '경기 시흥시 정왕동 ', '14:00','03:00','031-433-9284', 1.0, 1   ),
           ( '더베이징', '경기 시흥시 정왕동 ', '11:00','21:30','031-319-4289', 0.2, 2   ),
            ( '라홍방 마라탕', '경기 시흥시 정왕동 ', '10:00','22:20','031-498-4776', 0.5, 2   ),
            ( '회전훠쿼핫', '경기 시흥시 정왕동 ', '11:00','22:20','0507-1349-3305', 0.7, 2   ),
             ( '짬뽕관', '경기 시흥시 정왕동 ', '10:30','21:30','010-9282-1633', 0.8, 2   ),
             ( '니뽕내뽕', '경기 시흥시 정왕동 ', '11:00','19:50','031-431-3564', 1.0, 2   )
             
           ;

-- =========================================================
-- 핵심 2) menu
-- =========================================================
DROP TABLE IF EXISTS `menu`;
CREATE TABLE `menu` (
  `menu_id`   INT NOT NULL AUTO_INCREMENT,
  `store_id`  INT NOT NULL COMMENT '매장의 id',
  `name`      VARCHAR(60) NOT NULL,
  `price`     INT NOT NULL,
  `recommend` VARCHAR(60),
  PRIMARY KEY (`menu_id`),
  UNIQUE KEY `uq_menu_store_name` (`store_id`, `name`),
  KEY `idx_menu_store` (`store_id`),
  CONSTRAINT `fk_menu_store`
    FOREIGN KEY (`store_id`) REFERENCES `store`(`store_id`)
    ON UPDATE RESTRICT ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 샘플 메뉴(선택)
INSERT INTO menu (store_id, name, price) VALUES
-- 1. 금성이네 (한식)
(1, '김치찌개', 8000),
(1, '된장찌개', 8000),
(1, '삼겹살 1인분', 14000),

-- 2. 쭈꾸미삼겹살 (한식)
(2, '쭈꾸미볶음', 11000),
(2, '삼겹살추가', 7000),
(2, '볶음밥', 3000),

-- 3. 24시 수육국밥 (한식)
(3, '수육국밥', 9000),
(3, '모듬수육', 18000),
(3, '콩나물국밥', 8000),

-- 4. 고향 칼국수 (한식)
(4, '바지락칼국수', 9000),
(4, '들깨칼국수', 9500),
(4, '파전', 12000),

-- 5. 국민 낙곱새 (한식)
(5, '낙곱새', 12000),
(5, '곱창전골', 13000),
(5, '볶음밥', 3000),

-- 6. 더베이징 (중식)
(6, '짜장면', 7000),
(6, '짬뽕', 8000),
(6, '탕수육', 16000),

-- 7. 라홍방 마라탕 (중식)
(7, '마라탕', 12000),
(7, '마라샹궈', 16000),
(7, '꿔바로우', 15000),

-- 8. 회전훠궈핫 (중식)
(8, '훠궈 1인세트', 17000),
(8, '마라훠궈', 18000),
(8, '양꼬치', 13000),

-- 9. 짬뽕관 (중식)
(9, '불짬뽕', 9000),
(9, '차돌짬뽕', 10000),
(9, '군만두', 5000),

-- 10. 니뽕내뽕 (중식 퓨전)
(10, '니뽕짬뽕', 9800),
(10, '크림뽕', 10500),
(10, '로제뽕', 10800);

-- =========================================================
-- 핵심 3) review
-- =========================================================
DROP TABLE IF EXISTS `review`;
CREATE TABLE `review` (
  `review_id`    INT NOT NULL AUTO_INCREMENT,
  `user_id`      INT NOT NULL COMMENT '사용자의 id',
  `store_id`     INT NOT NULL COMMENT '매장의 id',
  `content`      TEXT,
  `rating`       TINYINT,                     
  `helpful_cnt`  INT NOT NULL DEFAULT 0,
  `created_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`review_id`),
  KEY `idx_review_user` (`user_id`),
  KEY `idx_review_store_created` (`store_id`, `created_at`),
  CONSTRAINT `fk_review_user`
    FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`)  
    ON UPDATE RESTRICT ON DELETE CASCADE,
  CONSTRAINT `fk_review_store`
    FOREIGN KEY (`store_id`) REFERENCES `store`(`store_id`)
    ON UPDATE RESTRICT ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--  리뷰
 USE fooddb;

INSERT INTO review (user_id, store_id, content, rating, created_at) VALUES
-- 1. 금성이네
(1, 1, '김치찌개 진짜 맛있어요. 밥 추가 필수.', 5, NOW()),
(1, 1, '반찬이 깔끔하고 양도 넉넉해요.', 4, NOW()),
(1, 1, '맛은 좋은데 피크 시간엔 조금 시끄러워요.', 4, NOW()),

-- 2. 쭈꾸미삼겹살
(1, 2, '쭈꾸미가 매콤한데 자극적이지 않아서 좋았어요.', 4, NOW()),
(1, 2, '삼겹살이랑 같이 먹으니까 진짜 맛있음.', 5, NOW()),
(1, 2, '양은 살짝 아쉽지만 맛은 인정.', 4, NOW()),

-- 3. 24시 수육국밥
(1, 3, '국물 진하고 속 든든해서 야식으로 최고.', 4, NOW()),
(1, 3, '24시간이라 새벽에 가기 좋았어요.', 5, NOW()),
(1, 3, '고기는 조금 적지만 국물 맛 하나로 커버.', 4, NOW()),

-- 4. 고향 칼국수
(1, 4, '바지락 많이 들어있고 국물 시원해요.', 5, NOW()),
(1, 4, '들깨칼국수 고소해서 겨울에 생각날 맛.', 4, NOW()),
(1, 4, '점심시간에는 줄 서야 해서 조금 힘들었음.', 4, NOW()),

-- 5. 국민 낙곱새
(1, 5, '밥도둑 인정… 볶음밥 꼭 추가해야 함.', 5, NOW()),
(1, 5, '매운 정도가 딱 적당해서 좋았어요.', 4, NOW()),
(1, 5, '기대보다 괜찮았고 재방문 의사 있음.', 4, NOW()),

-- 6. 더베이징
(1, 6, '짜장면이 너무 달지 않고 딱 좋아요.', 4, NOW()),
(1, 6, '짬뽕 국물 깔끔하고 해산물도 많았어요.', 5, NOW()),
(1, 6, '탕수육 소스가 과하지 않아서 좋았음.', 4, NOW()),

-- 7. 라홍방 마라탕
(1, 7, '처음 먹어본 마라탕인데 생각보다 안 맵고 맛있었어요.', 4, NOW()),
(1, 7, '마라샹궈에 재료 고르는 재미가 있음.', 5, NOW()),
(1, 7, '꿔바로우 튀김이 바삭해서 만족.', 4, NOW()),

-- 8. 회전훠궈핫
(1, 8, '훠궈 국물 베이스가 두 가지라 골라 먹기 좋음.', 5, NOW()),
(1, 8, '고기 리필 잘 해줘서 배 터지게 먹었어요.', 4, NOW()),
(1, 8, '조금 시끄럽지만 친구들이랑 가기 좋음.', 4, NOW()),

-- 9. 짬뽕관
(1, 9, '불짬뽕 진짜 칼칼하고 해장에 최고.', 5, NOW()),
(1, 9, '차돌짬뽕 고기가 많이 들어있어서 만족.', 4, NOW()),
(1, 9, '군만두는 평범했지만 짬뽕은 강추.', 4, NOW()),

-- 10. 니뽕내뽕
(1, 10, '니뽕짬뽕은 기본인데 국물이 깊어요.', 5, NOW()),
(1, 10, '크림뽕 처음 먹어봤는데 의외로 잘 어울림.', 4, NOW()),
(1, 10, '로제뽕은 조금 느끼했지만 또 생각나는 맛.', 4, NOW());


-- =========================================================
-- 랭킹용 뷰(간단 평균 + 리뷰수 가중 정렬) & 고급(베이지안) 점수
-- =========================================================
-- 1) 단순 평균/리뷰수 집계 뷰
DROP VIEW IF EXISTS v_store_scores_simple;
CREATE VIEW v_store_scores_simple AS
SELECT
  s.store_id,
  s.name,
  s.address,
  s.distance_km,
  COALESCE(AVG(r.rating), 0)          AS avg_rating,
  COUNT(r.review_id)                   AS review_cnt
FROM store s
LEFT JOIN review r ON r.store_id = s.store_id
GROUP BY s.store_id, s.name, s.address, s.distance_km;


-- 2) 베이지안 평균(전체 평균으로 스무딩: m=리뷰수 임계값) 계산용 뷰

DROP VIEW IF EXISTS v_store_scores_bayesian;
CREATE VIEW v_store_scores_bayesian AS
WITH global_stats AS (
  SELECT
    COALESCE(AVG(rating), 0) AS C
  FROM review
),
store_stats AS (
  SELECT
    s.store_id,
    s.name,
    s.address,
    s.distance_km,
    COALESCE(AVG(r.rating), 0) AS R,
    COUNT(r.review_id)         AS v
  FROM store s
  LEFT JOIN review r ON r.store_id = s.store_id
  GROUP BY s.store_id, s.name, s.address, s.distance_km

)
SELECT
  st.store_id,
  st.name,
  st.address,
  st.distance_km,
  st.R         AS avg_rating,
  st.v         AS review_cnt,
 
  CAST(5 AS DECIMAL(10,2))    AS m,
  gs.C,
  ((st.v/(st.v + 5.0))*st.R + (5.0/(st.v + 5.0))*gs.C) AS bayes_score
FROM store_stats st
CROSS JOIN global_stats gs;


DROP VIEW IF EXISTS v_store_ranking;
CREATE VIEW v_store_ranking AS
SELECT
  b.store_id,
  b.name,
  b.address,
  b.distance_km,
  b.avg_rating,
  b.review_cnt,
  b.bayes_score
FROM v_store_scores_bayesian b;
-- ORDER BY b.bayes_score DESC, b.review_cnt DESC, b.avg_rating DESC, b.store_id ASC;



SELECT * FROM v_store_ranking
ORDER BY bayes_score DESC
LIMIT 5;

