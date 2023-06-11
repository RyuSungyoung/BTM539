libname mine '/scratch/kaist/sungyoungryu';
/*CRSP and Compustat data at the security level by CUSIP*/
proc sql;
	create table mine.CUSIP_LINK as 
	select distinct a.permno, gvkey, iid, date, prc, vol, ret
	from
		crsp.msf as a, 					/*CRSP Monthly stock file*/
		crsp.msenames 
		(
			where=(not missing(ncusip)	/*Historical CUSIP is not missing*/
			and shrcd in (10 11))		/*Common stocks of U.S. Companies*/
		) as b, 
		comp.security
		(
			where=(not missing(cusip)	/*Current CUSIP is not missing*/
			and excntry='USA')			/*Stocks listed in U.S. Exchanges*/
		) as c
	where
		a.permno=b.permno
		and NAMEDT<=a.date<=NAMEENDT	/*Date range conditions*/
		and b.ncusip=substr(c.cusip,1,8);	/*Linking on the first 8 alpha-numerics of CUSIP*/
quit;

data mine.ibm;
set mine.CUSIP_LINK;
where permno = 12490;
run;


/*matching CRSP and Compustat at the security level using the CCM Linktable*/

proc sql;
	create table mine.CCM_LINK as 
	select distinct a.permno, gvkey, liid as iid, 
			date, prc, vol, ret
	from 
		crsp.msf as a, 						/*CRSP Monthly stock file*/
		crsp.msenames 
		(
			where=(shrcd in (10 11))		/*Common stocks of U.S. Companies*/
		) as b, 
		crsp.Ccmxpf_linktable
		(
			where=(
				linktype in ('LU' 'LC') 	/*KEEP reliable LINKS only*/
				and LINKPRIM in ('P' 'C')   /*KEEP primary Links*/
				and USEDFLAG=1 )			/*Legacy condition, no longer necessary*/
		) as c
	where a.permno=b.permno=c.lpermno		/*Linking by permno*/
	and NAMEDT<=a.date<=NAMEENDT			/*CRSP Date range conditions*/
	and linkdt<=a.date<=coalesce(linkenddt, today());	/*LinkTable Date range conditions*/
quit;
