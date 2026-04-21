/*Rewrite date macro variables so the format show date9. instead of a number, which is hard to know which date it is. 20230102 Miaomiao Zhu*/
/*Options mprint mlogic symbolgen;*/ /*2022-03-03 Miaomiao Zhu*/

/*Enviroment macro. 2022-03-14 Miaomiao*/
%let env=;
data _null_;
if "&syshostname"='aablprdsas11' then call symputx('env', 'prod', 'G');
else if "&syshostname"='aablstgsas21' then call symputx('env', 'test', 'G');
run;

%macro start_dwi();
	%if %symexist(_METAFOLDER)=0 %then %do; /* körs vid EG körning */
	/*---------------- OBS -------------------*/
	/* vid körning av projekt/skapa stp måste variabel initieras manuellt nedan. Används alltid AAB om ej ändras! */
		%get_libs(folder=finance)
	%end;	
	%else %do;
		%get_tenant_libs()
	%end;

	%get_dates;

%mend;


%macro start_dwi_manual(path=);
	%if %symexist(_METAFOLDER)=0 %then %do; /* körs vid EG körning */
	/*---------------- OBS -------------------*/
	/* vid körning av projekt/skapa stp måste variabel initieras manuellt nedan. Används alltid AAB om ej ändras! */
		%get_libs(folder=&path)
	%end;	
	%else %do;
		%get_tenant_libs()
	%end;

	%get_dates;

%mend;

%macro get_tenant_libs();
/* sets libs */

	/* %let folder=/dw_solution/int/programs/stp/finance/; */

	%let folder = &_METAFOLDER;
	/*%let stripIndex= %index(&folder,/dwi_);*/
	%let folder = %substr(&folder,1,%length(&folder)-1);
	%let folder = %substr(&folder,%index(&folder,/)+1); /* dw_solution/.. */
	%let folder = %substr(&folder,%index(&folder,/)+1) ;/* int/.. */
	%let folder = %substr(&folder,%index(&folder,/)+1); /* programs/.. */
	%let folder = %substr(&folder,%index(&folder,/)+1); /* stp/.. */
	%let folder = %substr(&folder,%index(&folder,/)+1); /* tenant folder */
	%get_libs(folder=&folder);
%mend;
%macro get_libs(folder=);
	%if %lowcase(&folder)=finance %then %do;
		%let tenant=aab;
		%let dw_inlib=dw_dw;
		%let dw_inlib_play=dw_play;
		%let dw_inlib_int=dwi_gen;
		%let dw_outlib=dwi_fina;
		%let dw_replib =play_tal;
		%let dw_paylib=dwi_affs;
		%let dw_inlib_miss=dw_dw;
	%end;
	%if %lowcase(&folder)=hypo %then %do;
		%let tenant=hypo;
		%let dw_inlib=dwh_dw;
		%let dw_inlib_play=dwi_hypo;
		%let dw_inlib_int=dwh_gen;
		%let dw_outlib =dwi_hypo;
		%let dw_replib =dwh_finr;
		%let dw_paylib=dwi_hypo;
		%let dw_inlib_miss=dwi_hypo;
	%end;
%mend;
 
%macro get_dates();
/* gets dates */
	%let card_date_active=.;
	PROC SQL noprint;
		select distinct run_type into :run_type from &dw_outlib..batch_par where type='daily_date';
