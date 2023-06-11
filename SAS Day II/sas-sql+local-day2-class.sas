/*PROC SQL options; *SQL ���� �ҷ��ͼ� �۾� ó���ϱ�
SELECT column(variants)
FROM table-name / view-name
WHERE expression
GROUP BY column(variants) *(grouping key) Compustat: GVKey, CRSP: Permno
HAVING expression *(condition in group, omit available)
ORDER BY column(variants); *(sort in the order: �⺻������ �������� ���������� DESC�� ���� �־��ָ� �������� ����)

#���� ���𺯼��� ����ϰ� ������, "CALCULATED" variant column name ����
#LABEL != COLUMN (label�� table������ �� �Ӹ� �̸��� ������ �̰��� �������� �ƴϴ�. dataset ���������� ���̴� column name.)

CASE
	WHEN column(variants) BETWEEN #,##0 AND #,##0 THEN "blah" ~ # #,##0 ~ #,##0 ���� ������ �ִ� ���� "blah"�� 
	ELSE "blah" #��� when���� ó������ ���� ���� "blah"�� ��ȯ�Ѵ�.
END AS categories #Case���� ������� ���� categories variants ���� ǥ��

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
