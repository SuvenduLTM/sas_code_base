/* --- Start of code for "get tenant". --- */
%global dw_inlib dw_inlib_play dw_inlib_int dw_outlib dw_replib dw_paylib dw_inlib_miss nobs run_type tenant
date_active acc_monthly_date_active onefactor_date_active country_date_active max_limit_date rwael_date_active loan_date_active 
timedep_date_active acc_monthly_start_date card_date_active card_info_date card_dt_active profit_date_active env;

%let env=prod;
%let timestamp_start=%sysfunc(datetime());

%if &syshostname=aablstgsas21 %then %do;
	%let env=test;
%end;

%include "/sasdw/&env/int/programs/stp/finance/macros_dwi.sas";

	/* loads macros and runs macro for tenant and libs */	
/*%start_dwi_manual(path=hypo);
%start_dwi_manual(path=hypo);
%start_dwi();*/

/* CHANGE PATH TO FINANCE IF RUNNING EG PROJECT MANUALLY FOR ÅAB
** CHANGE PATH TO HYPO IF RUNNING EG PROJECT MANUALLY FOR HYPO
** WHEN RUNNING PROJECT AS STORED PROCESS THJE PATH IS DETERMINED FROM THE STP PATH AUTOMATICALLY INSTEAD OF THIS VARIABLE
*/

%start_dwi_manual(path=hypo);

%macro start_dwi_manual(path=);
	%if %symexist(_METAFOLDER)=0 %then %do; /* körs vid EG körning */
	/*---------------- OBS -------------------*/
	/* vid körning av projekt/skapa stp måste variabel initieras manuellt nedan. Används alltid AAB om ej ändras! */
		%get_libs(folder=hypo)
	%end;	
	%else %do;
		%get_tenant_libs()
	%end;

	%get_dates;

%mend;

%macro get_tenant_libs();



