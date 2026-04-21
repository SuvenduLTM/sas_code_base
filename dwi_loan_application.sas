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

/* --- End of code for "get tenant". --- */

/* --- Start of code for "get partner account types". --- */
%include "/sasdw/&env/int/programs/stp/finance/macros_hypo.sas";
/* temporary date setting */
%*let loan_date_active = "10nov2021"d;
%let date_active_application=&loan_date_active;
proc sql noprint;
select max(information_date) into :last_loanapp_date from dwi_hypo.dwi_loan_app_changes;
quit;
/* --- End of code for "get partner account types". --- */

/* --- Start of code for "LOANAPP CHANGES". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_LOAN_APPLICATION_0007);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_LOAN_APPLICATION_0007 AS 
   SELECT t1.information_date, 
          t1.case_id, 
          t1.application_id, 
          t1.partner_name, 
          t1.application_type, 
          t1.application_purpose, 
          t1.total_credit_amount, 
          t1.application_status, 
          t1.decision_status, 
          t1.currency_cd, 
          t1.created_dt, 
          t1.updated_dt, 
          t1.termination_dt, 
          t1.change_flag, 
          /* loaded_dt */
            (datetime()) FORMAT=datetime20. AS loaded_dt
      FROM DWH_DW.LOAN_APPLICATION t1
      WHERE t1.change_flag NOT IS MISSING AND t1.information_date > &last_loanapp_date;
QUIT;
/* --- End of code for "LOANAPP CHANGES". --- */

/* --- Start of code for "insert changed loanapps". --- */

%dwi_insert(
	from_lib = work,
	from_table = QUERY_FOR_LOAN_APPLICATION_0007,
	to_lib = &dw_outlib,
	to_table = dwi_loan_app_changes);


/* --- End of code for "insert changed loanapps". --- */

/* --- Start of code for "find applications missing from change because created after export but on same day". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_DWI_LOAN_APP_CHAN_0009);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_DWI_LOAN_APP_CHAN_0009 AS 
   SELECT DISTINCT /* information_date */
                     (information_date-1) FORMAT=findfdd10. AS information_date, 
          t2.case_id, 
          t2.application_id, 
          t2.partner_name, 
          t2.application_type, 
          t2.application_purpose, 
          t2.total_credit_amount, 
          t2.application_status, 
          t2.decision_status, 
          t2.application_pd, 
          t2.risk_classification, 
          t2.currency_cd, 
          t2.created_dt, 
          t2.updated_dt, 
          t2.termination_dt, 
          t2.change_flag, 
          /* loaded_dt */
            (datetime()) FORMAT=datetime20. AS loaded_dt, 
          /* change_flag_new */
            (case when
            datepart(created_dt)=information_date-1 AND timepart(created_dt)>"22:15:00"t then 'NEW'
            when datepart(updated_dt)=information_date-1 AND timepart(updated_dt)>"22:15:00"t then 'UPDATED'
            end) AS change_flag_new
      FROM DWH_DW.LOAN_APPLICATION t2
      WHERE (datepart(created_dt)=information_date-1 AND timepart(created_dt)>"22:15:00"t AND timepart(created_dt)<=
           "23:59:59"t) 
           OR 
           (datepart(updated_dt)=information_date-1 AND (updated_dt)>"22:15:00"t AND (updated_dt)<="23:59:59"t);
QUIT;
/* --- End of code for "find applications missing from change because created after export but on same day". --- */

/* --- Start of code for "Query Builder (11)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_DWI_LOAN_APP_CHAN);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_DWI_LOAN_APP_CHAN AS 
   SELECT t1.information_date, 
          t1.case_id, 
          t1.application_id, 
          t1.partner_name, 
          t1.application_type, 
          t1.application_purpose, 
          t1.total_credit_amount, 
          t1.application_status, 
          t1.decision_status, 
          t1.currency_cd, 
          t1.created_dt, 
          t1.updated_dt, 
          t1.termination_dt, 
          t1.change_flag_new AS change_flag, 
          t1.loaded_dt
      FROM WORK.QUERY_FOR_DWI_LOAN_APP_CHAN_0009 t1
           LEFT JOIN DWI_HYPO.DWI_LOAN_APP_CHANGES t2 ON (t1.information_date = t2.information_date) AND 
          (t1.change_flag_new = t2.change_flag) AND (t1.case_id = t2.case_id) AND (t1.application_id = 
          t2.application_id)
      WHERE t2.application_id IS MISSING;
QUIT;
/* --- End of code for "Query Builder (11)". --- */

/* --- Start of code for "insert missing changes". --- */
	%dwi_insert(
	from_lib = work,
	from_table = QUERY_FOR_DWI_LOAN_APP_CHAN,
	to_lib = &dw_outlib,
	to_table = dwi_loan_app_changes);

/*Borttagen av Miaomiao, 2023-04-20*/
/*	proc sort data=dwi_hypo.dwi_loan_app_changes force;*/
/*		by information_date;*/
/*	run;*/


/* --- End of code for "insert missing changes". --- */

