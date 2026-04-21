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
%start_dwi_manual(path=hypo);

/* --- End of code for "get tenant". --- */

/* --- Start of code for "get latest date". --- */
PROC SQL noprint;

	  SELECT distinct t1.month_end_date format= Best8. into :acc_month_interval separated by ','
          FROM C_CTRL.PAR_BANK_DAYS_L t1
      WHERE t1.information_date <= &acc_monthly_date_active
		/*and t1.information_date >= intnx('month',&acc_monthly_date_active,-15,'same');*/
	and t1.information_date>='1jan2020'd;
quit;
/*%let date_active="31oct2021"d;
%let loan_date_active="31oct2021"d;

*/
/* --- End of code for "get latest date". --- */

/* --- Start of code for "get data". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_CREDIT_SYSTEM_CODES_L);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_CREDIT_SYSTEM_CODES_L AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.code_category_id, 
          t1.code_cd AS purpose_of_use_cd, 
          t1.language_cd, 
          t1.short_value_txt, 
          t1.long_value_txt AS purpose_of_use_name, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt
      FROM &dw_inlib..CREDIT_SYSTEM_CODES_L t1
      WHERE t1.code_category_id = 'PURPOSE_OF_USE' AND t1.language_cd = 'sv';
QUIT;

%_eg_conditional_dropds(WORK.LIMIT_L);
proc sql;
create table work.LIMIT_L as 
select * from &dw_inlib..LIMIT 
where information_date=&loan_date_active;
quit;

%_eg_conditional_dropds(WORK.LOAN_ADDITIONAL_DATA_L);
proc sql;
create table work.LOAN_ADDITIONAL_DATA_L as 
select * from &dw_inlib..LOAN_ADDITIONAL_DATA
where information_date=&loan_date_active;
quit;


%_eg_conditional_dropds(WORK.QUERY_FOR_ACCOUNT);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_ACCOUNT AS 
   SELECT *
		FROM &dw_inlib..ACCOUNT t1
      WHERE t1.currency_cd NOT = 'FIM' AND t1.account_type_cd NOT = '380' AND t1.information_date =&date_active;
QUIT;

%_eg_conditional_dropds(WORK.QUERY_FOR_ACCOUNT_DAILY);
proc sql;
create table work.QUERY_FOR_ACCOUNT_DAILY AS
select * from &dw_inlib..ACCOUNT_DAILY
where information_date=&date_active;
quit;

%_eg_conditional_dropds(WORK.COC_L);
proc sql;
create table work.COC_L as 
select * from &dw_outlib..CREDITS_ON_COLLECTION
where information_date=&loan_date_active;
quit;

%_eg_conditional_dropds(WORK.ACCOUNTS_L);
proc sql;
create table work.ACCOUNTS_L as 
select * from &dw_outlib..DWI_ACCOUNTS
where information_date=&loan_date_active;
quit;

%_eg_conditional_dropds(WORK.CUSTLIST_L);
proc sql;
create table work.CUSTLIST_L as 
select * from &dw_outlib..DWI_CUSTOMER_LIST
where information_date=&loan_date_active;
quit;

%_eg_conditional_dropds(WORK.QUERY_FOR_CREDIT_FORBEARANCE);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_CREDIT_FORBEARANCE AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.account_id, 
          t1.forbearance_status_cd, 
          t1.forbearance_date, 
          t1.action_status_cd, 
          t1.performing_status_cd, 
          t1.forbearance_txt, 
          t1.action_txt, 
          t1.performing_txt, 
          /* forbearance */
            ("1") AS forbearance
      FROM &dw_inlib_miss..CREDIT_FORBEARANCE t1;
QUIT;

%_eg_conditional_dropds(WORK.QUERY_FOR_CREDITS_ON_COLLECTION);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_CREDITS_ON_COLLECTION AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.account_id, 
          t1.original_account_id, 
          t1.collection_amt, 
          t1.juridical_case_nr, 
          /* credit_on_collection */
            ("1") AS credit_on_collection, 
          /* account_id_edited */
            (Case when t1.original_account_id="0" Then t1.account_id
            Else t1.original_account_id
            END) AS account_id_edited
      FROM &dw_inlib_miss..CREDITS_ON_COLLECTION t1
      WHERE t1.information_date IN 
           (
           &acc_month_interval
           );
QUIT;
proc sql;
create table work.ECL_COREBANK_L as select * from dwh_finr.ecl_corebank where information_date=&profit_date_active;
quit;

proc sql;
create table work.ACCOUNT_CREDIT_LINK as select * from dwh_dw.account_credit_link; 
quit;

proc sql;
create table work.LOAN_PROPERTIES as select * from dwh_dw.loan_properties; 
quit;


/* --- End of code for "get data". --- */

/* --- Start of code for "Query Builder". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_BC_LIST_CONTRACT_FTP);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_BC_LIST_CONTRACT_FTP AS 
   SELECT t3.information_date, 
          t3.bank_id, 
          t3.account_id, 
          t3.iban_number_id, 
          t3.account_number_official, 
          t3.account_type_cd, 
          t3.owner_id, 
          t3.owner_ssn_id, 
          /* custid */
            (CAT(t3.bank_id,t3.owner_id)) AS custid, 
          t2.external_application_id, 
          t2.reference_interest_type AS credit_ref_interest_cd, 
          t2.ref_interest_fix_period_m, 
          t2.interest_calculation_type, 
          t3.currency_cd AS currency_cd, 
          t2.purpose_of_use_cd, 
          t5.purpose_of_use_name LABEL='', 
          t2.first_withdrawal_date, 
          t3.opened_date, 
          /* new_contract_flag */
            (case when intnx('Month', t3.opened_date,0,'E')=t3.information_date Then "1"
            Else "0"
            END) AS new_contract_flag, 
          t3.changed_date, 
          t2.loan_end_date, 
          t2.loan_duration_m AS contract_length, 
          t2.loan_cancellation_date, 
          t2.total_interest_rate AS credit_interest_rate_pct, 
          t2.effective_interest_rate, 
          t2.production_price_rate, 
          t2.balance_amount, 
          t2.original_loan_amount, 
          t2.withdrawable_today_amount, 
          t2.total_withdrawable_amount, 
          t2.additional_loan_amount, 
          t2.renegotiated_loan_amount, 
          t2.interest_period_start_date, 
          t2.previous_renegotiation_date, 
          t2.next_renegotiation_date, 
          t2.interest_reduction, 
          t2.interest_reduction_rate, 
          t2.interest_reduction_start_date, 
          t2.interest_reduction_end_date, 
          t2.payment_plan_cd, 
          /* payment_plan_text */
            (Case when t2.payment_plan_cd="4" then "Bullet"
            when t2.payment_plan_cd="3" then "Rak amortering"
            when t2.payment_plan_cd="2" then "Annuitet"
            when t2.payment_plan_cd="1" then "Fast rat"
            when t2.payment_plan_cd="0" Then "Saknas"
            END) AS payment_plan_text, 
          t2.payment_plan_principal, 
          t2.payment_plan_interest, 
/*Jenny E 2022-09-12:
          t2.principal_payment_d, 
          t2.interest_payment_d, */
          t2.install_plan_standard_pay_amount, 
          t2.notification_fee, 
          t2.prior_information, 
          t2.penalty_interest_pct, 
          t2.total_due_interest_amount, 
          t2.total_due_principal_amount, 
          t2.inv_payment_spec_fee AS total_due_fee_amt, 
          t2.inv_payment_spec_pen_interest AS total_due_penalty_interest_amt, 
          t2.inv_payment_due_date, 
          t2.inv_pay_interest_per_start_date, 
          t2.inv_pay_interest_per_end_date, 
          t2.previous_interest_rate, 
          t2.previous_interest_change_date, 
          t2.next_interest_change_date, 
          t2.next_principal_payment_date, 
          t2.next_principal_payment_amount, 
