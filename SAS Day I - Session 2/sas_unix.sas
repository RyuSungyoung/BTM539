* Sample SAS program showing different input formats and compute some simple statistics;

OPTIONS NOCENTER;
***********************************************************************;

libname mine '/home/kaist/tigerz7/fin514';

* Internal fixed format;
DATA dataset1;
INPUT name $ 1-4 id $ 6-13 gender $ 14-14 score 15-19;

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
* External fixed format.compare how to read in file in unix sas to local sas;
DATA dataset2;
INFILE '/home/kaist/tigerz7/fin514/sasinput1a.txt';  
INPUT name $ 1-4 id $ 6-13 gender $ 14-14 score 15-19;

TITLE 'Printout of dataset2 (external fixed format)';
PROC PRINT DATA=dataset2; RUN;

***********************************************************************;
* Internal list (free) format;
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
* External comma delimited;
DATA dataset4;
INFILE '/home/kaist/tigerz7/fin514/sasinput1b.txt' dlm=",";
INPUT name $ id $ gender $ score;

TITLE 'Printout of dataset4 (external comma delimited)';
PROC PRINT DATA=dataset4; run;

***********************************************************************;
* Deleting observations;
DATA mine.dataset5; set dataset4;
IF gender eq 'F' then delete;
TITLE 'Deleting females';
PROC PRINT DATA=mine.dataset5; run;

***********************************************************************;
TITLE 'Simple statistics using proc means';
PROC MEANS DATA=dataset4; RUN;

TITLE 'Simple statistics using proc univariate';
PROC UNIVARIATE DATA=dataset4; RUN;

TITLE 'Simple statistics using proc means by gender';
PROC SORT DATA=dataset4; BY gender;
PROC MEANS DATA=dataset4; BY gender; RUN;
