
%MACRO DO_OVER(arraypos, array=,
               values=, delim=%STR( ),
               phrase=?, escape=?, between=,
               macro=, keyword=);


%LOCAL
  _IntrnlN
  _Intrnl1  _Intrnl2  _Intrnl3  _Intrnl4  _Intrnl5
  _Intrnl6  _Intrnl7  _Intrnl8  _Intrnl9  _Intrnl10
  _Intrnl11 _Intrnl12 _Intrnl13 _Intrnl14 _Intrnl15
  _Intrnl16 _Intrnl17 _Intrnl18 _Intrnl19 _Intrnl20
  _Intrnl21 _Intrnl22 _Intrnl23 _Intrnl24 _Intrnl25
  _Intrnl26 _Intrnl27 _Intrnl28 _Intrnl29 _Intrnl30
  _Intrnl31 _Intrnl32 _Intrnl33 _Intrnl34 _Intrnl35
  _Intrnl36 _Intrnl37 _Intrnl38 _Intrnl39 _Intrnl40
  _Intrnl41 _Intrnl42 _Intrnl43 _Intrnl44 _Intrnl45
  _Intrnl46 _Intrnl47 _Intrnl48 _Intrnl49 _Intrnl50
  _Intrnl51 _Intrnl52 _Intrnl53 _Intrnl54 _Intrnl55
  _Intrnl56 _Intrnl57 _Intrnl58 _Intrnl59 _Intrnl60
  _Intrnl61 _Intrnl62 _Intrnl63 _Intrnl64 _Intrnl65
  _Intrnl66 _Intrnl67 _Intrnl68 _Intrnl69 _Intrnl70
  _Intrnl71 _Intrnl72 _Intrnl73 _Intrnl74 _Intrnl75
  _Intrnl76 _Intrnl77 _Intrnl78 _Intrnl79 _Intrnl80
  _Intrnl81 _Intrnl82 _Intrnl83 _Intrnl84 _Intrnl85
  _Intrnl86 _Intrnl87 _Intrnl88 _Intrnl89 _Intrnl90
  _Intrnl91 _Intrnl92 _Intrnl93 _Intrnl94 _Intrnl95
  _Intrnl96 _Intrnl97 _Intrnl98 _Intrnl99 _Intrnl100
 _KEYWRDN _KEYWRD1 _KEYWRD2 _KEYWRD3 _KEYWRD4 _KEYWRD5
 _KEYWRD6 _KEYWRD7 _KEYWRD8 _KEYWRD9
 _KWRDI
 ARRAYNOTFOUND CRC CURRPREFIX DELIMI DID FRC I ITER J KWRDINDEX MANUM
 PREFIXES PREFIXN PREFIX1 PREFIX2 PREFIX3 PREFIX4 PREFIX5
 PREFIX6 PREFIX7 PREFIX8 PREFIX9
 SOMETHINGTODO TP VAL VALUESGIVEN
 ;

%let somethingtodo=Y;

%* Get macro array name(s) from either keyword or positional parameter;
%if       %str(&arraypos) ne %then %let prefixes=&arraypos;
%else %if %str(&array)    ne %then %let prefixes=&array;
%else %if %quote(&values) ne %then %let prefixes=_Intrnl;
%else %let Somethingtodo=N;

%if &somethingtodo=Y %then
%do;

%* Parse the macro array names;
%let PREFIXN=0;
%do MAnum = 1 %to 999;
 %let prefix&MANUM=%scan(&prefixes,&MAnum,' ');
 %if &&prefix&MAnum ne %then %let PREFIXN=&MAnum;
 %else %goto out1;
%end;
%out1:

%* Parse the keywords;
%let _KEYWRDN=0;
%do _KWRDI = 1 %to 999;
 %let _KEYWRD&_KWRDI=%scan(&KEYWORD,&_KWRDI,' ');
 %if &&_KEYWRD&_KWRDI ne %then %let _KEYWRDN=&_KWRDI;
 %else %goto out2;
%end;
%out2:

%* Load the VALUES into macro array 1 (only one is permitted);
%if %length(%str(&VALUES)) >0 %then %let VALUESGIVEN=1;
%else %let VALUESGIVEN=0;
%if &VALUESGIVEN=1 %THEN
%do;
         %* Check for numbered list of form xxx-xxx and expand it
            using NUMLIST macro.;
         %IF (%INDEX(%STR(&VALUES),-) GT 0) and
             (%SCAN(%str(&VALUES),2,-) NE ) and
             (%SCAN(%str(&VALUES),3,-) EQ )
           %THEN %LET VALUES=%NUMLIST(&VALUES);

%do iter=1 %TO 9999;
  %let val=%scan(%str(&VALUES),&iter,%str(&DELIM));
  %if %quote(&VAL) ne %then
    %do;
      %let &PREFIX1&ITER=&VAL;
      %let &PREFIX1.N=&ITER;
    %end;
  %else %goto out3;
%end;
%out3:
%end;

%let ArrayNotFound=0;
%do j=1 %to &PREFIXN;
  %*put prefix &j is &&prefix&j;
  %LET did=%sysfunc(open(sashelp.vmacro
                    (where=(name eq "%upcase(&&PREFIX&J..N)")) ));
  %LET frc=%sysfunc(fetchobs(&did,1));
  %LET crc=%sysfunc(close(&did));
  %IF &FRC ne 0 %then
    %do;
       %PUT Macro Array with Prefix &&PREFIX&J does not exist;
       %let ArrayNotFound=1;
    %end;
%end;

%if &ArrayNotFound=0 %then %do;

%if %quote(%upcase(&BETWEEN))=COMMA %then %let BETWEEN=%str(,);

%if %length(%str(&MACRO)) ne 0 %then
  %do;
     %let TP = %nrstr(%&MACRO)(;
     %do J=1 %to &PREFIXN;
         %let currprefix=&&prefix&J;
         %IF &J>1 %then %let TP=&TP%str(,);
            %* Write out macro keywords followed by equals.
               If fewer keywords than macro arrays, assume parameter
               is positional and do not write keyword=;
            %let kwrdindex=%eval(&_KEYWRDN-&PREFIXN+&J);
            %IF &KWRDINDEX>0 %then %let TP=&TP&&_KEYWRD&KWRDINDEX=;
         %LET TP=&TP%nrstr(&&)&currprefix%nrstr(&I);
     %END;
     %let TP=&TP);  %* close parenthesis on external macro call;
  %end;
%else
  %do;
     %let TP=&PHRASE;
     %let TP = %qsysfunc(tranwrd(&TP,&ESCAPE._I_,%nrstr(&I.)));
     %let TP = %qsysfunc(tranwrd(&TP,&ESCAPE._i_,%nrstr(&I.)));
     %do J=1 %to &PREFIXN;
         %let currprefix=&&prefix&J;
         %LET TP = %qsysfunc(tranwrd(&TP,&ESCAPE&currprefix,
                                 %nrstr(&&)&currprefix%nrstr(&I..)));
         %if &PREFIXN=1 %then %let TP = %qsysfunc(tranwrd(&TP,&ESCAPE,
                                 %nrstr(&&)&currprefix%nrstr(&I..)));
     %end;
  %end;

%* resolve TP (the translated phrase) and perform the looping;
%do I=1 %to &&&prefix1.n;
%if &I>1 and %length(%str(&between))>0 %then &BETWEEN;
%unquote(&TP)
%end;

%end;
%end;

%MEND;


%MACRO ARRAY(arraypos, array=, data=, var=, values=,
                       delim=%STR( ), debug=N, numlist=Y);


%LOCAL prefixes PREFIXN manum _VAR_N iter i J val VAR WHICH MINLENG
   PREFIX1 PREFIX2 PREFIX3 PREFIX4 PREFIX5 PREFIX6 PREFIX7 PREFIX8
   PREFIX9 PREFIX10 PREFIX11
   var1 var2 var3 var4 var5 var6 var7 var8 var9 var10 var11 ;

%* Get array names from either the keyword or positional parameter;
%if &ARRAY= %then %let PREFIXES=&ARRAYPOS;
%else %let PREFIXES=&ARRAY;

%* Parse the list of macro array names;
%do MANUM = 1 %to 999;
 %let prefix&MANUM=%scan(&prefixes,&MAnum,' ');
 %if &&prefix&MANUM ne %then
   %DO;
    %let PREFIXN=&MAnum;
    %global &&prefix&MANUM..N;
    %* initialize length to zero;
    %let &&prefix&MANUM..N=0;
   %END;
  %else %goto out1;
%end;
%out1:

%if &DEBUG=Y %then %put PREFIXN is &PREFIXN;

%* Parse the VAR parameter;
%let _VAR_N=0;
%do MANUM = 1 %to 999;
 %let _var_&MANUM=%scan(&VAR,&MAnum,' ');
 %if %str(&&_var_&MANUM) ne %then %let _VAR_N=&MAnum;
 %else %goto out2;
%end;
%out2:

%IF &PREFIXN=0 %THEN
    %PUT ERROR: No macro array names are given;
%ELSE %IF %LENGTH(%STR(&DATA)) >0 and &_VAR_N=0 %THEN
    %PUT ERROR: DATA parameter is used but VAR parameter is blank;
%ELSE %IF %LENGTH(%STR(&DATA)) >0 and &_VAR_N ne &PREFIXN %THEN
    %PUT ERROR: The number of variables in the VAR parameter is not
 equal to the number of arrays;
%ELSE %DO;

%*------------------------------------------------------;
%*  CASE 1: VALUES parameter is used
%*------------------------------------------------------;

%IF %LENGTH(%STR(&VALUES)) >0 %THEN
%DO;
     %IF &NUMLIST=Y %then
     %DO;
         %* Check for numbered list of form xxx-xxx and expand it using
             the NUMLIST macro.;
         %IF (%INDEX(%quote(&VALUES),-) GT 0) and
             (%length(%SCAN(%quote(&VALUES),1,-))>0) and
             (%length(%SCAN(%quote(&VALUES),2,-))>0) and
             (%length(%SCAN(%quote(&VALUES),3,-))=0)
           %THEN %LET VALUES=%NUMLIST(&VALUES);
     %END;

%LET MINLENG=99999;
%DO J=1 %TO &PREFIXN;
%DO ITER=1 %TO 9999;
  %LET WHICH=%EVAL((&ITER-1)*&PREFIXN +&J);
  %LET VAL=%SCAN(%STR(&VALUES),&WHICH,%STR(&DELIM));
  %IF %QUOTE(&VAL) NE %THEN
    %DO;
      %GLOBAL &&&&PREFIX&J..&ITER;
      %LET &&&&PREFIX&J..&ITER=&VAL;
      %LET &&&&PREFIX&J..N=&ITER;
    %END;
  %ELSE %goto out3;
%END;
%out3: %IF &&&&&&PREFIX&J..N LT &MINLENG
          %THEN %LET MINLENG=&&&&&&PREFIX&J..N;
%END;

%if &PREFIXN >1 %THEN
%DO J=1 %TO &PREFIXN;
    %IF &&&&&&PREFIX&J..N NE &MINLENG %THEN
%PUT ERROR: Number of values must be a multiple of the number of arrays;
%END;

%END;
%ELSE %DO;

%*------------------------------------------------------;
%*  CASE 2: DATA and VAR parameters used
%*------------------------------------------------------;

%* Get values from one or more variables in a dataset or view;
  data _null_;
  set &DATA end = lastobs;
%DO J=1 %to &PREFIXN;
  call execute('%GLOBAL '||"&&PREFIX&J.."||left(put(_n_,5.)) );
  call symput(compress("&&prefix&J"||left(put(_n_,5.))),
              trim(left(&&_VAR_&J)));
  if lastobs then
   call symput(compress("&&prefix&J"||"N"), trim(left(put(_n_,5.))));
%END;
  run ;

%* Write message to the log;
%IF &DEBUG=Y %then
%DO J=1 %to &PREFIXN;
 %PUT &&&&PREFIX&J..N is &&&&&&PREFIX&J..N;
%END;

%END;
%END;

%MEND;



libname mine 'C:\Users\ajou\Dropbox\외부강의\카이스트_코드강의\ICE4'; *data from wrds server;

/* execute do over and array macro at first before executing the following macro*/

/*
    Macro: cpiAdjust

    Purpose: Adjust time-series data for inflation

    Variables
    =========
        dsin        dataset in, needs year variable
        dsout       dataset out, will be dsin with variable(s) appended
        variables   list of variables separated by a space
                    (for example: variables=sale at ceq)


    Price index data
    ================
        U.S. Department Of Labor, Bureau of Labor Statistics, Washington, D.C. 20212
        Consumer Price Index, All Urban Consumers - (CPI-U), U.S. city average
        ftp://ftp.bls.gov/pub/special.requests/cpi/cpiai.txt



*/


/*
    Dataset with price index (CPI-U)
    ('datalines' cannot go in a macro) */