/*Jenny E 2022-09-12:
          t2.next_interest_payment_date, */
          t2.next_interest_amount, 
          t2.next_payment_due_date, 
          t2.next_pay_interest_per_start_date, 
          t2.next_pay_interest_per_end_date, 
          t2.next_pay_spec_interest, 
          t2.next_inv_pay_spec_principal, 
          t2.next_inv_pay_spec_fee, 
          t2.next_inv_pay_spec_pen_interest, 
          t2.overdue_oldest_due_date, 
          t2.overdue_pay_spec_interest, 
          t2.overdue_pay_spec_principal, 
          t2.overdue_due_pay_spec_fee, 
          t2.overdue_pay_spec_pen_interest, 
          t2.last_inv_date, 
          t2.amortization_alternative_rule, 
          t2.amortization_ltv_flag, 
          t2.amortization_dept_ratio_flag, 
          t2.mortgage_loan_type_cd, 
          t2.unmanaged_days_cnt, 
          t2.unmanaged_days_max_cnt,
/*nya variabler, Miaomiao, 20220610*/
					t2.migration_flag,
					t2.ocr_number,
					t2.mandate_status
      FROM WORK.LOAN_ADDITIONAL_DATA_L t2
           LEFT JOIN WORK.QUERY_FOR_CREDIT_SYSTEM_CODES_L t5 ON (t2.bank_id = t5.bank_id) AND (t2.purpose_of_use_cd = 
          t5.purpose_of_use_cd)
           LEFT JOIN WORK.QUERY_FOR_ACCOUNT t3 ON (t2.bank_id = t3.bank_id) AND (t2.account_id = t3.account_id)
           LEFT JOIN WORK.CUSTLIST_L t1 ON (t3.bank_id = t1.bank_id) AND (t3.owner_ssn_id = t1.ssn);
QUIT;
/* --- End of code for "Query Builder". --- */

/* --- Start of code for "Append Table". --- */
%_eg_conditional_dropds(WORK.Append_Table);
PROC SQL;
CREATE TABLE WORK.Append_Table AS 
SELECT * FROM WORK.QUERY_FOR_BC_LIST_CONTRACT_FTP
;
Quit;

/* --- End of code for "Append Table". --- */

/* --- Start of code for "Query Builder (20)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_ACCOUNT_0000);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_ACCOUNT_0000 AS 
   SELECT /* inf */
            (INTNX('MONTH', t1.information_date,0,'E')) FORMAT=FINDFDD10. AS inf, 
          t1.information_date, 
          t1.bank_id, 
          t1.account_id, 
          t1.account_number_official, 
          t1.iban_number_id, 
          t1.account_type_cd, 
          t1.currency_cd, 
          t1.owner_id, 
          t1.owner_ssn_id, 
          t1.shared, 
          t1.result_office_id, 
          t1.opened_date, 
          t1.changed_date, 
          t1.end_date, 
          t1.close_date, 
          t1.statement_period_cd, 
          t1.group_account_id, 
          t1.reference_date, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt, 
          t2.credit_ref_interest_cd, 
          t2.credit_interest_rate_pct, 
          t2.credit_margin_rate_pct
      FROM WORK.QUERY_FOR_ACCOUNT t1, WORK.QUERY_FOR_ACCOUNT_DAILY t2
      WHERE (t1.information_date = t2.information_date AND t1.bank_id = t2.bank_id AND t1.account_id = t2.account_id);
QUIT;
/* --- End of code for "Query Builder (20)". --- */

/* --- Start of code for "Query Builder (21)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_ACCOUNT_0001);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_ACCOUNT_0001 AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.account_id, 
          t1.account_number_official, 
          t1.iban_number_id, 
          t1.account_type_cd, 
          t1.currency_cd, 
          t1.owner_id, 
          t1.owner_ssn_id, 
          t1.shared, 
          t1.result_office_id, 
          t1.opened_date, 
          t1.changed_date, 
          t1.end_date, 
          t1.close_date, 
          t1.statement_period_cd, 
          t1.group_account_id, 
          t1.reference_date, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt, 
          t1.credit_ref_interest_cd, 
          t1.credit_interest_rate_pct, 
          t1.credit_margin_rate_pct
      FROM WORK.QUERY_FOR_ACCOUNT_0000 t1;
QUIT;
/* --- End of code for "Query Builder (21)". --- */

/* --- Start of code for "Query Builder (6)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_RWAEL);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_RWAEL AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.credit_number, 
          t1.amount_1, 
          t1.cf_type_1, 
          t1.cf_pct_1, 
          t1.amount_2, 
          t1.cf_type_2, 
          t1.cf_pct_2, 
          t1.tot_ead, 
          t1.ead_1, 
          t1.ead_2, 
          t1.tot_sm_amount, 
          t1.sm_cf_type_1, 
          t1.sm_cf_pct_1, 
          t1.sm_amount_1, 
          t1.sm_cf_type_2, 
          t1.sm_cf_pct_2, 
          t1.sm_amount_2, 
          t1.old_ead, 
          t1.irb_amount, 
          t1.s_value, 
          t1.credit_risk_type, 
          t1.sm_rwa_amount, 
          t1.irb_rwa_amount, 
          t1.irb_rw_pct, 
          t1.irb_lgd_pct, 
          t1.credit_rw_pct, 
          t1.credit_pd, 
          t1.irb_expected_loss, 
          t1.s_group, 
          t1.legal_form, 
          t1.group_pd, 
          t1.class_pd, 
          t1.purpose_of_use, 
          t1.credit_type, 
          t1.credit_open_date, 
          t1.customer_ssn, 
          t1.customer_name, 
          t1.shared_customer_id, 
          t1.customer_advisor_name, 
          t1.result_office_id, 
          t1.aab_employee_status_cd, 
          t1.total_credit_amount, 
          t1.decision_maker_name, 
          t1.rapporteur_name, 
          t1.decision_maker_cd, 
          t1.ltv_value, 
          t1.ltv_group, 
          t1.risk_group_text, 
          t1.lgd_class_nr, 
          t1.lgd_class_value, 
          t1.pd_class_nr_prev_month, 
          t1.pd_class_nr, 
          t1.credit_close_date, 
          t1.sm_risk_weight_pct, 
          t1.nr_of_oponents, 
          t1.writedown_amount, 
          t1.customer_entity_flag, 
          t1.customer_entity_ssn, 
          t1.customer_relations, 
          t1.customer_entity_relations, 
          t1.house_company_30, 
          t1.crm_amount, 
          t1.other_collateral_amount, 
          t1.stat_sector_cd, 
          t1.stat_branch_cd, 
          t1.customer_agreement_cd, 
          t1.payment_plan, 
          t1.result_office_name, 
          t1.area_sector, 
          t1.guarantee_commission, 
          t1.marginal, 
          t1.limit_commission, 
          t1.rating_class, 
          t1.rating_date, 
          t1.sm_k_amount, 
          t1.irb_k_amount, 
          t1.qj_date, 
          t1.qj_approve_date, 
          t1.leap_time, 
          t1.mortgage_grade, 
          t1.credit_deficit, 
          t1.pd_class_nr_calc, 
          t1.pd_class_nr_wht, 
          t1.qj_special_lending_category, 
          t1.qj_score, 
          t1.qj_form_type, 
          t1.annual_review_ovr_pd_class, 
          t1.annual_review_pd_class, 
          t1.annual_review_reg_date, 
          t1.annual_review_exp_date, 
          t1.base_for_decision_date, 
          t1.is_pd_override, 
          t1.pd_override_code, 
          t1.weighted_pd_class, 
          t1.frozen_pd_qj_date, 
          t1.customer_limit_reg_date, 
          t1.customer_limit_amount, 
          t1.customer_limit_max_sec_deficit, 
          t1.cf_credit_group, 
          t1.cf_type_group, 
          t1.ref_rate_type, 
          t1.interest_rate, 
          t1.customer_type, 
          t1.stat_branch_text_group, 
          t1.stat_branch_text, 
          t1.gross_income, 
          t1.currency, 
          t1.company_currency, 
          t1.exchange_rate, 
          t1.sm_k_amount_b, 
          t1.irb_k_amount_b, 
          t1.supporting_factor_approved, 
          t1.exposure_amount_b, 
          t1.turnover, 
          t1.haircut, 
          t1.frpdwhtpr, 
          t1.pdwhtpr, 
          t1.requires_annual_review, 
          t1.housing_credit, 
          /* RISK */
            (CAT(t1.risk_group_text,t1.pd_class_nr,t1.lgd_class_nr)) AS RISK
      FROM DWH_GEN.RWAEL t1
      WHERE t1.information_date IN 
           (
           &rwael_date_active
           );
