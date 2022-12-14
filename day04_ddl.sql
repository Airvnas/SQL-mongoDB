--day04_ddl.sql
대괄호는 생략가능
create table [스키마.]테이블명 (
    컬럼명 자료형 default 기본값 constraint 제약조건이름 제약조건유형
    ...
);

#PRIMARY KEY
--컬럼수준에서 제약하기
CREATE TABLE TEST_TAB1(
    NO NUMBER(2) CONSTRAINT TEST_TAB1_NO_PK PRIMARY KEY,
    NAME VARCHAR2(20) 
);

DESC TEST_TAB1;

데이터사전에서 조회
SELECT *
FROM USER_CONSTRAINTS WHERE TABLE_NAME='TEST_TAB1';

INSERT INTO TEST_TAB1(NO,NAME)
VALUES(2,NULL);
SELECT * FROM TEST_TAB1;
COMMIT;

--테이블 수준에서 PK제약
CREATE TABLE TEST_TAB2(
    NO NUMBER(2),
    NAME VARCHAR(20),
    CONSTRAINT TEST_TAB2_NO_PK PRIMARY KEY(NO)
);

SELECT * FROM USER_CONSTRAINTS WHERE TABLE_NAME='TEST_TAB2';

#제약조건 삭제

ALTER TABLE 테이블명 DROP CONSTRAINT 제약조건명[CASCADE];

ALTER TABLE TEST_TAB2 DROP CONSTRAINT TEST_TAB2_NO_PK;

#제약조건 추가
--ALTER TABLE 테이블명 ADD CONSTRAINT 제약조건명 제약조건유형(컬럼명)

ALTER TABLE TEST_TAB2 ADD CONSTRAINT TEST_TAB2_NO_PK PRIMARY KEY (NO);

SELECT * FROM USER_CONSTRAINTS WHERE TABLE_NAME='TEST_TAB2';

#제약조건명 변경
--ALTER TABLE 테이블명 RENAME CONSTRAINT OLD명 TO NEW명

ALTER TABLE TEST_TAB2 RENAME CONSTRAINT TEST_TAB2_PK TO TEST_TAB2_NO_PK;

#Foreign Key 제약조건
부모테이블(MASTER)의 pk를 자식테이블(DETAIL)의 FK로 참조
==> FK는 자식테이블에서 정의해야함
MASTER 테이블의 PK,UK로 정의된 컬럼을 FK로 지정할 수 있다.
컬럼의 자료형이 일치해야한다. 크기는 일치하지 않아도 상관없음
ON DELETE CASCADE 옵션을 주면 MASTER 테이블의 레코드가 삭제될때
DETAIL 테이블의 레코드도 같이 삭제된다.

CREATE TABLE DEPT_TAB(
    DEPTNO NUMBER(2),
    DNAME VARCHAR2(15),
    LOC VARCHAR2(15),
    CONSTRAINT DEPT_TAB_DEPTNO_PK PRIMARY KEY(DEPTNO)
);

CREATE TABLE EMP_TAB(
    EMPNO NUMBER(4),
    ENAME VARCHAR2(20),
    JOB VARCHAR2(10),
    MGR NUMBER(4) CONSTRAINT EMP_TAB_MGR_FK REFERENCES EMP_TAB(EMPNO),
    HIREDATE DATE,
    SAL NUMBER(7,2),
    COMM NUMBER(7,2),
    DEPTNO NUMBER(2),
    --테이블 수준에서 FK주기
    CONSTRAINT EMP_TAB_DEPTNO_FK FOREIGN KEY(DEPTNO)
    REFERENCES DEPT_TAB (DEPTNO),
    CONSTRAINT EMP_TAB_EMPNO_PK PRIMARY KEY (EMPNO)
);

부서정보 INSERT 하기
10 기획부 서울
20 인사부 인천

INSERT INTO DEPT_TAB(DEPTNO,DNAME,LOC)
VALUES(10,'기획부','서울');

INSERT INTO DEPT_TAB(DEPTNO,DNAME,LOC)
VALUES(20,'인사부','인천');

DELETE FROM DEPT_TAB WHERE DEPTNO=2;

COMMIT;
SELECT * FROM DEPT_TAB;

INSERT INTO EMP_TAB(EMPNO,ENAME,JOB,MGR,DEPTNO)
VALUES(1000,'홍길동','기획',NULL,10);

INSERT INTO EMP_TAB(EMPNO,ENAME,JOB,MGR,DEPTNO)
VALUES(1001,'이철수','인사',NULL,20);

INSERT INTO EMP_TAB(EMPNO,ENAME,JOB,MGR,DEPTNO)
VALUES(1002,'이영희','인사',NULL,20);
SELECT * FROM EMP_TAB;
COMMIT;

INSERT INTO EMP_TAB(EMPNO,ENAME,JOB,MGR,DEPTNO)
VALUES(1003,'김순희','노무',1002,20);