/* --- Start of code for "Query Builder (2)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_LOAN_APPLICATION);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_LOAN_APPLICATION AS 
   SELECT t1.information_date, 
          t1.case_id, 
          t1.application_id, 
          t1.partner_name, 
          t1.application_type, 
          t1.application_purpose, 
          t1.total_credit_amount, 
          t1.application_status, 
          t1.decision_status, 
          t1.application_pd, 
          t1.risk_classification, 
          t1.currency_cd, 
          t1.created_dt, 
          t1.updated_dt, 
          t1.termination_dt, 
          t1.change_flag, 
		  t1.desired_disbursement_dt, /* Adam Ö 2022-12-14 */
		  t1.desired_increase_amount, /* Adam Ö 2022-12-14 */
		  t1.purpose_of_use, /* Adam Ö 2022-12-14 */
		  t1.sample_object,  /*Adam Ö 2023-11-15 */
          t1.loaded_dt
      FROM DWH_DW.LOAN_APPLICATION t1
      WHERE t1.information_date = &date_active_application;
QUIT;
/* --- End of code for "Query Builder (2)". --- */

/* --- Start of code for "Query Builder (5)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_LOAN_APPLICATION_CAL);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_LOAN_APPLICATION_CAL AS 
   SELECT t1.information_date, 
          t1.application_id, 
          t1.ltv_system_ratio, 
          t1.lti_system_ratio, 
          t1.ltv_application_ratio, 
          t1.lti_application_ratio, 
          t1.kalp, 
          t1.loaded_dt
      FROM DWH_DW.LOAN_APPLICATION_CAL t1
      WHERE t1.information_date = &date_active_application;
QUIT;
/* --- End of code for "Query Builder (5)". --- */


/* --- Start of code for "Query Builder (14)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_LOAN_ADDITIONAL_DATA);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_LOAN_ADDITIONAL_DATA AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.account_id, 
          t1.external_application_id, 
          t1.first_withdrawal_date
      FROM DWH_DW.LOAN_ADDITIONAL_DATA t1
      WHERE t1.information_date = &loan_date_active;
QUIT;
/* --- End of code for "Query Builder (14)". --- */

proc sql;  /* Adam Ö 2022-12-23 */
create table WORK.LOAN_APPLICATION_PREVIOUS_DAY as 
select information_date,
case_id, 
application_id, 
application_status,
decision_status,
created_dt, 
updated_dt, 
termination_dt,
change_flag 
from dwh_dw.loan_application
WHERE information_date = &loan_date_active -1;

QUIT;


/* --- Start of code for "Query Builder (13)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_LOAN_APPLICATION_0006);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_LOAN_APPLICATION_0006 AS 
   SELECT DISTINCT t1.information_date, 
          t1.case_id, 
          t1.application_id, 
          t1.partner_name, 
          t1.application_type, 
          t1.application_purpose, 
          t1.total_credit_amount, 
          t1.application_status, 
          t1.decision_status, 
          t1.application_pd, 
          t1.risk_classification, 
          t1.currency_cd, 
          t1.created_dt, 
          t1.updated_dt, 
          t1.termination_dt, 
          t1.change_flag, 
          t2.ltv_system_ratio, 
          t2.lti_system_ratio, 
          t2.ltv_application_ratio, 
          t2.lti_application_ratio, 
          t2.kalp, 
          /* loan_first_withdrawal_date */
            (MIN(t3.first_withdrawal_date)) FORMAT=FINDFDD10. AS loan_first_withdrawal_date,
		  t1.desired_disbursement_dt, /* Adam Ö 2022-12-14 */
		  t1.desired_increase_amount, /* Adam Ö 2022-12-14 */
		  t1.purpose_of_use,  /* Adam Ö 2022-12-14 */
		 (case when t1.decision_status = 'APPROVED' and t4.decision_status ne 'APPROVED' then &loan_date_active
			else t5.credit_decision_date end) as credit_decision_date format=FINDFDD10.,  /* Adam Ö 2022-12-23 */
		  t1.sample_object  /*Adam Ö 2023-11-15 */
      FROM WORK.QUERY_FOR_LOAN_APPLICATION t1
           LEFT JOIN WORK.QUERY_FOR_LOAN_APPLICATION_CAL t2 ON (t1.information_date = t2.information_date) AND 
          (t1.application_id = t2.application_id)
           LEFT JOIN WORK.QUERY_FOR_LOAN_ADDITIONAL_DATA t3 ON (t1.information_date = t3.information_date) AND 
          (t1.application_id = t3.external_application_id)
		   LEFT JOIN WORK.LOAN_APPLICATION_PREVIOUS_DAY t4 on t1.application_id = t4.application_id
		   LEFT JOIN dwi_hypo.DWI_LOAN_APPLICATION t5 on (t1.application_id = t5.application_id) AND (t5.information_date = (Select Max(information_date) from dwi_hypo.DWI_LOAN_APPLICATION))  /* Adam Ö 2022-12-29 */
      GROUP BY t1.information_date,
               t1.case_id,
               t1.application_id;
QUIT;
/* --- End of code for "Query Builder (13)". --- */

/* --- Start of code for "insert loanapps". --- */
%dwi_delete(
	del_lib = &dw_outlib,	
	del_table = dwi_loan_application,	
	del_date = &loan_date_active);

%dwi_insert(
	from_lib = work,
	from_table = QUERY_FOR_LOAN_APPLICATION_0006,
	to_lib = &dw_outlib,
	to_table = dwi_loan_application);


