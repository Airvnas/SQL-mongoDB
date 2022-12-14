--#패키지
--여러개의 프로시저, 함수,커서 등을 하나의 패키지로 묶어 관리할 수 있다.
---선언부
---본문(package body)

--패키지 선언부
create or replace package empInfo as
procedure allEmp;
procedure allSal;
end empInfo;

--패키지 본문 구성
create or replace package body empInfo as
    procedure allEmp
    is
    cursor empCr is
    select empno,ename,hiredate from emp
    order by 3;
    begin
    for k in empCr loop
        dbms_output.put_line(k.empno||lpad(k.ename,16,' ')||lpad(k.hiredate,16,' '));
    end loop;
    exception
        when others then
        dbms_output.put_line(SQLERRM||'에러가 발생함');
    end allEmp;
    
-- allSal은 전체 급여 합계, 사원수, 급여평균, 최대급여, 최소급여를 가져와 출력하는 프로시저
    procedure allSal
    is
    begin
        dbms_output.put_line('급여 총합'||lpad('사원수',10,' ')||lpad('평균급여',10,' ')||
            lpad('최대 급여',10,' ')||lpad('최소급여',10,' '));
        for k in (select sum(sal) sm,count(empno) cnt,round(avg(sal)) av, 
        max(sal) mx, min(sal) mn from emp) loop
            dbms_output.put_line(k.sm||lpad(k.cnt,10,' ')||lpad(k.av,10,' ')||
            lpad(k.mx,10,' ')||lpad(k.mn,10,' '));
        end loop;
    end allSal;
end empInfo;
/

set serveroutput on
exec empInfo.allemp;
exec empInfo.allSal;

--#trigger 
--INSERT, UPDATE, DELETE 문이 실행될때 묵시적으로 수행되는 일종의 프로시저

CREATE OR REPLACE TRIGGER TRG_DEPT
BEFORE 
UPDATE ON DEPT
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('변경 전 컬럼값: '|| :OLD.DNAME);
    DBMS_OUTPUT.PUT_LINE('변경 후 컬럼값: '|| :NEW.DNAME);
END;
/

SELECT * FROM DEPT;
UPDATE DEPT SET DNAME='운영부' WHERE DEPTNO=40;
ROLLBACK;

--트리거 비활성화
ALTER TRIGGER TRG_DEPT DISABLE;
--트리거 활성화
ALTER TRIGGER TRG_DEPT ENABLE;
--트리거 삭제
DROP TRIGGER TRG_DEPT;
--데이터 사전에서 조회
SELECT * FROM USER_TRIGGERS WHERE TRIGGER_NAME='TRG_DEPT';


--EMP 테이블에 데이터가 INSERT되거나 UPDATE될 경우 (BEFORE)
--전체 사원들의 평균급여를 출력하는 트리거를 작성하세요.

CREATE OR REPLACE TRIGGER TRG_EMP_AVG 
BEFORE 
INSERT OR UPDATE ON EMP
FOR EACH ROW
DECLARE 
AVG_SAL NUMBER;
BEGIN
    SELECT ROUND(AVG(SAL)) INTO AVG_SAL FROM EMP;
    DBMS_OUTPUT.PUT_LINE('평균급여: '||AVG_SAL);
END;
/
INSERT INTO EMP (EMPNO, ENAME, DEPTNO, SAL)
VALUES (9000,'PETER',30,6000);
ROLLBACK;
SELECT AVG(SAL) FROM EMP;


--[트리거 실습 1] 행 트리거
--입고 테이블에 상품이 입고될 경우
--상품 테이블에 상품 보유수량이 자동으로 변경되는 
--트리거를 작성해봅시다.

CREATE TABLE MYPRODUCT(
    PCODE CHAR(6) PRIMARY KEY,
    PNAME VARCHAR2(20) NOT NULL,
    PCOMPANY VARCHAR2(20),
    PRICE NUMBER(8),
    PQTY NUMBER DEFAULT 0
);
DESC MYPRODUCT;
CREATE SEQUENCE MYPRODUCT_SEQ
START WITH 1
INCREMENT BY 1
NOCACHE;
INSERT INTO MYPRODUCT VALUES('A00'||MYPRODUCT_SEQ.NEXTVAL,'노트북','A사',800000,10);
INSERT INTO MYPRODUCT VALUES('A00'||MYPRODUCT_SEQ.NEXTVAL,'자전거','B사',100000,20);
INSERT INTO MYPRODUCT VALUES('A00'||MYPRODUCT_SEQ.NEXTVAL,'킥보드','C사',70000,30);
COMMIT;
SELECT * FROM MYPRODUCT;