data work.cpi;
input year levelCPI;
datalines;
1913    9.9
1914    10
1915    10.1
1916    10.9
1917    12.8
1918    15.1
1919    17.3
1920    20
1921    17.9
1922    16.8
1923    17.1
1924    17.1
1925    17.5
1926    17.7
1927    17.4
1928    17.1
1929    17.1
1930    16.7
1931    15.2
1932    13.7
1933    13
1934    13.4
1935    13.7
1936    13.9
1937    14.4
1938    14.1
1939    13.9
1940    14
1941    14.7
1942    16.3
1943    17.3
1944    17.6
1945    18
1946    19.5
1947    22.3
1948    24.1
1949    23.8
1950    24.1
1951    26
1952    26.5
1953    26.7
1954    26.9
1955    26.8
1956    27.2
1957    28.1
1958    28.9
1959    29.1
1960    29.6
1961    29.9
1962    30.2
1963    30.6
1964    31
1965    31.5
1966    32.4
1967    33.4
1968    34.8
1969    36.7
1970    38.8
1971    40.5
1972    41.8
1973    44.4
1974    49.3
1975    53.8
1976    56.9
1977    60.6
1978    65.2
1979    72.6
1980    82.4
1981    90.9
1982    96.5
1983    99.6
1984    103.9
1985    107.6
1986    109.6
1987    113.6
1988    118.3
1989    124
1990    130.7
1991    136.2
1992    140.3
1993    144.5
1994    148.2
1995    152.4
1996    156.9
1997    160.5
1998    163
1999    166.6
2000    172.2
2001    177.1
2002    179.9
2003    184
2004    188.9
2005    195.3
2006    201.6
2007    207.342
2008    215.303
2009    214.537
2010    218.056
2011    224.939
2012    229.594
2013    232.957
2014    236.736
;

/*  Macro computedAdjusted is a macro that is called by main macro cpiAdjust
    and is called for each of the variables passed to cpiAdjust in 'variables'

    This macro generates new variable as old variable divided by relative CPI index
    For example: sale_adj = sale/relativeBase
    */

%macro computedAdjusted(var);
    &var._adj = &var/relativeBase;
%mend;



%macro cpiAdjust(dsin=, dsout=, baseyear=, variables=);

    %array(vars, VALUES=&variables);

    /*  Get price index for base year */

    data _null_;
    set work.cpi;
    if year eq &baseyear then CALL SYMPUT("baseCPI",levelCPI);
    run;

    /*  Append relativeBase to dataset
        (divide year's price level by base year '&baseCPI') */

    proc sql;

        create table work.cpi_temp as
        select a.*, b.levelCPI/&baseCPI as relativeBase
        from
            &dsin a
        LEFT JOIN
            work.cpi b
        on
            a.fyear = b.year;
    quit;

    /*  Create output dataset, with variables adjusted */

    data &dsout;
    set work.cpi_temp;
        %DO_OVER(vars, MACRO = computedAdjusted);
    run;

    /*  Clean up */

    proc datasets library=work;
       delete cpi_temp;
    run;

%mend ;



/*  Invoke macro */

%cpiAdjust(dsin=mine.compu, dsout=work.sample_adj, baseyear=1990, variables=che at dltt sale oibdp xint txt dvc csho dlc xrd ceq capx
     aqc wcap prcc_f cshpri ib txdi itci sstk prstkc dltis dltr);

quit;

data cpi_adj1;
set sample_adj;
drop che at dltt sale oibdp xint txt dvc csho dlc xrd ceq capx aqc wcap prcc_f  cshpri ib txdi itci sstk prstkc dltis dltr;
run;

data cpi_adj;
set cpi_adj1;
rename che_adj = che;
rename at_adj = at;
rename dltt_adj = dltt;
rename sale_adj = sale;
rename oibdp_adj = oibdp;
rename xint_adj = xint;
rename txt_adj = txt;
rename dvc_adj = dvc;
rename csho_adj = csho;
rename dlc_adj = dlc;
rename xrd_adj = xrd;
rename ceq_adj = ceq;
rename capx_adj = capx;
rename aqc_adj = aqc;
rename wcap_adj = wcap;
rename prcc_f_adj = prcc_f;
rename cshpri_adj = cshpri;
rename ib_adj = ib;
rename txdi_adj = txdi;
rename itci_adj = itci;
rename sstk_adj = sstk;
rename prstkc_adj = prstkc;
rename dltis_adj = dltis;
rename dltr_adj = dltr;
run;

/*merge with sic code*/
proc sql;
        create table cash1 as
        select a.*, b.sic as siccd from cpi_adj as a left join mine.sic as b
        on a.gvkey = b.gvkey and a.datadate = b.datadate;
quit;


/*create industry dummies*/
data cash1_1;
    set cash1;

if 0100 <= siccd <= 0199 or
   0200 <= siccd <= 0299 or
   0700 <= siccd <= 0799 or
   0910 <= siccd <= 0919 or
   2048 <= siccd <= 2048  then ind_48 = 1;


if 2000 <= siccd <= 2009 or
   2010 <= siccd <= 2019 or
   2020 <= siccd <= 2029 or
   2030 <= siccd <= 2039 or
   2040 <= siccd <= 2046 or
   2050 <= siccd <= 2059 or
   2060 <= siccd <= 2063 or
   2070 <= siccd <= 2079 or
   2090 <= siccd <= 2092 or
   2095 <= siccd <= 2095 or
   2098 <= siccd <= 2099 then ind_48 = 2;


if 2064 <= siccd <= 2068 or
   2086 <= siccd <= 2086 or
   2087 <= siccd <= 2087 or
   2096 <= siccd <= 2096 or
   2097 <= siccd <= 2097 then ind_48 = 3;


if 2080 <= siccd <= 2080 or
   2082 <= siccd <= 2082 or
   2083 <= siccd <= 2083 or
   2084 <= siccd <= 2084 or
   2085 <= siccd <= 2085 then ind_48 = 4;


if 2100 <= siccd <= 2199 then ind_48 = 5;


if 0920 <= siccd <= 0999 or
   3650 <= siccd <= 3651 or
   3652 <= siccd <= 3652 or
   3732 <= siccd <= 3732 or
   3930 <= siccd <= 3931 or
   3940 <= siccd <= 3949 then ind_48 = 6;


if 7800 <= siccd <= 7829 or
   7830 <= siccd <= 7833 or
   7840 <= siccd <= 7841 or
   7900 <= siccd <= 7900 or
   7910 <= siccd <= 7911 or
   7920 <= siccd <= 7929 or
   7930 <= siccd <= 7933 or
   7940 <= siccd <= 7949 or
   7980 <= siccd <= 7980 or
   7990 <= siccd <= 7999 then ind_48 = 7;


if 2700 <= siccd <= 2709 or
   2710 <= siccd <= 2719 or
   2720 <= siccd <= 2729 or
   2730 <= siccd <= 2739 or
   2740 <= siccd <= 2749 or
   2770 <= siccd <= 2771 or
   2780 <= siccd <= 2789 or
   2790 <= siccd <= 2799 then ind_48 = 8;


if 2047 <= siccd <= 2047 or
   2391 <= siccd <= 2392 or
   2510 <= siccd <= 2519 or
   2590 <= siccd <= 2599 or
   2840 <= siccd <= 2843 or
   2844 <= siccd <= 2844 or
   3160 <= siccd <= 3161 or
   3170 <= siccd <= 3171 or
   3172 <= siccd <= 3172 or
   3190 <= siccd <= 3199 or
   3229 <= siccd <= 3229 or
   3260 <= siccd <= 3260 or
   3262 <= siccd <= 3263 or
   3269 <= siccd <= 3269 or
   3230 <= siccd <= 3231 or
   3630 <= siccd <= 3639 or
   3750 <= siccd <= 3751 or
   3800 <= siccd <= 3800 or
   3860 <= siccd <= 3861 or
   3870 <= siccd <= 3873 or
   3910 <= siccd <= 3911 or
   3914 <= siccd <= 3914 or
   3915 <= siccd <= 3915 or
   3960 <= siccd <= 3962 or
   3991 <= siccd <= 3991 or
   3995 <= siccd <= 3995 then ind_48 = 9;


if 2300 <= siccd <= 2390 or
   3020 <= siccd <= 3021 or
   3100 <= siccd <= 3111 or
   3130 <= siccd <= 3131 or
   3140 <= siccd <= 3149 or
   3150 <= siccd <= 3151 or
   3963 <= siccd <= 3965 then ind_48 = 10;


if 8000 <= siccd <= 8099 then ind_48 = 11;


if 3693 <= siccd <= 3693 or
   3840 <= siccd <= 3849 or
   3850 <= siccd <= 3851 then ind_48 = 12;


if 2830 <= siccd <= 2830 or
   2831 <= siccd <= 2831 or
   2833 <= siccd <= 2833 or
   2834 <= siccd <= 2834 or
   2835 <= siccd <= 2835 or
   2836 <= siccd <= 2836 then ind_48 = 13;


if 2800 <= siccd <= 2809 or
   2810 <= siccd <= 2819 or
   2820 <= siccd <= 2829 or
   2850 <= siccd <= 2859 or
   2860 <= siccd <= 2869 or
   2870 <= siccd <= 2879 or
   2890 <= siccd <= 2899 then ind_48 = 14;


if 3031 <= siccd <= 3031 or
   3041 <= siccd <= 3041 or
   3050 <= siccd <= 3053 or
   3060 <= siccd <= 3069 or
   3070 <= siccd <= 3079 or
   3080 <= siccd <= 3089 or
   3090 <= siccd <= 3099 then ind_48 = 15;


if 2200 <= siccd <= 2269 or
   2270 <= siccd <= 2279 or
   2280 <= siccd <= 2284 or
   2290 <= siccd <= 2295 or
   2297 <= siccd <= 2297 or
   2298 <= siccd <= 2298 or
   2299 <= siccd <= 2299 or
   2393 <= siccd <= 2395 or
   2397 <= siccd <= 2399 then ind_48 = 16;


if 0800 <= siccd <= 0899 or
   2400 <= siccd <= 2439 or
   2450 <= siccd <= 2459 or
   2490 <= siccd <= 2499 or
   2660 <= siccd <= 2661 or
   2950 <= siccd <= 2952 or
   3200 <= siccd <= 3200 or
   3210 <= siccd <= 3211 or
   3240 <= siccd <= 3241 or
   3250 <= siccd <= 3259 or
   3261 <= siccd <= 3261 or
   3264 <= siccd <= 3264 or
   3270 <= siccd <= 3275 or
   3280 <= siccd <= 3281 or
   3290 <= siccd <= 3293 or
   3295 <= siccd <= 3299 or
   3420 <= siccd <= 3429 or
   3430 <= siccd <= 3433 or
   3440 <= siccd <= 3441 or
   3442 <= siccd <= 3442 or
   3446 <= siccd <= 3446 or
   3448 <= siccd <= 3448 or
   3449 <= siccd <= 3449 or
   3450 <= siccd <= 3451 or
   3452 <= siccd <= 3452 or
   3490 <= siccd <= 3499 or
   3996 <= siccd <= 3996 then ind_48 = 17;


if 1500 <= siccd <= 1511 or
   1520 <= siccd <= 1529 or
   1530 <= siccd <= 1539 or
   1540 <= siccd <= 1549 or
   1600 <= siccd <= 1699 or
   1700 <= siccd <= 1799 then ind_48 = 18;


if 3300 <= siccd <= 3300 or
   3310 <= siccd <= 3317 or
   3320 <= siccd <= 3325 or
   3330 <= siccd <= 3339 or
   3340 <= siccd <= 3341 or
   3350 <= siccd <= 3357 or
   3360 <= siccd <= 3369 or
   3370 <= siccd <= 3379 or
   3390 <= siccd <= 3399 then ind_48 = 19;


if 3400 <= siccd <= 3400 or
   3443 <= siccd <= 3443 or
   3444 <= siccd <= 3444 or
   3460 <= siccd <= 3469 or
   3470 <= siccd <= 3479 then ind_48 = 20;


if 3510 <= siccd <= 3519 or
   3520 <= siccd <= 3529 or
   3530 <= siccd <= 3530 or
   3531 <= siccd <= 3531 or
   3532 <= siccd <= 3532 or
   3533 <= siccd <= 3533 or
   3534 <= siccd <= 3534 or
   3535 <= siccd <= 3535 or
   3536 <= siccd <= 3536 or
   3538 <= siccd <= 3538 or
   3540 <= siccd <= 3549 or
   3550 <= siccd <= 3559 or
   3560 <= siccd <= 3569 or
   3580 <= siccd <= 3580 or
   3581 <= siccd <= 3581 or
   3582 <= siccd <= 3582 or
   3585 <= siccd <= 3585 or
   3586 <= siccd <= 3586 or
   3589 <= siccd <= 3589 or
   3590 <= siccd <= 3599 then ind_48 = 21;


if 3600 <= siccd <= 3600 or
   3610 <= siccd <= 3613 or
   3620 <= siccd <= 3621 or
   3623 <= siccd <= 3629 or
   3640 <= siccd <= 3644 or
   3645 <= siccd <= 3645 or
   3646 <= siccd <= 3646 or
   3648 <= siccd <= 3649 or
   3660 <= siccd <= 3660 or
   3690 <= siccd <= 3690 or
   3691 <= siccd <= 3692 or
   3699 <= siccd <= 3699 then ind_48 = 22;


if 2296 <= siccd <= 2296 or
   2396 <= siccd <= 2396 or
   3010 <= siccd <= 3011 or
   3537 <= siccd <= 3537 or
   3647 <= siccd <= 3647 or
   3694 <= siccd <= 3694 or
   3700 <= siccd <= 3700 or
   3710 <= siccd <= 3710 or
   3711 <= siccd <= 3711 or
   3713 <= siccd <= 3713 or
   3714 <= siccd <= 3714 or
   3715 <= siccd <= 3715 or
   3716 <= siccd <= 3716 or
   3792 <= siccd <= 3792 or
   3790 <= siccd <= 3791 or
   3799 <= siccd <= 3799 then ind_48 = 23;