%dwi_create_latest(lib=&dw_outlib,table=dwi_loan_application);

/* --- End of code for "insert loanapps". --- */

/* --- Start of code for "Query Builder (10)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_CUSTOMER_PARTY_LINK);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_CUSTOMER_PARTY_LINK AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.party_id, 
          t1.party_type_cd, 
          t1.party_name_txt, 
          t1.roles_list, 
          t1.ssn_id, 
          t1.partner_relations, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt
      FROM DWH_DW.CUSTOMER_PARTY_LINK t1
      WHERE t1.information_date = &date_active_application;
QUIT;
/* --- End of code for "Query Builder (10)". --- */

/* --- Start of code for "Query Builder (17)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_CUSTOMER);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_CUSTOMER AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.customer_id, 
          t1.ssn_id, 
          t1.customer_type, 
          t1.birth_date, 
          t1.gender_cd, 
          t1.aab_employee_status_cd, 
          t1.opened_date, 
          t1.changed_date, 
          t1.deceased_date, 
          t1.name, 
          t1.person_last_name, 
          t1.person_first_name, 
          t1.co_name, 
          t1.street_address, 
          t1.street_address2, 
          t1.post_office_number, 
          t1.country_cd, 
          t1.state_province_cd, 
          t1.post_office_name, 
          t1.municipality_cd, 
          t1.adress_ok_cd, 
          t1.result_office_id, 
          t1.lang_cd, 
          t1.citizenship_cd, 
          t1.tax_country_cd, 

          t1.legal_form_cd, 
          t1.stat_sector_cd, 
          t1.stat_branch_cd, 
          t1.phone_country_nr, 
          t1.phone_area_nr, 
          t1.phone_number_nr, 
          t1.work_phone_country_nr, 
          t1.work_phone_area_nr, 

          t1.work_phone_number_nr, 
          t1.cell_phone_country_nr, 
          t1.cell_phone_area_nr, 
          t1.cell_phone_number_nr, 
          t1.other_cell_phone_countr_nr, 
          t1.other_cell_phone_area_nr, 
          t1.other_cell_phone_number_nr, 
          t1.email, 
          t1.work_email, 
          t1.direct_advertisment_cd, 
          t1.electr_advertisment_cd, 
          t1.advisor1_id, 
          t1.advisor2_id, 
          t1.issue_country_cd, 
          t1.foreign_tax_id, 
          t1.deviant_tax_cd, 
          t1.tax_pct, 
          t1.id_doc_nr, 
          t1.id_doc_exp_date, 
          t1.id_doc_type_cd, 
          t1.id_doc_issuer_cd, 
          t1.id_doc_country_cd, 
          t1.id_doc_copy, 
          t1.insider_cd, 
          t1.x_sign_id, 
          t1.tax_form_cd, 
          t1.tax_form_date, 
          t1.empl_situation_cd, 
          t1.empl_situation_start_date, 
          t1.politically_exposed, 
          t1.occupational_status_cd, 
          t1.profession, 
          t1.service_main_purpose_cd, 
          t1.payments_in_cnt, 
          t1.payments_in_amt, 
          t1.payments_out_cnt, 
          t1.payments_out_amt, 
          t1.foreign_payments_out_cnt, 
          t1.relation_boardmember, 
          t1.relation_boardmember_date, 
          t1.net_wage_income_monthly_amt, 
          t1.net_capital_income_yearly_amt, 
          t1.net_other_income_monthly_amt, 
          t1.net_total_income_monthly_amt, 
          t1.main_bank_private, 
          t1.main_bank_corp, 
          t1.fax_country_nr, 
          t1.fax_area_nr, 
          t1.fax_number_nr, 
          t1.trade_register_date, 
          t1.trade_register_number, 
          t1.dismissed_date, 
          t1.treaty_stmt, 
          t1.sole_propietor_holder_id, 
          t1.under_construction_start_date, 
          t1.fiscal_period_month_nr, 
          t1.fiscal_period_day_nr, 
          t1.capital_coverage_cd, 
          t1.turnover_amt, 
          t1.assets_total_amt, 
          t1.employees_cnt, 
          t1.signatory1_title, 
          t1.signatory2_title, 
          t1.signatory3_title, 
          t1.money_laundry_checked, 
          t1.money_laundry_check_date, 
          t1.lei, 
          t1.lei_expiry_date, 
          t1.active_customer_flag, 
          t1.account_customer_flag, 
          t1.risk_grade_cd, 
          t1.source_system_cd, 
          t1.search_name, 
          t1.id_issue_date, 
          t1.foreign_ssn, 
          t1.foreign_ssn_issued_in, 
          t1.extra_address_street_address, 
          t1.extra_address_street_address2, 
          t1.extra_address_co_name, 
          t1.extra_address_country_iso_cd, 
          t1.extra_address_state_province_cd, 
          t1.extra_address_post_cd, 
          t1.extra_address_city, 
          t1.extra_address_valid_from_date, 
          t1.extra_address_Valid_to_date, 
          t1.birth_place, 
          t1.birth_country, 
          t1.nationality2, 
          t1.tax_tin_regular, 
          t1.parallel_tax_tin1, 
          t1.parallel_tax_country1, 
          t1.parallel_tax_tin2, 
          t1.parallel_tax_country2, 
          t1.fatca_control, 
          t1.crsdac2_status_cd, 
          t1.owner_control, 
          t1.sector_spec_cd, 
          t1.work_rel_end_date, 
          t1.emp_info, 
          t1.other_profession, 
          t1.indirect_customer, 
          t1.other_serv_products, 
          t1.foreign_payments_in_amt, 
          t1.foregin_payments_out_amt, 
          t1.origin_in_payments, 
          t1.other_in_payments, 
          t1.origin_foreign_in_pay, 
          t1.other_foreign_in_pay, 
          t1.purpose_of_avg_payment, 
          t1.purp_of_international_trans, 
          t1.politics_status, 
          t1.risk_grade_freetext, 
          t1.cust_bank_relations, 

          t1.cust_fore_bank_relations, 
          t1.recommendation_letter, 
          t1.crsdac2_financial_type_cd, 
          t1.representative, 
          t1.copy_of_transcript, 
          t1.primary_reason, 
          t1.primary_reason_txt, 
          t1.origin_of_funds_cd, 
          t1.origin_of_funds_txt, 
          t1.domestic_incom_payment, 
          t1.domestic_outg_payment, 
          t1.use_of_cash, 
          t1.reg_foreign_trans, 
          t1.foreign_trans_country_cd, 
          t1.estimt_amt_of_foreign_trans, 
          t1.group_structure, 
          t1.dreams_customer_id, 
          t1.do_customer_id, 
          t1.chili_id, 
          t1.extracted_dt, 
          t1.loaded_dt
      FROM DWH_DW.CUSTOMER t1
      WHERE t1.information_date = &loan_date_active;
QUIT;
/* --- End of code for "Query Builder (17)". --- */

