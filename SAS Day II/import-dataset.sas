PROC IMPORT OUT= WORK.IBMcsv 
            DATAFILE= "C:\Users\samsung\Desktop\SAS Day II\ibm.txt" 
            DBMS=TAB REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