if 3720 <= siccd <= 3720 or
   3721 <= siccd <= 3721 or
   3723 <= siccd <= 3724 or
   3725 <= siccd <= 3725 or
   3728 <= siccd <= 3729 then ind_48 = 24;


if 3730 <= siccd <= 3731 or
   3740 <= siccd <= 3743 then ind_48 = 25;


if 3760 <= siccd <= 3769 or
   3795 <= siccd <= 3795 or
   3480 <= siccd <= 3489 then ind_48 = 26;


if 1040 <= siccd <= 1049 then ind_48 = 27;


if 1000 <= siccd <= 1009 or
   1010 <= siccd <= 1019 or
   1020 <= siccd <= 1029 or
   1030 <= siccd <= 1039 or
   1050 <= siccd <= 1059 or
   1060 <= siccd <= 1069 or
   1070 <= siccd <= 1079 or
   1080 <= siccd <= 1089 or
   1090 <= siccd <= 1099 or
   1100 <= siccd <= 1119 or
   1400 <= siccd <= 1499 then ind_48 = 28;


if 1200 <= siccd <= 1299 then ind_48 = 29;


if 1300 <= siccd <= 1300 or
   1310 <= siccd <= 1319 or
   1320 <= siccd <= 1329 or
   1330 <= siccd <= 1339 or
   1370 <= siccd <= 1379 or
   1380 <= siccd <= 1380 or
   1381 <= siccd <= 1381 or
   1382 <= siccd <= 1382 or
   1389 <= siccd <= 1389 or
   2900 <= siccd <= 2912 or
   2990 <= siccd <= 2999 then ind_48 = 30;


if 4900 <= siccd <= 4900 or
   4910 <= siccd <= 4911 or
   4920 <= siccd <= 4922 or
   4923 <= siccd <= 4923 or
   4924 <= siccd <= 4925 or
   4930 <= siccd <= 4931 or
   4932 <= siccd <= 4932 or
   4939 <= siccd <= 4939 or
   4940 <= siccd <= 4942 then ind_48 = 31;


if 4800 <= siccd <= 4800 or
   4810 <= siccd <= 4813 or
   4820 <= siccd <= 4822 or
   4830 <= siccd <= 4839 or
   4840 <= siccd <= 4841 or
   4880 <= siccd <= 4889 or
   4890 <= siccd <= 4890 or
   4891 <= siccd <= 4891 or
   4892 <= siccd <= 4892 or
   4899 <= siccd <= 4899 then ind_48 = 32;


if 7020 <= siccd <= 7021 or
   7030 <= siccd <= 7033 or
   7200 <= siccd <= 7200 or
   7210 <= siccd <= 7212 or
   7214 <= siccd <= 7214 or
   7215 <= siccd <= 7216 or
   7217 <= siccd <= 7217 or
   7219 <= siccd <= 7219 or
   7220 <= siccd <= 7221 or
   7230 <= siccd <= 7231 or
   7240 <= siccd <= 7241 or
   7250 <= siccd <= 7251 or
   7260 <= siccd <= 7269 or
   7270 <= siccd <= 7290 or
   7291 <= siccd <= 7291 or
   7292 <= siccd <= 7299 or
   7395 <= siccd <= 7395 or
   7500 <= siccd <= 7500 or
   7520 <= siccd <= 7529 or
   7530 <= siccd <= 7539 or
   7540 <= siccd <= 7549 or
   7600 <= siccd <= 7600 or
   7620 <= siccd <= 7620 or
   7622 <= siccd <= 7622 or
   7623 <= siccd <= 7623 or
   7629 <= siccd <= 7629 or
   7630 <= siccd <= 7631 or
   7640 <= siccd <= 7641 or
   7690 <= siccd <= 7699 or
   8100 <= siccd <= 8199 or
   8200 <= siccd <= 8299 or
   8300 <= siccd <= 8399 or
   8400 <= siccd <= 8499 or
   8600 <= siccd <= 8699 or
   8800 <= siccd <= 8899 then ind_48 = 33;


if 2750 <= siccd <= 2759 or
   3993 <= siccd <= 3993 or
   7218 <= siccd <= 7218 or
   7300 <= siccd <= 7300 or
   7310 <= siccd <= 7319 or
   7320 <= siccd <= 7329 or
   7330 <= siccd <= 7339 or
   7340 <= siccd <= 7342 or
   7349 <= siccd <= 7349 or
   7350 <= siccd <= 7351 or
   7352 <= siccd <= 7352 or
   7353 <= siccd <= 7353 or
   7359 <= siccd <= 7359 or
   7360 <= siccd <= 7369 or
   7370 <= siccd <= 7372 or
   7374 <= siccd <= 7374 or
   7375 <= siccd <= 7375 or
   7376 <= siccd <= 7376 or
   7377 <= siccd <= 7377 or
   7378 <= siccd <= 7378 or
   7379 <= siccd <= 7379 or
   7380 <= siccd <= 7380 or
   7381 <= siccd <= 7382 or
   7383 <= siccd <= 7383 or
   7384 <= siccd <= 7384 or
   7385 <= siccd <= 7385 or
   7389 <= siccd <= 7390 or
   7391 <= siccd <= 7391 or
   7392 <= siccd <= 7392 or
   7393 <= siccd <= 7393 or
   7394 <= siccd <= 7394 or
   7396 <= siccd <= 7396 or
   7397 <= siccd <= 7397 or
   7399 <= siccd <= 7399 or
   7510 <= siccd <= 7519 or
   8700 <= siccd <= 8700 or
   8710 <= siccd <= 8713 or
   8720 <= siccd <= 8721 or
   8730 <= siccd <= 8734 or
   8740 <= siccd <= 8748 or
   8900 <= siccd <= 8910 or
   8911 <= siccd <= 8911 or
   8920 <= siccd <= 8999 then ind_48 = 34;


if 3570 <= siccd <= 3579 or
   3680 <= siccd <= 3680 or
   3681 <= siccd <= 3681 or
   3682 <= siccd <= 3682 or
   3683 <= siccd <= 3683 or
   3684 <= siccd <= 3684 or
   3685 <= siccd <= 3685 or
   3686 <= siccd <= 3686 or
   3687 <= siccd <= 3687 or
   3688 <= siccd <= 3688 or
   3689 <= siccd <= 3689 or
   3695 <= siccd <= 3695 or
   7373 <= siccd <= 7373 then ind_48 = 35;


if 3622 <= siccd <= 3622 or
   3661 <= siccd <= 3661 or
   3662 <= siccd <= 3662 or
   3663 <= siccd <= 3663 or
   3664 <= siccd <= 3664 or
   3665 <= siccd <= 3665 or
   3666 <= siccd <= 3666 or
   3669 <= siccd <= 3669 or
   3670 <= siccd <= 3679 or
   3810 <= siccd <= 3810 or
   3812 <= siccd <= 3812 then ind_48 = 36;


if 3811 <= siccd <= 3811 or
   3820 <= siccd <= 3820 or
   3821 <= siccd <= 3821 or
   3822 <= siccd <= 3822 or
   3823 <= siccd <= 3823 or
   3824 <= siccd <= 3824 or
   3825 <= siccd <= 3825 or
   3826 <= siccd <= 3826 or
   3827 <= siccd <= 3827 or
   3829 <= siccd <= 3829 or
   3830 <= siccd <= 3839 then ind_48 = 37;


if 2520 <= siccd <= 2549 or
   2600 <= siccd <= 2639 or
   2670 <= siccd <= 2699 or
   2760 <= siccd <= 2761 or
   3950 <= siccd <= 3955 then ind_48 = 38;


if 2440 <= siccd <= 2449 or
   2640 <= siccd <= 2659 or
   3220 <= siccd <= 3221 or
   3410 <= siccd <= 3412 then ind_48 = 39;


if 4000 <= siccd <= 4013 or
   4040 <= siccd <= 4049 or
   4100 <= siccd <= 4100 or
   4110 <= siccd <= 4119 or
   4120 <= siccd <= 4121 or
   4130 <= siccd <= 4131 or
   4140 <= siccd <= 4142 or
   4150 <= siccd <= 4151 or
   4170 <= siccd <= 4173 or
   4190 <= siccd <= 4199 or
   4200 <= siccd <= 4200 or
   4210 <= siccd <= 4219 or
   4220 <= siccd <= 4229 or
   4230 <= siccd <= 4231 or
   4240 <= siccd <= 4249 or
   4400 <= siccd <= 4499 or
   4500 <= siccd <= 4599 or
   4600 <= siccd <= 4699 or
   4700 <= siccd <= 4700 or
   4710 <= siccd <= 4712 or
   4720 <= siccd <= 4729 or
   4730 <= siccd <= 4739 or
   4740 <= siccd <= 4749 or
   4780 <= siccd <= 4780 or
   4782 <= siccd <= 4782 or
   4783 <= siccd <= 4783 or
   4784 <= siccd <= 4784 or
   4785 <= siccd <= 4785 or
   4789 <= siccd <= 4789 then ind_48 = 40;


if 5000 <= siccd <= 5000 or
   5010 <= siccd <= 5015 or
   5020 <= siccd <= 5023 or
   5030 <= siccd <= 5039 or
   5040 <= siccd <= 5042 or
   5043 <= siccd <= 5043 or
   5044 <= siccd <= 5044 or
   5045 <= siccd <= 5045 or
   5046 <= siccd <= 5046 or
   5047 <= siccd <= 5047 or
   5048 <= siccd <= 5048 or
   5049 <= siccd <= 5049 or
   5050 <= siccd <= 5059 or
   5060 <= siccd <= 5060 or
   5063 <= siccd <= 5063 or
   5064 <= siccd <= 5064 or
   5065 <= siccd <= 5065 or
   5070 <= siccd <= 5078 or
   5080 <= siccd <= 5080 or
   5081 <= siccd <= 5081 or
   5082 <= siccd <= 5082 or
   5083 <= siccd <= 5083 or
   5084 <= siccd <= 5084 or
   5085 <= siccd <= 5085 or
   5086 <= siccd <= 5087 or
   5088 <= siccd <= 5088 or
   5090 <= siccd <= 5090 or
   5091 <= siccd <= 5092 or
   5093 <= siccd <= 5093 or
   5094 <= siccd <= 5094 or
   5099 <= siccd <= 5099 or
   5100 <= siccd <= 5100 or
   5110 <= siccd <= 5113 or
   5120 <= siccd <= 5122 or
   5130 <= siccd <= 5139 or
   5140 <= siccd <= 5149 or
   5150 <= siccd <= 5159 or
   5160 <= siccd <= 5169 or
   5170 <= siccd <= 5172 or
   5180 <= siccd <= 5182 or
   5190 <= siccd <= 5199 then ind_48 = 41;


if 5200 <= siccd <= 5200 or
   5210 <= siccd <= 5219 or
   5220 <= siccd <= 5229 or
   5230 <= siccd <= 5231 or
   5250 <= siccd <= 5251 or
   5260 <= siccd <= 5261 or
   5270 <= siccd <= 5271 or
   5300 <= siccd <= 5300 or
   5310 <= siccd <= 5311 or
   5320 <= siccd <= 5320 or
   5330 <= siccd <= 5331 or
   5334 <= siccd <= 5334 or
   5340 <= siccd <= 5349 or
   5390 <= siccd <= 5399 or
   5400 <= siccd <= 5400 or
   5410 <= siccd <= 5411 or
   5412 <= siccd <= 5412 or
   5420 <= siccd <= 5429 or
   5430 <= siccd <= 5439 or
   5440 <= siccd <= 5449 or
   5450 <= siccd <= 5459 or
   5460 <= siccd <= 5469 or
   5490 <= siccd <= 5499 or
   5500 <= siccd <= 5500 or
   5510 <= siccd <= 5529 or
   5530 <= siccd <= 5539 or
   5540 <= siccd <= 5549 or
   5550 <= siccd <= 5559 or
   5560 <= siccd <= 5569 or
   5570 <= siccd <= 5579 or
   5590 <= siccd <= 5599 or
   5600 <= siccd <= 5699 or
   5700 <= siccd <= 5700 or
   5710 <= siccd <= 5719 or
   5720 <= siccd <= 5722 or
   5730 <= siccd <= 5733 or
   5734 <= siccd <= 5734 or
   5735 <= siccd <= 5735 or
   5736 <= siccd <= 5736 or
   5750 <= siccd <= 5799 or
   5900 <= siccd <= 5900 or
   5910 <= siccd <= 5912 or
   5920 <= siccd <= 5929 or
   5930 <= siccd <= 5932 or
   5940 <= siccd <= 5940 or
   5941 <= siccd <= 5941 or
   5942 <= siccd <= 5942 or
   5943 <= siccd <= 5943 or
   5944 <= siccd <= 5944 or
   5945 <= siccd <= 5945 or
   5946 <= siccd <= 5946 or
   5947 <= siccd <= 5947 or
   5948 <= siccd <= 5948 or
   5949 <= siccd <= 5949 or
   5950 <= siccd <= 5959 or
   5960 <= siccd <= 5969 or
   5970 <= siccd <= 5979 or
   5980 <= siccd <= 5989 or
   5990 <= siccd <= 5990 or
   5992 <= siccd <= 5992 or
   5993 <= siccd <= 5993 or
   5994 <= siccd <= 5994 or
   5995 <= siccd <= 5995 or
   5999 <= siccd <= 5999 then ind_48 = 42;