/* --- Start of code for "Query Builder (18)". --- */


%_eg_conditional_dropds(WORK.QUERY_FOR_CUSTOMER_PARTY_LI_0000);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_CUSTOMER_PARTY_LI_0000 AS 
   SELECT t2.information_date, 
          t2.bank_id, 
          t2.customer_id, 
          t2.ssn_id, 
          t1.party_id, 
          t1.party_type_cd, 
          t1.party_name_txt, 
          t1.roles_list, 
          t1.partner_relations, 
          t2.customer_type, 
          t2.birth_date, 
          t2.gender_cd, 
          t2.aab_employee_status_cd, 
          t2.opened_date, 
          t2.changed_date, 
          t2.deceased_date, 
          t2.name, 
          t2.person_last_name, 
          t2.person_first_name, 
          t2.co_name, 
          t2.street_address, 
          t2.street_address2, 
          t2.post_office_number, 
          t2.country_cd, 
          t2.state_province_cd, 
          t2.post_office_name, 
          t2.municipality_cd, 
          t2.adress_ok_cd, 
          t2.result_office_id, 
          t2.lang_cd, 
          t2.citizenship_cd, 
          t2.tax_country_cd, 
          t2.legal_form_cd, 
          t2.stat_sector_cd, 
          t2.stat_branch_cd, 
          t2.phone_country_nr, 
          t2.phone_area_nr, 
          t2.phone_number_nr, 
          t2.work_phone_country_nr, 
          t2.work_phone_area_nr, 
          t2.work_phone_number_nr, 
          t2.cell_phone_country_nr, 
          t2.cell_phone_area_nr, 
          t2.cell_phone_number_nr, 
          t2.other_cell_phone_countr_nr, 
          t2.other_cell_phone_area_nr, 
          t2.other_cell_phone_number_nr, 
          t2.email, 
          t2.work_email, 
          t2.direct_advertisment_cd, 
          t2.electr_advertisment_cd, 
          t2.advisor1_id, 
          t2.advisor2_id, 
          t2.issue_country_cd, 
          t2.foreign_tax_id, 
          t2.deviant_tax_cd, 
          t2.tax_pct, 
          t2.id_doc_nr, 
          t2.id_doc_exp_date, 

          t2.id_doc_type_cd, 
          t2.id_doc_issuer_cd, 
          t2.id_doc_country_cd, 
          t2.id_doc_copy, 
          t2.insider_cd, 
          t2.x_sign_id, 
          t2.tax_form_cd, 
          t2.tax_form_date, 
          t2.empl_situation_cd, 
          t2.empl_situation_start_date, 
          t2.politically_exposed, 
          t2.occupational_status_cd, 
          t2.profession, 
          t2.service_main_purpose_cd, 
          t2.payments_in_cnt, 
          t2.payments_in_amt, 
          t2.payments_out_cnt, 
          t2.payments_out_amt, 
          t2.foreign_payments_out_cnt, 
          t2.relation_boardmember, 
          t2.relation_boardmember_date, 
          t2.net_wage_income_monthly_amt, 
          t2.net_capital_income_yearly_amt, 
          t2.net_other_income_monthly_amt, 
          t2.net_total_income_monthly_amt, 
          t2.main_bank_private, 
          t2.main_bank_corp, 
          t2.fax_country_nr, 
          t2.fax_area_nr, 
          t2.fax_number_nr, 
          t2.trade_register_date, 
          t2.trade_register_number, 
          t2.dismissed_date, 
          t2.treaty_stmt, 
          t2.sole_propietor_holder_id, 
          t2.under_construction_start_date, 
          t2.fiscal_period_month_nr, 
          t2.fiscal_period_day_nr, 
          t2.capital_coverage_cd, 
          t2.turnover_amt, 
          t2.assets_total_amt, 
          t2.employees_cnt, 
          t2.signatory1_title, 
          t2.signatory2_title, 
          t2.signatory3_title, 
          t2.money_laundry_checked, 
          t2.money_laundry_check_date, 
          t2.lei, 
          t2.lei_expiry_date, 
          t2.active_customer_flag, 
          t2.account_customer_flag, 
          t2.risk_grade_cd, 
          t2.source_system_cd, 
          t2.search_name, 
          t2.id_issue_date, 
          t2.foreign_ssn, 
          t2.foreign_ssn_issued_in, 
          t2.extra_address_street_address, 
          t2.extra_address_street_address2, 
          t2.extra_address_co_name, 
          t2.extra_address_country_iso_cd, 
          t2.extra_address_state_province_cd, 
          t2.extra_address_post_cd, 

          t2.extra_address_city, 
          t2.extra_address_valid_from_date, 
          t2.extra_address_Valid_to_date, 
          t2.birth_place, 
          t2.birth_country, 
          t2.nationality2, 
          t2.tax_tin_regular, 
          t2.parallel_tax_tin1, 
          t2.parallel_tax_country1, 
          t2.parallel_tax_tin2, 
          t2.parallel_tax_country2, 
          t2.fatca_control, 
          t2.crsdac2_status_cd, 
          t2.owner_control, 
          t2.sector_spec_cd, 
          t2.work_rel_end_date, 
          t2.emp_info, 
          t2.other_profession, 
          t2.indirect_customer, 
          t2.other_serv_products, 
          t2.foreign_payments_in_amt, 
          t2.foregin_payments_out_amt, 
          t2.origin_in_payments, 
          t2.other_in_payments, 
          t2.origin_foreign_in_pay, 
          t2.other_foreign_in_pay, 
          t2.purpose_of_avg_payment, 
          t2.purp_of_international_trans, 
          t2.politics_status, 
          t2.risk_grade_freetext, 
          t2.cust_bank_relations, 
          t2.cust_fore_bank_relations, 
          t2.recommendation_letter, 
          t2.crsdac2_financial_type_cd, 
          t2.representative, 
          t2.copy_of_transcript, 
          t2.primary_reason, 
          t2.primary_reason_txt, 
          t2.origin_of_funds_cd, 
          t2.origin_of_funds_txt, 
          t2.domestic_incom_payment, 
          t2.domestic_outg_payment, 
          t2.use_of_cash, 
          t2.reg_foreign_trans, 
          t2.foreign_trans_country_cd, 
          t2.estimt_amt_of_foreign_trans, 
          t2.group_structure, 
          t2.dreams_customer_id, 
          t2.do_customer_id, 
          t2.chili_id, 
          t2.extracted_dt, 
          t2.loaded_dt
      FROM WORK.QUERY_FOR_CUSTOMER_PARTY_LINK t1, WORK.QUERY_FOR_CUSTOMER t2
      WHERE (t1.information_date = t2.information_date AND t1.bank_id = t2.bank_id AND t1.ssn_id = t2.ssn_id);