/* ---------------------------------------------------------------------------- *
   CHANGE LOG
   2022-04-08 Miaomiao: added hrtc_connection, hrtc_connection_ok
   2022-05-13 Adam: added crypto_trading, crypto_mainly, crypto_ok, bo_check, bo_checkUser, bo_checkDate
   2022-10-03 Jenny E: Added money_laundry_check_date
   2022-10-19 Jenny E: Added kyc_expiration_date 
   2022-10-20 Jenny E: Added gender, restructed the code   
   2023-01-11 Adam Ö: Added, external risk grade  
   2023-06-05 Adam Ö: Added, pep_status_change_date
 * ---------------------------------------------------------------------------- */

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_CUSTOMER_L_0000 AS 
   SELECT DISTINCT t1.name, 
          t1.information_date, 
          t1.bank_id, 
          t1.customer_id, 
          t1.ssn_id AS ssn, 
          t3.customer_status_txt AS customer_status, 
          t1.customer_type, 
          t3.customer_type_txt AS customer_type_text, 
	  case when t1.gender_cd = 0 then 'Company'
	       when t1.gender_cd = 1 then 'Man'
	       when t1.gender_cd = 2 then 'Kvinna'
	   else ''
          end as gender length=8,
          t2.result_office_id, 
          t2.result_office_txt_cbs AS result_office, 
          t2.business_area AS business_area, 
          t1.advisor1_id, 
          t1.advisor2_id, 
          t1.AAB_employee_status_cd, 
          t3.age, 
          t1.stat_sector_cd AS sector_cd, 
          t1.stat_branch_cd AS branch_cd, 
          t1.politically_exposed AS pep_flag, 
          t1.risk_grade_cd, 
 		  t1.external_risk_grade_value,			/*Lagt till external Risk grade Adam 2023.01.11*/
          t3.high_risk_country_flag, 
          t3.has_custody_flag AS has_custody, 
          t3.has_depot_accounts_flag, 
          t3.has_digital_services_flag AS has_digital_services, 
          t3.owns_credit_cards_flag AS has_credit_cards,   
          t3.has_currency_accounts_flag, 
          t3.use_others_corp_acc_flag AS access_accounts_flag_corporate, 
          t3.use_others_priv_acc_flag AS access_accounts_flag_private, 
          t3.has_loans_flag, 
          t3.has_bo_reps_flag, 
          t3.is_bo_reps_flag, 
          t3.owns_accounts_flag, 
          t3.owns_endowment_insurance_flag, 
          t3.debit_card_others_corp_acc_flag, 
          t3.debit_card_others_priv_acc_flag, 
          t3.has_services_flag AS has_services, 
          t4.deposit_balance AS deposits, 
          t4.deposit_balance_avg_m AS deposit_mean, 
          t4.lending_balance AS lending, 
          t4.lending_balance_avg_m AS lending_mean, 
          t4.credit_card_lending_balance AS lending_creditcard, 
          t4.aab_own_funds_market_value AS funds_aab, 
          t4.custody_other_mandate_mv AS securities_other, 
          t4.custody_consultative_mandate_mv AS managed_consultative, 
          t4.custody_discretionary_mandate_mv AS managed_discretionary_mandate_mv, 
          t4.custody_market_value, 
          t4.investable_finances_amt AS investable_capital, 
          t4.business_volume, 
          t3.concept AS concept_group, 
          t1.opened_date, 
          t3.kyc_status, 
          t1.money_laundry_check_date,
	  case when t1.money_laundry_check_date = . then today()
               when t1.risk_grade_cd = 3 then intnx('Year', coalesce(t1.money_laundry_check_date, today()-1 ), 1, 'S')
	       else intnx('Year', coalesce(t1.money_laundry_check_date, today()-1 ), 3, 'S')
	    end as kyc_expiration_date format=FINDFDD10. label='Next KYC Expiration date',
          t4.business_volume_eur, 
          t3.age_group, 
          t3.address_country_txt, 
          (CAT(trim(t3.address_post_office_nr),' ', trim(t3.address_post_office_name))) LENGTH=50 AS adress_post_office, 
          t2.nav_cost_center_cd LABEL='' AS cost_center_cd, 
          t3.latest_activity_dt AS last_activity_dt, 
          t3.latest_meeting_dt AS last_meeting_dt, 
          t3.customer_relationship_age, 
          (case 
            when t1.opened_date is missing then '20+'
            when customer_relationship_age>=0 and customer_relationship_age <=5 then '0-5'
            when customer_relationship_age>5 and customer_relationship_age <=10 then '06-10'
            when customer_relationship_age>10 and customer_relationship_age<=20 then '11-20'
            when customer_relationship_age>20 then '20+'
            end) AS customer_relationship_age_group, 
          t3.mandate_type, 
          t3.age_text, 
          (CAT(trim(t1.name),' (', trim(t1.ssn_id),')')) AS customer_number, 
          t3.portfolio_manager_id, 
          t2.segment, 
          t3.portfolio_manager_name AS portfolio_manager, 
          (case when business_volume_eur=0 then ""
            when business_volume_eur <1000 then '0 - 1000'
            when business_volume_eur >=1000 and business_volume_eur<10000 then '1000 - 10 000'
            when business_volume_eur >=10000 and business_volume_eur<100000 then '10 000 - 100 000'
            when business_volume_eur >=100000 and business_volume_eur<500000 then '100 000 - 500 000'
            when business_volume_eur >=500000 and business_volume_eur<2000000 then '500 000 - 2 000 000'
            when business_volume_eur >=2000000 and business_volume_eur<10000000 then '2 000 000 - 10 000 000'
            when business_volume_eur >=10000000 and business_volume_eur<50000000 then '10 000 000 - 50 000 000'
            when business_volume_eur >=500000000 then '50 000 000 000+'
            end) AS business_volume_group_eur, 
          (case when business_volume_eur=0 then "0"
            when business_volume_eur <1000 then "1"
            when business_volume_eur >=1000 and business_volume_eur<10000 then "2"
            when business_volume_eur >=10000 and business_volume_eur<100000 then "3"
            when business_volume_eur >=100000 and business_volume_eur<500000 then "4"
            when business_volume_eur >=500000 and business_volume_eur<2000000 then "5"
            when business_volume_eur >=2000000 and business_volume_eur<10000000 then "6"
            when business_volume_eur >=10000000 and business_volume_eur<50000000 then "7"
            when business_volume_eur >=500000000 then "8"
            end) AS business_volume_group_sort_order, 
          t4.allocated_capital_amt, 
          t1.lei, 
          t1.email, 
          t1.work_email, 
          t3.phone_nr, 
          t3.work_phone_nr, 
          t3.cell_phone_nr, 
          t3.other_cell_phone_nr, 
          (case when t1.direct_advertisment_cd=1 then 'Ja' else 'Nej' end) AS direct_advertisement_text, 
          (case when t1.electr_advertisment_cd=1 then 'Ja' else 'Nej' end) AS electronic_advertisement_text, 
          t5.customer_relations LABEL="Total exposure, calculated in RWAEL" AS customer_relations, 
          t5.customer_entity_flag, 
          t5.customer_entity_ssn, 
          t6.cairo_customer_url AS cairo_link, 
          t3.latest_login_dt AS digitalchannel_latest_login_dt, 
          t3.active_regular_fundsavings_flag, 
          (case when lang_cd='S' then 'Svenska'
            when lang_cd='E' then 'Engelska'
            when lang_cd='F' then 'Finska'
            end) AS lang_txt, 
          t1.id_doc_type_cd, 
          t3.profitability_class_r12, 

          t3.profitability_class_3m, 
          t3.lcr_class, 
          t3.lcr_deposit_balance, 
          t3.finrep_counterparty_type, 
          t3.credit_institute_flag, 
          t3.credit_institute_flag_hw, 
          t1.Hrtc_connection, 
          t1.Hrtc_connection_ok, 
          t1.crypto_trading, 
          t1.crypto_mainly, 
          t1.crypto_ok, 
          t1.bo_check, 
          t1.bo_checkUser, 
          t1.bo_checkDate,
		  /*lagt till adress/Joakim 2022.11.16*/
		  t3.address_street_1,
		  t3.address_street_2,
		  t3.address_co_name,
		  t3.birth_date
      FROM &dw_inlib..CUSTOMER (where=(information_date = &date_active)) t1
           LEFT JOIN &dw_inlib_int..RESULT_OFFICES_L t2 
             ON (t1.bank_id = t2.bank_id) AND (t1.result_office_id = t2.result_office_id)

           LEFT JOIN &dw_outlib..DWI_CUSTOMER_ATTR(where=(information_date = &date_active)) t3 
             ON (t1.bank_id = t3.bank_id) AND (t1.customer_id = t3.customer_id)

           LEFT JOIN &dw_outlib..DWI_CUSTOMER_BALANCE (where=(information_date = &date_active)) t4 
             ON (t1.information_date = t4.information_date) AND (t1.bank_id = t4.bank_id) AND (t1.customer_id = t4.customer_id)

           LEFT JOIN &dw_inlib_int..RWAEL (where=(information_date = &rwael_date_active)) t5 
             ON (t1.bank_id = t5.bank_id) AND (t1.ssn_id = t5.customer_ssn)

           LEFT JOIN &dw_outlib..SRC_CAIRO_CUSTOMER t6 
             ON (t1.bank_id = t6.bank_id) AND (t1.ssn_id = t6.ssn_id);