QUIT;
/* --- End of code for "Query Builder (6)". --- */

/* --- Start of code for "Query Builder (3) - Copy". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_RWAEL_0001);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_RWAEL_0001 AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.credit_number, 
          t1.amount_1, 
          t1.cf_type_1, 
          t1.cf_pct_1, 
          t1.amount_2, 
          t1.cf_type_2, 
          t1.cf_pct_2, 
          t1.tot_ead, 
          t1.ead_1, 
          t1.ead_2, 
          t1.tot_sm_amount, 
          t1.sm_cf_type_1, 
          t1.sm_cf_pct_1, 
          t1.sm_amount_1, 
          t1.sm_cf_type_2, 
          t1.sm_cf_pct_2, 
          t1.sm_amount_2, 
          t1.old_ead, 
          t1.irb_amount, 
          t1.s_value, 
          t1.credit_risk_type, 
          t1.sm_rwa_amount, 
          t1.irb_rwa_amount, 
          t1.irb_rw_pct, 
          t1.irb_lgd_pct, 
          t1.credit_rw_pct, 
          t1.credit_pd, 
          t1.irb_expected_loss, 
          t1.s_group, 
          t1.legal_form, 
          t1.group_pd, 
          t1.class_pd, 
          t1.purpose_of_use, 
          t1.credit_type, 
          t1.credit_open_date, 
          t1.customer_ssn, 
          t1.customer_name, 
          t1.shared_customer_id, 
          t1.customer_advisor_name, 
          t1.result_office_id, 
          t1.aab_employee_status_cd, 
          t1.total_credit_amount, 
          t1.decision_maker_name, 
          t1.rapporteur_name, 
          t1.decision_maker_cd, 
          t1.ltv_value, 
          t1.ltv_group, 
          t1.risk_group_text, 
          t1.lgd_class_nr, 
          t1.lgd_class_value, 
          t1.pd_class_nr_prev_month, 
          t1.pd_class_nr, 
          t1.credit_close_date, 
          t1.sm_risk_weight_pct, 
          t1.nr_of_oponents, 
          t1.writedown_amount, 
          t1.customer_entity_flag, 
          t1.customer_entity_ssn, 
          t1.customer_relations, 
          t1.customer_entity_relations, 
          t1.house_company_30, 
          t1.crm_amount, 
          t1.other_collateral_amount, 
          t1.stat_sector_cd, 
          t1.stat_branch_cd, 
          t1.customer_agreement_cd, 
          t1.payment_plan, 
          t1.result_office_name, 
          t1.area_sector, 
          t1.guarantee_commission, 
          t1.marginal, 
          t1.limit_commission, 
          t1.rating_class, 
          t1.rating_date, 
          t1.sm_k_amount, 
          t1.irb_k_amount, 
          t1.qj_date, 
          t1.qj_approve_date, 
          t1.leap_time, 
          t1.mortgage_grade, 
          t1.credit_deficit, 
          t1.pd_class_nr_calc, 
          t1.pd_class_nr_wht, 
          t1.qj_special_lending_category, 
          t1.qj_score, 
          t1.qj_form_type, 
          t1.annual_review_ovr_pd_class, 
          t1.annual_review_pd_class, 
          t1.annual_review_reg_date, 
          t1.annual_review_exp_date, 
          t1.base_for_decision_date, 
          t1.is_pd_override, 
          t1.pd_override_code, 
          t1.weighted_pd_class, 
          t1.frozen_pd_qj_date, 
          t1.customer_limit_reg_date, 
          t1.customer_limit_amount, 
          t1.customer_limit_max_sec_deficit, 
          t1.cf_credit_group, 
          t1.cf_type_group, 
          t1.ref_rate_type, 
          t1.interest_rate, 
          t1.customer_type, 
          t1.stat_branch_text_group, 
          t1.stat_branch_text, 
          t1.gross_income, 
          t1.currency, 
          t1.company_currency, 
          t1.exchange_rate, 
          t1.sm_k_amount_b, 
          t1.irb_k_amount_b, 
          t1.supporting_factor_approved, 
          t1.exposure_amount_b, 
          t1.turnover, 
          t1.haircut, 
          t1.frpdwhtpr, 
          t1.pdwhtpr, 
          t1.requires_annual_review, 
          t1.housing_credit, 
          t1.RISK
      FROM WORK.QUERY_FOR_RWAEL t1;
QUIT;
/* --- End of code for "Query Builder (3) - Copy". --- */

/* --- Start of code for "Query Builder (3)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_REAL_PROPERTY_SWE_OBJE);









PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_REAL_PROPERTY_SWE_OBJE AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.internal_object_id, 
          t1.plot_name, 
          t1.block_id, 
          t1.address_street_1, 
          t1.address_street_2, 
          t1.address_city, 
          t1.municipality_cd, 
          t1.post_office_number_id, 
          t1.country_cd, 
          t1.leasehold_right_flag, 
          t1.tax_year, 
          t1.tax_value_amt, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt, 
          /* object_id */
            (cat(t1.bank_id,t1.internal_object_id)) AS object_id
      FROM DWH_DW.REAL_PROPERTY_SWE_OBJECT t1
      WHERE t1.information_date = &loan_date_active;
QUIT;
/* --- End of code for "Query Builder (3)". --- */

/* --- Start of code for "Query Builder (28)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_PAR_CODES);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_PAR_CODES AS 
   SELECT t1.code_cd_txt AS Risk, 
          t1.text_swe AS risk_level
      FROM DWI_HYPO.PAR_CODES t1
      WHERE t1.code_type = 'RISK_LEVEL';
QUIT;
/* --- End of code for "Query Builder (28)". --- */