QUIT;
/* --- End of code for "Query Builder (18)". --- */

/* --- Start of code for "Query Builder (12)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_CUSTOMER_PROSPECTS);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_CUSTOMER_PROSPECTS AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.party_id, 
          t1.full_name, 
          t1.given_name, 
          t1.surname, 
          t1.revision_number, 
          t1.created_date, 
          t1.created_by_user, 
          t1.changed_date, 
          t1.changed_by_user, 
          t1.prospect_language, 
          t1.direct_advertising, 
          t1.electronic_advertising, 
          t1.advisor_1, 
          t1.advisor_2, 
          t1.result_office, 
          t1.birth_date, 
          t1.phone_number, 


          t1.private_email, 
          t1.due_date, 
          t1.reminder_date, 
          t1.asset_range, 
          t1.prospect_purpose, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt
      FROM DWH_DW.CUSTOMER_PROSPECTS t1
      WHERE t1.information_date = &loan_date_active;
QUIT;
/* --- End of code for "Query Builder (12)". --- */

/* --- Start of code for "Query Builder (15)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_CUSTOMER_PROSPECT);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_CUSTOMER_PROSPECT AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.party_id, 
          t1.party_type_cd, 
          t1.party_name_txt, 
          t1.ssn_id, 
          t1.partner_relations, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt
      FROM DWH_DW.CUSTOMER_PROSPECT t1
      WHERE t1.information_date = &loan_date_active;
QUIT;
/* --- End of code for "Query Builder (15)". --- */

/* --- Start of code for "Query Builder (16)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_CUSTOMER_PROSPECT_0000);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_CUSTOMER_PROSPECT_0000 AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.party_id, 
          t2.party_type_cd, 
          t2.party_name_txt, 
          t2.ssn_id, 
          t2.partner_relations, 
          t1.full_name, 
          t1.given_name, 
          t1.surname, 
          t1.revision_number, 
          t1.created_date, 
          t1.created_by_user, 
          t1.changed_date, 
          t1.changed_by_user, 
          t1.prospect_language, 
          t1.direct_advertising, 
          t1.electronic_advertising, 
          t1.advisor_1, 
          t1.advisor_2, 
          t1.result_office, 
          t1.birth_date, 
          t1.phone_number, 
          t1.private_email, 
          t1.due_date, 
          t1.reminder_date, 
          t1.asset_range, 
          t1.prospect_purpose, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt
      FROM WORK.QUERY_FOR_CUSTOMER_PROSPECTS t1, WORK.QUERY_FOR_CUSTOMER_PROSPECT t2

      WHERE (t1.information_date = t2.information_date AND t1.bank_id = t2.bank_id AND t1.party_id = t2.party_id);
QUIT;
/* --- End of code for "Query Builder (16)". --- */