QUIT;


PROC SQL;
   CREATE TABLE WORK.CODES_USER_NAMES AS 
   SELECT *
      FROM &dw_inlib..CODES_USER_NAMES t1
      WHERE t1.information_date = &date_active;

   CREATE TABLE WORK.CODES_BRANCH_CODES AS 
   SELECT *
      FROM &dw_inlib..CODES_BRANCH_CODES t1
      WHERE t1.information_date = &date_active;

   CREATE TABLE WORK.CODES_SECTOR_CODES AS 
   SELECT *
      FROM &dw_inlib..CODES_SECTOR_CODES t1
      WHERE t1.information_date = &date_active;

   CREATE TABLE WORK.CODES_ID_TYPE AS 
   SELECT *
      FROM &dw_inlib..CODES_ID_TYPE t1
      WHERE t1.information_date = &date_active;
QUIT;


PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_BC_KL_TOTTABLE_0000 AS 
   SELECT (&profit_date_active) FORMAT=findfdd10. AS information_date, 
          (substr(t1.custid,1,1)) AS bank_id, 
          (substr(t1.custid,2,length(t1.custid))) AS customer_id, 
          t1.custid, 
          (SUM(t1.amount)) FORMAT=NUMX12. AS SUM_of_amount,
          (MAX(t1.information_date)) FORMAT=FINDFDD10. AS latest_date
      FROM &dw_inlib_play..BC_KL_TOTTABLE t1
           INNER JOIN &dw_inlib_play..BC_KL_CHART_OF_ACCOUNTS t2 
           ON (t1.source_cd = t2.source_cd)
      WHERE t2.typ = 'Intäkt' and 
            t1.information_date>intnx('day',&profit_date_active,-360,'same') AND t1.information_date <= &profit_date_active
      GROUP BY CALCULATED information_date,
               CALCULATED bank_id,
               CALCULATED customer_id,
               t1.custid;
QUIT;