/* --- Start of code for "Query Builder (2) - Copy". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_RWAEL_0000);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_RWAEL_0000 AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.credit_number, 
          t1.amount_1, 
          t1.cf_type_1, 
          t1.cf_pct_1, 
          t1.amount_2, 
          t1.cf_type_2, 
          t1.cf_pct_2, 
          t1.tot_ead, 
          t1.ead_1, 
          t1.ead_2, 
          t1.tot_sm_amount, 
          t1.sm_cf_type_1, 
          t1.sm_cf_pct_1, 
          t1.sm_amount_1, 
          t1.sm_cf_type_2, 
          t1.sm_cf_pct_2, 
          t1.sm_amount_2, 
          t1.old_ead, 
          t1.irb_amount, 
          t1.s_value, 
          t1.credit_risk_type, 
          t1.sm_rwa_amount, 

          t1.irb_rwa_amount, 
          t1.irb_rw_pct, 
          t1.irb_lgd_pct, 
          t1.credit_rw_pct, 
          t1.credit_pd, 
          t1.irb_expected_loss, 
          t1.s_group, 
          t1.legal_form, 
          t1.group_pd, 
          t1.class_pd, 
          t1.purpose_of_use, 
          t1.credit_type, 
          t1.credit_open_date, 
          t1.customer_ssn, 
          t1.customer_name, 
          t1.shared_customer_id, 
          t1.customer_advisor_name, 
          t1.result_office_id, 
          t1.aab_employee_status_cd, 
          t1.total_credit_amount, 
          t1.decision_maker_name, 
          t1.rapporteur_name, 
          t1.decision_maker_cd, 
          t1.ltv_value, 
          t1.ltv_group, 
          t1.risk_group_text, 
          t1.lgd_class_nr, 
          t1.lgd_class_value, 
          t1.pd_class_nr_prev_month, 
          t1.pd_class_nr, 
          t1.credit_close_date, 
          t1.sm_risk_weight_pct, 
          t1.nr_of_oponents, 
          t1.writedown_amount, 
          t1.house_company_30, 
          t1.crm_amount, 
          t1.other_collateral_amount, 
          t1.stat_sector_cd, 
          t1.stat_branch_cd, 
          t1.customer_agreement_cd, 
          t1.payment_plan, 
          t1.result_office_name, 
          t1.area_sector, 
          t1.guarantee_commission, 
          t1.marginal, 
          t1.limit_commission, 
          t1.rating_class, 
          t1.rating_date, 
          t1.sm_k_amount, 
          t1.irb_k_amount, 
          t1.qj_date, 
          t1.qj_approve_date, 
          t1.leap_time, 
          t1.mortgage_grade, 
          t1.credit_deficit, 
          t1.pd_class_nr_calc, 
          t1.pd_class_nr_wht, 
          t1.qj_special_lending_category, 
          t1.qj_score, 
          t1.qj_form_type, 
          t1.annual_review_ovr_pd_class, 
          t1.annual_review_pd_class, 
          t1.annual_review_reg_date, 
          t1.annual_review_exp_date, 
          t1.base_for_decision_date, 
          t1.is_pd_override, 
          t1.pd_override_code, 
          t1.weighted_pd_class, 
          t1.frozen_pd_qj_date, 
          t1.customer_limit_reg_date, 
          t1.customer_limit_amount, 
          t1.customer_limit_max_sec_deficit, 
          t1.cf_credit_group, 
          t1.cf_type_group, 
          t1.ref_rate_type, 
          t1.interest_rate, 
          t1.customer_type, 
          t1.stat_branch_text_group, 
          t1.stat_branch_text, 
          t1.gross_income, 
          t1.currency, 
          t1.company_currency, 
          t1.exchange_rate, 
          t1.sm_k_amount_b, 
          t1.irb_k_amount_b, 
          t1.supporting_factor_approved, 
          t1.exposure_amount_b, 
          t1.turnover, 
          t1.haircut, 
          t1.frpdwhtpr, 
          t1.pdwhtpr, 
          t1.requires_annual_review, 
          t1.housing_credit, 
          t1.customer_entity_flag, 
          t1.customer_entity_ssn, 
          t1.customer_relations, 

          t1.customer_entity_relations, 
          t1.RISK, 
          /* risk_level */
            (Case 
            when (t1.credit_risk_type="S" AND t1.credit_rw_pct=50) Then "Låg"
            when (t1.credit_risk_type="S" AND t1.credit_rw_pct=70) Then "Låg"
            when (t1.credit_risk_type="S" AND t1.credit_rw_pct=90) Then "Skälig"
            when (t1.credit_risk_type="S" AND t1.credit_rw_pct=115) Then "Hög"
            when (t1.credit_risk_type="S" AND t1.credit_rw_pct=250) Then "Hög"
            when (t1.credit_risk_type="S" AND t1.credit_rw_pct=0) Then "Fallerad"
            Else t2.risk_level
            END) AS risk_level
      FROM WORK.QUERY_FOR_RWAEL_0001 t1
           LEFT JOIN WORK.QUERY_FOR_PAR_CODES t2 ON (t1.RISK = t2.Risk);
QUIT;
/* --- End of code for "Query Builder (2) - Copy". --- */

/* --- Start of code for "Query Builder (4)". --- */
%_eg_conditional_dropds(WORK.HYP_CREDIT_LIST);

PROC SQL;
   CREATE TABLE WORK.HYP_CREDIT_LIST AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.account_id, 
          t1.iban_number_id, 
          t1.account_number_official, 
          t7.credit_id,  /* ny kolumn Adam Ö, 2022-11-14*/
          t1.account_type_cd, 
          t1.owner_id AS owner_id, 
          t1.owner_ssn_id, 
          t1.custid AS custid, 
          t1.external_application_id, 
          t1.credit_ref_interest_cd, 
          t1.ref_interest_fix_period_m, 
          t1.interest_calculation_type, 
          t1.currency_cd, 
          t1.purpose_of_use_cd, 
          t1.purpose_of_use_name, 
          t1.first_withdrawal_date, 
          t1.opened_date, 
          t1.new_contract_flag, 
          t1.changed_date, 
          t1.loan_end_date, 
          t1.contract_length, 
          t1.loan_cancellation_date AS loan_cancellation_date, 
          t1.credit_interest_rate_pct, 
          t1.effective_interest_rate, 
          t1.production_price_rate, 
          t1.balance_amount, 
          t1.original_loan_amount, 

          t1.withdrawable_today_amount, 
          t1.total_withdrawable_amount, 
          t1.additional_loan_amount, 
          t1.renegotiated_loan_amount, 
          t1.interest_period_start_date, 
          t1.previous_renegotiation_date, 
          t1.next_renegotiation_date, 
          t1.interest_reduction, 
          t1.interest_reduction_rate, 
          t1.interest_reduction_start_date, 
          t1.interest_reduction_end_date, 
          t1.payment_plan_cd, 
          t1.payment_plan_text, 
          t1.payment_plan_principal, 
          t1.payment_plan_interest, 
/*Jenny E 2022-09-12:
          t1.principal_payment_d, 
          t1.interest_payment_d, 
          t1.next_interest_payment_date, 
*/
          t1.install_plan_standard_pay_amount, 
          t1.notification_fee, 
          t1.prior_information, 
          t1.penalty_interest_pct, 
          t1.total_due_interest_amount, 
          t1.total_due_principal_amount, 
          t1.total_due_fee_amt, 

          t1.total_due_penalty_interest_amt, 
          t1.inv_payment_due_date, 
          t1.inv_pay_interest_per_start_date, 
          t1.inv_pay_interest_per_end_date, 
          t1.previous_interest_rate, 
          t1.previous_interest_change_date, 
          t1.next_interest_change_date, 
          t1.next_principal_payment_date, 
          t1.next_principal_payment_amount, 

          t1.next_interest_amount, 
          t1.next_payment_due_date, 
          t1.next_pay_interest_per_start_date, 
          t1.next_pay_interest_per_end_date, 
          t1.next_pay_spec_interest, 
          t1.next_inv_pay_spec_principal, 
          t1.next_inv_pay_spec_fee, 
          t1.next_inv_pay_spec_pen_interest, 
          t1.overdue_oldest_due_date, 
          t1.overdue_pay_spec_interest, 
          t1.overdue_pay_spec_principal, 
          t1.overdue_due_pay_spec_fee, 
          t1.overdue_pay_spec_pen_interest, 
          t1.last_inv_date, 
          t1.amortization_alternative_rule, 

          t1.amortization_ltv_flag, 
          t1.amortization_dept_ratio_flag, 
          t1.mortgage_loan_type_cd, 
          t1.unmanaged_days_cnt, 