if 5800 <= siccd <= 5819 or
   5820 <= siccd <= 5829 or
   5890 <= siccd <= 5899 or
   7000 <= siccd <= 7000 or
   7010 <= siccd <= 7019 or
   7040 <= siccd <= 7049 or
   7213 <= siccd <= 7213 then ind_48 = 43;


if 6000 <= siccd <= 6000 or
   6010 <= siccd <= 6019 or
   6020 <= siccd <= 6020 or
   6021 <= siccd <= 6021 or
   6022 <= siccd <= 6022 or
   6023 <= siccd <= 6024 or
   6025 <= siccd <= 6025 or
   6026 <= siccd <= 6026 or
   6027 <= siccd <= 6027 or
   6028 <= siccd <= 6029 or
   6030 <= siccd <= 6036 or
   6040 <= siccd <= 6059 or
   6060 <= siccd <= 6062 or
   6080 <= siccd <= 6082 or
   6090 <= siccd <= 6099 or
   6100 <= siccd <= 6100 or
   6110 <= siccd <= 6111 or
   6112 <= siccd <= 6113 or
   6120 <= siccd <= 6129 or
   6130 <= siccd <= 6139 or
   6140 <= siccd <= 6149 or
   6150 <= siccd <= 6159 or
   6160 <= siccd <= 6169 or
   6170 <= siccd <= 6179 or
   6190 <= siccd <= 6199 then ind_48 = 44;


if 6300 <= siccd <= 6300 or
   6310 <= siccd <= 6319 or
   6320 <= siccd <= 6329 or
   6330 <= siccd <= 6331 or
   6350 <= siccd <= 6351 or
   6360 <= siccd <= 6361 or
   6370 <= siccd <= 6379 or
   6390 <= siccd <= 6399 or
   6400 <= siccd <= 6411 then ind_48 = 45;


if 6500 <= siccd <= 6500 or
   6510 <= siccd <= 6510 or
   6512 <= siccd <= 6512 or
   6513 <= siccd <= 6513 or
   6514 <= siccd <= 6514 or
   6515 <= siccd <= 6515 or
   6517 <= siccd <= 6519 or
   6520 <= siccd <= 6529 or
   6530 <= siccd <= 6531 or
   6532 <= siccd <= 6532 or
   6540 <= siccd <= 6541 or
   6550 <= siccd <= 6553 or
   6590 <= siccd <= 6599 or
   6610 <= siccd <= 6611 then ind_48 = 46;


if 6200 <= siccd <= 6299 or
   6700 <= siccd <= 6700 or
   6710 <= siccd <= 6719 or
   6720 <= siccd <= 6722 or
   6723 <= siccd <= 6723 or
   6724 <= siccd <= 6724 or
   6725 <= siccd <= 6725 or
   6730 <= siccd <= 6733 or
   6740 <= siccd <= 6779 or
   6790 <= siccd <= 6791 or
   6792 <= siccd <= 6792 or
   6793 <= siccd <= 6793 or
   6794 <= siccd <= 6794 or
   6795 <= siccd <= 6795 or
   6798 <= siccd <= 6798 or
   6799 <= siccd <= 6799 then ind_48 = 47;


if 3990 <= siccd <= 3990 or
   3992 <= siccd <= 3994 or
   3997 <= siccd <= 3999 or
   4950 <= siccd <= 4959 or
   4960 <= siccd <= 4961 or
   4970 <= siccd <= 4971 or
   4990 <= siccd <= 4991 or
   9900 <= siccd <= 9999 then ind_48 = 48;


length ind_48_name $5;

if ind_48 = 1 then ind_48_name = 'Agric';
if ind_48 = 2 then ind_48_name = 'Food';
if ind_48 = 3 then ind_48_name = 'Soda';
if ind_48 = 4 then ind_48_name = 'Beer';
if ind_48 = 5 then ind_48_name = 'Smoke';
if ind_48 = 6 then ind_48_name = 'Toys';
if ind_48 = 7 then ind_48_name = 'Fun';
if ind_48 = 8 then ind_48_name = 'Books';
if ind_48 = 9 then ind_48_name = 'Hshld';
if ind_48 = 10 then ind_48_name = 'Clths';
if ind_48 = 11 then ind_48_name = 'Hlth';
if ind_48 = 12 then ind_48_name = 'MedEq';
if ind_48 = 13 then ind_48_name = 'Drugs';
if ind_48 = 14 then ind_48_name = 'Chems';
if ind_48 = 15 then ind_48_name = 'Rubbr';
if ind_48 = 16 then ind_48_name = 'Txtls';
if ind_48 = 17 then ind_48_name = 'BldMt';
if ind_48 = 18 then ind_48_name = 'Cnstr';
if ind_48 = 19 then ind_48_name = 'Steel';
if ind_48 = 20 then ind_48_name = 'FabPr';
if ind_48 = 21 then ind_48_name = 'Mach';
if ind_48 = 22 then ind_48_name = 'ElcEq';
if ind_48 = 23 then ind_48_name = 'Autos';
if ind_48 = 24 then ind_48_name = 'Aero';
if ind_48 = 25 then ind_48_name = 'Ships';
if ind_48 = 26 then ind_48_name = 'Guns';
if ind_48 = 27 then ind_48_name = 'Gold';
if ind_48 = 28 then ind_48_name = 'Mines';
if ind_48 = 29 then ind_48_name = 'Coal';
if ind_48 = 30 then ind_48_name = 'Oil';
if ind_48 = 31 then ind_48_name = 'Util';
if ind_48 = 32 then ind_48_name = 'Telcm';
if ind_48 = 33 then ind_48_name = 'PerSv';
if ind_48 = 34 then ind_48_name = 'BusSv';
if ind_48 = 35 then ind_48_name = 'Comps';
if ind_48 = 36 then ind_48_name = 'Chips';
if ind_48 = 37 then ind_48_name = 'LabEq';
if ind_48 = 38 then ind_48_name = 'Paper';
if ind_48 = 39 then ind_48_name = 'Boxes';
if ind_48 = 40 then ind_48_name = 'Trans';
if ind_48 = 41 then ind_48_name = 'Whlsl';
if ind_48 = 42 then ind_48_name = 'Rtail';
if ind_48 = 43 then ind_48_name = 'Meals';
if ind_48 = 44 then ind_48_name = 'Banks';
if ind_48 = 45 then ind_48_name = 'Insur';
if ind_48 = 46 then ind_48_name = 'RlEst';
if ind_48 = 47 then ind_48_name = 'Fin';
if ind_48 = 48 then ind_48_name = 'Other';
run;


/*Code for making industry dummies*/

*option errorabend;
*option merror mlogic mprint symbolgen;
*option nonotes nosource nosource2;
*option notes source source2;
*option logic print symbolgen;

/********************************************************************************
        Author:         Ed deHaan, derived from work of unknown authors

        Macro:          ind_ff48

        Purpose:        to assign Fama French industry codes

        Versions:       1.0 -   7/21/10   - original version
                                1.1     -       11/19/10  - redid all codes based on updated FF classification


        Notes:          48 Industry classification codes obtained from French's website in Nov. 2010
                                http://mba.tuck.dartmouth.edu/pages/faculty/ken.french/data_library.html


--------------------------------------------

Generates Fama-French industry codes based on four-digit SIC codes.


Outputs the original dataset with appended industry code information:

        '&ind_code'     = count variable of industry codes from 1 through 48
        'FF_IND'                = text variable with name of the fama-french industry
        '&bin_var.#'    = 48 individual binary variables, one for each industry
        '_&global'              = global macro variable to include call 48 industry dummies

--------------------------------------------


        Required INPUT parameters:
                dset                    -       input dataset name
                sic                             -       four-digit sic code variable name
                outp                    -       output dataset
                bin_var                 -       prefix for industry binary variables
                ind_code                -       name of count variable for industry codes 1 through 48
                global                  -       name of global macro variable to call all 48 industry dummies

        Optional INPUT parameters





********************************************************************************/


%let _industry_fe=      i1 i2 i3 i4 i5 i6 i7 i8 i9
                                        i10 i11 i12 i13 i14 i15 i16 i17 i18 i19
                                        i20 i21 i22 i23 i24 i25 i26 i27 i28 i29
                                        i30 i31 i32 i33 i34 i35 i36 i37 i38 i39
                                        i40 i41 i42 i43 i44 i45 i46 i47 i48;

%macro ind_ff48 (dset, outp, sic, bin_var, ind_code );

********** FF Ind Codes Macro **********;



data &outp;
        set &dset;

        indus2=int(&sic/100);
        indus3=int(&sic/10);

* 1 Agric  Agriculture;
          if &sic ge 0100 and &sic le 0199  then FF_IND='AGRIC';
          if &sic ge 0200 and &sic le 0299  then FF_IND='AGRIC';
          if &sic ge 0700 and &sic le 0799  then FF_IND='AGRIC';
          if &sic ge 0910 and &sic le 0919  then FF_IND='AGRIC';
          if &sic ge 2048 and &sic le 2048  then FF_IND='AGRIC';
        if FF_IND='AGRIC' then &ind_code=1;

* 2 Food   Food Products;
          if &sic ge 2000 and &sic le 2009  then FF_IND='FOOD';
          if &sic ge 2010 and &sic le 2019  then FF_IND='FOOD';
          if &sic ge 2020 and &sic le 2029  then FF_IND='FOOD';
          if &sic ge 2030 and &sic le 2039  then FF_IND='FOOD';
          if &sic ge 2040 and &sic le 2046  then FF_IND='FOOD';
          if &sic ge 2050 and &sic le 2059  then FF_IND='FOOD';
          if &sic ge 2060 and &sic le 2063  then FF_IND='FOOD';
          if &sic ge 2070 and &sic le 2079  then FF_IND='FOOD';
          if &sic ge 2090 and &sic le 2092  then FF_IND='FOOD';
          if &sic ge 2095 and &sic le 2095  then FF_IND='FOOD';
          if &sic ge 2098 and &sic le 2099  then FF_IND='FOOD';
        if FF_IND='FOOD' then &ind_code=2;

* 3 Soda   Candy & Soda;
          if &sic ge 2064 and &sic le 2068  then FF_IND='SODA';
          if &sic ge 2086 and &sic le 2086  then FF_IND='SODA';
          if &sic ge 2087 and &sic le 2087  then FF_IND='SODA';
          if &sic ge 2096 and &sic le 2096  then FF_IND='SODA';
          if &sic ge 2097 and &sic le 2097  then FF_IND='SODA';
        if FF_IND='SODA' then &ind_code=3;

* 4 Beer   Beer & Liquor;
          if &sic ge 2080 and &sic le 2080  then FF_IND='BEER';
          if &sic ge 2082 and &sic le 2082  then FF_IND='BEER';
          if &sic ge 2083 and &sic le 2083  then FF_IND='BEER';
          if &sic ge 2084 and &sic le 2084  then FF_IND='BEER';
          if &sic ge 2085 and &sic le 2085  then FF_IND='BEER';
        if FF_IND='BEER' then &ind_code=4;

* 5 Smoke  Tobacco Products;
          if &sic ge 2100 and &sic le 2199  then FF_IND='SMOKE';
        if FF_IND='SMOKE' then &ind_code=5;

* 6 Toys   Recreation;
          if &sic ge 0920 and &sic le 0999  then FF_IND='TOYS';
          if &sic ge 3650 and &sic le 3651  then FF_IND='TOYS';
          if &sic ge 3652 and &sic le 3652  then FF_IND='TOYS';
          if &sic ge 3732 and &sic le 3732   then FF_IND='TOYS';
          if &sic ge 3930 and &sic le 3931   then FF_IND='TOYS';
          if &sic ge 3940 and &sic le 3949   then FF_IND='TOYS';
        if FF_IND='TOYS' then &ind_code=6;

* 7 Fun    Entertainment;
          if &sic ge 7800 and &sic le 7829   then FF_IND='FUN';
          if &sic ge  7830 and &sic le 7833   then FF_IND='FUN';
          if &sic ge 7840 and &sic le 7841   then FF_IND='FUN';
          if &sic ge 7900 and &sic le 7900   then FF_IND='FUN';
          if &sic ge 7910 and &sic le 7911   then FF_IND='FUN';
          if &sic ge 7920 and &sic le 7929   then FF_IND='FUN';
          if &sic ge 7930 and &sic le 7933   then FF_IND='FUN';
          if &sic ge 7940 and &sic le 7949   then FF_IND='FUN';
          if &sic ge 7980 and &sic le 7980   then FF_IND='FUN';
          if &sic ge 7990 and &sic le 7999   then FF_IND='FUN';
        if FF_IND='FUN' then &ind_code=7;

* 8 Books  Printing and Publishing;
          if &sic ge 2700 and &sic le 2709   then FF_IND='BOOKS';
          if &sic ge 2710 and &sic le 2719   then FF_IND='BOOKS';
          if &sic ge 2720 and &sic le 2729   then FF_IND='BOOKS';
          if &sic ge 2730 and &sic le 2739   then FF_IND='BOOKS';
          if &sic ge 2740 and &sic le 2749   then FF_IND='BOOKS';
          if &sic ge 2770 and &sic le 2771   then FF_IND='BOOKS';
          if &sic ge 2780 and &sic le 2789   then FF_IND='BOOKS';
          if &sic ge 2790 and &sic le 2799   then FF_IND='BOOKS';
        if FF_IND='BOOKS' then &ind_code=8;