PROC SQL;
   CREATE TABLE WORK.custlist_export AS 
   SELECT DISTINCT
		  t1.name, 
          t1.information_date, 
          t1.bank_id, 
          t1.customer_id, 
          t1.ssn, 
          t1.customer_status,          
          t1.customer_type, 
          t1.customer_type_text, 
	      t1.gender,
          t1.result_office_id, 
          t1.result_office, 
          t1.business_area, 
          t1.advisor1_id, 
          t2.long_name AS advisor1_name, 
          t1.advisor2_id, 
          t3.long_name AS advisor2_name, 
          t1.AAB_employee_status_cd, 
          t1.age, 
          t1.sector_cd, 
          t5.long_name AS sector, 
          t1.branch_cd, 
          t4.long_name AS branch, 
          t1.pep_flag, 
          t1.risk_grade_cd, 
		  t1.external_risk_grade_value,			/*Lagt till external Risk grade Adam Ö 2023.01.11*/

          t1.high_risk_country_flag, 
     	  t1.Hrtc_connection, 
          t1.Hrtc_connection_ok, 
          t1.crypto_trading, 
          t1.crypto_mainly, 
          t1.crypto_ok, 
          t1.bo_check, 
          t1.bo_checkUser, 
          t1.bo_checkDate,
          t7.long_name AS id_type, 
          t1.has_custody, 
          t1.has_depot_accounts_flag, 
          t1.has_digital_services, 
          t1.has_credit_cards,  
          t1.has_currency_accounts_flag, 
          t1.access_accounts_flag_corporate, 
          t1.access_accounts_flag_private, 
          t1.has_loans_flag, 
          t1.has_bo_reps_flag, 
          t1.is_bo_reps_flag, 
          t1.owns_accounts_flag, 
          t1.owns_endowment_insurance_flag, 
          t1.debit_card_others_corp_acc_flag, 
          t1.debit_card_others_priv_acc_flag, 
          t1.has_services, 
          t1.deposits, 
          t1.deposit_mean, 
          t1.lending, 
          t1.lending_mean, 
          t1.lending_creditcard, 
          t1.funds_aab, 
          t1.securities_other, 
          t1.managed_consultative, 
          t1.managed_discretionary_mandate_mv, 
          t1.custody_market_value, 
          t1.investable_capital, 
          t1.business_volume, 
          t1.concept_group, 
          t1.opened_date, 
          t1.kyc_status, 
          t1.money_laundry_check_date,
          t1.kyc_expiration_date,
          t6.SUM_of_amount AS profit_amt_ry, 
          t1.business_volume_eur, 
          t1.age_group, 
          t1.address_country_txt, 
          t1.adress_post_office, 
          t1.cost_center_cd, 
          t1.last_activity_dt, 
          t1.last_meeting_dt, 
          t1.customer_relationship_age, 
          t1.mandate_type, 
          t1.age_text, 
          t1.customer_number, 
          t1.portfolio_manager_id, 
          t1.segment, 
          t1.portfolio_manager, 
          t1.business_volume_group_eur, 
          t1.business_volume_group_sort_order, 
          t1.lei, 
          t1.email, 
          t1.work_email, 
          t1.phone_nr, 
          t1.work_phone_nr, 
          t1.cell_phone_nr, 
          t1.other_cell_phone_nr, 
          t1.direct_advertisement_text, 
          t1.electronic_advertisement_text, 
          t1.customer_relations, 
          t1.customer_entity_flag, 
          t1.customer_entity_ssn, 
          t1.cairo_link, 
          t1.digitalchannel_latest_login_dt, 
          t1.lang_txt, 
          t1.active_regular_fundsavings_flag, 
          t1.profitability_class_r12, 
          t1.profitability_class_3m, 
          t1.lcr_class, 
          t1.lcr_deposit_balance, 
          t1.finrep_counterparty_type, 
          t1.credit_institute_flag, 
          t1.credit_institute_flag_hw,
		  /*joakim 2022.11.16 adress lagt till*/
  		  t1.address_street_1,
		  t1.address_street_2,
		  t1.address_co_name,
		  t1.birth_date,
          (datetime()) FORMAT=datetime20. AS loaded_dt,
          case when "&tenant"="aab"  and t8.code_value_char is missing and t1.customer_status ne 'Ej kund' and t1.business_area NOT='PARTNER'
		         then 'rs'
               when "&tenant"="hypo" and t8.code_value_char is missing and t1.customer_status ne 'Ej kund'
                 then 'bg'
               when "&tenant"="aab"  and t1.business_area='PARTNER' 
                 then 'pa'
               else ''
          end as mart_flags length=20,
		 /* t1.pep_flag, 
		  t12.pep_flag as pep_previous,*/
		  case when t9.pep_flag = . then t9.pep_status_change_date when t1.pep_flag ne t9.pep_flag then &date_active         /* ändra t.12 till t9 på måndag */
			else t9.pep_status_change_date end as pep_status_change_date format=FINDFDD10.  /* Adam Ö 2023-06-05 */

      FROM WORK.QUERY_FOR_CUSTOMER_L_0000 t1
           LEFT JOIN WORK.CODES_USER_NAMES t2 
             ON (t1.bank_id = t2.bank_id) AND (t1.advisor1_id = t2.code_cd)

           LEFT JOIN WORK.CODES_USER_NAMES t3 
             ON (t1.bank_id = t3.bank_id) AND (t1.advisor2_id = t3.code_cd)

           LEFT JOIN WORK.CODES_BRANCH_CODES t4 
             ON (t1.bank_id = t4.bank_id) AND (t1.branch_cd = t4.code_cd)

           LEFT JOIN WORK.CODES_SECTOR_CODES t5 
             ON (t1.bank_id = t5.bank_id) AND (t1.sector_cd = t5.code_cd)

           LEFT JOIN WORK.QUERY_FOR_BC_KL_TOTTABLE_0000 t6 
             ON (t1.bank_id = t6.bank_id) AND (t1.customer_id = t6.customer_id)

           LEFT JOIN WORK.CODES_ID_TYPE t7 
             ON (t1.bank_id = t7.bank_id) AND (t1.id_doc_type_cd = t7.code_cd)

           LEFT JOIN DWI_FINA.BATCH_FILTERS t8 
             ON (t1.bank_id = t8.bank_id) AND (t1.customer_id = t8.code_value_char AND (t8.target_column='customer_id'))

		  LEFT JOIN dwi_hypo.dwi_customer_list_L t9 
			 on (t1.customer_id = t9.customer_id) /* Adam Ö 2023-06.05*/

          LEFT JOIN dwi_hypo.DWI_CUSTOMER_LIST t11
			 on (t1.customer_id = t11.customer_id) and t1.information_date = t11.information_date   /* Adam Ö 2023-06.05*/

		 /*LEFT JOIN dwi_hypo.DWI_CUSTOMER_LIST t12
		     on (t1.customer_id = t12.customer_id) and t12.information_date = '01Jun2023'd   /* Adam Ö 2023-06.05*/ 

      	  ORDER BY t1.information_date, t1.bank_id, t1.customer_id;

