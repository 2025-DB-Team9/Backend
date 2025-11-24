#1 계정 목록

	1. 유저 계정
		id: user1 pw: 1234
		id: user2 pw: 1234
		id: user3 pw: 1234
		id: user4 pw: 1234
		id: user5 pw: 1234

	2. 공급자 계정
		id: store1 pw: 1234

	3. 관리자 계정	
		id: admin01 pw: 1234

#2 실행 순서

	1. 가상 환경을 설치 후 터미널에 venv_win\Scripts\activate.bat을 통해 가상환경 접속
	2. requirements.txt를 이용해 실행환경 다운로드
	3. Main_food.sql을 MySQL에서 실행해서 DB를 생성
	4. db.py파일의 user, password, db 등을 자신의 DB환경에 맞추어 수정
	5. python app.py로 flask서버를 실행
	6. 브라우저 창에 localhost:5000/login 접속
	7. 일반 계정, 공급자 계정 로그인시 기존 저장된 유저계정의 id, pw 입력 혹은 회원가입 후 로그인
	8. 관리자 계정 로그인 시 관리자 id, pw 입력 후 로그인
	9. 프로그램을 종료하기 전에 우측 상단의 로그아웃 버튼으로 로그아웃 후 프로그램 종료

#3 설치 명령어와 파일 구조 등 확인
	
	README.md 파일 확인