* 9 Hshld  Consumer Goods;
          if &sic ge 2047 and &sic le 2047   then FF_IND='HSHLD';
          if &sic ge 2391 and &sic le 2392   then FF_IND='HSHLD';
          if &sic ge 2510 and &sic le 2519   then FF_IND='HSHLD';
          if &sic ge 2590 and &sic le 2599   then FF_IND='HSHLD';
          if &sic ge 2840 and &sic le 2843   then FF_IND='HSHLD';
          if &sic ge 2844 and &sic le 2844   then FF_IND='HSHLD';
          if &sic ge 3160 and &sic le 3161   then FF_IND='HSHLD';
          if &sic ge 3170 and &sic le 3171   then FF_IND='HSHLD';
          if &sic ge 3172 and &sic le 3172   then FF_IND='HSHLD';
          if &sic ge 3190 and &sic le 3199   then FF_IND='HSHLD';
          if &sic ge 3229 and &sic le 3229   then FF_IND='HSHLD';
          if &sic ge 3260 and &sic le 3260   then FF_IND='HSHLD';
          if &sic ge 3262 and &sic le 3263   then FF_IND='HSHLD';
          if &sic ge 3269 and &sic le 3269   then FF_IND='HSHLD';
          if &sic ge 3230 and &sic le 3231   then FF_IND='HSHLD';
          if &sic ge 3630 and &sic le 3639   then FF_IND='HSHLD';
          if &sic ge 3750 and &sic le 3751   then FF_IND='HSHLD';
          if &sic ge 3800 and &sic le 3800   then FF_IND='HSHLD';
          if &sic ge 3860 and &sic le 3861   then FF_IND='HSHLD';
          if &sic ge 3870 and &sic le 3873   then FF_IND='HSHLD';
          if &sic ge 3910 and &sic le 3911   then FF_IND='HSHLD';
          if &sic ge 3914 and &sic le 3914   then FF_IND='HSHLD';
          if &sic ge 3915 and &sic le 3915   then FF_IND='HSHLD';
          if &sic ge 3960 and &sic le 3962   then FF_IND='HSHLD';
          if &sic ge 3991 and &sic le 3991   then FF_IND='HSHLD';
          if &sic ge 3995 and &sic le 3995   then FF_IND='HSHLD';
        if FF_IND='HSHLD' then &ind_code=9;

*10 Clths  Apparel;
          if &sic ge 2300 and &sic le 2390   then FF_IND='CLTHS';
          if &sic ge 3020 and &sic le 3021   then FF_IND='CLTHS';
          if &sic ge 3100 and &sic le 3111   then FF_IND='CLTHS';
          if &sic ge 3130 and &sic le 3131   then FF_IND='CLTHS';
          if &sic ge 3140 and &sic le 3149   then FF_IND='CLTHS';
          if &sic ge 3150 and &sic le 3151   then FF_IND='CLTHS';
          if &sic ge 3963 and &sic le 3965   then FF_IND='CLTHS';
        if FF_IND='CLTHS' then &ind_code=10;

*11 Hlth   Healthcare;
          if &sic ge 8000 and &sic le 8099   then FF_IND='HLTH';
        if FF_IND='HLTH' then &ind_code=11;

*12 MedEq  Medical Equipment;
          if &sic ge 3693 and &sic le 3693   then FF_IND='MEDEQ';
          if &sic ge 3840 and &sic le 3849   then FF_IND='MEDEQ';
          if &sic ge 3850 and &sic le 3851   then FF_IND='MEDEQ';
        if FF_IND='MEDEQ' then &ind_code=12;

*13 Drugs  Pharmaceutical Products;
          if &sic ge 2830 and &sic le 2830   then FF_IND='DRUGS';
          if &sic ge 2831 and &sic le 2831   then FF_IND='DRUGS';
          if &sic ge 2833 and &sic le 2833   then FF_IND='DRUGS';
          if &sic ge 2834 and &sic le 2834   then FF_IND='DRUGS';
          if &sic ge 2835 and &sic le 2835   then FF_IND='DRUGS';
          if &sic ge 2836 and &sic le 2836   then FF_IND='DRUGS';
        if FF_IND='DRUGS' then &ind_code=13;

*14 Chems  Chemicals;
          if &sic ge 2800 and &sic le 2809   then FF_IND='CHEM';
          if &sic ge 2810 and &sic le 2819   then FF_IND='CHEM';
          if &sic ge 2820 and &sic le 2829   then FF_IND='CHEM';
          if &sic ge 2850 and &sic le 2859   then FF_IND='CHEM';
          if &sic ge 2860 and &sic le 2869   then FF_IND='CHEM';
          if &sic ge 2870 and &sic le 2879   then FF_IND='CHEM';
          if &sic ge 2890 and &sic le 2899   then FF_IND='CHEM';
        if FF_IND='CHEM' then &ind_code=14;

*15 Rubbr  Rubber and Plastic Products;
          if &sic ge 3031 and &sic le 3031   then FF_IND='RUBBR';
          if &sic ge 3041 and &sic le 3041   then FF_IND='RUBBR';
          if &sic ge 3050 and &sic le 3053   then FF_IND='RUBBR';
          if &sic ge 3060 and &sic le 3069   then FF_IND='RUBBR';
          if &sic ge 3070 and &sic le 3079   then FF_IND='RUBBR';
          if &sic ge 3080 and &sic le 3089   then FF_IND='RUBBR';
          if &sic ge 3090 and &sic le 3099   then FF_IND='RUBBR';
        if FF_IND='RUBBR' then &ind_code=15;

*16 Txtls  Textiles;
          if &sic ge 2200 and &sic le 2269   then FF_IND='TXTLS';
          if &sic ge 2270 and &sic le 2279   then FF_IND='TXTLS';
          if &sic ge 2280 and &sic le 2284   then FF_IND='TXTLS';
          if &sic ge 2290 and &sic le 2295   then FF_IND='TXTLS';
          if &sic ge 2297 and &sic le 2297   then FF_IND='TXTLS';
          if &sic ge 2298 and &sic le 2298   then FF_IND='TXTLS';
          if &sic ge 2299 and &sic le 2299   then FF_IND='TXTLS';
          if &sic ge 2393 and &sic le 2395   then FF_IND='TXTLS';
          if &sic ge 2397 and &sic le 2399   then FF_IND='TXTLS';
        if FF_IND='TXTLS' then &ind_code=16;

*17 BldMt  Construction Materials;
          if &sic ge 0800 and &sic le 0899   then FF_IND='BLDMT';
          if &sic ge 2400 and &sic le 2439   then FF_IND='BLDMT';
          if &sic ge 2450 and &sic le 2459   then FF_IND='BLDMT';
          if &sic ge 2490 and &sic le 2499   then FF_IND='BLDMT';
          if &sic ge 2660 and &sic le 2661   then FF_IND='BLDMT';
          if &sic ge 2950 and &sic le 2952   then FF_IND='BLDMT';
          if &sic ge 3200 and &sic le 3200   then FF_IND='BLDMT';
          if &sic ge 3210 and &sic le 3211   then FF_IND='BLDMT';
          if &sic ge 3240 and &sic le 3241   then FF_IND='BLDMT';
          if &sic ge 3250 and &sic le 3259   then FF_IND='BLDMT';
          if &sic ge 3261 and &sic le 3261   then FF_IND='BLDMT';
          if &sic ge 3264 and &sic le 3264   then FF_IND='BLDMT';
          if &sic ge 3270 and &sic le 3275   then FF_IND='BLDMT';
          if &sic ge 3280 and &sic le 3281   then FF_IND='BLDMT';
          if &sic ge 3290 and &sic le 3293   then FF_IND='BLDMT';
          if &sic ge 3295 and &sic le 3299   then FF_IND='BLDMT';
          if &sic ge 3420 and &sic le 3429   then FF_IND='BLDMT';
          if &sic ge 3430 and &sic le 3433   then FF_IND='BLDMT';
          if &sic ge 3440 and &sic le 3441   then FF_IND='BLDMT';
          if &sic ge 3442 and &sic le 3442   then FF_IND='BLDMT';
          if &sic ge 3446 and &sic le 3446   then FF_IND='BLDMT';
          if &sic ge 3448 and &sic le 3448   then FF_IND='BLDMT';
          if &sic ge 3449 and &sic le 3449   then FF_IND='BLDMT';
          if &sic ge 3450 and &sic le 3451   then FF_IND='BLDMT';
          if &sic ge 3452 and &sic le 3452   then FF_IND='BLDMT';
          if &sic ge 3490 and &sic le 3499   then FF_IND='BLDMT';
          if &sic ge 3996 and &sic le 3996   then FF_IND='BLDMT';
        if FF_IND='BLDMT' then &ind_code=17;

*18 Cnstr  Construction;
          if &sic ge 1500 and &sic le 1511   then FF_IND='CNSTR';
          if &sic ge 1520 and &sic le 1529   then FF_IND='CNSTR';
          if &sic ge 1530 and &sic le 1539   then FF_IND='CNSTR';
          if &sic ge 1540 and &sic le 1549   then FF_IND='CNSTR';
          if &sic ge 1600 and &sic le 1699   then FF_IND='CNSTR';
          if &sic ge 1700 and &sic le 1799   then FF_IND='CNSTR';
        if FF_IND='CNSTR' then &ind_code=18;

*19 Steel  Steel Works Etc;
          if &sic ge 3300 and &sic le 3300   then FF_IND='STEEL';
          if &sic ge 3310 and &sic le 3317   then FF_IND='STEEL';
          if &sic ge 3320 and &sic le 3325   then FF_IND='STEEL';
          if &sic ge 3330 and &sic le 3339   then FF_IND='STEEL';
          if &sic ge 3340 and &sic le 3341   then FF_IND='STEEL';
          if &sic ge 3350 and &sic le 3357   then FF_IND='STEEL';
          if &sic ge 3360 and &sic le 3369   then FF_IND='STEEL';
          if &sic ge 3370 and &sic le 3379   then FF_IND='STEEL';
          if &sic ge 3390 and &sic le 3399   then FF_IND='STEEL';
        if FF_IND='STEEL' then &ind_code=19;

*20 FabPr  Fabricated Products;
          if &sic ge 3400 and &sic le 3400   then FF_IND='FABPR';
          if &sic ge 3443 and &sic le 3443   then FF_IND='FABPR';
          if &sic ge 3444 and &sic le 3444   then FF_IND='FABPR';
          if &sic ge 3460 and &sic le 3469   then FF_IND='FABPR';
          if &sic ge 3470 and &sic le 3479   then FF_IND='FABPR';
        if FF_IND='FABPR' then &ind_code=20;

*21 Mach   Machinery;
          if &sic ge 3510 and &sic le 3519   then FF_IND='MACH';
          if &sic ge 3520 and &sic le 3529   then FF_IND='MACH';
          if &sic ge 3530 and &sic le 3530   then FF_IND='MACH';
          if &sic ge 3531 and &sic le 3531   then FF_IND='MACH';
          if &sic ge 3532 and &sic le 3532   then FF_IND='MACH';
          if &sic ge 3533 and &sic le 3533   then FF_IND='MACH';
          if &sic ge 3534 and &sic le 3534   then FF_IND='MACH';
          if &sic ge 3535 and &sic le 3535   then FF_IND='MACH';
          if &sic ge 3536 and &sic le 3536   then FF_IND='MACH';
          if &sic ge 3538 and &sic le 3538   then FF_IND='MACH';
          if &sic ge 3540 and &sic le 3549   then FF_IND='MACH';
          if &sic ge 3550 and &sic le 3559   then FF_IND='MACH';
          if &sic ge 3560 and &sic le 3569   then FF_IND='MACH';
          if &sic ge 3580 and &sic le 3580   then FF_IND='MACH';
          if &sic ge 3581 and &sic le 3581   then FF_IND='MACH';
          if &sic ge 3582 and &sic le 3582   then FF_IND='MACH';
          if &sic ge 3585 and &sic le 3585   then FF_IND='MACH';
          if &sic ge 3586 and &sic le 3586   then FF_IND='MACH';
          if &sic ge 3589 and &sic le 3589   then FF_IND='MACH';
          if &sic ge 3590 and &sic le 3599   then FF_IND='MACH';
        if FF_IND='MACH' then &ind_code=21;

*22 ElcEq  Electrical Equipment;
          if &sic ge 3600 and &sic le 3600   then FF_IND='ELCEQ';
          if &sic ge 3610 and &sic le 3613   then FF_IND='ELCEQ';
          if &sic ge 3620 and &sic le 3621   then FF_IND='ELCEQ';
          if &sic ge 3623 and &sic le 3629   then FF_IND='ELCEQ';
          if &sic ge 3640 and &sic le 3644   then FF_IND='ELCEQ';
          if &sic ge 3645 and &sic le 3645   then FF_IND='ELCEQ';
          if &sic ge 3646 and &sic le 3646   then FF_IND='ELCEQ';
          if &sic ge 3648 and &sic le 3649   then FF_IND='ELCEQ';
          if &sic ge 3660 and &sic le 3660   then FF_IND='ELCEQ';
          if &sic ge 3690 and &sic le 3690   then FF_IND='ELCEQ';
          if &sic ge 3691 and &sic le 3692   then FF_IND='ELCEQ';
          if &sic ge 3699 and &sic le 3699   then FF_IND='ELCEQ';
        if FF_IND='ELCEQ' then &ind_code=22;

