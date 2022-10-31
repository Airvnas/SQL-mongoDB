/*
# 시퀀스
구문
CREATE SEQUENCE 시퀀스명
[INCREMENT BY n] --증가치
[START WITH n]   --시작값
[{MAXVALUE n | NOMAXVALE}]--최대값
[{MINVALUE n | NOMINVALUE}]--최소값
[{CYCLE | NOCYCLE}]-- 최대 최소에 도달한 후 계속 값을 생성할지 여부를 지정nocycle이 기본
[{CACHE n| NOCACHE}]--메모리 캐시 디폴트 사이즈 20
*/

create sequence dept2_seq
start with 50
increment by 5
maxvalue 95
cache 20
nocycle;

select * from user_sequences;

시퀀스 사용
-nextval: 시퀀스 다음값
-currval: 시퀀스 현재값
[주의] nextval이 호출되지 않은 상태에서 currval이 사용되면 에러가난다.

select dept2_seq.currval from dual; ==> 에러

select dept2_seq.nextval from dual;

insert into dept2(deptno,dname,loc)
values(dept2_seq.nextval,'SALES','SEOUL');

SELECT * FROM DEPT2;

CREATE SEQUENCE TEMP_SEQ
START WITH 100
INCREMENT BY -5
MAXVALUE 100
MINVALUE 0
CYCLE 
NOCACHE;

SELECT * FROM USER_SEQUENCES WHERE SEQUENCE_NAME='DEPT2_SEQ';

SELECT TEMP_SEQ.NEXTVAL FROM DUAL;

#시퀀스 수정
[주의사항] 시작값은 수정할 수 없다. 시작값을 수정하려면 DROP후 다시생성

ALTER SEQUENCE 시퀀스명
INCREMENT BY N
MAXVALUE N
MINVALUE N
...;

ALTER SEQUENCE DEPT2_SEQ
INCREMENT BY 1
MAXVALUE 1000;
SELECT * FROM USER_SEQUENCES WHERE SEQUENCE_NAME='DEPT2_SEQ';

INSERT INTO DEPT2 VALUES(DEPT2_SEQ.NEXTVAL,'TEST','TEST');
SELECT * FROM DEPT2;
#시퀀스 삭제
DROP SEQUENCE 시퀀스명;

DROP SEQUENCE TEMP_SEQ;

#VIEW
[주의사항 ] VIEW를 생성하려면 CREATE VIEW 권한을 가져야한다.

--CREATE VIEW 뷰이름
--	AS
--	SELECT 컬럼명1, 컬럼명2...
--	FROM 뷰에 사용할 테이블명
--	WHERE 조건

--EMP테이블에서 20번 부서의 모든 컬럼을 포함하는 EMP20_VIEW를 생성하라.
CREATE VIEW EMP20_VIEW
AS SELECT * FROM EMP WHERE DEPTNO= 20;

--system
--Abcd1234
--grant create view to scott;

select * from emp20_view;
select * from user_views;

desc emp20_view;
drop view emp20_view;

#VIEW 수정
CREATE OR REPLACE 뷰이름 
AS SELECT문;

--[문제] 
--	고객테이블의 고객 정보 중 나이가 19세 이상인
--	고객의 정보를
--	확인하는 뷰를 만들어보세요.
--	단 뷰의 이름은 MEMBER_19로 하세요.

CREATE OR REPLACE VIEW MEMBER_19
AS SELECT * FROM MEMBER WHERE AGE>=19;

SELECT * FROM MEMBER_19;

CREATE OR REPLACE VIEW MEMBER_19
AS SELECT * FROM MEMBER WHERE AGE>=30;

EMP테이블에서 30번 부서만 EMPNO를 EMP_NO로 ENAME을 NAME으로
	SAL를 SALARY로 바꾸어 EMP30_VIEW를 생성하여라.
CREATE OR REPLACE VIEW EMP30_VIEW
AS SELECT EMPNO EMP_NO,ENAME NAME,SAL SALARY FROM EMP
WHERE DEPTNO=30;

SELECT * FROM EMP30_VIEW;

CREATE OR REPLACE VIEW EMP30_VIEW(ENO,NAME,SALARY,DNO)
AS SELECT EMPNO, ENAME, SAL, DEPTNO FROM EMP
WHERE DEPTNO=30;

UPDATE EMP SET DEPTNO= 20 WHERE EMPNO=7499;
SELECT * FROM EMP;

SELECT * FROM EMP30_VIEW;--VIEW의 데이터를 가져온 테이블이 변경되면 변경내용이 VIEW테이블에도 변하게됨

SELECT * FROM EMP_DEPT_VIEW ORDER BY 1;

CREATE OR REPLACE VIEW EMP_DEPT_VIEW
AS  
SELECT D.DEPTNO,DNAME,ENAME,JOB
FROM DEPT D JOIN EMP E
ON D.DEPTNO= E.DEPTNO;

UPDATE EMP30_VIEW SET DNO=10 WHERE ENO=7521;
SELECT * FROM EMP30_VIEW;

SELECT *FROM EMP;
ROLLBACK;
--뷰를 수정하면 원테이블도 수정됨
--원테이블을 수정하면 관련된 뷰도 수정됨

