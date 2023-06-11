
/*Before running this program, run CPI adjusted code at first to get compu data adjusted to CPI*/

/*screening*/
data cash;
set mine.cpiadj_ind;
*if not missing(sic);
if 6000 <= sich <=6999 then delete;
if 4900 <= sich <= 4999 then delete;
if sich >= 9900 then delete; /*Laura's paper*/
if at > 0;
run; 

/*create variables*/
data cash1;
set cash;
c = (che)/(at);*(at-che);
m = cshpri*prcc_f; /*mv of equity*/
na = at - che;
e = ib+xint+txdi+itci;
d = dvc;
l = ((dltt + dlc)/(dltt+dlc+m)); /*leverage*/
nf = (sstk-prstkc)+(dltis-dltr);
lsize = log(at-che); *from here, Liu and Mauer (2011) control variables for cash holding;
mtb = ((at-che-ceq+csho+ csho*prcc_f)/(at-che));
cfa = ((oibdp-xint-txt-dvc)/(at-che)); /*cash flow net asset*/
nwc = ((wcap-che)/(at-che));
capex = (capx/(at-che));
lev = ((dltt+dlc)/(at-che));
rd = (xrd/sale);
aq = (aqc/(at-che));
if dvc > 0 then ddummy = 1;
else ddummy = 0;
if missing (xrd) then do;
	rd = 0;
end;
else do;
rd = xrd;
end;
i = xint;
if na < 0 then delete;
if m <0 then delete;
if d<0 then delete;
run;


proc sort data = cash1; by permno fyear;run;
/*create change in variables to run model 9*/
proc expand data = cash1 out=cash2 method=none;
    by permno;
    id fyear;
    convert c = c_1/transformout=(lag 1);
	convert e = e_1/transformout=(lag 1);
	convert m = m_1/transformout=(lag 1);
	convert na = na_1/transformout=(lag 1);
	convert rd = rd_1/transformout=(lag 1);
	convert i = i_1/transformout=(lag 1);
    convert d = d_1/transformout=(lag 1);
	label c_1= 'lagged cash';
quit;

/*first difference in variables*/
data cash3;
set cash2;
cc = (c - c_1)/m_1;
ce = (e - e_1)/m_1;
cna = (na- na_1)/m_1;
crd = (rd-rd_1)/m_1;
ci = (i -i_1)/m_1;
cd = (d-d_1)/m_1;
nf = nf/m_1;
c_1m_1 = c_1/m_1;
ccc=c_1m_1*cc;
lcc=l*cc;
run;



/*trim  DV and INDV at the 1% tail*/ 
proc rank data=cash3 Nplus1 ties=mean out=cash3_rnk;
     var  cc c_1 ce cna crd ci cd l nf c;
     ranks  cc_rnk c_1_rnk ce_rnk cna_rnk crd_rnk ci_rnk cd_rnk l_rnk nf_rnk c_rnk; /*variable names of percentile variables*/
run;

data cash3_trim;
set cash3_rnk;
if cc_rnk <= 0.01 then delete;
if c_1_rnk <=0.01 then delete;
*if ce_rnk <=0.01 then delete;
if cna_rnk <=0.01 then delete;
if crd_rnk <=0.01 then delete;
if ci_rnk <=0.01 then delete;
if cd_rnk <=0.01 then delete;
if l_rnk <=0.01 then delete;
if nf_rnk <=0.01 then delete;
datadate_pre11 = intnx("month",datadate,-11,'b');
format datadate_pre11 date9.;
drop  cc_rnk c_1_rnk ce_rnk cna_rnk crd_rnk ci_rnk cd_rnk l_rnk nf_rnk;
run;

/*Table1. 
강의는 여기까지만*/
proc means data = cash3_trim mean q1 median q3 max std;
var c cc c_1 ce cna crd ci cd l nf;
run;

/*table 3, main table*/
ods output ParameterEstimates= parameterestimates;
proc reg data  = cash3_trim;
	model dv = cc ce cna crd ci cd c_1 l nf ccc lcc;
run;quit;
ods output close;

data param1; set ParameterEstimates;     /*parameterEstimates contains model estimates*/
if Probt<.01 then str="***"; else if Probt<.05 then str="**";
else if Probt<.1 then str="*";
coef=strip(roundz(Estimate,0.001)||str); idx=_N_;
proc sort; by Variable coef;
run;
 
proc transpose data=param1 out=param2;                   /*formating estimate report 1*/
var Estimate tValue; by Variable coef idx;
run;

data param3; set param2;                                 /*formating estimate report 2*/
if _NAME_="tValue" then  do coef=cats("[",roundz(col1,0.001),"]"); Variable=""; end;
proc sort; by idx _NAME_;
run;
proc export 
  data=param3
  dbms=xlsx 
  outfile="D:\Dropbox\외부강의\전북대\세미나_Faulkender_Wang\cpi\table3.xlsx" 
  replace;
run;