*23 Autos  Automobiles and Trucks;
          if &sic ge 2296 and &sic le 2296   then FF_IND='AUTOS';
          if &sic ge 2396 and &sic le 2396   then FF_IND='AUTOS';
          if &sic ge 3010 and &sic le 3011   then FF_IND='AUTOS';
          if &sic ge 3537 and &sic le 3537   then FF_IND='AUTOS';
          if &sic ge 3647 and &sic le 3647   then FF_IND='AUTOS';
          if &sic ge 3694 and &sic le 3694   then FF_IND='AUTOS';
          if &sic ge 3700 and &sic le 3700   then FF_IND='AUTOS';
          if &sic ge 3710 and &sic le 3710   then FF_IND='AUTOS';
          if &sic ge 3711 and &sic le 3711   then FF_IND='AUTOS';
          if &sic ge 3713 and &sic le 3713   then FF_IND='AUTOS';
          if &sic ge 3714 and &sic le 3714   then FF_IND='AUTOS';
          if &sic ge 3715 and &sic le 3715   then FF_IND='AUTOS';
          if &sic ge 3716 and &sic le 3716   then FF_IND='AUTOS';
          if &sic ge 3792 and &sic le 3792   then FF_IND='AUTOS';
          if &sic ge 3790 and &sic le 3791   then FF_IND='AUTOS';
          if &sic ge 3799 and &sic le 3799   then FF_IND='AUTOS';
        if FF_IND='AUTOS' then &ind_code=23;

*24 Aero   Aircraft;
          if &sic ge 3720 and &sic le 3720   then FF_IND='AERO';
          if &sic ge 3721 and &sic le 3721   then FF_IND='AERO';
          if &sic ge 3723 and &sic le 3724   then FF_IND='AERO';
          if &sic ge 3725 and &sic le 3725   then FF_IND='AERO';
          if &sic ge 3728 and &sic le 3729   then FF_IND='AERO';
        if FF_IND='AERO' then &ind_code=24;

*25 Ships  Shipbuilding, Railroad Equipment;
          if &sic ge 3730 and &sic le 3731   then FF_IND='SHIPS';
          if &sic ge 3740 and &sic le 3743   then FF_IND='SHIPS';
        if FF_IND='SHIPS' then &ind_code=25;

*26 Guns   Defense;
          if &sic ge 3760 and &sic le 3769   then FF_IND='GUNS';
          if &sic ge 3795 and &sic le 3795   then FF_IND='GUNS';
          if &sic ge 3480 and &sic le 3489   then FF_IND='GUNS';
        if FF_IND='GUNS' then &ind_code=26;

*27 Gold   Precious Metals;
          if &sic ge 1040 and &sic le 1049   then FF_IND='GOLD';
        if FF_IND='GOLD' then &ind_code=27;

*28 Mines  Non and &sic le Metallic and Industrial Metal Mining;;
          if &sic ge 1000 and &sic le 1009   then FF_IND='MINES';
          if &sic ge 1010 and &sic le 1019   then FF_IND='MINES';
          if &sic ge 1020 and &sic le 1029   then FF_IND='MINES';
          if &sic ge 1030 and &sic le 1039   then FF_IND='MINES';
          if &sic ge 1050 and &sic le 1059   then FF_IND='MINES';
          if &sic ge 1060 and &sic le 1069   then FF_IND='MINES';
          if &sic ge 1070 and &sic le 1079   then FF_IND='MINES';
          if &sic ge 1080 and &sic le 1089   then FF_IND='MINES';
          if &sic ge 1090 and &sic le 1099   then FF_IND='MINES';
          if &sic ge 1100 and &sic le 1119   then FF_IND='MINES';
          if &sic ge 1400 and &sic le 1499   then FF_IND='MINES';
        if FF_IND='MINES' then &ind_code=28;

*29 Coal   Coal;
          if &sic ge 1200 and &sic le 1299   then FF_IND='COAL';
        if FF_IND='COAL' then &ind_code=29;

*30 Oil    Petroleum and Natural Gas;
          if &sic ge 1300 and &sic le 1300   then FF_IND='OIL';
          if &sic ge 1310 and &sic le 1319   then FF_IND='OIL';
          if &sic ge 1320 and &sic le 1329   then FF_IND='OIL';
          if &sic ge 1330 and &sic le 1339   then FF_IND='OIL';
          if &sic ge 1370 and &sic le 1379   then FF_IND='OIL';
          if &sic ge 1380 and &sic le 1380   then FF_IND='OIL';
          if &sic ge 1381 and &sic le 1381   then FF_IND='OIL';
          if &sic ge 1382 and &sic le 1382   then FF_IND='OIL';
          if &sic ge 1389 and &sic le 1389   then FF_IND='OIL';
          if &sic ge 2900 and &sic le 2912   then FF_IND='OIL';
          if &sic ge 2990 and &sic le 2999   then FF_IND='OIL';
        if FF_IND='OIL' then &ind_code=30;

*31 Util   Utilities;
          if &sic ge 4900 and &sic le 4900   then FF_IND='UTIL';
          if &sic ge 4910 and &sic le 4911   then FF_IND='UTIL';
          if &sic ge 4920 and &sic le 4922   then FF_IND='UTIL';
          if &sic ge 4923 and &sic le 4923   then FF_IND='UTIL';
          if &sic ge 4924 and &sic le 4925   then FF_IND='UTIL';
          if &sic ge 4930 and &sic le 4931   then FF_IND='UTIL';
          if &sic ge 4932 and &sic le 4932   then FF_IND='UTIL';
          if &sic ge 4939 and &sic le 4939   then FF_IND='UTIL';
          if &sic ge 4940 and &sic le 4942   then FF_IND='UTIL';
        if FF_IND='UTIL' then &ind_code=31;

*32 Telcm  Communication;
          if &sic ge 4800 and &sic le 4800   then FF_IND='TELCM';
          if &sic ge 4810 and &sic le 4813   then FF_IND='TELCM';
          if &sic ge 4820 and &sic le 4822   then FF_IND='TELCM';
          if &sic ge 4830 and &sic le 4839   then FF_IND='TELCM';
          if &sic ge 4840 and &sic le 4841   then FF_IND='TELCM';
          if &sic ge 4880 and &sic le 4889   then FF_IND='TELCM';
          if &sic ge 4890 and &sic le 4890   then FF_IND='TELCM';
          if &sic ge 4891 and &sic le 4891   then FF_IND='TELCM';
          if &sic ge 4892 and &sic le 4892   then FF_IND='TELCM';
          if &sic ge 4899 and &sic le 4899   then FF_IND='TELCM';
        if FF_IND='TELCM' then &ind_code=32;

*33 PerSv  Personal Services;
          if &sic ge 7020 and &sic le 7021   then FF_IND='PERSV';
          if &sic ge 7030 and &sic le 7033   then FF_IND='PERSV';
          if &sic ge 7200 and &sic le 7200   then FF_IND='PERSV';
          if &sic ge 7210 and &sic le 7212   then FF_IND='PERSV';
          if &sic ge 7214 and &sic le 7214   then FF_IND='PERSV';
          if &sic ge 7215 and &sic le 7216   then FF_IND='PERSV';
          if &sic ge 7217 and &sic le 7217   then FF_IND='PERSV';
          if &sic ge 7219 and &sic le 7219   then FF_IND='PERSV';
          if &sic ge 7220 and &sic le 7221   then FF_IND='PERSV';
          if &sic ge 7230 and &sic le 7231   then FF_IND='PERSV';
          if &sic ge 7240 and &sic le 7241   then FF_IND='PERSV';
          if &sic ge 7250 and &sic le 7251   then FF_IND='PERSV';
          if &sic ge 7260 and &sic le 7269   then FF_IND='PERSV';
          if &sic ge 7270 and &sic le 7290   then FF_IND='PERSV';
          if &sic ge 7291 and &sic le 7291   then FF_IND='PERSV';
          if &sic ge 7292 and &sic le 7299   then FF_IND='PERSV';
          if &sic ge 7395 and &sic le 7395   then FF_IND='PERSV';
          if &sic ge 7500 and &sic le 7500   then FF_IND='PERSV';
          if &sic ge 7520 and &sic le 7529   then FF_IND='PERSV';
          if &sic ge 7530 and &sic le 7539   then FF_IND='PERSV';
          if &sic ge 7540 and &sic le 7549   then FF_IND='PERSV';
          if &sic ge 7600 and &sic le 7600   then FF_IND='PERSV';
          if &sic ge 7620 and &sic le 7620   then FF_IND='PERSV';
          if &sic ge 7622 and &sic le 7622   then FF_IND='PERSV';
          if &sic ge 7623 and &sic le 7623   then FF_IND='PERSV';
          if &sic ge 7629 and &sic le 7629   then FF_IND='PERSV';
          if &sic ge 7630 and &sic le 7631   then FF_IND='PERSV';
          if &sic ge 7640 and &sic le 7641   then FF_IND='PERSV';
          if &sic ge 7690 and &sic le 7699   then FF_IND='PERSV';
          if &sic ge 8100 and &sic le 8199   then FF_IND='PERSV';
          if &sic ge 8200 and &sic le 8299   then FF_IND='PERSV';
          if &sic ge 8300 and &sic le 8399   then FF_IND='PERSV';
          if &sic ge 8400 and &sic le 8499   then FF_IND='PERSV';
          if &sic ge 8600 and &sic le 8699   then FF_IND='PERSV';
          if &sic ge 8800 and &sic le 8899   then FF_IND='PERSV';
          if &sic ge 7510 and &sic le 7515   then FF_IND='PERSV';
        if FF_IND='PERSV' then &ind_code=33;

*34 BusSv  Business Services;
          if &sic ge 2750 and &sic le 2759   then FF_IND='BUSSV';
          if &sic ge 3993 and &sic le 3993   then FF_IND='BUSSV';
          if &sic ge 7218 and &sic le 7218   then FF_IND='BUSSV';
          if &sic ge 7300 and &sic le 7300   then FF_IND='BUSSV';
          if &sic ge 7310 and &sic le 7319   then FF_IND='BUSSV';
          if &sic ge 7320 and &sic le 7329   then FF_IND='BUSSV';
          if &sic ge 7330 and &sic le 7339   then FF_IND='BUSSV';
          if &sic ge 7340 and &sic le 7342   then FF_IND='BUSSV';
          if &sic ge 7349 and &sic le 7349   then FF_IND='BUSSV';
          if &sic ge 7350 and &sic le 7351   then FF_IND='BUSSV';
          if &sic ge 7352 and &sic le 7352   then FF_IND='BUSSV';
          if &sic ge 7353 and &sic le 7353   then FF_IND='BUSSV';
          if &sic ge 7359 and &sic le 7359   then FF_IND='BUSSV';
          if &sic ge 7360 and &sic le 7369   then FF_IND='BUSSV';
          if &sic ge 7370 and &sic le 7372   then FF_IND='BUSSV';
          if &sic ge 7374 and &sic le 7374   then FF_IND='BUSSV';
          if &sic ge 7375 and &sic le 7375   then FF_IND='BUSSV';
          if &sic ge 7376 and &sic le 7376   then FF_IND='BUSSV';
          if &sic ge 7377 and &sic le 7377   then FF_IND='BUSSV';
          if &sic ge 7378 and &sic le 7378   then FF_IND='BUSSV';
          if &sic ge 7379 and &sic le 7379   then FF_IND='BUSSV';
          if &sic ge 7380 and &sic le 7380   then FF_IND='BUSSV';
          if &sic ge 7381 and &sic le 7382   then FF_IND='BUSSV';
          if &sic ge 7383 and &sic le 7383   then FF_IND='BUSSV';
          if &sic ge 7384 and &sic le 7384   then FF_IND='BUSSV';
          if &sic ge 7385 and &sic le 7385   then FF_IND='BUSSV';
          if &sic ge 7389 and &sic le 7390   then FF_IND='BUSSV';
          if &sic ge 7391 and &sic le 7391   then FF_IND='BUSSV';
          if &sic ge 7392 and &sic le 7392   then FF_IND='BUSSV';
          if &sic ge 7393 and &sic le 7393   then FF_IND='BUSSV';
          if &sic ge 7394 and &sic le 7394   then FF_IND='BUSSV';
          if &sic ge 7396 and &sic le 7396   then FF_IND='BUSSV';
          if &sic ge 7397 and &sic le 7397   then FF_IND='BUSSV';
          if &sic ge 7399 and &sic le 7399   then FF_IND='BUSSV';
          if &sic ge 7519 and &sic le 7519   then FF_IND='BUSSV';
          if &sic ge 8700 and &sic le 8700   then FF_IND='BUSSV';
          if &sic ge 8710 and &sic le 8713   then FF_IND='BUSSV';
          if &sic ge 8720 and &sic le 8721   then FF_IND='BUSSV';
          if &sic ge 8730 and &sic le 8734   then FF_IND='BUSSV';
          if &sic ge 8740 and &sic le 8748   then FF_IND='BUSSV';
          if &sic ge 8900 and &sic le 8910   then FF_IND='BUSSV';
          if &sic ge 8911 and &sic le 8911   then FF_IND='BUSSV';
          if &sic ge 8920 and &sic le 8999   then FF_IND='BUSSV';
          if &sic ge 4220 and &sic le 4229  then FF_IND='BUSSV';
        if FF_IND='BUSSV' then &ind_code=34;