INSERT INTO EMP_TAB(EMPNO,ENAME,JOB,MGR,DEPTNO)
VALUES(1004,'김길동','재무',1001,20);

DELETE FROM DEPT_TAB WHERE DEPTNO=10;
==>자식 레코드가 있을 경우는 부모테이블의 레코드를 삭제할 수 없다.
홍길동을 부서이동후 삭제
UPDATE EMP_TAB SET DEPTNO=20 WHERE ENAME='홍길동';
SELECT * FROM EMP_TAB;
DELETE FROM DEPT_TAB WHERE DEPTNO=10;
SELECT * FROM DEPT_TAB;

부모테이블 BOARD_TAB

CREATE TABLE BOARD_TAB(
    NO NUMBER(8) PRIMARY KEY,
    USERID VARCHAR2(20) NOT NULL,
    TITLE VARCHAR2(100),
    CONTENT VARCHAR2(1000),
    WDATE DATE DEFAULT SYSDATE
);

CREATE TABLE REPLY_TAB(
    RNO NUMBER(8) PRIMARY KEY,
    USERID VARCHAR2(20) NOT NULL,
    CONTENT VARCHAR2(300),
    NO_FK NUMBER(8) REFERENCES BOARD_TAB (NO) ON DELETE CASCADE
);
SELECT * FROM USER_CONSTRAINTS WHERE TABLE_NAME='BOARD_TAB';
SELECT * FROM USER_CONSTRAINTS WHERE TABLE_NAME='REPLY_TAB';

INSERT INTO BOARD_TAB VALUES (1,'HONG','반가워요','안녕',SYSDATE);
INSERT INTO BOARD_TAB VALUES (2,'CHOI','저도 반가워요','안녕2',SYSDATE);

SELECT * FROM BOARD_TAB;

댓글달기
INSERT INTO REPLY_TAB VALUES(3,'안녕?','KIM',1);

COMMIT;
SELECT * FROM BOARD_TAB;

SELECT B.NO,B.TITLE, B.USERID,B.WDATE,r.content,r.userid
FROM BOARD_TAB B JOIN REPLY_TAB R
ON B.NO=R.NO_FK;

DELETE FORM BOARD_TAB WHERE NO=2;

#Unique Key
컬럼수준 제약
CREATE TABLE UNI_TAB1(
    DEPTNO NUMBER(2) CONSTRAINT UNI_TAB1_DEPTNO_UK UNIQUE,
    DNAME CHAR(20),
    LOC CHAR(10)
);
SELECT * FROM USER_CONSTRAINTS WHERE TABLE_NAME='UNI_TAB1';
INSERT INTO UNI_TAB1 VALUES(NULL,'영업부4','서울');
SELECT * FROM UNI_TAB1;
COMMIT;

테이블 수준에서 제약
CREATE TABLE UNI_TAB2(
    DEPTNO NUMBER(2),
    DNAME CHAR(20),
    LOC CHAR(10),
    CONSTRAINTS UNI_TAB2_DEPTNO_UK UNIQUE(DEPTNO)
);

#NOT NULL 제약조건 - 체크 제약조건의 일종
-NOT NULL 제약조건은 컬럼수준에서만 제약할 수 있다.
CREATE TABLE NN_TAB(
    DEPTNO NUMBER(2) CONSTRAINT NN_TAB_DEPTNO_NN NOT NULL,
    DNAME CHAR(20) NOT NULL,
    LOC CHAR(10)
    --CONSTRAINT LOC_NN NOT NULL(LOC)[X]
);

#CHECK 제약조건
-행이 만족해야하는 조건을 정의한다.

CREATE TABLE CK_TAB(
    DEPTNO NUMBER(2) CONSTRAINT CK_TAB_DEPTNO_CK CHECK(DEPTNO IN (10,20,30,40)),
    DNAME CHAR(20)
);

SELECT * FROM USER_CONSTRAINTS WHERE TABLE_NAME='CK_TAB';
INSERT INTO CK_TAB VALUES (50,'BAA');

테이블 수준에서 CK_TAB2

CREATE TABLE CK_TAB2(
    DEPTNO NUMBER(2),
    DNAME CHAR(20),
    LOC CHAR(10),
    CONSTRAINT CK_TAB2_LOC_CK CHECK (LOC IN ('서울','수원'))

);
INSERT INTO CK_TAB2 VALUES (10,'BAA','경기');

CREATE TABLE ZIPCODE(
    POST1 CHAR(3),
    POST2 CHAR(3),
    ADDR VARCHAR2(60) CONSTRAINT ZIPCODE_ADDR_NN NOT NULL,
    CONSTRAINT ZIPCODE_POST_PK PRIMARY KEY (POST1,POST2)
);