#WITH READ ONLY 옵션을 주면 뷰에 DML문장을 수행할 수 없다.
CREATE OR REPLACE VIEW EMP10_VIEW
AS SELECT EMPNO,ENAME,JOB,DEPTNO
FROM EMP WHERE DEPTNO=10
WITH READ ONLY;

SELECT * FROM EMP10_VIEW;

UPDATE EMP10_VIEW SET JOB='SALESMAN' WHERE EMPNO = 7782;
--"cannot perform a DML operation on a read-only view"

#WITH CHECK OPTION

CREATE OR REPLACE VIEW EMP_SALES_VIEW
AS SELECT * FROM EMP WHERE JOB='SALESMAN'
WITH CHECK OPTION;
==>WHERE절을 엄격하게 체크함
    WHERE절에 위배되는 값이 INSERT되거나 UPDATE되는것을 막는다
    
SELECT * FROM EMP_SALES_VIEW;
UPDATE EMP_SALES_VIEW SET DEPTNO = 10 WHERE EMPNO= 7499;
==>수정가능함

UPDATE EMP_SALES_VIEW SET JOB ='MANAGER' WHERE ENAME ='WARD';
==>view WITH CHECK OPTION where-clause violation

#INLINE VIEW
FROM절에서 사용된 서브쿼리를 인라인뷰라고 한다.
EMP에서 장기근속자 3명만 뽑아서 해외여행. 3명선출
DROP VIEW EMP_OLD;

CREATE VIEW EMP_OLD_VIEW
AS SELECT * FROM EMP ORDER BY HIREDATE ASC;

SELECT * FROM EMP_OLD_VIEW;

SELECT ROWNUM ,EMPNO,ENAME,HIREDATE FROM EMP_OLD_VIEW WHERE ROWNUM<4;

SELECT * FROM{
SELECT ROWNUM RN ,A.* FROM
(SELECT * FROM EMP ORDER BY HIREDATE ASC) A
}
WHERE RN<4;

#INDEX
-자동생성되는 경우 : PRIMARY, UNIQUE 제약조건을 주면 자동으로 생성
-명시적으로 생성하는 경우 : 사용자가 특정 컬럼을 지정해서 UNIQUE INDEX 또는 NON-UNIQUE    
                        인덱스를 지정할 수 있다.

CREATE INDEX 인덱스명 ON 테이블명(컬럼명[,컬럼명2,...])
[주의] 인덱스는 NOT NULL 인 컬럼에만 사용사능하다.

CREATE INDEX EMP_ENAME_INDX ON EMP (ENAME);

SELECT * FROM EMP WHERE ENAME='SCOTT';
인덱스를 지정하면 내부적으로 해당컬럼을 읽어서 오름차순 정렬을 한다
ROWID와 ENAME을 저장하기 위한 저장공간을 항당한 후 값을 저장한다.

데이터사전에서 조회
SELECT * FROM USER_OBJECTS WHERE OBJECT_TYPE='INDEX';
SELECT * FROM USER_OBJECTS WHERE OBJECT_TYPE='VIEW';
SELECT* FROM USER_INDEXES;

SELECT * FROM USER_IND_COLUMNS
WHERE INDEX_NAME= 'EMP_ENAME_INDX';

SELECT * FROM USER_IND_COLUMNS
WHERE TABLE_NAME= 'DEPT2';

CREATE INDEX PRODUCTS_CATEGORY_FK_INDX ON PRODUCTS(CATEGORY_FK);
CREATE INDEX PRODUCTS_EP_CODE_FK_INDX ON PRODUCTS(EP_CODE_FK);

SELECT * FROM USER_INDEXES WHERE TABLE_NAME='PRODUCTS';

카테고리, 상품, 공급업체 JOIN하여 출력
CREATE OR REPLACE VIEW PRODUCTS_INFO_VIEW
AS
SELECT C.CATEGORY_CODE,CATEGORY_NAME,PNUM,PRODUCTS_NAME,OUTPUT_PRICE,
EP_CODE_FK,EP_NAME
FROM CATEGORY C RIGHT OUTER JOIN PRODUCTS P
ON C.CATEGORY_CODE= P.CATEGORY_FK
LEFT OUTER JOIN SUPPLY_COMP S
ON P.EP_CODE_FK=S.EP_CODE;

SELECT * FROM PRODUCTS_INFO_VIEW
ORDER BY OUTPUT_PRICE ASC;

#DROP INDEX 인덱스명
EMP_ENAME_INDX 인덱스 삭제

DROP INDEX EMP_ENAME_INDX;
SELECT * FROM USER_INDEXES WHERE TABLE_NAME='EMP';


#인덱스 수정
==>DROP 하고 다시 생성


#synonym :동의어
create [public] synonym for 객체
-public은 DBA만 줄 수 있다.
-동의어 생성 권한도 부여받아야 할 수 있다.
SYSTEM계정으로 접속해서
GRANT CREATE SYNONYM TO SCOTT
데이터 사전에서 조회
SELECT * FROM USER_OBJECTS
WHERE OBJECT_TYPE='SYNONYM';

동의어 삭제
DROP SYNONYM NOTE;
SELECT * FROM NOTE;
SELECT * FROM MYSTAR.MYSTARSTABLENOTE;