*35 Comps  Computers;
          if &sic ge 3570 and &sic le 3579   then FF_IND='COMPS';
          if &sic ge 3680 and &sic le 3680   then FF_IND='COMPS';
          if &sic ge 3681 and &sic le 3681   then FF_IND='COMPS';
          if &sic ge 3682 and &sic le 3682   then FF_IND='COMPS';
          if &sic ge 3683 and &sic le 3683   then FF_IND='COMPS';
          if &sic ge 3684 and &sic le 3684   then FF_IND='COMPS';
          if &sic ge 3685 and &sic le 3685   then FF_IND='COMPS';
          if &sic ge 3686 and &sic le 3686   then FF_IND='COMPS';
          if &sic ge 3687 and &sic le 3687   then FF_IND='COMPS';
          if &sic ge 3688 and &sic le 3688   then FF_IND='COMPS';
          if &sic ge 3689 and &sic le 3689   then FF_IND='COMPS';
          if &sic ge 3695 and &sic le 3695   then FF_IND='COMPS';
          if &sic ge 7373 and &sic le 7373   then FF_IND='COMPS';
        if FF_IND='COMPS' then &ind_code=35;

*36 Chips  Electronic Equipment;
          if &sic ge 3622 and &sic le 3622   then FF_IND='CHIPS';
          if &sic ge 3661 and &sic le 3661   then FF_IND='CHIPS';
          if &sic ge 3662 and &sic le 3662   then FF_IND='CHIPS';
          if &sic ge 3663 and &sic le 3663   then FF_IND='CHIPS';
          if &sic ge 3664 and &sic le 3664   then FF_IND='CHIPS';
          if &sic ge 3665 and &sic le 3665   then FF_IND='CHIPS';
          if &sic ge 3666 and &sic le 3666   then FF_IND='CHIPS';
          if &sic ge 3669 and &sic le 3669   then FF_IND='CHIPS';
          if &sic ge 3670 and &sic le 3679   then FF_IND='CHIPS';
          if &sic ge 3810 and &sic le 3810   then FF_IND='CHIPS';
          if &sic ge 3812 and &sic le 3812   then FF_IND='CHIPS';
        if FF_IND='CHIPS' then &ind_code=36;

*37 LabEq  Measuring and Control Equipment;
          if &sic ge 3811 and &sic le 3811   then FF_IND='LABEQ';
          if &sic ge 3820 and &sic le 3820   then FF_IND='LABEQ';
          if &sic ge 3821 and &sic le 3821   then FF_IND='LABEQ';
          if &sic ge 3822 and &sic le 3822   then FF_IND='LABEQ';
          if &sic ge 3823 and &sic le 3823   then FF_IND='LABEQ';
          if &sic ge 3824 and &sic le 3824   then FF_IND='LABEQ';
          if &sic ge 3825 and &sic le 3825   then FF_IND='LABEQ';
          if &sic ge 3826 and &sic le 3826   then FF_IND='LABEQ';
          if &sic ge 3827 and &sic le 3827   then FF_IND='LABEQ';
          if &sic ge 3829 and &sic le 3829   then FF_IND='LABEQ';
          if &sic ge 3830 and &sic le 3839   then FF_IND='LABEQ';
        if FF_IND='LABEQ' then &ind_code=37;

*38 Paper  Business Supplies;
          if &sic ge 2520 and &sic le 2549   then FF_IND='PAPER';
          if &sic ge 2600 and &sic le 2639   then FF_IND='PAPER';
          if &sic ge 2670 and &sic le 2699   then FF_IND='PAPER';
          if &sic ge 2760 and &sic le 2761   then FF_IND='PAPER';
          if &sic ge 3950 and &sic le 3955   then FF_IND='PAPER';
        if FF_IND='PAPER' then &ind_code=38;

*39 Boxes  Shipping Containers;
          if &sic ge 2440 and &sic le 2449   then FF_IND='BOXES';
          if &sic ge 2640 and &sic le 2659   then FF_IND='BOXES';
          if &sic ge 3220 and &sic le 3221   then FF_IND='BOXES';
          if &sic ge 3410 and &sic le 3412   then FF_IND='BOXES';
        if FF_IND='BOXES' then &ind_code=39;

*40 Trans  Transportation;
          if &sic ge 4000 and &sic le 4013   then FF_IND='TRANS';
          if &sic ge 4040 and &sic le 4049   then FF_IND='TRANS';
          if &sic ge 4100 and &sic le 4100   then FF_IND='TRANS';
          if &sic ge 4110 and &sic le 4119   then FF_IND='TRANS';
          if &sic ge 4120 and &sic le 4121   then FF_IND='TRANS';
          if &sic ge 4130 and &sic le 4131   then FF_IND='TRANS';
          if &sic ge 4140 and &sic le 4142   then FF_IND='TRANS';
          if &sic ge 4150 and &sic le 4151   then FF_IND='TRANS';
          if &sic ge 4170 and &sic le 4173   then FF_IND='TRANS';
          if &sic ge 4190 and &sic le 4199   then FF_IND='TRANS';
          if &sic ge 4200 and &sic le 4200   then FF_IND='TRANS';
          if &sic ge 4210 and &sic le 4219   then FF_IND='TRANS';
          if &sic ge 4230 and &sic le 4231   then FF_IND='TRANS';
          if &sic ge 4240 and &sic le 4249   then FF_IND='TRANS';
          if &sic ge 4400 and &sic le 4499   then FF_IND='TRANS';
          if &sic ge 4500 and &sic le 4599   then FF_IND='TRANS';
          if &sic ge 4600 and &sic le 4699   then FF_IND='TRANS';
          if &sic ge 4700 and &sic le 4700   then FF_IND='TRANS';
          if &sic ge 4710 and &sic le 4712   then FF_IND='TRANS';
          if &sic ge 4720 and &sic le 4729   then FF_IND='TRANS';
          if &sic ge 4730 and &sic le 4739   then FF_IND='TRANS';
          if &sic ge 4740 and &sic le 4749   then FF_IND='TRANS';
          if &sic ge 4780 and &sic le 4780   then FF_IND='TRANS';
          if &sic ge 4782 and &sic le 4782   then FF_IND='TRANS';
          if &sic ge 4783 and &sic le 4783   then FF_IND='TRANS';
          if &sic ge 4784 and &sic le 4784   then FF_IND='TRANS';
          if &sic ge 4785 and &sic le 4785   then FF_IND='TRANS';
          if &sic ge 4789 and &sic le 4789   then FF_IND='TRANS';
        if FF_IND='TRANS' then &ind_code=40;

*41 Whlsl  Wholesale;
          if &sic ge 5000 and &sic le 5000   then FF_IND='WHLSL';
          if &sic ge 5010 and &sic le 5015   then FF_IND='WHLSL';
          if &sic ge 5020 and &sic le 5023   then FF_IND='WHLSL';
          if &sic ge 5030 and &sic le 5039   then FF_IND='WHLSL';
          if &sic ge 5040 and &sic le 5042   then FF_IND='WHLSL';
          if &sic ge 5043 and &sic le 5043   then FF_IND='WHLSL';
          if &sic ge 5044 and &sic le 5044   then FF_IND='WHLSL';
          if &sic ge 5045 and &sic le 5045   then FF_IND='WHLSL';
          if &sic ge 5046 and &sic le 5046   then FF_IND='WHLSL';
          if &sic ge 5047 and &sic le 5047   then FF_IND='WHLSL';
          if &sic ge 5048 and &sic le 5048   then FF_IND='WHLSL';
          if &sic ge 5049 and &sic le 5049   then FF_IND='WHLSL';
          if &sic ge 5050 and &sic le 5059   then FF_IND='WHLSL';
          if &sic ge 5060 and &sic le 5060   then FF_IND='WHLSL';
          if &sic ge 5063 and &sic le 5063   then FF_IND='WHLSL';
          if &sic ge 5064 and &sic le 5064   then FF_IND='WHLSL';
          if &sic ge 5065 and &sic le 5065   then FF_IND='WHLSL';
          if &sic ge 5070 and &sic le 5078   then FF_IND='WHLSL';
          if &sic ge 5080 and &sic le 5080   then FF_IND='WHLSL';
          if &sic ge 5081 and &sic le 5081   then FF_IND='WHLSL';
          if &sic ge 5082 and &sic le 5082   then FF_IND='WHLSL';
          if &sic ge 5083 and &sic le 5083   then FF_IND='WHLSL';
          if &sic ge 5084 and &sic le 5084   then FF_IND='WHLSL';
          if &sic ge 5085 and &sic le 5085   then FF_IND='WHLSL';
          if &sic ge 5086 and &sic le 5087   then FF_IND='WHLSL';
          if &sic ge 5088 and &sic le 5088   then FF_IND='WHLSL';
          if &sic ge 5090 and &sic le 5090   then FF_IND='WHLSL';
          if &sic ge 5091 and &sic le 5092   then FF_IND='WHLSL';
          if &sic ge 5093 and &sic le 5093   then FF_IND='WHLSL';
          if &sic ge 5094 and &sic le 5094   then FF_IND='WHLSL';
          if &sic ge 5099 and &sic le 5099   then FF_IND='WHLSL';
          if &sic ge 5100 and &sic le 5100   then FF_IND='WHLSL';
          if &sic ge 5110 and &sic le 5113   then FF_IND='WHLSL';
          if &sic ge 5120 and &sic le 5122   then FF_IND='WHLSL';
          if &sic ge 5130 and &sic le 5139   then FF_IND='WHLSL';
          if &sic ge 5140 and &sic le 5149   then FF_IND='WHLSL';
          if &sic ge 5150 and &sic le 5159   then FF_IND='WHLSL';
          if &sic ge 5160 and &sic le 5169   then FF_IND='WHLSL';
          if &sic ge 5170 and &sic le 5172   then FF_IND='WHLSL';
          if &sic ge 5180 and &sic le 5182   then FF_IND='WHLSL';
          if &sic ge 5190 and &sic le 5199   then FF_IND='WHLSL';
        if FF_IND='WHLSL' then &ind_code=41;

*42 Rtail  Retail ;
          if &sic ge 5200 and &sic le 5200   then FF_IND='RTAIL';
          if &sic ge 5210 and &sic le 5219   then FF_IND='RTAIL';
          if &sic ge 5220 and &sic le 5229   then FF_IND='RTAIL';
          if &sic ge 5230 and &sic le 5231   then FF_IND='RTAIL';
          if &sic ge 5250 and &sic le 5251   then FF_IND='RTAIL';
          if &sic ge 5260 and &sic le 5261   then FF_IND='RTAIL';
          if &sic ge 5270 and &sic le 5271   then FF_IND='RTAIL';
          if &sic ge 5300 and &sic le 5300   then FF_IND='RTAIL';
          if &sic ge 5310 and &sic le 5311   then FF_IND='RTAIL';
          if &sic ge 5320 and &sic le 5320   then FF_IND='RTAIL';
          if &sic ge 5330 and &sic le 5331   then FF_IND='RTAIL';
          if &sic ge 5334 and &sic le 5334   then FF_IND='RTAIL';
          if &sic ge 5340 and &sic le 5349   then FF_IND='RTAIL';
          if &sic ge 5390 and &sic le 5399   then FF_IND='RTAIL';
          if &sic ge 5400 and &sic le 5400   then FF_IND='RTAIL';
          if &sic ge 5410 and &sic le 5411   then FF_IND='RTAIL';
          if &sic ge 5412 and &sic le 5412   then FF_IND='RTAIL';
          if &sic ge 5420 and &sic le 5429   then FF_IND='RTAIL';
          if &sic ge 5430 and &sic le 5439   then FF_IND='RTAIL';
          if &sic ge 5440 and &sic le 5449   then FF_IND='RTAIL';
          if &sic ge 5450 and &sic le 5459   then FF_IND='RTAIL';
          if &sic ge 5460 and &sic le 5469   then FF_IND='RTAIL';
          if &sic ge 5490 and &sic le 5499   then FF_IND='RTAIL';
          if &sic ge 5500 and &sic le 5500   then FF_IND='RTAIL';
          if &sic ge 5510 and &sic le 5529   then FF_IND='RTAIL';
          if &sic ge 5530 and &sic le 5539   then FF_IND='RTAIL';
          if &sic ge 5540 and &sic le 5549   then FF_IND='RTAIL';
          if &sic ge 5550 and &sic le 5559   then FF_IND='RTAIL';
          if &sic ge 5560 and &sic le 5569   then FF_IND='RTAIL';
          if &sic ge 5570 and &sic le 5579   then FF_IND='RTAIL';
          if &sic ge 5590 and &sic le 5599   then FF_IND='RTAIL';
          if &sic ge 5600 and &sic le 5699   then FF_IND='RTAIL';
          if &sic ge 5700 and &sic le 5700   then FF_IND='RTAIL';
          if &sic ge 5710 and &sic le 5719   then FF_IND='RTAIL';
          if &sic ge 5720 and &sic le 5722   then FF_IND='RTAIL';
          if &sic ge 5730 and &sic le 5733   then FF_IND='RTAIL';
          if &sic ge 5734 and &sic le 5734   then FF_IND='RTAIL';
          if &sic ge 5735 and &sic le 5735   then FF_IND='RTAIL';
          if &sic ge 5736 and &sic le 5736   then FF_IND='RTAIL';
          if &sic ge 5750 and &sic le 5799   then FF_IND='RTAIL';
          if &sic ge 5900 and &sic le 5900   then FF_IND='RTAIL';
          if &sic ge 5910 and &sic le 5912   then FF_IND='RTAIL';
          if &sic ge 5920 and &sic le 5929   then FF_IND='RTAIL';
          if &sic ge 5930 and &sic le 5932   then FF_IND='RTAIL';
          if &sic ge 5940 and &sic le 5940   then FF_IND='RTAIL';
          if &sic ge 5941 and &sic le 5941   then FF_IND='RTAIL';
          if &sic ge 5942 and &sic le 5942   then FF_IND='RTAIL';
          if &sic ge 5943 and &sic le 5943   then FF_IND='RTAIL';
          if &sic ge 5944 and &sic le 5944   then FF_IND='RTAIL';
          if &sic ge 5945 and &sic le 5945   then FF_IND='RTAIL';
          if &sic ge 5946 and &sic le 5946   then FF_IND='RTAIL';
          if &sic ge 5947 and &sic le 5947   then FF_IND='RTAIL';
          if &sic ge 5948 and &sic le 5948   then FF_IND='RTAIL';
          if &sic ge 5949 and &sic le 5949   then FF_IND='RTAIL';
          if &sic ge 5950 and &sic le 5959   then FF_IND='RTAIL';
          if &sic ge 5960 and &sic le 5969   then FF_IND='RTAIL';
          if &sic ge 5970 and &sic le 5979   then FF_IND='RTAIL';
          if &sic ge 5980 and &sic le 5989   then FF_IND='RTAIL';
          if &sic ge 5990 and &sic le 5990   then FF_IND='RTAIL';
          if &sic ge 5992 and &sic le 5992   then FF_IND='RTAIL';
          if &sic ge 5993 and &sic le 5993   then FF_IND='RTAIL';
          if &sic ge 5994 and &sic le 5994   then FF_IND='RTAIL';
          if &sic ge 5995 and &sic le 5995   then FF_IND='RTAIL';
          if &sic ge 5999 and &sic le 5999   then FF_IND='RTAIL';
        if FF_IND='RTAIL' then &ind_code=42;

