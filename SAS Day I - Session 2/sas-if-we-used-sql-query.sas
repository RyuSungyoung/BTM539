*merging datasets using proc sql. Much shorter and effective code to write;

TITLE 'Merging dataset1 and dataset2 in proc sql';
PROC SQL;
 CREATE TABLE sql_merged12 AS
 SELECT *
 FROM dataset1 AS A INNER JOIN (SELECT * FROM dataset2 WHERE score2 IS NOT MISSING) as B
 ON A.ID=B.ID
 ORDER BY ID;
QUIT;

PROC PRINT DATA=sql_merged12; run;

DATA sql_merged12; SET sql_merged12;
 avg = (score1 + score2) / 2;

TITLE 'Merging sql_merged12 and dataset3 in proc sql';
PROC SQL;
 CREATE TABLE sql_merged123 AS
 SELECT *
 FROM sql_merged12 AS A LEFT JOIN dataset3 as B
 ON A.testtime=B.testtime
 ORDER BY ID;
QUIT;

PROC PRINT DATA=sql_merged123; run;

TITLE 'Calculating mean values and merging in proc sql';
PROC SQL;
 CREATE TABLE sql_merged124 AS
 SELECT *
 , MEAN(score1) AS score1mean
 , MEAN(score2) AS score2mean
 , MEAN(avg) AS avgmean
 FROM sql_merged12
 GROUP BY TESTTIME
 ORDER BY ID;
QUIT;

DATA sql_merged124; SET sql_merged124;
 newcurve = 85 - avgmean;
 curvedavg = avg + newcurve;
PROC PRINT DATA=sql_merged124; run;

* for some help on proc sql, see:
   http://www2.sas.com/proceedings/sugi27/p070-27.pdf
   http://www2.sas.com/proceedings/sugi29/042-29.pdf;

