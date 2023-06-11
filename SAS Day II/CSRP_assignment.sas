libname path 'C:\Users\samsung\Desktop\SAS Day II';

data ibm;
infile 'C:\Users\samsung\Desktop\SAS Day II\ibm.txt' firstobs=3;
input permno 4-8 cdate $ 9-18 comnam $ 19-50 prc 51-61 ret 62-69 cshrout $ 70-78 distcd 79-89 divamt 90-97 vwretd 98-106;
run;
date = input(cdate.date9.);
shrout = input(cshrout.comma9.);

if distcd = -99 then distcd = .;
if divamt = -99 then divamt = .;
run;

data ibm; retain permno date comnam prc ret shrout distcd divamt vwretd; set ibm;
drop cdate cshrout;
format date date9.;
year = year(date);
mve = prc * shrout * 0.001;
format prc 10.2;
format ret 10.6;
format vwretd 10.6;
format mve 10.3;
run;

data ibmcsv;
infile 'C:\Users\samsung\Desktop\SAS Day II\ibm.txt' firstobs=3;
input permno 4-8 cdate $ 9-18 comnam $ 19-50 prc 51-61 ret 62-69 cshrout $ 70-78 distcd 79-89 divamt 90-97 vwretd 98-106;
format date Date9.;
year = int(date/10000);
month = int((date-year*10000)/100);
day = date-year*10000-month*100;
mmddyy = mdy(month, day, year);
mve = prc * shrout * 0.001;
format prc 10.2;
format ret 10.6;
format vwretd 10.6;
format mve 10.3;
run;