/* --- Start of code for "Query Builder (3)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_LOAN_APPLICANT_EXT_REP);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_LOAN_APPLICANT_EXT_REP AS 
   SELECT t1.information_date, 
          t1.applicant_id, 
          t1.street, 
          t1.postal_code, 
          t1.civil_status, 
          t1.legally_incompetent, 
          t1.municipal_cd, 
          t1.county_cd, 
          t1.surplus_income, 
          t1.score_W1A092, 
          t1.inquiries, 
          t1.payment_claims, 
          t1.payment_complains, 
          t1.house_loans_credit_utilized, 
          t1.apartment_loans_credit_utilized, 
          t1.debt_cases, 

          t1.number_of_properties, 
          t1.taxable_value_property1_full, 
          t1.taxable_value_property2_full, 
          t1.taxable_owned_share_property1, 
          t1.taxable_owned_share_property2, 
          t1.other_credit_amount, 
          t1.is_pep, 
          t1.is_sanction_list, 
          t1.loaded_dt
      FROM DWH_DW.LOAN_APPLICANT_EXT_REPORT t1
      WHERE t1.information_date = &date_active_application;
QUIT;
/* --- End of code for "Query Builder (3)". --- */

/* --- Start of code for "Query Builder (4)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_LOAN_APPLICANT);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_LOAN_APPLICANT AS 
   SELECT t1.information_date, 
          t1.application_id, 
          t1.applicant_id, 
          t1.household_nr, 
          t1.national_id, 
          t1.ssn_id, 
          t1.email, 
          t1.mobile_phone_nr, 
          t1.is_primary_applicant, 
          t1.civil_status, 
          t1.employment_type, 
          t1.employment_start_date, 
          t1.income_employment, 
          t1.income_capital, 
          t1.monthly_cost, 
          t1.saving_amount, 
          t1.other_credits_amount, 
          t1.citizenship_within_EES, 
          t1.cost_student_loan, 
          t1.is_pep, 
          t1.member_swedish_church, 
          t1.number_of_properties, 
          t1.stated_amount_obligations, 
          t1.total_monthly_property_taxation, 
          t1.loaded_dt
      FROM DWH_DW.LOAN_APPLICANT t1
      WHERE t1.information_date = &date_active_application;
QUIT;
/* --- End of code for "Query Builder (4)". --- */

/* --- Start of code for "Query Builder (8)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_LOAN_APPLICATION_HOUSE);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_LOAN_APPLICATION_HOUSE AS 
   SELECT t1.information_date, 
          t1.application_id, 
          t1.household_number, 
          t1.housing_loan_amount, 
          t1.apartments_loan_amount, 
          t1.number_of_holiday_homes, 
          t1.number_of_houses, 
          t1.number_of_apartments, 
          t1.number_of_rental_apartments, 
          t1.operating_cost_holiday_homes, 
          t1.operating_cost_houses, 
          t1.operating_cost_apartments, 
          t1.operating_cost_rented_apartments, 
          t1.ground_rent_other_accommodations, 
          t1.loaded_dt
      FROM DWH_DW.LOAN_APPLICATION_HOUSEHOLD t1
      WHERE t1.information_date = &date_active_application;
QUIT;
/* --- End of code for "Query Builder (8)". --- */