/*20230102 Miaomiao Zhu*/		
		select cats(quote(put(latest_date, date9.)), "d") into :date_active from &dw_outlib..batch_par where type='daily_date';
		select cats(quote(put(latest_date, date9.)), "d") into :acc_monthly_date_active from &dw_outlib..batch_par where type='acc_monthly_date';
   		select cats(quote(put(latest_date, date9.)), "d") into :onefactor_date_active from &dw_outlib..batch_par where type='1F_date';
		select cats(quote(put(latest_date, date9.)), "d") into :country_date_active from &dw_outlib..batch_par where type='country_date';
		select cats(quote(put(latest_date, date9.)), "d") into :max_limit_date from &dw_outlib..batch_par where type='limit_date';
		select cats(quote(put(latest_date, date9.)), "d") into :rwael_date_active from &dw_outlib..batch_par where type='rwael_date';
		select cats(quote(put(latest_date, date9.)), "d") into :loan_date_active from  &dw_outlib..batch_par where type='loan_date';
		select cats(quote(put(latest_date, date9.)), "d") into :timedep_date_active from  &dw_outlib..batch_par where type='timedeposit_date';
		select cats(quote(put(latest_date, date9.)), "d") into :card_date_active from &dw_outlib..batch_par where type='card_date';
		select cats(quote(put(latest_date, date9.)), "d") into :profit_date_active from &dw_outlib..batch_par where type='profit_date';

   SELECT t1.month_start_date format= Best8. into :acc_monthly_start_date
          FROM C_CTRL.PAR_BANK_DAYS_L t1
      WHERE t1.information_date = &acc_monthly_date_active;
	quit;
	%put &card_date_active;
	%if &card_date_active= %then %do;
		%let card_date_active = %sysfunc(mdy(1,1,2999));
	%end;
	%let card_dt_active = %sysfunc(dhms(&card_date_active,5,0,0));
	%let card_info_date = %sysfunc(datepart(&card_dt_active))-1;
%mend;

/* export macros */
%macro dev_dwi_create(from_lib=,from_table=,to_lib=,to_table=);
	proc sql noprint;
	create table &to_lib..&to_table as select * from &from_lib..&from_table;
	quit;
%mend;

%macro dwi_delete(del_lib=,del_table=,del_date=);
	proc sql noprint;
	/*create table &dw_outlib..dwi_accounts as select * from work.dwi_accounts_load;*/
	delete from &del_lib..&del_table 
	where information_date=&del_date;
	quit;
%mend;

%macro dwi_insert(from_lib=,from_table=,to_lib=,to_table=);
	proc sql noprint;
	/*create table work.ins_temp_table (compress=binary) as select * from &from_lib..&from_table; Deleted by Miaomiao, 20220517 */
	insert into &to_lib..&to_table select * from &from_lib..&from_table;
	quit;
	
	/*20230419, Miaomiao change for performence*/
	%let dsid=%sysfunc(open(&to_lib..&to_table));
	%let index_flag=%sysfunc(attrn(&dsid,isindex));
	%let rc=%sysfunc(close( &dsid ));
	%if &index_flag ne 1 %then %do;
		proc datasets lib = &to_lib nolist;
		modify &to_table;
		index create information_date;
		quit;
	%end;
%mend;

%macro dwi_create_latest(lib=,table=,L_date=&M_latest_BankDay);
/*20230419, Miaomiao change for performence*/
	/*proc sql noprint;
	create table &lib..&table._l as 
	SELECT * from &lib..&table 
	where information_date = (select max(information_date) from &lib..&table);
	quit;*/
	proc sql noprint;
	create table &lib..&table._l as 
	SELECT * from &lib..&table 
	where information_date = &L_date;
	quit;
%mend;

%macro dwi_log(lib=,str1=,str2=,timestamp_start=,timestamp_end=,user=,tenant=);
	proc sql noprint;
	insert into dwi_fina.BATCH_LOG values (&tenant,&str1,&str2, &timestamp_start,&timestamp_end,&user);
	quit;
%mend;

