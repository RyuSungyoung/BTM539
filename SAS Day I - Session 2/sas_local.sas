* Sample SAS program showing different input formats and compute some simple statistics;

OPTIONS NOCENTER;
***********************************************************************;
* Internal fixed format;
DATA dataset1;
INPUT name $ 1-4 id $ 6-13 gender $ 14-14 score 15-19; *var 뒤에 $(=str)/없으면 int, 변수의 column 길이를 지정함 (n-m)

CARDS;
Mary R0000001F100.0
Doug R0000002M 94.3
Sue  R0000003F    .
Joe  R0000004M 85.7
;
TITLE 'Printout of dataset1 (internal fixed format)';
PROC PRINT DATA=dataset1; RUN;

TITLE 'Printout of line 2 and 3 from dataset1';
PROC PRINT DATA=dataset1 (firstobs=2 obs=3); RUN;

***********************************************************************;
* External fixed format, change directory in infile statement;
DATA dataset2;
INFILE 'C:\Users\samsung\Desktop\SAS Day I - Session 2\sasinput1a.txt';
INPUT name $ 1-4 id $ 6-13 gender $ 14-14 score 15-19;

TITLE 'Printout of dataset2 (external fixed format)';
PROC PRINT DATA=dataset2; RUN;

***********************************************************************;
* Internal list (free) format. Note the number of length;
DATA dataset3;
INPUT name $ id $ gender $ score;

CARDS;
Mary R0000001 F 100
Doug R0000002 M 94.3
Sue R0000003 F .
Joe R0000004 M 85.7
;
TITLE 'Printout of dataset3 (internal list format)';
PROC PRINT DATA=dataset3; run;

***********************************************************************;
* External comma delimited. change directory in infile statement;
DATA dataset4;
INFILE 'C:\Users\samsung\Desktop\SAS Day I - Session 2\sasinput1b.txt' dlm=","; /*dlm : 구분자*/
INPUT name $ id $ gender $ score;

TITLE 'Printout of dataset4 (external comma delimited)';
PROC PRINT DATA=dataset4; run;

***********************************************************************;
* Deleting observations;
DATA dataset5; set dataset4; /* set dataset4를 인용해와서 아래 작업 결과를 DATA dataset5로 저장하세요 */
IF gender eq 'F' then delete; /*범위 if 또는 where 구문으로 지정할 수 있음, eq '=', le '<=', ge '>='*/
TITLE 'Deleting females';
PROC PRINT DATA=dataset5; run;

***********************************************************************;
TITLE 'Simple statistics using proc means';
PROC MEANS DATA=dataset4; RUN;

TITLE 'Simple statistics using proc univariate';
PROC UNIVARIATE DATA=dataset4; RUN;

TITLE 'Simple statistics using proc means by gender';
PROC SORT DATA=dataset4; BY gender; RUN;
PROC MEANS DATA=dataset4; BY gender; RUN; * 선행하여 정렬된 상태(sort)에서 그루핑 들어가야함.