CREATE TABLE MEMBER_TAB(
    ID NUMBER(4),
    NAME VARCHAR2(10) CONSTRAINT MEMBER_TAB_NAME_NN NOT NULL,
    GENDER CHAR(1),
    JUMIN1 CHAR(6),
    JUMIN2 CHAR(7),
    TEL VARCHAR2(15),
    POST1 CHAR(3),
    POST2 CHAR(3),
    ADDR VARCHAR2(60),
    CONSTRAINT MEMBER_TAB_ID_PK_ PRIMARY KEY (ID),
    CONSTRAINT MEMBER_TAB_GENDER_CK CHECK(GENDER IN('F','M')),
    CONSTRAINT MEMBER_TAB_JUMIN_UK UNIQUE(JUMIN1, JUMIN2),
    CONSTRAINT MEMBER_TAB_POST_FK FOREIGN KEY (POST1, POST2)
    REFERENCES ZIPCODE(POST1, POST2)
);

#SUBQUERY를 통한 테이블생성
--       사원 테이블에서 30번 부서에 근무하는 사원의 정보만 추출하여
--	    EMP_30 테이블을 생성하여라. 단 열은 사번,이름,업무,입사일자,
--		급여,보너스를 포함한다.
CREATE TABLE EMP_30 (EMPNO,ENAME,JOB,HIREDATE,SAL,COMM) 
AS
SELECT EMPNO,ENAME,JOB,HIREDATE,SAL,COMM
FROM EMP WHERE DEPTNO=30;

SELECT * FROM EMP WHERE DEPTNO=30;
SELECT * FROM EMP_30;

--    [문제1]
--		EMP테이블에서 부서별로 인원수,평균 급여, 급여의 합, 최소 급여,
--		최대 급여를 포함하는 EMP_DEPTNO 테이블을 생성하라.
DROP TABLE EMP_DEPTNO;
CREATE TABLE EMP_DEPTNO
AS
SELECT DEPTNO, COUNT(EMPNO) CNT,ROUND(AVG(SAL)) AVG_SAL,
SUM(SAL)SUM_SAL,MIN(SAL)MIN_SAL,MAX(SAL)MAX_SAL
FROM EMP GROUP BY DEPTNO;

SELECT * FROM EMP_DEPTNO;
        
--	[문제2]	EMP테이블에서 사번,이름,업무,입사일자,부서번호만 포함하는
--		EMP_TEMP 테이블을 생성하는데 자료는 포함하지 않고 구조만
--		생성하여라
CREATE TABLE EMP_TEMP
AS
SELECT EMPNO,ENAME, JOB, HIREDATE, DEPTNO
FROM EMP WHERE 1=2;

SELECT *FROM EMP_TEMP;

--#DDL
--CREATE, DROP, ALTER, RENAME, TRUNCATE

--#컬럼 추가 및 변경, 삭제

--	- ALTER TABLE 테이블명 ADD 추가할 컬럼 정보 [default 값]
--	- ALTER TABLE 테이블명 MODIFY 변경할 컬럼 정보 
--	- ALTER TABLE 테이블명 RENAME OLDNAME TO NEWNAME 
--	- ALTER TABLE 테이블명 DROP (column 삭제할 컬럼명)

CREATE TABLE TEMP(
    NO NUMBER(4)
);
ALTER TABLE TEMP ADD NAME VARCHAR2(10);
ALTER TABLE TEMP ADD INDATE DATE DEFAULT SYSDATE;
SELECT * FROM TEMP;
DESC TEMP;

ALTER TABLE PRODUCTS ADD PROD_DESC VARCHAR2(1000) NOT NULL;
ALTER TABLE TEMP MODIFY NO CHAR(4);
ALTER TABLE TEMP RENAME COLUMN NO TO NUM;
ALTER TABLE TEMP DROP COLUMN INDATE;

ALTER TABLE TEMP ADD CONSTRAINT TEMP_NUM_PK PRIMARY KEY (NUM);

SELECT * FROM USER_CONSTRAINTS WHERE TABLE_NAME='TEMP';
INSERT INTO TEMP VALUES(1,'AAA');
SELECT * FROM TEMP;
제약조건 비활성화
ALTER TABLE 테이블명 DISABLE CONSTRAINT 제약조건명[CASCADE];
ALTER TABLE 테이블명 ENABLE CONSTRAINT 제약조건명[CASCADE];
ALTER TABLE TEMP DISABLE CONSTRAINT TEMP_NUM_PK;
SELECT * FROM USER_CONSTRAINTS WHERE TABLE_NAME='TEMP';
DELETE FROM TEMP;
COMMIT;
ALTER TABLE TEMP ENABLE CONSTRAINT TEMP_NUM_PK;
RENAME TEMP TO TEST_TEMP;
SELECT * FROM TAB;
DROP TABLE TEST_TEMP CASCADE CONSTRAINT;
DROP TABLE TEST PURGE; 
테이블 모든구조와 데이터가 삭제, 관련 인덱스도 모두 삭제
select* from memo;
SELECT idx,name,msg,wdate FROM memo ORDER BY idx DESC;