%macro exportfile_card_campaign(lib=,table=,type=);
	%let nobs=0;

	proc sql noprint; 
		select count(*) into %trim(:nobs) from &lib..&table;
	quit;

	%if &nobs NE 0 %then %do;

	%let now = %sysfunc(datetime());
	%let fname = COF_CC_CAMPAIGN_&type._%trim(%sysfunc(today(),yymmddn8.))%sysfunc(timepart(&now),B8601TM6);
	%put =====> fname= &fname;

	/* detect proper delim for UNIX vs. Windows */
	%let delim=%sysfunc(ifc(%eval(&sysscp. = WIN),\,/));
	 
	%let download_from =
	  %sysfunc(getoption(work))&delim.&fname..csv;

	 /********  PROD CREATE FILE **********/

	%let download_from = /sasdw/prod/dw/external_files/output&delim.&fname..csv;
	libname from_lib '/sasdw/prod/dw/external_files/output';
	filename src "&download_from.";
	 
	proc export data=&lib..&table.
	  dbms=csv 
	  file=src
	  replace;
	  delimiter=';';
	run;
	 
	filename src clear;

	/******* PROD SEND FILE TO CARD SYSTEM ******/
	/*prod*/
	%let download_to =  /sftp/sftp_cc_prd_cardsystem/outgoing&delim.&fname..csv;
	
	filename to "&download_to.";
 
	proc export data=&lib..&table.
	  dbms=csv 
	  file=to
	  replace;
	  delimiter=';';
	run;
	filename to clear;
	%end;
%mend;

* -- Macro for checking if the specified table has rows for the specified date (KL 230517) -- ;
* -- Default date is m_latest_bankday since date_active will not have the right date if account is not updated -- ;
%macro check_table_updated(lib=, tab=, checkdate=&m_latest_bankday);
  data _null_;
    call symput('datchar',put(&checkdate,yymmdd10.));
  run;

  %global tab_rows;

  proc sql noprint;
    select count(*) into :tab_rows
    from &lib..&tab
    where information_date = &checkdate;
  quit;

  %if %eval(&tab_rows = 0) %then %put NOTE: The table &lib..&tab does not contain the information date &datchar (run at: &sysdate9 &systime).;

%mend check_table_updated;

* Examples ;
*%check_table_updated(lib=dwh_dw, tab=CUSTOMER_L);
*%check_table_updated(lib=dwh_dw, tab=CUSTOMER_L, checkdate='12may23'd);

* -- Macro for checking if all specified tables in specified EG project have rows for specified information date (KL 230517) -- ;
%macro check_tables_in_project(egproj=, projpath=, lib2check=, tabs2check=, date2check=&m_latest_bankday, sec2wait=60, max_iter=120);

  data _null_;
    call symput('datchar',put(&date2check,yymmddn8.));
  run;

  %* -- Initiate the macro variables before the first iteration. -- ;
  %global all_tabs_OK tab_rows;
  %let all_tabs_ok = 0;
  %let tab_rows = 0;

  %* -- Count number of tables to check -- ;
  %let numtabs = %sysfunc(countw(&tabs2check));
  %put NOTE: Number of tables to check for this project: &numtabs;

  %* -- To count number of iterations in the loop -- ;
  %let iteration = 1;

  %* -- All tables need to be OK before we can proceed, but loop for a limited number of iterations. -- ;
  %do %until (&all_tabs_ok ^= 0 or &iteration > &max_iter);

    %* -- Initiate the macro variables for this iteration. Values will change when macro check_table_updated is called. -- ;
    %let all_tabs_ok = 1;
    %let tab_rows = 0;

    %* -- Loop through all tables. If at least one table has 0 rows for the current info date, all_tabs_ok will get value 0. -- ;
    %do i = 1 %to &numtabs;
      %check_table_updated(lib=&lib2check, tab=%scan(&tabs2check,&i), checkdate=&date2check);

      %* -- all_tabs_ok will get value 0 if one table has 0 rows, otherwise it will get value 1 -- ;
      %let all_tabs_ok = %sysevalf(&all_tabs_OK * &tab_rows);
      %if %eval(&all_tabs_ok ^= 0) %then %let all_tabs_ok = %sysevalf(&all_tabs_ok/&all_tabs_ok);

      %put NOTE: Iteration &iteration, table no &i: %scan(&tabs2check,&i);
      %put NOTE: Number of rows in table: &tab_rows;
      %put NOTE: &=all_tabs_ok;
    %end;

    %let iteration = %eval(&iteration + 1);

    %* -- Wait for specified number of seconds before next iteration -- ;
    %if %eval(&all_tabs_ok = 0) %then %do;
      data _null_;
        rc = sleep(&sec2wait,1);
      run;
    %end;

  %end;

  %if %eval(&all_tabs_ok = 0) %then %do;
    %put %sysfunc(cats(ERR,OR: All source tables for the project does not contain the information date &datchar.. Processing will be interrupted.));

    filename msg email
    to=("data@alandsbanken.fi")
    subject = "The run of EG project &egproj has been interrupted";

    data _null_;
      file msg;
      put "Execution of a SAS EG project has been interrupted when run for date &datchar..";
      put "All source tables needed for the project does not contain the information date &datchar., see the project log file for details.";
      put " ";
      put "Project: &egproj.";
      put "Location: &projpath.";
    run;

    data _null_ ;
      abort cancel;
    run;
  %end;

  %else %if %eval(&all_tabs_ok ^= 0) %then %do;
    %put NOTE: All source tables for this project have rows for the current information date, continue processing.;
  %end;