/* --- Start of code for "LOAN APPLICANTS". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_LOAN_APPLICANT_0002);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_LOAN_APPLICANT_0002 AS 
   SELECT t1.information_date, 
          t1.application_id, 
          t1.applicant_id, 
          /* applicant_status */
            (case when t5.ssn_id is not missing then 'CUSTOMER' 
            when t4.ssn_id is not missing then 'PROSPECT'
            else 'APPLICANT'
            end) AS applicant_status, 
          t1.household_nr, 
          t1.national_id, 
          t1.ssn_id, 
          /* name */
            (case when t5.name is not missing then t5.name else t4.full_name end) AS name, 
          /* partner_relations */
            (case when t5.partner_relations is not missing then t5.partner_relations else t4.partner_relations end) AS 
            partner_relations, 
          t1.email, 
          t1.mobile_phone_nr, 
          t1.is_primary_applicant, 
          t1.civil_status, 
          t1.employment_type, 
          t1.employment_start_date, 
          t1.income_employment, 
          t1.income_capital, 
          t1.monthly_cost, 
          t1.saving_amount, 
          t1.other_credits_amount, 
          t1.citizenship_within_EES, 
          t1.cost_student_loan, 
          t1.is_pep, 
          t1.member_swedish_church, 
          t1.number_of_properties, 
          t1.stated_amount_obligations, 
          t1.total_monthly_property_taxation, 
          t2.street AS uc_street, 
          t2.postal_code AS uc_postal_code, 
          t2.civil_status AS uc_civil_status, 
          t2.legally_incompetent AS uc_legally_incompetent, 
          t2.municipal_cd AS uc_municipal_cd, 
          t2.county_cd AS uc_county_cd, 
          t2.surplus_income AS uc_surplus_income, 
          t2.score_W1A092 AS uc_score_W1A092, 
          t2.inquiries AS uc_inquiries_count, 
          t2.payment_claims AS uc_payment_claims_count, 
          t2.payment_complains AS uc_payment_complains_count, 
          t2.house_loans_credit_utilized AS uc_house_loans_credit_utilized, 
          t2.apartment_loans_credit_utilized AS uc_apartm_loans_credit_utilized, 
          t2.debt_cases AS uc_debt_cases_count, 
          t2.number_of_properties AS uc_number_of_properties, 
          t2.taxable_value_property1_full AS uc_taxable_value_prop1_full, 
          t2.taxable_value_property2_full AS uc_taxable_value_prop2_full, 
          t2.taxable_owned_share_property1 AS uc_taxable_own_share_property1, 
          t2.taxable_owned_share_property2 AS uc_taxable_own_share_property2, 
          t2.other_credit_amount AS uc_other_credit_amount, 
          t2.is_pep AS iw_is_pep, 
          t2.is_sanction_list AS iw_is_sanction_list, 
          t3.housing_loan_amount AS hh_housing_loan_amount, 
          t3.apartments_loan_amount AS hh_apartments_loan_amount, 
          t3.number_of_holiday_homes AS hh_number_of_holiday_homes, 
          t3.number_of_houses AS hh_number_of_houses, 
          t3.number_of_apartments AS hh_number_of_apartments, 
          t3.number_of_rental_apartments AS hh_number_of_rental_apartments, 
          t3.operating_cost_holiday_homes AS hh_operating_cost_holiday_homes, 
          t3.operating_cost_houses AS hh_operating_cost_houses, 
          t3.operating_cost_apartments AS hh_operating_cost_apartments, 
          t3.operating_cost_rented_apartments AS hh_operating_cost_rented_apartm, 
          t3.ground_rent_other_accommodations AS hh_ground_rent_other_accomm, 
          t2.loaded_dt
      FROM WORK.QUERY_FOR_LOAN_APPLICANT t1
           LEFT JOIN WORK.QUERY_FOR_LOAN_APPLICANT_EXT_REP t2 ON (t1.information_date = t2.information_date) AND 
          (t1.applicant_id = t2.applicant_id)
           LEFT JOIN WORK.QUERY_FOR_LOAN_APPLICATION_HOUSE t3 ON (t1.information_date = t3.information_date) AND 
          (t1.application_id = t3.application_id) AND (t1.household_nr = t3.household_number)
           LEFT JOIN WORK.QUERY_FOR_CUSTOMER_PROSPECT_0000 t4 ON (t1.information_date = t4.information_date) AND 
          (t1.ssn_id = t4.ssn_id)
           LEFT JOIN WORK.QUERY_FOR_CUSTOMER_PARTY_LI_0000 t5 ON (t1.information_date = t5.information_date) AND 
          (t1.ssn_id = t5.ssn_id);
QUIT;
/* --- End of code for "LOAN APPLICANTS". --- */

/* --- Start of code for "insert loan applicants". --- */
	%dwi_delete(
	del_lib = &dw_outlib,	
	del_table = dwi_loan_applicant,	
	del_date = &loan_date_active);

	%dwi_insert(
	from_lib = work,
	from_table = QUERY_FOR_LOAN_APPLICANT_0002,
	to_lib = &dw_outlib,
	to_table = dwi_loan_applicant);

	%dwi_create_latest(lib=&dw_outlib,table=dwi_loan_applicant);

/* --- End of code for "insert loan applicants". --- */

/* --- Start of code for "Query Builder (7)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_LOAN_APPLICATION_COLLA);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_LOAN_APPLICATION_COLLA AS 
   SELECT t1.information_date, 
          t1.collateral_id, 
          t1.application_id, 
          t1.insured_flag, 
          t1.accommodation_type, 
          t1.apartment_number, 
          t1.loan_object_flag, 
          t1.credit_amount, 
          t1.purchase_price, 
          t1.monthly_fee, 
          t1.market_value, 
          t1.house_ground_rent_amount, 
          t1.operating_cost, 
          t1.living_area, 
          t1.loaded_dt
      FROM DWH_DW.LOAN_APPLICATION_COLLATERAL t1
      WHERE t1.information_date = &date_active_application;
QUIT;
/* --- End of code for "Query Builder (7)". --- */

/* --- Start of code for "Query Builder (6)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_LOAN_APPLICATION_COLL_);


PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_LOAN_APPLICATION_COLL_ AS 
   SELECT t1.information_date, 
          t1.collateral_id, 
          t1.application_id, 
          t1.property_designation, 
          t1.cooperative_organisation_type, 
          t1.cooperative_status, 
          t1.cooperative_number_apartments, 
          t1.cooperative_debts_per_sqm, 
          t1.cooperative_debts_total, 
          t1.cooperative_rates_total, 
          t1.cooperative_living_area, 
          t1.market_value, 
          t1.market_value_down, 
          t1.credit_amount, 
          t1.ownership_external_percentage, 
          t1.taxation_value_full_value, 
          t1.property_type_code, 
          t1.municipal_code, 
          t1.county_code, 
          t1.loaded_dt
      FROM DWH_DW.LOAN_APPLICATION_COLL_EX_REP t1
      WHERE t1.information_date = &date_active_application;
QUIT;
/* --- End of code for "Query Builder (6)". --- */