CREATE TABLE MYINPUT(
    INCODE NUMBER PRIMARY KEY,
    PCODE_FK CHAR(6) REFERENCES MYPRODUCT (PCODE),
    INDATE DATE DEFAULT SYSDATE,
    INQTY NUMBER(6),
    INPRICE NUMBER(8)
);

CREATE SEQUENCE MYINPUT_SEQ NOCACHE;
--입고 테이블에 상품이 들어오면
--상품 테이블의 보유수량을 변경하는 트리거를 작성하세요

CREATE OR REPLACE TRIGGER QTY_CHANGE
AFTER 
INSERT ON MYINPUT
FOR EACH ROW
DECLARE 
     cnt number := :new.inqty;
     code char(6) := :new.pcode_fk;
BEGIN 
    UPDATE MYPRODUCT SET PQTY=PQTY+CNT WHERE PCODE= CODE;
    DBMS_OUTPUT.PUT_LINE(CODE||'상품이 추가로 '||CNT||'개 들어옴');
END;
/

SELECT * FROM MYPRODUCT;
INSERT INTO MYINPUT
VALUES (MYINPUT_SEQ.NEXTVAL,'A002',SYSDATE,8,50000);

--입고 테이블의 수량이 변경될 경우-UPDATE문이 실행될 때
--상품 테이블의 수량을 수정하는 트리거를 작성하세요

CREATE OR REPLACE TRIGGER TRG_INPUT_PRODUCTS2
AFTER 
UPDATE ON MYINPUT
FOR EACH ROW
DECLARE
    GAP NUMBER;
BEGIN
    GAP:= :NEW.INQTY-:OLD.INQTY;
    

    UPDATE MYPRODUCT SET PQTY=PQTY+GAP WHERE PCODE = :NEW.PCODE_FK;
    DBMS_OUTPUT.PUT_LINE('NEW: '||:NEW.INQTY||',OLD: '||:OLD.INQTY||',GAP: '||GAP);
    --DBMS_OUTPUT.PUT_LINE(CODE||'상품의 재고가 '||CNT||'개 수정됨');
END;
/

SELECT * FROM MYPRODUCT;
SELECT * FROM MYINPUT;
UPDATE MYINPUT SET INQTY=10 WHERE INCODE=1;
UPDATE MYINPUT SET INQTY=18 WHERE INCODE=2;

SELECT * FROM USER_TRIGGERS;


--[트리거 실습2] - 문장 트리거
--EMP 테이블에 신입사원이 들어오면(INSERT) 로그 기록을 남기자
--어떤 DML문장을 실행했는지, DML이 수행된 시점의 시간, USER 데이터를
--EMP_LOG테이블에 기록하자.
CREATE TABLE EMP_LOG(
    LOG_CODE NUMBER PRIMARY KEY,
    USER_ID VARCHAR2(30),
    LOG_DATE DATE DEFAULT SYSDATE,
    DEHAVIOR VARCHAR2(20)
);
CREATE SEQUENCE EMP_LOG_SEQ NOCACHE;
CREATE OR REPLACE TRIGGER TRG_EMP_LOG
BEFORE INSERT ON EMP
BEGIN
    IF (TO_CHAR(SYSDATE,'DY') IN ('FRI','SAT','SUN') )THEN
        RAISE_APPLICATION_ERROR(-20001,'금,토,일에는 입력작업을 할 수 없어요');
    ELSE 
        INSERT INTO EMP_LOG VALUES (EMP_LOG_SEQ.NEXTVAL,USER,SYSDATE,'INSERT');
    END IF;
END;
/

INSERT INTO EMP(EMPNO,ENAME,SAL,DEPTNO) VALUES(9010,'THOMAS',3300,20);
SELECT * FROM EMP_LOG;