%mend check_tables_in_project;

/* Example ;
*%check_tables_in_project(egproj     = batch_daily_hypo_export_partner_files,
                         projpath   = K:\DW - Rådgivarstöd\DWI dataset\PROD\projects,
                         lib2check  = dwh_dw,
                         tabs2check = ACCOUNT ACCOUNT_COLLATERAL_LINK ACCOUNT_OWNERS 
                                      COLL_OBJECT_AMO_REQ COLLATERAL COLLATERAL_OBJECT_LINK CUSTOMER_L 
                                      LOAN_ACCOUNT_OWNERS LOAN_ADDITIONAL_DATA LOAN_COLL_OBJ_HOUSING 
                                      LOAN_COLL_OBJ_MORT LOAN_COLL_OBJ_REAL TRANSACTION);

* run for another day ;
*%check_tables_in_project(egproj     = batch_daily_hypo_export_partner_files,
                         projpath   = K:\DW - Rådgivarstöd\DWI dataset\PROD\projects,
                         lib2check  = dwh_dw,
                         tabs2check = ACCOUNT ACCOUNT_COLLATERAL_LINK ACCOUNT_OWNERS 
                                      COLL_OBJECT_AMO_REQ COLLATERAL COLLATERAL_OBJECT_LINK CUSTOMER_L 
                                      LOAN_ACCOUNT_OWNERS LOAN_ADDITIONAL_DATA LOAN_COLL_OBJ_HOUSING 
                                      LOAN_COLL_OBJ_MORT LOAN_COLL_OBJ_REAL TRANSACTION,
                         date2check = '12may23'd);

* run with other parameters for max number of iterations and seconds to wait ;
*%check_tables_in_project(egproj     = batch_daily_hypo_export_partner_files,
                         projpath   = K:\DW - Rådgivarstöd\DWI dataset\PROD\projects,
                         lib2check  = dwh_dw,
                         tabs2check = ACCOUNT ACCOUNT_COLLATERAL_LINK ACCOUNT_OWNERS 
                                      COLL_OBJECT_AMO_REQ COLLATERAL COLLATERAL_OBJECT_LINK CUSTOMER_L 
                                      LOAN_ACCOUNT_OWNERS LOAN_ADDITIONAL_DATA LOAN_COLL_OBJ_HOUSING 
                                      LOAN_COLL_OBJ_MORT LOAN_COLL_OBJ_REAL TRANSACTION,
                         sec2wait   = 30, 
                         max_iter   = 5);
*/

