/*PROC SQL options; *SQL 구문 불러와서 작업 처리하기
SELECT column(variants)
FROM table-name / view-name
WHERE expression
GROUP BY column(variants) *(grouping key) Compustat: GVKey, CRSP: Permno
HAVING expression *(condition in group, omit available)
ORDER BY column(variants); *(sort in the order: 기본적으로 오름차순 정리하지만 DESC를 끝에 넣어주면 내림차순 정리)

#선행 선언변수를 사용하고 싶으면, "CALCULATED" variant column name 기입
#LABEL != COLUMN (label은 table에서의 열 머리 이름이 되지만 이것은 변수명이 아니다. dataset 외형상으로 보이는 column name.)

CASE
	WHEN column(variants) BETWEEN #,##0 AND #,##0 THEN "blah" ~ # #,##0 ~ #,##0 사이 구간에 있는 값은 "blah"로 
	ELSE "blah" #상기 when에서 처리하지 못한 값은 "blah"로 반환한다.
END AS categories #Case에서 만들어진 값을 categories variants 열로 표현

RUN*/

libname r 'C:\Users\samsung\Desktop\SAS Day II';

PROC SQL;
SELECT state, sum(sales) as TOTSALES
FROM r.ussales
WHERE state in ("WI","MI","IL")
GROUP BY state
/* HAVING sum(sales) > 103000 */
ORDER BY state;
quit;

PROC SQL;
SELECT STATE,
CASE
WHEN SALES BETWEEN 0 AND 10000 THEN "LOW"
WHEN SALES BETWEEN 10001 AND 15000 THEN "AVG"
WHEN SALES BETWEEN 15001 AND 20000 THEN "HIGH"
ELSE "VERY HIGH"
END AS SALESCAT
FROM r.USSALES;
QUIT;

DATA COMPUVARIABLE:
