* Sample SAS program showing how to merge two different datasets;

OPTIONS NOCENTER;
*********************************************************************;
* one-to-one merge;

DATA dataset1;
INPUT id $ 1-8 score1 9-11 testtime $ 13-17;

CARDS;
R0000001 90 10:00
R0000002 80 10:00
R0000003 60 12:00
R0000004 70 10:00
R0000005100 12:00
R0000006 75 18:00
R0000007 80 18:00
R0000008 40 10:00
R0000009 55 18:00
R0000010 45 12:00
;

TITLE 'Printout out of first test scores'; /*중간고사*/
PROC PRINT DATA=dataset1; RUN;

DATA dataset2;
INPUT id $ 1-8 score2 9-11 testtime $ 13-17;

CARDS;
R0000005100 12:00
R0000001 75 10:00
R0000003 50 12:00
R0000004 70 10:00
R0000007 90 18:00
R0000006 70 18:00
R0000002 95 10:00
R0000010  . 12:00
R0000009  . 18:00
R0000008  . 10:00
;

TITLE 'Printout out of second scores'; /*기말고사*/
PROC PRINT DATA=dataset2; RUN;

*ID를 key identifier으로 가지고 dataset1, 2에서 각각 align;
PROC SORT DATA=dataset1; by ID;
PROC SORT DATA=dataset2; by ID;

* one-to-one merge;
DATA datamerge12;
 MERGE dataset1 dataset2; by id;
 avg = (score1 + score2) / 2;

*same result as above using proc sql, SQL을 사용하면 proc sort할 필요도 없고, 3개 이상의 복수의 as var 값 설정이 가능한 이점이 있다;
 /* proc sql;
 	create table datamerge12 as
		select a.*, b.score2, (score1+score2).2 as average, avg(score1) as score1_avg, min(score1) as minscore1, max(score1) as max_score1
		from dataset1 as a left join dataset2 as b on a.id = b.id group by a.id;
quit; */

proc sql;
 	create table datamerge12 as
		select a.*, b.score2, (score1+score2)/2 as avg from dataset1 as a left join dataset2 as b on a.id = b.id;
quit;

* Delete students that dropped the class;
DATA datamerge12; SET datamerge12;
 IF score2 eq . then delete;

/*without VAR, by default it will show all variables*/
TITLE 'Printout out of both test scores and average after one-to-one merge';
PROC PRINT DATA=datamerge12; VAR id testtime score1 score2 avg; RUN;

*********************************************************************;
* one-to-many (or many-to-one) merge;

DATA dataset3;
INPUT testtime $ 1-5 curve 6-7; /*testtime 조건(자체 데이터셋 cards:)에 따라서 가산점(curve) 부여*/

CARDS;
10:00 3
12:00 2
14:00 4
16:00 1
;

PROC SORT DATA=datamerge12; by testtime;
PROC SORT DATA=dataset3; by testtime;

TITLE 'Regular merge (no conditions given)';
DATA datamerge123;
 MERGE datamerge12 dataset3; by testtime;
 PROC PRINT DATA=datamerge123; VAR id testtime score1 score2 avg curve; RUN;

TITLE 'Inner join merge (must be in both datasets)';
DATA datamerge123;
 MERGE datamerge12 (in=a) dataset3 (in=b); by testtime; if a and b; /*교집합 조건(and)*/

 PROC PRINT DATA=datamerge123; VAR id testtime score1 score2 avg curve; RUN;

TITLE 'Outer full join merge (same as regular merge - could be in either dataset)';
DATA datamerge123;
 MERGE datamerge12 (in=a) dataset3 (in=b); by testtime; if a or b; /*합집합 조건(or)*/
 PROC PRINT DATA=datamerge123; VAR id testtime score1 score2 avg curve; RUN;

TITLE 'Outer left join merge (must be in the left dataset)';
DATA datamerge123;
 MERGE datamerge12 (in=a) dataset3 (in=b); by testtime; if a;  /*☆LEFTJOIN☆ a가 key 값으로 호출하고, a에다가 b 값을 이어붙여라 (b.curve가 없어도 나타냄)*/
 PROC PRINT DATA=datamerge123; VAR id testtime score1 score2 avg curve; RUN;