/*nya variabler, Miaomiao, 20220610*/
                                                  t1.migration_flag,
                                                  t1.ocr_number,
                                                  t1.mandate_status,

          t5.risk_level AS risk_level, 
          t4.on_balance_ecl FORMAT=NUMX12. AS on_balance_ecl, 
          t4.off_balance_ecl FORMAT=NUMX12. AS off_balance_ecl, 
          t4.on_balance_ecl_change_amt FORMAT=NUMX12. AS on_balance_ecl_change_amt, 
          t4.off_balance_ecl_change_amt FORMAT=NUMX12. AS off_balance_ecl_change_amt, 
          t4.stage, 
          t4.stage_prev_month, 
          t4.stage_status, 
          t4.on_balance_ecl_cause_of_change, 
          t4.off_balance_ecl_cause_of_change, 
          t6.lgd_future_1_pct, 
          t6.pd_actual_lifetime_pct, 
          t6.ead_future_1_amt, 
          t5.housing_credit, 
          t5.requires_annual_review, 
          t5.credit_deficit FORMAT=NUMX12. AS credit_deficit, 
          t5.decision_maker_name, 
          t5.rapporteur_name, 
          /* directdebiting_account_1_id */
            ('') AS directdebiting_account_1_id, 
          t5.irb_expected_loss FORMAT=NUMX12. AS irb_expected_loss, 
          t5.irb_k_amount FORMAT=NUMX12. AS irb_k_amount, 
          t5.ltv_value FORMAT=NUMX5.3 AS ltv_value, 
          t5.risk_group_text, 
          t5.class_pd FORMAT=NUMX6.4 AS class_pd, 
          t5.lgd_class_nr, 
          t5.lgd_class_value FORMAT=NUMX5.3 AS lgd_class_value, 
          t5.pd_class_nr, 
          /* total_credit_amount */
            (-t5.total_credit_amount) FORMAT=NUMX12. AS total_credit_amount


      FROM WORK.APPEND_TABLE t1
           LEFT JOIN WORK.ECL_COREBANK_L t4 ON (t1.information_date = t4.information_date) AND (t1.bank_id = 
          t4.bank_id) AND (t1.account_id = t4.account_id)

           LEFT JOIN WORK.QUERY_FOR_RWAEL_0000 t5 ON (t1.information_date = t5.information_date) AND (t1.bank_id = 
          t5.bank_id) AND (t1.account_number_official = t5.credit_number)
           LEFT JOIN WORK.QUERY_FOR_ACCOUNT_0001 t2 ON (t1.information_date = t2.information_date) AND (t1.bank_id = 
          t2.bank_id) AND (t1.account_id = t2.account_id)
           LEFT JOIN WORK.QUERY_FOR_CREDIT_FORBEARANCE t3 ON (t1.information_date = t3.information_date) AND 
          (t1.bank_id = t3.bank_id) AND (t1.account_id = t3.account_id)
           LEFT JOIN DWH_DW.ECL_RESULTS t6 ON (t1.information_date = t6.information_date) AND (t1.bank_id = t6.bank_id) 
          AND (t1.account_id = t6.account_id)
                       LEFT JOIN WORK.ACCOUNT_CREDIT_LINK t7 ON (t1.information_date = t7.information_date) AND (t1.bank_id = t7.bank_id) 
                      AND (t1.account_number_official = t7.account_number_official_2);
  
QUIT;

PROC SQL;
   CREATE TABLE WORK.HYP_CREDIT_LIST_TEST AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.account_id, 
          t1.iban_number_id, 
          t1.account_number_official, 
          t7.credit_id,  /* ny kolumn Adam Ö, 2022-11-14*/
          t1.account_type_cd, 
          t1.owner_id AS owner_id, 
          t1.owner_ssn_id, 
          t1.custid AS custid, 
          t1.external_application_id, 
          t1.credit_ref_interest_cd, 
          t1.ref_interest_fix_period_m, 
          t1.interest_calculation_type, 
          t1.currency_cd, 
          t1.purpose_of_use_cd, 
          t1.purpose_of_use_name, 
          t1.first_withdrawal_date, 
          t1.opened_date, 
          t1.new_contract_flag, 
          t1.changed_date, 
          t1.loan_end_date, 
          t1.contract_length, 
          t1.loan_cancellation_date AS loan_cancellation_date, 
          t1.credit_interest_rate_pct, 
          t1.effective_interest_rate, 
          t1.production_price_rate, 
          t1.balance_amount, 
          t1.original_loan_amount, 
          t1.withdrawable_today_amount, 
          t1.total_withdrawable_amount, 
          t1.additional_loan_amount, 
          t1.renegotiated_loan_amount, 
          t1.interest_period_start_date, 
          t1.previous_renegotiation_date, 
          t1.next_renegotiation_date, 
          t1.interest_reduction, 
          t1.interest_reduction_rate, 
          t1.interest_reduction_start_date, 
          t1.interest_reduction_end_date, 
          t1.payment_plan_cd, 
          t1.payment_plan_text, 
          t1.payment_plan_principal, 
          t1.payment_plan_interest, 
/*Jenny E 2022-09-12:
          t1.principal_payment_d, 
          t1.interest_payment_d, 
          t1.next_interest_payment_date, 
*/
          t1.install_plan_standard_pay_amount, 
          t1.notification_fee, 
          t1.prior_information, 
          t1.penalty_interest_pct, 
          t1.total_due_interest_amount, 
          t1.total_due_principal_amount, 
          t1.total_due_fee_amt, 

          t1.total_due_penalty_interest_amt, 
          t1.inv_payment_due_date, 
          t1.inv_pay_interest_per_start_date, 
          t1.inv_pay_interest_per_end_date, 
          t1.previous_interest_rate, 
          t1.previous_interest_change_date, 
          t1.next_interest_change_date, 
          t1.next_principal_payment_date, 
          t1.next_principal_payment_amount, 
          t1.next_interest_amount, 
          t1.next_payment_due_date, 
          t1.next_pay_interest_per_start_date, 
          t1.next_pay_interest_per_end_date, 
          t1.next_pay_spec_interest, 
          t1.next_inv_pay_spec_principal, 
          t1.next_inv_pay_spec_fee, 
          t1.next_inv_pay_spec_pen_interest, 
          t1.overdue_oldest_due_date, 
          t1.overdue_pay_spec_interest, 
          t1.overdue_pay_spec_principal, 
          t1.overdue_due_pay_spec_fee, 
          t1.overdue_pay_spec_pen_interest, 
          t1.last_inv_date, 
          t1.amortization_alternative_rule, 
          t1.amortization_ltv_flag, 
          t1.amortization_dept_ratio_flag, 
          t1.mortgage_loan_type_cd, 
          t1.unmanaged_days_cnt, 
/*nya variabler, Miaomiao, 20220610*/
                                                  t1.migration_flag,
                                                  t1.ocr_number,
                                                  t1.mandate_status,

          t5.risk_level AS risk_level, 
          t4.on_balance_ecl FORMAT=NUMX12. AS on_balance_ecl, 
          t4.off_balance_ecl FORMAT=NUMX12. AS off_balance_ecl, 
          t4.on_balance_ecl_change_amt FORMAT=NUMX12. AS on_balance_ecl_change_amt, 
          t4.off_balance_ecl_change_amt FORMAT=NUMX12. AS off_balance_ecl_change_amt, 
          t4.stage, 
          t4.stage_prev_month, 
          t4.stage_status, 
          t4.on_balance_ecl_cause_of_change, 
          t4.off_balance_ecl_cause_of_change, 
          t6.lgd_future_1_pct, 
          t6.pd_actual_lifetime_pct, 
          t6.ead_future_1_amt, 

          t5.housing_credit, 
          t5.requires_annual_review, 
          t5.credit_deficit FORMAT=NUMX12. AS credit_deficit, 
          t5.decision_maker_name, 
          t5.rapporteur_name, 
          /* directdebiting_account_1_id */
            ('') AS directdebiting_account_1_id, 
          t5.irb_expected_loss FORMAT=NUMX12. AS irb_expected_loss, 
          t5.irb_k_amount FORMAT=NUMX12. AS irb_k_amount, 
          t5.ltv_value FORMAT=NUMX5.3 AS ltv_value, 
          t5.risk_group_text, 
          t5.class_pd FORMAT=NUMX6.4 AS class_pd, 
          t5.lgd_class_nr, 
          t5.lgd_class_value FORMAT=NUMX5.3 AS lgd_class_value, 
          t5.pd_class_nr, 
          /* total_credit_amount */
            (-t5.total_credit_amount) FORMAT=NUMX12. AS total_credit_amount,
		  t8.name,
		  t8.street_address,
		  t8.post_office_number

      FROM WORK.APPEND_TABLE t1
           LEFT JOIN WORK.ECL_COREBANK_L t4 ON (t1.information_date = t4.information_date) AND (t1.bank_id = 
          t4.bank_id) AND (t1.account_id = t4.account_id)

           LEFT JOIN WORK.QUERY_FOR_RWAEL_0000 t5 ON (t1.information_date = t5.information_date) AND (t1.bank_id = 
          t5.bank_id) AND (t1.account_number_official = t5.credit_number)
           LEFT JOIN WORK.QUERY_FOR_ACCOUNT_0001 t2 ON (t1.information_date = t2.information_date) AND (t1.bank_id = 
          t2.bank_id) AND (t1.account_id = t2.account_id)
           LEFT JOIN WORK.QUERY_FOR_CREDIT_FORBEARANCE t3 ON (t1.information_date = t3.information_date) AND 
          (t1.bank_id = t3.bank_id) AND (t1.account_id = t3.account_id)
           LEFT JOIN DWH_DW.ECL_RESULTS t6 ON (t1.information_date = t6.information_date) AND (t1.bank_id = t6.bank_id) 
          AND (t1.account_id = t6.account_id)
       LEFT JOIN WORK.ACCOUNT_CREDIT_LINK t7 ON (t1.information_date = t7.information_date) AND (t1.bank_id = t7.bank_id) 
      AND (t1.account_number_official = t7.account_number_official_2)
      LEFT JOIN dwh_dw.customer t8 ON (t1.information_date = t8.information_date) AND (t1.bank_id = t8.bank_id) 
       AND (t1.owner_id = t8.customer_id);