* -- Macro for checking if the specified log exists for the specified date (Oscar D 20231120) -- ;
* -- Default date is m_latest_bankday  + 1 since date_active will not have the right date if account is not updated -- ;
%macro check_logs_updated(dir=, log=, checkdate=&m_latest_bankday + 1);
	
	filename dirlist pipe "ls &dir*&log";
	data log_files;
	    infile dirlist truncover;
	    input log $1000.;
	run;

	data _null_;
	    date_string = put(&checkdate., yymmddn8.);
		call symput('date_string', date_string);
	run;

	%put date_string: &date_string.;

    %global log_exists;

	proc sql noprint;
	    select (case when max(index(log, "&date_string.")) > 0 then 1 else 0 end) 
	    into :log_exists
	    from log_files;
	quit;

	%put log_exists: &log_exists;

 %if %eval(&log_exists = 0) %then %put NOTE: The log &dir. *&log. is not updated &date_string. (run at: &sysdate9 &systime).;

%mend check_logs_updated;


* -- Macro for checking if all specified logs exist for specified date (Oscar D 20231120) -- ;
%macro check_logs_for_project(egproj=, projpath=, dir_to_check=, logs_to_check=, date_to_check=&m_latest_bankday + 1, sec_to_wait=60, max_iter=120);

  data _null_;
    call symput('datchar',put(&date_to_check,yymmddn8.));
  run;

  %* -- Initiate the macro variables before the first iteration. -- ;
  %global all_logs_ok log_exists;
  %let all_logs_ok = 0;
  %let log_exists = 0;

  %* -- Count number of logs to check -- ;
  %let num_logs = %sysfunc(countw(&logs_to_check, '|'));
  %put NOTE: Number of logs to check for this project: &num_logs;
  
  %put logs_to_check: &logs_to_check;

  %* -- To count number of iterations in the loop -- ;
  %let iteration = 1;

  %* -- All logs need to be OK before we can proceed, but loop for a limited number of iterations. -- ;
  %do %until (&all_logs_ok ^= 0 or &iteration > &max_iter);

    %* -- Initiate the macro variables for this iteration. Values will change when macro check_logs_updated is called. -- ;
    %let all_logs_ok = 1;
    %let log_exists = 0;

    %* -- Loop through all logs. If at least one log do not exist for the current date, all_logs_ok will get value 0. -- ;
    %do i = 1 %to &num_logs;
      %check_logs_updated(dir=&dir_to_check, log=%scan(&logs_to_check, &i, '|'), checkdate=&date_to_check);

      %* -- all_tabs_ok will get value 0 if one table has 0 rows, otherwise it will get value 1 -- ;
      %let all_logs_ok = %sysevalf(&all_logs_ok * &log_exists);
      %if %eval(&all_logs_ok ^= 0) %then %let all_logs_ok = %sysevalf(&all_logs_ok/&all_logs_ok);

      %put NOTE: Iteration &iteration, table no &i: %scan(&logs_to_check, &i, ' ');
      %put NOTE: Number of logs: &log_exists;
      %put NOTE: &=all_logs_ok;
    %end;

    %let iteration = %eval(&iteration + 1);

    %* -- Wait for specified number of seconds before next iteration -- ;
    %if %eval(&all_logs_ok = 0) %then %do;
      data _null_;
        rc = sleep(&sec_to_wait,1);
      run;
    %end;

  %end;

  %if %eval(&all_logs_ok = 0) %then %do;
    %put %sysfunc(cats(ERR,OR: All source logs for the project does not exist for &datchar.. Processing will be interrupted.));
  
    filename msg email
    to=("data@alandsbanken.fi")
    subject = "The run of EG project &egproj has been interrupted";

    data _null_;
      file msg;
      put "Execution of a SAS EG project has been interrupted when run for date &datchar..";
      put "All source tables needed for the project does not contain the date &datchar., see the project log file for details.";
      put " ";
      put "Project: &egproj.";
      put "Location: &projpath.";
    run;

    data _null_ ;
      abort cancel;
    run;
  %end;

  %else %if %eval(&all_logs_ok ^= 0) %then %do;
    %put NOTE: All logs for this project exists for the current date, continue processing.;

  %end;
	

%mend check_logs_for_project;




						 