/* --- Start of code for "Query Builder". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_LOAN_APPLICATION_AMORT);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_LOAN_APPLICATION_AMORT AS 
   SELECT t1.information_date, 
          t1.application_id, 
          t1.collateral_id, 
          t1.amortization_basis_value, 
          t1.amortization_basis_debt, 
          t1.amortization_basis_date, 
          t1.current_rule_framework, 
          t1.credit_amt_based_on_alt_rule, 
          t1.monthly_amort_alt_rule, 
          t1.credit_amt_without_amort_req, 
          t1.credit_amt_based_on_ltv, 
          t1.credit_amt_Based_on_ltv_lti, 
          t1.monthly_amortization_total, 
          t1.monthly_amort_main_rule, 
          t1.updated_dt, 
          t1.loaded_dt
      FROM DWH_DW.LOAN_APPLICATION_AMORT_BASE t1
      WHERE t1.information_date = &date_active_application;
QUIT;
/* --- End of code for "Query Builder". --- */

/* --- Start of code for "Query Builder (9)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_LOAN_APPLICATION__0000);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_LOAN_APPLICATION__0000 AS 
   SELECT t1.information_date, 
          t1.collateral_id, 
          t1.application_id, 
          t1.insured_flag, 
          t1.accommodation_type, 
          t1.apartment_number, 
          t1.loan_object_flag, 
          t1.credit_amount, 
          t1.purchase_price, 
          t1.monthly_fee, 
          t1.market_value, 
          t1.house_ground_rent_amount, 
          t1.operating_cost, 
          t1.living_area, 
          t2.property_designation AS uc_property_designation, 
          t2.cooperative_organisation_type AS uc_cooperative_organisation_type, 
          t2.cooperative_status AS uc_cooperative_status, 
          t2.cooperative_number_apartments AS uc_cooperative_number_apartments, 
          t2.cooperative_debts_per_sqm AS uc_cooperative_debts_per_sqm, 
          t2.cooperative_debts_total AS uc_cooperative_debts_total, 
          t2.cooperative_rates_total AS uc_cooperative_rates_total, 
          t2.cooperative_living_area AS uc_cooperative_living_area, 
          t2.market_value AS uc_market_value, 
          t2.market_value_down AS uc_market_value_down, 
          t2.credit_amount AS uc_credit_amount, 
          t2.ownership_external_percentage AS uc_ownership_external_pct, 
          t2.taxation_value_full_value AS uc_taxation_value_full_value, 
          t2.property_type_code AS uc_property_type_code, 
          t2.municipal_code AS uc_municipal_code, 
          t2.county_code AS uc_county_code, 
          t3.amortization_basis_value AS amortization_basis_value, 
          t3.amortization_basis_debt AS amortization_basis_debt, 
          t3.amortization_basis_date, 
          t3.current_rule_framework, 
          t3.credit_amt_based_on_alt_rule, 
          t3.monthly_amort_alt_rule, 
          t3.credit_amt_without_amort_req, 
          t3.credit_amt_based_on_ltv, 
          t3.credit_amt_based_on_ltv_lti, 
          t3.monthly_amortization_total, 
          t3.monthly_amort_main_rule, 
          t3.updated_dt
      FROM WORK.QUERY_FOR_LOAN_APPLICATION_COLLA t1
           LEFT JOIN WORK.QUERY_FOR_LOAN_APPLICATION_COLL_ t2 ON (t1.information_date = t2.information_date) AND 
          (t1.collateral_id = t2.collateral_id) AND (t1.application_id = t2.application_id)
           LEFT JOIN WORK.QUERY_FOR_LOAN_APPLICATION_AMORT t3 ON (t1.information_date = t3.information_date) AND 
          (t1.collateral_id = t3.collateral_id) AND (t1.application_id = t3.application_id);
QUIT;
/* --- End of code for "Query Builder (9)". --- */

/* --- Start of code for "insert loan app collateral". --- */
	%dwi_delete(
	del_lib = &dw_outlib,	
	del_table = dwi_loan_app_collateral,	
	del_date = &loan_date_active);

	%dwi_insert(
	from_lib = work,
	from_table = QUERY_FOR_LOAN_APPLICATION__0000,
	to_lib = &dw_outlib,
	to_table = dwi_loan_app_collateral);

	%dwi_create_latest(lib=&dw_outlib,table=dwi_loan_app_collateral);

/* --- End of code for "insert loan app collateral". --- */

/* --- Start of code for "log - Copy". --- */

%dwi_log(lib=&dw_outlib,str1="dwi_loan_application",str2="", timestamp_start=&timestamp_start,timestamp_end=%sysfunc(datetime()),user="&_metauser",tenant="&tenant");


/* --- End of code for "log - Copy". --- */

*  Begin EG generated code (do not edit this line);
;*';*";*/;quit;
%STPEND;

*  End EG generated code (do not edit this line);