QUIT;



/* --- End of code for "Query Builder (4)". --- */

/* --- Start of code for "get data 2". --- */

%_eg_conditional_dropds(WORK.COLLATERAL_CODES_L);

PROC SQL;
   CREATE TABLE WORK.COLLATERAL_CODES_L AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.code_category_id, 
          t1.code_cd, 
          t1.language_cd, 
          t1.short_value_txt, 
          t1.long_value_txt, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt
      FROM &dw_inlib..CREDIT_SYSTEM_CODES_L t1
      WHERE t1.code_category_id = 'COLLATERAL_TYPE' AND t1.language_cd = 'sv';
QUIT;
%_eg_conditional_dropds(WORK.OBJECT_CODES_L);

PROC SQL;
   CREATE TABLE WORK.OBJECT_CODES_L AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.code_category_id, 
          t1.code_cd, 
          t1.language_cd, 
          t1.short_value_txt, 
          t1.long_value_txt, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt
      FROM &dw_inlib..CREDIT_SYSTEM_CODES_L t1
      WHERE t1.code_category_id = 'COLLATERAL_OBJECT_TYPE' AND t1.language_cd = 'sv';
QUIT;

%_eg_conditional_dropds(WORK.QUERY_FOR_COLL_OBJECT_AMO_REQ);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_COLL_OBJECT_AMO_REQ AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.version, 
          t1.object_id, 
          t1.amortization_basis_value, 
          t1.amortization_basis_debt, 
          t1.amortization_basis_date, 
          t1.current_rule_framework, 
          t1.alternative_rule_framework, 
          /*. as alternative_rule_amount, Miaomiao, 20230203*/
          t1.min_amortization_amount, 
          t1.alternative_rule_min_amort_amt, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt
      FROM DWH_DW.COLL_OBJECT_AMO_REQ t1
      WHERE t1.information_date = &loan_date_active;
QUIT;
/* --- End of code for "get data 2". --- */

/* --- Start of code for "Query Builder (3) - Copy (2)". --- */


%_eg_conditional_dropds(WORK.QUERY_FOR_BC_LIST_CONTRACT__0004);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_BC_LIST_CONTRACT__0004 AS 
   SELECT DISTINCT t1.information_date, 
          t1.bank_id, 
          t1.owner_id, 
          t1.account_id, 
          /* internal_collateral_id */
            (CAT('C',t2.internal_collateral_id)) AS internal_collateral_id, 
          t2.internal_pledge_id
      FROM WORK.HYP_CREDIT_LIST t1, DWH_DW.ACCOUNT_COLLATERAL_LINK t2
      WHERE (t1.bank_id = t2.bank_id AND t1.account_id = t2.account_id) AND t1.information_date = &loan_date_active;
QUIT;
/* --- End of code for "Query Builder (3) - Copy (2)". --- */

/* --- Start of code for "Query Builder (7)". --- */
%_eg_conditional_dropds(WORK.DWI_COLLATERAL_OBJECT_LINK);

PROC SQL;
   CREATE TABLE WORK.DWI_COLLATERAL_OBJECT_LINK AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          /* internal_collateral_id */
            (CAT(t1.bank_id,t1.internal_collateral_id)) AS internal_collateral_id, 
          /* internal_object_id */
            (CAT(t1.bank_id,t1.internal_object_id)) AS internal_object_id, 
          t1.internal_object_id AS internal_object_id_join
      FROM DWH_DW.COLLATERAL_OBJECT_LINK t1
      WHERE t1.information_date = &loan_date_active;
QUIT;
/* --- End of code for "Query Builder (7)". --- */

/* --- Start of code for "Query Builder (23)". --- */
%_eg_conditional_dropds(WORK.DWI_COLLATERAL_OBJECT_HOUSING);

PROC SQL;
   CREATE TABLE WORK.DWI_COLLATERAL_OBJECT_HOUSING AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.internal_object_id, 
          t1.housing_id, 
          t1.apartment_shares_txt, 
          t1.apartment_size, 
          t1.company_name, 
          t1.agreement_date, 
          t1.street_address_txt, 
          t1.post_office_number_id, 
          t1.city_name, 
          t1.country_cd, 
          t1.debt_share_amt, 
          t1.managing_certificate_date, 
          /* object_id */
            (Cat(t1.bank_id,t1.internal_object_id)) AS object_id
      FROM DWH_DW.HOUSING_OBJECT t1
      WHERE t1.information_date = &loan_date_active;
QUIT;
/* --- End of code for "Query Builder (23)". --- */

/* --- Start of code for "Query Builder (22)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_LOAN_PRODUCTION_COST);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_LOAN_PRODUCTION_COST AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.booking_date, 
          t1.account_id, 
          t1.interest_date, 
          t1.account_type_cd, 
          t1.account_ref_interest_cd, 
          t1.production_price_amt, 
          t1.interest_amt, 
          t1.distribution_comp_amt, 
          t1.production_price_rate, 
          t1.interest_rate, 
          t1.transaction_type_cd, 
          t1.interest_period_start_date, 
          t1.interest_period_end_date, 
          t1.production_price_coeff, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt
      FROM DWH_DW.LOAN_PRODUCTION_COST t1
      WHERE t1.information_date = &loan_date_active;
QUIT;
/* --- End of code for "Query Builder (22)". --- */

/* --- Start of code for "Query Builder (10)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_COLLATERAL_OBJECT_0000);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_COLLATERAL_OBJECT_0000 AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.internal_object_id, 
          t1.object_type_cd, 
          t1.currency_cd, 
          t1.market_value_amt, 
          t1.residence_value_amt, 
          t1.collateral_loan_value_amt, 
          t1.valuation_date, 
          t1.valuation_1_txt, 
          t1.valuation_2_txt, 
          t1.index_market_value_amt, 
          t1.index_residence_market_value_amt, 
          t1.index_collateral_loan_value_amt, 
          t1.index_valuation_date, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt
      FROM DWH_DW.COLLATERAL_OBJECT t1
      WHERE t1.information_date = &loan_date_active;
QUIT;
/* --- End of code for "Query Builder (10)". --- */