*43 Meals  Restaraunts, Hotels, Motels;
          if &sic ge 5800 and &sic le 5819   then FF_IND='MEALS';
          if &sic ge 5820 and &sic le 5829   then FF_IND='MEALS';
          if &sic ge 5890 and &sic le 5899   then FF_IND='MEALS';
          if &sic ge 7000 and &sic le 7000   then FF_IND='MEALS';
          if &sic ge 7010 and &sic le 7019   then FF_IND='MEALS';
          if &sic ge 7040 and &sic le 7049   then FF_IND='MEALS';
          if &sic ge 7213 and &sic le 7213   then FF_IND='MEALS';
        if FF_IND='MEALS' then &ind_code=43;

*44 Banks  Banking;
          if &sic ge 6000 and &sic le 6000   then FF_IND='BANKS';
          if &sic ge 6010 and &sic le 6019   then FF_IND='BANKS';
          if &sic ge 6020 and &sic le 6020   then FF_IND='BANKS';
          if &sic ge 6021 and &sic le 6021   then FF_IND='BANKS';
          if &sic ge 6022 and &sic le 6022   then FF_IND='BANKS';
          if &sic ge 6023 and &sic le 6024   then FF_IND='BANKS';
          if &sic ge 6025 and &sic le 6025   then FF_IND='BANKS';
          if &sic ge 6026 and &sic le 6026   then FF_IND='BANKS';
          if &sic ge 6027 and &sic le 6027   then FF_IND='BANKS';
          if &sic ge 6028 and &sic le 6029   then FF_IND='BANKS';
          if &sic ge 6030 and &sic le 6036   then FF_IND='BANKS';
          if &sic ge 6040 and &sic le 6059   then FF_IND='BANKS';
          if &sic ge 6060 and &sic le 6062   then FF_IND='BANKS';
          if &sic ge 6080 and &sic le 6082   then FF_IND='BANKS';
          if &sic ge 6090 and &sic le 6099   then FF_IND='BANKS';
          if &sic ge 6100 and &sic le 6100   then FF_IND='BANKS';
          if &sic ge 6110 and &sic le 6111   then FF_IND='BANKS';
          if &sic ge 6112 and &sic le 6113   then FF_IND='BANKS';
          if &sic ge 6120 and &sic le 6129   then FF_IND='BANKS';
          if &sic ge 6130 and &sic le 6139   then FF_IND='BANKS';
          if &sic ge 6140 and &sic le 6149   then FF_IND='BANKS';
          if &sic ge 6150 and &sic le 6159   then FF_IND='BANKS';
          if &sic ge 6160 and &sic le 6169   then FF_IND='BANKS';
          if &sic ge 6170 and &sic le 6179   then FF_IND='BANKS';
          if &sic ge 6190 and &sic le 6199   then FF_IND='BANKS';
        if FF_IND='BANKS' then &ind_code=44;

*45 Insur  Insurance;
          if &sic ge 6300 and &sic le 6300   then FF_IND='INSUR';
          if &sic ge 6310 and &sic le 6319   then FF_IND='INSUR';
          if &sic ge 6320 and &sic le 6329   then FF_IND='INSUR';
          if &sic ge 6330 and &sic le 6331   then FF_IND='INSUR';
          if &sic ge 6350 and &sic le 6351   then FF_IND='INSUR';
          if &sic ge 6360 and &sic le 6361   then FF_IND='INSUR';
          if &sic ge 6370 and &sic le 6379   then FF_IND='INSUR';
          if &sic ge 6390 and &sic le 6399   then FF_IND='INSUR';
          if &sic ge 6400 and &sic le 6411   then FF_IND='INSUR';
        if FF_IND='INSUR' then &ind_code=45;

*46 RlEst  Real Estate;
          if &sic ge 6500 and &sic le 6500   then FF_IND='RLEST';
          if &sic ge 6510 and &sic le 6510   then FF_IND='RLEST';
          if &sic ge 6512 and &sic le 6512   then FF_IND='RLEST';
          if &sic ge 6513 and &sic le 6513   then FF_IND='RLEST';
          if &sic ge 6514 and &sic le 6514   then FF_IND='RLEST';
          if &sic ge 6515 and &sic le 6515   then FF_IND='RLEST';
          if &sic ge 6517 and &sic le 6519   then FF_IND='RLEST';
          if &sic ge 6520 and &sic le 6529   then FF_IND='RLEST';
          if &sic ge 6530 and &sic le 6531   then FF_IND='RLEST';
          if &sic ge 6532 and &sic le 6532   then FF_IND='RLEST';
          if &sic ge 6540 and &sic le 6541   then FF_IND='RLEST';
          if &sic ge 6550 and &sic le 6553   then FF_IND='RLEST';
          if &sic ge 6590 and &sic le 6599   then FF_IND='RLEST';
          if &sic ge 6610 and &sic le 6611   then FF_IND='RLEST';
        if FF_IND='RLEST' then &ind_code=46;

*47 Fin    Trading;
          if &sic ge 6200 and &sic le 6299   then FF_IND='FIN';
          if &sic ge 6700 and &sic le 6700   then FF_IND='FIN';
          if &sic ge 6710 and &sic le 6719   then FF_IND='FIN';
          if &sic ge 6720 and &sic le 6722   then FF_IND='FIN';
          if &sic ge 6723 and &sic le 6723   then FF_IND='FIN';
          if &sic ge 6724 and &sic le 6724   then FF_IND='FIN';
          if &sic ge 6725 and &sic le 6725   then FF_IND='FIN';
          if &sic ge 6726 and &sic le 6726   then FF_IND='FIN';
          if &sic ge 6730 and &sic le 6733   then FF_IND='FIN';
          if &sic ge 6740 and &sic le 6779   then FF_IND='FIN';
          if &sic ge 6790 and &sic le 6791   then FF_IND='FIN';
          if &sic ge 6792 and &sic le 6792   then FF_IND='FIN';
          if &sic ge 6793 and &sic le 6793   then FF_IND='FIN';
          if &sic ge 6794 and &sic le 6794   then FF_IND='FIN';
          if &sic ge 6795 and &sic le 6795   then FF_IND='FIN';
          if &sic ge 6798 and &sic le 6798   then FF_IND='FIN';
          if &sic ge 6799 and &sic le 6799   then FF_IND='FIN';
        if FF_IND='FIN' then &ind_code=47;

*48 Other  Almost Nothing;
          if &sic ge 4950 and &sic le 4959   then FF_IND='OTHER';
          if &sic ge 4960 and &sic le 4961   then FF_IND='OTHER';
          if &sic ge 4970 and &sic le 4971   then FF_IND='OTHER';
          if &sic ge 4990 and &sic le 4991   then FF_IND='OTHER';
          if &sic ge 9990 and &sic le 9999   then FF_IND='OTHER';
        if FF_IND='OTHER' then &ind_code=48;





        if(&ind_code=1) then &bin_var.1=1;              else &bin_var.1=0;
        if(&ind_code=2) then &bin_var.2=1;              else &bin_var.2=0;
        if(&ind_code=3) then &bin_var.3=1;              else &bin_var.3=0;
        if(&ind_code=4) then &bin_var.4=1;              else &bin_var.4=0;
        if(&ind_code=5) then &bin_var.5=1;              else &bin_var.5=0;
        if(&ind_code=6) then &bin_var.6=1;              else &bin_var.6=0;
        if(&ind_code=7) then &bin_var.7=1;              else &bin_var.7=0;
        if(&ind_code=8) then &bin_var.8=1;              else &bin_var.8=0;
        if(&ind_code=9) then &bin_var.9=1;              else &bin_var.9=0;
        if(&ind_code=10) then &bin_var.10=1;            else &bin_var.10=0;
        if(&ind_code=11) then &bin_var.11=1;            else &bin_var.11=0;
        if(&ind_code=12) then &bin_var.12=1;            else &bin_var.12=0;
        if(&ind_code=13) then &bin_var.13=1;            else &bin_var.13=0;
        if(&ind_code=14) then &bin_var.14=1;            else &bin_var.14=0;
        if(&ind_code=15) then &bin_var.15=1;            else &bin_var.15=0;
        if(&ind_code=16) then &bin_var.16=1;            else &bin_var.16=0;
        if(&ind_code=17) then &bin_var.17=1;            else &bin_var.17=0;
        if(&ind_code=18) then &bin_var.18=1;            else &bin_var.18=0;
        if(&ind_code=19) then &bin_var.19=1;            else &bin_var.19=0;
        if(&ind_code=20) then &bin_var.20=1;            else &bin_var.20=0;
        if(&ind_code=21) then &bin_var.21=1;            else &bin_var.21=0;
        if(&ind_code=22) then &bin_var.22=1;            else &bin_var.22=0;
        if(&ind_code=23) then &bin_var.23=1;            else &bin_var.23=0;
        if(&ind_code=24) then &bin_var.24=1;            else &bin_var.24=0;
        if(&ind_code=25) then &bin_var.25=1;            else &bin_var.25=0;
        if(&ind_code=26) then &bin_var.26=1;            else &bin_var.26=0;
        if(&ind_code=27) then &bin_var.27=1;            else &bin_var.27=0;
        if(&ind_code=28) then &bin_var.28=1;            else &bin_var.28=0;
        if(&ind_code=29) then &bin_var.29=1;            else &bin_var.29=0;
        if(&ind_code=30) then &bin_var.30=1;            else &bin_var.30=0;
        if(&ind_code=31) then &bin_var.31=1;            else &bin_var.31=0;
        if(&ind_code=32) then &bin_var.32=1;            else &bin_var.32=0;
        if(&ind_code=33) then &bin_var.33=1;            else &bin_var.33=0;
        if(&ind_code=34) then &bin_var.34=1;            else &bin_var.34=0;
        if(&ind_code=35) then &bin_var.35=1;            else &bin_var.35=0;
        if(&ind_code=36) then &bin_var.36=1;            else &bin_var.36=0;
        if(&ind_code=37) then &bin_var.37=1;            else &bin_var.37=0;
        if(&ind_code=38) then &bin_var.38=1;            else &bin_var.38=0;
        if(&ind_code=39) then &bin_var.39=1;            else &bin_var.39=0;
        if(&ind_code=40) then &bin_var.40=1;            else &bin_var.40=0;
        if(&ind_code=41) then &bin_var.41=1;            else &bin_var.41=0;
        if(&ind_code=42) then &bin_var.42=1;            else &bin_var.42=0;
        if(&ind_code=43) then &bin_var.43=1;            else &bin_var.43=0;
        if(&ind_code=44) then &bin_var.44=1;            else &bin_var.44=0;
        if(&ind_code=45) then &bin_var.45=1;            else &bin_var.45=0;
        if(&ind_code=46) then &bin_var.46=1;            else &bin_var.46=0;
        if(&ind_code=47) then &bin_var.47=1;            else &bin_var.47=0;
        if(&ind_code=48) then &bin_var.48=1;            else &bin_var.48=0;

run;


%mend;
%ind_ff48 (dset =cash1_1, outp=mine.cpiadj_ind, sic=siccd, bin_var=ind_48_name, ind_code= ind_48);

/*use all_test2 dataset to run the regression with industry dummies*/


/*run cash code, using compu dataset, create cash1_1 dataset in this code*/