TITLE 'Outer right join merge (must be in the right dataset)';
DATA datamerge123;
 MERGE datamerge12 (in=a) dataset3 (in=b); by testtime; if b;  /*b가 key 값으로 호출하고, b에다가 a 값을 이어붙여라 (a.ID가 없어도 나타냄)*/
 PROC PRINT DATA=datamerge123; VAR id testtime score1 score2 avg curve; RUN;

 * problems with duplicate data when merging;
DATA dataset3a;
INPUT testtime $ 1-5 curve 6-7;

CARDS;
10:00 3
12:00 2
14:00 4
16:00 1
18:00 5
10:00 0
12:00 2
;

TITLE 'Print out all entries';
PROC SORT DATA=dataset3a; by testtime;
PROC PRINT DATA=dataset3a; RUN;

/*빈도분석 결과를 하나의 데이터셋으로 저장*/
TITLE 'Identify dupicate entries';
PROC FREQ DATA=dataset3a;
 TABLES testtime / /*NOPRINT*/ OUT=duplist; RUN;
PROC PRINT DATA=duplist; WHERE COUNT ge 2; RUN;

/*nodup(정확히 같은 중복값이 나오면 무조건 제거 처리하라) 과 nodupkey(중복값이 나타나면 1 key : n variants 만 남기고 제거 처리하라)의 차이점*/
TITLE 'Eliminating exact duplicates using nodup';
PROC SORT DATA=dataset3a nodup out=dataset3a_nodup; by testtime;
PROC PRINT DATA=dataset3a_nodup; RUN;

TITLE 'Eliminating duplicates based on the by variable using nodupkey';
PROC SORT DATA=dataset3a by testtime ascending curve;
/*sort 정의 안되면 가장 상단 값을 지워버림, descending: var 값의 내림차순, ascending: 오름차순
nodupkey (case) MIN 제거(ascending order), MAX 제거(descending order), count(rank) 함수 지정 ex. proc sql group by count*/
PROC SORT DATA=dataset3a nodupkey out=dataset3a_nodupkey; by testtime;
PROC PRINT DATA=dataset3a_nodupkey; RUN;

* for details, see http://www2.sas.com/proceedings/forum2007/069-2007.pdf;

* merging with output from a proc statement;

PROC SORT data=datamerge12; BY testtime;
TITLE 'Calculate means by testtime';
PROC MEANS data=datamerge12; BY testtime; VAR score1 score2 avg;
 OUTPUT OUT=dataset4 MEAN = score1mean score2mean avgmean; RUN;

PROC SORT DATA=datamerge12; by testtime;
PROC SORT DATA=dataset4; by testtime;

DATA datamerge124;
 MERGE datamerge12 dataset4; by testtime;
 newcurve = 85 - avgmean;
 curvedavg = avg + newcurve;

PROC SORT DATA=datamerge124; BY ID;
TITLE 'Print curved average score';
PROC PRINT DATA=datamerge124; VAR id testtime score1 score2 avg newcurve curvedavg; RUN;

* Compustat data sql import -- 2013년 1월부터 2023년 1월까지, 북미권 S&P 500 기업 기말재무제표 (download local from WRDS);

libname corprate 'C:\Users\samsung\Downloads';

proc sql;
	create table compu as
		select gvkey, at, ni, prcc_f, avg(ni) as ni_avg from corprate.FSdataAdecade
			group by gvkey;
quit;

libname corprate 'C:\Users\samsung\Downloads';
proc sql;
	create table a1 as
		select a.gvkey, a.ni, a.at from corprate.FSdataAdecade a;
quit;

/* proc sql;
create table compu as
select c.*, avg(c.ni) as total_avg
from (select gvkey.ni, avg(ni) as ni_avg from GVcorporate.FSdatas
group by gvkey).c;
quit; */