/* --- Start of code for "Query Builder (2)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_BC_LIST_CONTRACT_0004);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_BC_LIST_CONTRACT_0004 AS 
   SELECT DISTINCT t1.information_date, 
          t1.bank_id, 
          t1.account_id, 
          t2.internal_object_id, 
          t2.internal_object_id_join, 
          t3.object_type_cd, 
          t3.currency_cd, 
          t3.market_value_amt, 
          t3.residence_value_amt, 
          t3.collateral_loan_value_amt, 
          t3.valuation_date, 
          t3.valuation_1_txt, 
          t3.valuation_2_txt, 
          t3.index_market_value_amt, 
          t3.index_residence_market_value_amt, 
          t3.index_collateral_loan_value_amt, 
          t3.index_valuation_date, 
          t3.source_system_cd, 
          t3.extracted_dt, 
          t3.loaded_dt
      FROM WORK.QUERY_FOR_BC_LIST_CONTRACT__0004 t1
           LEFT JOIN WORK.DWI_COLLATERAL_OBJECT_LINK t2 ON (t1.bank_id = t2.bank_id) AND (t1.internal_collateral_id = 
          t2.internal_collateral_id)
           INNER JOIN WORK.QUERY_FOR_COLLATERAL_OBJECT_0000 t3 ON (t2.internal_object_id_join = t3.internal_object_id) 
          AND (t2.bank_id = t3.bank_id);
QUIT;
/* --- End of code for "Query Builder (2)". --- */

/* --- Start of code for "Query Builder (9)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_BC_LIST_CONTRACT_0005);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_BC_LIST_CONTRACT_0005 AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.account_id, 
          t1.internal_object_id, 
          t1.object_type_cd, 
          t5.long_value_txt AS object_type_txt, 
          /* object_category */
            (case when t2.internal_object_id is not missing then 'Bostadsrätt'
            when t3.internal_object_id is not missing then 'Fastighet'
            else ''
            end) AS object_category, 
          t1.currency_cd, 
          t1.market_value_amt, 
          t1.residence_value_amt, 
          t1.collateral_loan_value_amt, 
          t1.valuation_date, 
          t1.valuation_1_txt, 
          t1.valuation_2_txt, 
          t1.index_market_value_amt, 
          t1.index_residence_market_value_amt, 
          t1.index_collateral_loan_value_amt, 
          t1.index_valuation_date, 
          t4.amortization_basis_value, 
          t4.amortization_basis_debt, 
          t4.amortization_basis_date, 
          t4.current_rule_framework, 
          t4.alternative_rule_framework, 
          /*t4.alternative_rule_amount, Miaomiao, 20230203*/
          t4.min_amortization_amount, 
          t4.alternative_rule_min_amort_amt, 
          t2.housing_id AS h_housing_id, 
          t2.apartment_shares_txt AS h_apartment_shares_txt, 
          t2.apartment_size AS h_apartment_size, 
          t2.company_name AS h_company_name, 
          t2.agreement_date AS h_agreement_date, 
          t2.debt_share_amt AS h_debt_share_amt, 
          t2.managing_certificate_date AS h_managing_certificate_date, 
          t3.plot_name AS rp_plot_name, 
          t3.block_id AS rp_block_id, 
          t3.leasehold_right_flag AS rp_leasehold_right_flag, 
          t3.tax_year AS rp_tax_year, 
          t3.tax_value_amt AS rp_tax_value_amt, 
          /* street_address */
            (coalesce(t2.street_address_txt)) AS street_address, 
          /* city */
            (coalesce(t2.city_name)) AS city, 
          /* post_office_number */
            (coalesce(t2.post_office_number_id)) AS post_office_number, 
          t3.municipality_cd AS municipality_cd, 
          /* country_cd */
            (coalesce(t2.country_cd)) AS country_cd
      FROM WORK.QUERY_FOR_BC_LIST_CONTRACT_0004 t1
           LEFT JOIN WORK.DWI_COLLATERAL_OBJECT_HOUSING t2 ON (t1.bank_id = t2.bank_id) AND (t1.internal_object_id = 
          t2.object_id)
           LEFT JOIN WORK.QUERY_FOR_REAL_PROPERTY_SWE_OBJE t3 ON (t1.information_date = t3.information_date) AND 
          (t1.bank_id = t3.bank_id) AND (t1.internal_object_id = t3.object_id)
           LEFT JOIN WORK.QUERY_FOR_COLL_OBJECT_AMO_REQ t4 ON (t1.information_date = t4.information_date) AND 
          (t1.bank_id = t4.bank_id) AND (t1.internal_object_id_join = t4.object_id)
           LEFT JOIN WORK.OBJECT_CODES_L t5 ON (t1.information_date = t5.information_date) AND (t1.bank_id = 
          t5.bank_id) AND (t1.object_type_cd = t5.code_cd);
QUIT;
/* --- End of code for "Query Builder (9)". --- */

/* --- Start of code for "Query Builder (24)". --- */
%_eg_conditional_dropds(WORK.BG_COLLATERAL_OBJECT);

PROC SQL;
   CREATE TABLE WORK.BG_COLLATERAL_OBJECT AS 
   SELECT DISTINCT t1.information_date, 
          t1.bank_id, 
          t1.internal_object_id, 
          t1.object_type_cd, 
          t1.object_type_txt, 
          t1.object_category, 
          t1.currency_cd, 
          t1.market_value_amt, 

          t1.residence_value_amt, 
          t1.collateral_loan_value_amt, 
          t1.valuation_date, 
          t1.valuation_1_txt, 
          t1.valuation_2_txt, 
          t1.index_market_value_amt, 
          t1.index_residence_market_value_amt, 
          t1.index_collateral_loan_value_amt, 
          t1.index_valuation_date, 
          t1.amortization_basis_value, 
          t1.amortization_basis_debt, 
          t1.amortization_basis_date, 
          t1.current_rule_framework, 
          t1.alternative_rule_framework, 
          /*t1.alternative_rule_amount, Miaomiao, 20230203*/
          t1.min_amortization_amount, 
          t1.alternative_rule_min_amort_amt, 
          t1.h_housing_id, 
          t1.h_apartment_shares_txt, 
          t1.h_apartment_size, 
          t1.h_company_name, 
          t1.h_agreement_date, 
          t1.h_debt_share_amt, 
          t1.h_managing_certificate_date, 
          t1.rp_plot_name, 
          t1.rp_block_id, 
          t1.rp_leasehold_right_flag, 
          t1.rp_tax_year, 
          t1.rp_tax_value_amt, 
          t1.street_address, 
          t1.city, 
          t1.post_office_number, 
          t1.municipality_cd, 
          t1.country_cd
      FROM WORK.QUERY_FOR_BC_LIST_CONTRACT_0005 t1;
QUIT;
/* --- End of code for "Query Builder (24)". --- */

/* --- Start of code for "Query Builder (27)". --- */
%_eg_conditional_dropds(WORK.BG_LOAN_OBJECT_LINK);

PROC SQL;
   CREATE TABLE WORK.BG_LOAN_OBJECT_LINK AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.account_id, 
          t1.internal_object_id
      FROM WORK.QUERY_FOR_BC_LIST_CONTRACT_0005 t1;
QUIT;
/* --- End of code for "Query Builder (27)". --- */

/* --- Start of code for "Query Builder (5)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_LOAN_PRODUCTION_C_0000);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_LOAN_PRODUCTION_C_0000 AS 

   SELECT t1.information_date, 
          t1.bank_id, 
          t1.account_id, 
          t1.account_type_cd, 
          t1.account_ref_interest_cd, 
          t1.interest_rate, 
          /* SUM_of_production_price_amt */
            (SUM(t1.production_price_amt)) FORMAT=15.2 AS SUM_of_production_price_amt, 
          /* SUM_of_interest_amt */
            (SUM(t1.interest_amt)) FORMAT=15.2 AS SUM_of_interest_amt, 
          /* SUM_of_distribution_comp_amt */
            (SUM(t1.distribution_comp_amt)) FORMAT=15.2 AS SUM_of_distribution_comp_amt
      FROM DWH_DW.LOAN_PRODUCTION_COST t1
      WHERE t1.information_date = &loan_date_active
      GROUP BY t1.information_date,
               t1.bank_id,
               t1.account_id,
               t1.account_type_cd,
               t1.account_ref_interest_cd,
               t1.interest_rate
      ORDER BY t1.information_date,
               t1.bank_id,
               t1.account_id;
QUIT;
/* --- End of code for "Query Builder (5)". --- */

/* --- Start of code for "Query Builder (8)". --- */
%_eg_conditional_dropds(WORK.HYP_CREDIT_LIST_HIST);