QUIT;

/*lägg till Vilja kunder, Miaomiao 2023-06-27*/
data vilja_cust;
set dwi_hypo.vilja_customer;
bank_id='V';
customer_id=id;
address_street_1=street_address;

format customer_type_text $12. adress_post_office $50.;
if entity_type = 'Customer' then do;
customer_type=1;
customer_type_text='Privatperson';
end;
else do;
customer_type=2;
customer_type_text='Företag';
end;

opened_date=datepart(created_dt1);
adress_post_office=catx(' ', address_id, city);
customer_number=catx(' ', name, cats('(', ssn, ')'));		 

keep name information_date bank_id customer_id address_street_1 ssn customer_type customer_type_text sector_cd opened_date
adress_post_office customer_number loaded_dt;
where information_date=&DATE_ACTIVE;
run;

proc sql;
create table vilja_not_in_cust as
select * 
from vilja_cust 
where ssn not in (select ssn from custlist_export);
quit;


data custlist_exp_v_och_c;
set custlist_export
vilja_not_in_cust;
run;


/* --- Start of code for "Export data". --- */
	%dwi_delete(
	del_lib=&dw_outlib,
	del_table=dwi_customer_list,
	del_date=&date_active);

	%dwi_insert(
	from_lib=work,
	from_table=custlist_export,
	to_lib=&dw_outlib,
	to_table=dwi_customer_list);

	%dwi_delete(
	del_lib=&dw_outlib,
	del_table=dwi_customer_list_Vilja_test,
	del_date=&date_active);

	%dwi_insert(
	from_lib=work,
	from_table=custlist_exp_v_och_c,
	to_lib=&dw_outlib,
	to_table=dwi_customer_list_Vilja_test);

	%dwi_create_latest(lib=&dw_outlib,table=dwi_customer_list_Vilja_test);

	%dwi_create_latest(lib=&dw_outlib,table=dwi_customer_list);

/* --- End of code for "Export data". --- */

/* --- Start of code for "log". --- */
%put _all_;



/* --- End of code for "log". --- */

*  Begin EG generated code (do not edit this line);
;*';*";*/;quit;
%STPEND;

*  End EG generated code (do not edit this line);