PROC SQL;
   CREATE TABLE WORK.HYP_CREDIT_LIST_HIST AS 
   SELECT t2.information_date, 
          t2.bank_id, 
          t2.account_id, 
          t2.iban_number_id, 
          t2.account_number_official, 
          t2.credit_id,  /*Adam 2022-11-14*/
          t2.account_type_cd, 
          t2.owner_id, 
          t2.owner_ssn_id, 
          t2.custid, 
          t2.external_application_id, 
          t2.credit_ref_interest_cd, 
          t2.ref_interest_fix_period_m, 
          t2.interest_calculation_type, 
          t2.currency_cd, 
          t2.purpose_of_use_cd, 
          t2.purpose_of_use_name, 
          t2.first_withdrawal_date, 
          t2.opened_date, 
          t2.new_contract_flag, 
          t2.changed_date, 
          t2.loan_end_date, 
          t2.contract_length, 
          t2.loan_cancellation_date, 
          t2.credit_interest_rate_pct, 
          t2.effective_interest_rate, 
          t2.production_price_rate, 
          t2.balance_amount, 
          t2.original_loan_amount, 
          t2.withdrawable_today_amount, 
          t2.total_withdrawable_amount, 
          t2.additional_loan_amount, 
          t2.renegotiated_loan_amount, 
          t2.interest_period_start_date, 
          t2.previous_renegotiation_date, 
          t2.next_renegotiation_date, 
          t2.interest_reduction, 
          t2.interest_reduction_rate, 
          t2.interest_reduction_start_date, 
          t2.interest_reduction_end_date, 
          t2.payment_plan_cd, 
          t2.payment_plan_text, 
          t2.payment_plan_principal, 
          t2.payment_plan_interest, 
/*Jenny E 2022-09-12:
          t2.principal_payment_d, 
          t2.interest_payment_d, 
          t2.next_interest_payment_date, 
*/
          t2.install_plan_standard_pay_amount, 
          t2.notification_fee, 
          t2.prior_information, 
          t2.penalty_interest_pct, 
          t2.total_due_interest_amount, 
          t2.total_due_principal_amount, 
          t2.total_due_fee_amt, 
          t2.total_due_penalty_interest_amt, 
          t2.inv_payment_due_date, 
          t2.inv_pay_interest_per_start_date, 
          t2.inv_pay_interest_per_end_date, 
          t2.previous_interest_rate, 
          t2.previous_interest_change_date, 
          t2.next_interest_change_date, 
          t2.next_principal_payment_date, 
          t2.next_principal_payment_amount, 

          t2.next_interest_amount, 
          t2.next_payment_due_date, 
          t2.next_pay_interest_per_start_date, 
          t2.next_pay_interest_per_end_date, 
          t2.next_pay_spec_interest, 
          t2.next_inv_pay_spec_principal, 
          t2.next_inv_pay_spec_fee, 
          t2.next_inv_pay_spec_pen_interest, 
          t2.overdue_oldest_due_date, 
          t2.overdue_pay_spec_interest, 
          t2.overdue_pay_spec_principal, 
          t2.overdue_due_pay_spec_fee, 
          t2.overdue_pay_spec_pen_interest, 

          t2.last_inv_date, 
          t2.amortization_alternative_rule, 
          t2.amortization_ltv_flag, 
          t2.amortization_dept_ratio_flag, 
          t2.mortgage_loan_type_cd, 
          t2.unmanaged_days_cnt, 
/*nya variabler, Miaomiao, 20220610*/
                                                  t2.migration_flag,
                                                  t2.ocr_number,
                                                  t2.mandate_status,

          t2.risk_level, 
          t2.on_balance_ecl, 
          t2.off_balance_ecl, 
          t2.on_balance_ecl_change_amt, 
          t2.off_balance_ecl_change_amt, 
          t2.stage, 
          t2.stage_prev_month, 
          t2.stage_status, 
          t2.on_balance_ecl_cause_of_change, 
          t2.off_balance_ecl_cause_of_change, 
          t2.lgd_future_1_pct, 
          t2.pd_actual_lifetime_pct, 
          t2.ead_future_1_amt, 
          t2.housing_credit, 
          t2.requires_annual_review, 
          t2.credit_deficit, 
          t2.decision_maker_name, 
          t2.rapporteur_name, 
          t2.directdebiting_account_1_id, 
          t2.irb_expected_loss, 
          t2.irb_k_amount, 
          t2.ltv_value, 
          t2.risk_group_text, 
          t2.class_pd, 
          t2.lgd_class_nr, 
          t2.lgd_class_value, 
          t2.pd_class_nr, 
          t2.total_credit_amount, 
          t1.SUM_of_interest_amt AS interest_amt, 
          t1.SUM_of_production_price_amt AS production_price_amt, 
          t1.SUM_of_distribution_comp_amt AS distribution_comp_amt
      FROM WORK.QUERY_FOR_LOAN_PRODUCTION_C_0000 t1, WORK.HYP_CREDIT_LIST t2
      WHERE (t1.information_date = t2.information_date AND t1.bank_id = t2.bank_id AND t1.account_id = t2.account_id);

QUIT;


/* --- End of code for "Query Builder (8)". --- */

/* --- Start of code for "export". --- */
proc sql noprint;
create table dwi_Hypo.BG_CREDIT_LIST_L as select * from work.HYP_CREDIT_LIST;
/*create table dwi_Hypo.BG_CREDIT_LIST_HIST as select * from work.HYP_CREDIT_LIST_HIST;
create table dwi_Hypo.BG_CREDIT_OBJECT_LINK as select * from work.BG_LOAN_OBJECT_LINK;
create table dwi_Hypo.BG_COLLATERAL_OBJECT as select * from work.BG_COLLATERAL_OBJECT;*/
quit;

proc sql noprint;
create table dwi_Hypo.BG_CREDIT_LIST_L_TEST as select * from work.HYP_CREDIT_LIST_TEST;
quit;



	%dwi_delete(
	del_lib = dwi_hypo,	
	del_table = BG_CREDIT_LIST_HIST,	
	del_date = &loan_date_active);

/* 2022-09-26 Jenny Espling: changed source table from HYP_CREDIT_LIST_HIST to HYP_CREDIT_LIST */
	%dwi_insert(
	from_lib = work,
	from_table = HYP_CREDIT_LIST,
	to_lib = dwi_hypo,
	to_table = BG_CREDIT_LIST_HIST);

/* 2022-09-26 Jenny Espling: removed this since the latest table is BG_CREDIT_LIST_L... 
	%dwi_create_latest(lib=dwi_hypo,table=BG_CREDIT_LIST_HIST); 
*/

	%dwi_delete(
	del_lib = dwi_hypo,	
	del_table = BG_CREDIT_OBJECT_LINK,	
	del_date = &loan_date_active);


	%dwi_insert(
	from_lib = work,
	from_table = BG_LOAN_OBJECT_LINK,

	to_lib = dwi_hypo,
	to_table = BG_CREDIT_OBJECT_LINK);

	%dwi_create_latest(lib=dwi_hypo,table=BG_CREDIT_OBJECT_LINK);

	%dwi_delete(
	del_lib = dwi_hypo,	
	del_table = BG_COLLATERAL_OBJECT,	
	del_date = &loan_date_active);

	%dwi_insert(
	from_lib = work,
	from_table = BG_COLLATERAL_OBJECT,

	to_lib = dwi_hypo,
	to_table = BG_COLLATERAL_OBJECT);

	%dwi_create_latest(lib=dwi_hypo,table=BG_COLLATERAL_OBJECT);
/* --- End of code for "export". --- */

/* --- Start of code for "log - Copy". --- */

%dwi_log(lib=&dw_outlib,str1="bg_credit_analysis",str2="", timestamp_start=&timestamp_start,timestamp_end=%sysfunc(datetime()),user="&_metauser",tenant="&tenant");

/* --- End of code for "log - Copy". --- */

*  Begin EG generated code (do not edit this line);
;*';*";*/;quit;
%STPEND;

*  End EG generated code (do not edit this line);

