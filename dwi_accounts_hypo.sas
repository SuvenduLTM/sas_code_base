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
/*%start_dwi();*/
%start_dwi_manual(path=hypo);
%put _user_;

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_ACCOUNT_0001 AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.account_id, 
          t1.iban_number_id, 
          t1.account_number_official, 
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
          t1.blocked_account_cd, 
          t1.closed_account_cd, 
          t1.statement_type_cd, 
          t1.statement_channel_cd, 
          t1.account_address, 
          t1.secret_account, 
          t1.account_text, 
          t1.statement_fee, 
          t1.reminder_letter_cd, 
          t1.open_channel_cd, 
          t1.account_purpose_cd, 
          t1.estimate_balance_cd, 
          t1.maximum_deposite, 
          t1.maximum_withdrawals, 
          t1.origin_of_funds, 
          t1.account_origin_country, 
          t1.partner_account
      FROM &dw_inlib..ACCOUNT t1
      WHERE t1.information_date = &date_active;
QUIT;

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_DWI_ACCOUNT_ATTR_DAILY AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.account_id, 
          t1.account_number_official, 
          t1.owner_id, 
          t1.owner_ssn_id, 
          t1.hb_book_account, 
          t1.debt_creditor_account, 
          t1.overdraft_account, 
          t1.volume_type, 
          t1.account_type_aab, 
          t1.deposit_balance, 
          t1.lending_balance, 
          t1.current_limit_amt, 
          t1.overdraft, 
          t1.lending_spec, 
          t1.cost_center_account_cd, 
          t1.contract_type, 
          t1.use_rights_flag, 
          t1.total_owner_count
      FROM &dw_outlib..DWI_ACCOUNT_ATTR_DAILY t1
      WHERE t1.information_date = &date_active;
QUIT;

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_DWI_ACCOUNT_OWNERS AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.account_id, 
          t1.owner_id, 
          t1.customer_id, 
          t1.endowment_insurance_flag, 
          t1.active_insurance_restr_flag, 
          t1.main_account_customer_flag, 
          t1.main_account_owner_flag, 
          t1.loaded_dt
      FROM &dw_outlib..DWI_ACCOUNT_OWNERS t1
      WHERE t1.information_date = &date_active;
QUIT;
%_eg_conditional_dropds(WORK.QUERY_FOR_DWI_POA);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_DWI_POA AS 
   SELECT DISTINCT t1.information_date, 
          t1.bank_id, 
          t1.account_id, 
          t1.poa_type
      FROM &dw_outlib..DWI_POA t1
      WHERE t1.information_date = &date_active;
QUIT;

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_ACCOUNT_DAILY AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.account_id, 
          t1.booked_balance_amt, 
          t1.valuedate_balance_amt, 
          t1.debit_ref_interest_cd, 
          t1.debit_interest_rate_pct, 
          t1.debit_margin_rate_pct, 
          t1.credit_ref_interest_cd, 
          t1.credit_interest_rate_pct, 
          t1.credit_margin_rate_pct, 
          t1.interest_start_date, 
          t1.interest_end_date, 
          t1.debit_interest_estimate_amt, 
          t1.credit_interest_estimate_amt, 
          t1.debit_interest_accrued_amt, 
          t1.credit_interest_accrued_amt, 
          t1.overdraft_date, 
          t1.debit_interest_calc_cd, 
          t1.credit_interest_calc_cd, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt
      FROM &dw_inlib..ACCOUNT_DAILY t1
      WHERE t1.information_date = &date_active;
QUIT;

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_BALANCE_AVERAGE AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.account_id, 
          t1.balance_average_amt, 
          t1.deposit_sum_amt, 
          t1.deposit_cnt, 
          t1.withdrawal_sum_amt, 
          t1.withdrawal_cnt, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt
      FROM &dw_inlib..BALANCE_AVERAGE t1
      WHERE t1.information_date = &acc_monthly_date_active;
QUIT;

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_LIMIT AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.account_id, 
          t1.purpose_cd, 
          t1.changed_date, 
          t1.expiry_date, 
          t1.current_limit_amt, 
          t1.max_limit_amt, 
          t1.provision_rate_pct, 
          t1.provision_start_date, 
          t1.provision_end_date, 
          t1.provision_limit_amt, 
          t1.provision_accum_amt, 
          t1.provision_left_amt, 
          t1.overdraft_interest_pct, 
          t1.overdraft_days_cnt, 
          t1.overdraft_days_max_cnt, 
          t1.limit_capitalized_mon_cnt, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt
      FROM &dw_inlib..LIMIT t1
      WHERE t1.information_date = &loan_date_active;
QUIT;

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_LIMIT AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.account_id, 
          t1.purpose_cd, 
          t1.changed_date, 
          t1.expiry_date, 
          t1.current_limit_amt, 
          t1.max_limit_amt, 
          t1.provision_rate_pct, 
          t1.provision_start_date, 
          t1.provision_end_date, 
          t1.provision_limit_amt, 
          t1.provision_accum_amt, 
          t1.provision_left_amt, 
          t1.overdraft_interest_pct, 
          t1.overdraft_days_cnt, 
          t1.overdraft_days_max_cnt, 
          t1.limit_capitalized_mon_cnt, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt
      FROM &dw_inlib..LIMIT t1
      WHERE t1.information_date = &loan_date_active;
QUIT;

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_TIME_DEPOSIT AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.account_id, 
          t1.start_date, 
          t1.turn_date, 
          t1.end_date, 
          t1.from_account_id, 
          t1.start_amount, 
          t1.interest_ref_cd, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt
      FROM &dw_inlib_miss..TIME_DEPOSIT t1
      WHERE t1.information_date = &timedep_date_active;
QUIT;

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_LOAN_ADDITIONAL_DATA AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.account_id, 
          t1.payment_plan_cd, 
          t1.principal_payments_per_year_cnt, 
          t1.interest_payments_per_year_cnt, 
          t1.next_principal_payment_date, 
          t1.next_principal_payment_amount, 
          t1.next_interest_amount, 
          t1.next_interest_change_date, 
          t1.interest_period_start_date, 
          t1.purpose_of_use_cd, 
          t1.loan_end_date, 
          t1.loan_cancellation_date, 
          t1.actual_repayment_date, 
          t1.additional_loan_amount, 
          t1.renegotiated_loan_amount, 
          t1.original_loan_amount, 
          t1.withdrawable_today_amount, 
          t1.total_withdrawable_amount, 
          t1.payment_plan_principal, 
          t1.payment_plan_interest, 
          t1.prior_information, 
          t1.notification_fee, 
          t1.calculated_end_date, 
          t1.original_end_date, 
          t1.penalty_interest_pct, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt
      FROM &dw_inlib..LOAN_ADDITIONAL_DATA t1
      WHERE t1.information_date = &loan_date_active;
QUIT;

PROC SQL;
   CREATE TABLE WORK.DWI_CUSTOMER_LIST_L AS 
   SELECT * from &dw_outlib..DWI_CUSTOMER_LIST where information_date=&date_active;
QUIT; 

PROC SQL;
   CREATE TABLE WORK.DWI_ACCOUNT_BALANCE_AVG_L AS 
   SELECT * from &dw_outlib..DWI_ACCOUNT_BALANCE_AVG where information_date=&acc_monthly_date_active;
QUIT; 

PROC SQL;
   CREATE TABLE WORK.DWI_ACCOUNT_PER_INTEREST_L AS 
   SELECT * from &dw_outlib..DWI_ACCOUNT_PER_INTEREST where information_date=&acc_monthly_date_active;
QUIT; 

PROC SQL;
   CREATE TABLE WORK.DWI_ACCOUNT_ALLOC_CAP_L AS 
   SELECT * from &dw_outlib..DWI_ACCOUNT_ALLOCATED_CAPITAL where information_date=&acc_monthly_date_active;
QUIT; 

PROC SQL;
   CREATE TABLE WORK.BASEL_IRB_L AS 
   SELECT * from &dw_inlib_miss..BASEL_IRB where information_date=&acc_monthly_date_active;
QUIT; 

PROC SQL;
   CREATE TABLE WORK.BASE_SA_L AS 
   SELECT * from &dw_inlib_miss..BASEL_SA where information_date=&acc_monthly_date_active;
QUIT; 

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_TMS_DETAIL AS 
   SELECT DISTINCT t1.information_date, 
          t1.bank_id, 
          t1.account_id, 
          t1.portfolio_name
      FROM &dw_inlib..TMS_DETAIL t1
      WHERE t1.information_date = &acc_monthly_date_active;
QUIT;

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_CODES_ACCOUNT_TYPES_L AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.account_type_cd, 
          t1.account_type_cd_num, 
          t1.description_internal_swe_txt, 
          t1.description_external_swe_txt
      FROM &dw_inlib..CODES_ACCOUNT_TYPES_L t1;
QUIT;

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_CODES_L AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.code_number_cd, 
          t1.code_cd, 
          t1.long_name, 
          t1.short_name, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt
      FROM &dw_inlib..CODES_L t1;
QUIT;

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_EXCHANGE_RATES_L AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.currency_cd, 
          t1.base_currency_cd, 
          t1.registration_date, 
          t1.mid_rate, 
          t1.inverse_mid_rate, 
          t1.sale_rate, 
          t1.buy_rate, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt
      FROM &dw_inlib..EXCHANGE_RATES_L t1;
QUIT;

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_ACCOUNT AS 
   SELECT DISTINCT t1.information_date, 
          t1.bank_id, 
          /* last_used_date */
            (MAX(t2.reference_date)) FORMAT=FINDFDD10. AS last_used_date, 
          t1.owner_id, 
          t2.owner_ssn_id, 
          t1.account_id, 
          t2.account_number_official, 
          t2.account_type_cd, 
          t4.description_internal_swe_txt AS account_type, 
          t3.account_type_aab AS account_type_aab, 
          t3.deposit_balance, 
          t3.lending_balance, 
          t3.overdraft, 
          t3.total_owner_count, 
          t2.opened_date, 
          t2.close_date,  /*Adam 2022-11-22*/
          t2.currency_cd, 
          t3.hb_book_account, 
          t3.debt_creditor_account, 
          t3.overdraft_account, 
          t3.volume_type, 
          t3.lending_spec, 
          t3.cost_center_account_cd, 
          t3.contract_type, 
          /* avg_deposit_amt */
            (case when t5.avg_deposit_amt is missing then 0 else t5.avg_deposit_amt end) AS avg_deposit_amt, 
          /* avg_lending_amt */
            (case when avg_lending_amt is missing then 0 else avg_lending_amt end) AS avg_lending_amt, 
          /* avg_deposit_book_amt */
            (case when avg_deposit_book_amt is missing then 0 else avg_deposit_book_amt end) AS avg_deposit_book_amt, 
          /* avg_lending_book_amt */
            (case when avg_lending_book_amt is missing then 0 else avg_lending_book_amt end) AS avg_lending_book_amt, 
          /* periodized_interest_m */
            (case when periodized_interest_m is missing then 0 else periodized_interest_m end) AS periodized_interest_m, 
          t6.amount_currency_cd, 
          /* ead_amount */
            (case when t8.ead_amount is missing then 0 else t8.ead_amount end) AS ead_amount, 
          /* tot_ead */
            (case when t7.tot_ead is missing then 0 else t7.tot_ead end) AS tot_ead, 
          /* credit_amount */
            (case when t8.credit_amount is missing then 0 else t8.credit_amount end) AS credit_amount, 
          /* sm_amount */
            (case when t8.sm_amount is missing then 0 else t8.sm_amount end) AS sm_amount, 
          t7.sm_k_amount, 
          t8.irb_amount, 
          t7.irb_k_amount, 
          t8.expected_loss_amount, 
          t7.irb_expected_loss, 
          t7.writedown_amount, 
          t8.portfolio_cd, 
          t7.risk_weight_pct, 
          t7.added_pct, 
          t7.added_cap_req_mortgage_floor, 
          t7.capital_requirements, 
          t7.rea_credit_risk, 
          t7.net_expected_loss, 
          t7.allocated_capital, 
          t7.net_writedown_amount, 
          t9.portfolio_name
      FROM WORK.QUERY_FOR_DWI_ACCOUNT_OWNERS t1
           INNER JOIN WORK.QUERY_FOR_ACCOUNT_0001 t2 ON (t1.information_date = t2.information_date) AND (t1.bank_id =     /*Adam 2022-11-22*/
          t2.bank_id) AND (t1.account_id = t2.account_id) AND (t1.owner_id = t2.owner_id)
           LEFT JOIN WORK.QUERY_FOR_DWI_ACCOUNT_ATTR_DAILY t3 ON (t2.bank_id = t3.bank_id) AND (t2.account_id = 			/*Adam 2022-11-22*/
          t3.account_id)
           LEFT JOIN WORK.QUERY_FOR_CODES_ACCOUNT_TYPES_L t4 ON (t2.bank_id = t4.bank_id) AND (t2.account_type_cd = 
          t4.account_type_cd)
           LEFT JOIN WORK.DWI_ACCOUNT_BALANCE_AVG_L t5 ON (t1.bank_id = t5.bank_id) AND (t1.account_id = t5.account_id)
           LEFT JOIN WORK.DWI_ACCOUNT_PER_INTEREST_L t6 ON (t1.bank_id = t6.bank_id) AND (t1.account_id = t6.account_id)
           LEFT JOIN WORK.DWI_ACCOUNT_ALLOC_CAP_L t7 ON (t1.bank_id = t7.bank_id) AND (t1.account_id = t7.credit_number)
           LEFT JOIN WORK.BASEL_IRB_L t8 ON (t1.bank_id = t8.bank_id) AND (t1.account_id = t8.account_id)
           LEFT JOIN WORK.QUERY_FOR_TMS_DETAIL t9 ON (t1.bank_id = t9.bank_id) AND (t1.account_id = t9.account_id)
      GROUP BY t1.information_date,
               t1.bank_id,
               t1.owner_id,
               t2.owner_ssn_id,
               t1.account_id,
               t2.account_number_official,
               t2.account_type_cd,
               t4.description_internal_swe_txt,
               t3.account_type_aab,
               t3.deposit_balance,
               t3.lending_balance,
               t3.overdraft,
               t3.total_owner_count,
               t2.opened_date,
               t2.close_date,
               t2.currency_cd,
               t3.hb_book_account,
               t3.debt_creditor_account,
               t3.overdraft_account,
               t3.volume_type,
               t3.lending_spec,
               t3.cost_center_account_cd,
               t3.contract_type,
               (CALCULATED avg_deposit_amt),
               (CALCULATED avg_lending_amt),
               (CALCULATED avg_deposit_book_amt),
               (CALCULATED avg_lending_book_amt),
               (CALCULATED periodized_interest_m),
               t6.amount_currency_cd,
               (CALCULATED ead_amount),
               (CALCULATED tot_ead),
               (CALCULATED credit_amount),
               (CALCULATED sm_amount),
               t7.sm_k_amount,
               t8.irb_amount,
               t7.irb_k_amount,
               t8.expected_loss_amount,
               t7.irb_expected_loss,
               t7.writedown_amount,
               t8.portfolio_cd,
               t7.risk_weight_pct,
               t7.added_pct,
               t7.added_cap_req_mortgage_floor,
               t7.capital_requirements,
               t7.rea_credit_risk,
               t7.net_expected_loss,
               t7.allocated_capital,
               t7.net_writedown_amount,
               t9.portfolio_name;
QUIT;

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_ACCOUNT_0009 AS 
   SELECT DISTINCT t1.information_date, 
          t1.bank_id, 
          t1.last_used_date, 
          t1.owner_id, 
          t1.owner_ssn_id, 
          t4.customer_type, 
          t4.name, 
          t4.advisor1_id, 
          t4.advisor2_id, 
          t1.account_id, 
          t1.account_number_official, 
          t1.account_type_cd, 
          t1.account_type, 
          t1.account_type_aab, 
          t4.sector_cd, 
          t1.deposit_balance, 
          t1.lending_balance, 
          t1.overdraft, 
          /* use_rights_flag */
            (case when t11.poa_type is not missing then 1 else 0 end) AS use_rights_flag, 
          t1.total_owner_count, 
          /* balance_currency_book_amt */
            (t2.booked_balance_amt
            ) AS balance_currency_book_amt, 
          /* balance_currency_book_amt_split */
            (t2.booked_balance_amt/t1.total_owner_count) AS balance_currency_book_amt_split, 
          t2.valuedate_balance_amt, 
          t6.balance_average_amt, 
          t6.deposit_sum_amt, 
          t6.deposit_cnt, 
          t6.withdrawal_sum_amt, 
          t6.withdrawal_cnt, 
          t2.debit_ref_interest_cd, 
          t2.debit_interest_rate_pct, 
          t2.debit_margin_rate_pct, 
          t2.credit_ref_interest_cd, 
          t2.credit_interest_rate_pct, 
          t2.credit_margin_rate_pct, 
          t2.interest_start_date, 
          t2.interest_end_date, 
          t2.debit_interest_estimate_amt, 
          t2.credit_interest_estimate_amt, 
          t2.debit_interest_accrued_amt, 
          t2.credit_interest_accrued_amt, 
          t2.overdraft_date, 
          t7.expiry_date AS limit_expiry_date, 
          t7.current_limit_amt, 
          t7.max_limit_amt, 
          t1.currency_cd, 
          /* balance_book_amt */
            ( booked_balance_amt/t8.mid_rate) LABEL="balance converted to book amt" AS balance_book_amt, 
          /* balance_book_amt_split */
            ((t2.booked_balance_amt/t1.total_owner_count)/t8.mid_rate) LABEL="balance converted to book amt" AS 
            balance_book_amt_split, 
		  t9.start_date,  /*Adam 2023-01-31*/
           (case when t10.loan_cancellation_date is not missing then loan_cancellation_date
           when t9.end_date is not missing then t9.end_date
           else .
            end) FORMAT=FINDFDD10. AS end_date, 
		  t1.close_date,
          t1.hb_book_account, 
          t1.debt_creditor_account, 
          t1.overdraft_account, 
          t1.volume_type, 
          t1.lending_spec, 
          t1.cost_center_account_cd, 
          t1.contract_type, 
          t1.avg_deposit_amt, 
          t1.avg_lending_amt, 
          t1.avg_deposit_book_amt, 
          t1.avg_lending_book_amt, 
          t1.periodized_interest_m, 
          t1.amount_currency_cd, 
          t1.ead_amount, 
          t1.tot_ead, 
          t1.credit_amount, 
          t1.sm_amount, 
          t1.sm_k_amount, 
          t1.irb_amount, 
          t1.irb_k_amount, 
          t1.expected_loss_amount, 
          t1.irb_expected_loss, 
          t1.writedown_amount, 
          t1.portfolio_cd, 
          t1.risk_weight_pct, 
          t1.added_pct, 
          t1.added_cap_req_mortgage_floor, 
          t1.capital_requirements, 
          t1.rea_credit_risk, 
          t1.net_expected_loss, 
          t1.allocated_capital, 
          t1.net_writedown_amount, 
          t1.portfolio_name
      FROM WORK.QUERY_FOR_ACCOUNT t1
           LEFT JOIN WORK.QUERY_FOR_ACCOUNT_DAILY t2 ON (t1.bank_id = t2.bank_id) AND (t1.account_id = t2.account_id)   /* Adam Ö 2022-11-22 left ist för inner */
           LEFT JOIN WORK.QUERY_FOR_CODES_L t3 ON (t1.bank_id = t3.bank_id) AND (t1.account_type_cd = t3.code_cd AND 
          (code_number_cd='1'))
           LEFT JOIN WORK.QUERY_FOR_BALANCE_AVERAGE t6 ON (t1.bank_id = t6.bank_id) AND (t1.account_id = t6.account_id)
           LEFT JOIN WORK.QUERY_FOR_LIMIT t7 ON (t1.bank_id = t7.bank_id) AND (t1.account_id = t7.account_id)
           LEFT JOIN WORK.QUERY_FOR_EXCHANGE_RATES_L t8 ON (t1.bank_id = t8.bank_id) AND (t1.currency_cd = 
          t8.currency_cd)
           LEFT JOIN WORK.QUERY_FOR_TIME_DEPOSIT t9 ON (t1.bank_id = t9.bank_id) AND (t1.account_id = t9.account_id)
           LEFT JOIN WORK.QUERY_FOR_LOAN_ADDITIONAL_DATA t10 ON (t1.bank_id = t10.bank_id) AND (t1.account_id = 
          t10.account_id)
           LEFT JOIN WORK.QUERY_FOR_DWI_POA t11 ON (t1.bank_id = t11.bank_id) AND (t1.account_id = t11.account_id)
           LEFT JOIN WORK.DWI_CUSTOMER_LIST_L t4 ON (t1.bank_id = t4.bank_id) AND (t1.owner_ssn_id = t4.ssn)
      WHERE t1.account_type_cd NOT IN 
           (
           '833',
           '840',
           '847',
           '849'
           );
QUIT;

proc sql;	/*Adam Ö 2023-01-24*/
create table WORK.start_intrest_date as
select 
	  account_id
	 ,max(interest_start_date) as max_interest_start_date format=FINDFDD10.
from 
	dwi_hypo.dwi_accounts
group by 
	account_id;
run;quit;

PROC SQL;
   CREATE TABLE WORK.DWI_ACCOUNTS_LOAD AS 
   SELECT DISTINCT t1.information_date, 
          t1.bank_id, 
          t1.last_used_date, 
          t1.owner_id, 
          t1.account_id, 
          t1.account_type_cd, 
          t1.account_type, 
          t1.account_type_aab, 
          t1.deposit_balance, 
          t1.lending_balance, 
          t1.overdraft, 
          t1.use_rights_flag, 
          t1.total_owner_count, 
          t1.balance_currency_book_amt, 
          t1.balance_currency_book_amt_split, 
          t1.valuedate_balance_amt, 
          t1.balance_average_amt, 
          t1.debit_ref_interest_cd, 
          t1.debit_interest_rate_pct, 
          t1.debit_margin_rate_pct, 
          t1.credit_ref_interest_cd, 
          t1.credit_interest_rate_pct, 
          t1.credit_margin_rate_pct, 
          case when t1.interest_start_date is null then t2.max_interest_start_date else t1.interest_start_date end as interest_start_date FORMAT=FINDFDD10. ,     /*Adam Ö 2023-01-24, populera intrest_start date och interest_end_date*/ 
          case when t1.interest_end_date is null then t1.close_date else t1.interest_end_date end as interest_end_date FORMAT=FINDFDD10. , 						 /*Adam Ö 2023-01-24*/
          t1.debit_interest_estimate_amt, 
          t1.credit_interest_estimate_amt, 
          t1.debit_interest_accrued_amt, 
          t1.credit_interest_accrued_amt, 
          t1.overdraft_date, 
          t1.account_number_official, 
          t1.max_limit_amt, 
          t1.limit_expiry_date, 
          t1.currency_cd, 
          t1.balance_book_amt, 
          t1.balance_book_amt_split, 
		  t1.start_date,  /* 2023-01-31 start_date Adam Ö */
		  t1.end_date,	  /* 2023-01-31 end_date Adam Ö */			  	
          t1.close_date,  /* 2022-11-22 close date Adam Ö */
          t1.hb_book_account, 
          t1.debt_creditor_account, 
          t1.overdraft_account, 
          t1.volume_type, 
          t1.lending_spec, 
          t1.cost_center_account_cd, 
          t1.contract_type, 
          t1.avg_deposit_amt AS avg_deposit_monthly_amt, 
          t1.avg_lending_amt AS avg_lending_monthly_amt, 
          t1.avg_deposit_book_amt AS avg_deposit_monthly_book_amt, 
          t1.avg_lending_book_amt AS avg_lending_monthly_book_amt, 
          t1.periodized_interest_m, 
          t1.amount_currency_cd AS per_interest_currency_cd, 
          t1.portfolio_cd, 
          t1.risk_weight_pct, 
          t1.added_pct, 
          t1.added_cap_req_mortgage_floor, 
          t1.capital_requirements, 
          t1.rea_credit_risk, 
          t1.net_expected_loss, 
          t1.allocated_capital, 
          t1.net_writedown_amount, 
          t1.portfolio_name, 
          /* loaded_dt */
            (datetime()) FORMAT=datetime20. AS loaded_dt
      FROM WORK.QUERY_FOR_ACCOUNT_0009 t1
		  LEFT JOIN WORK.start_intrest_date t2 ON (t1.account_id = t2.account_id)
;
QUIT;


/*Add vilja accounts. Miaomiao 2023-06-28*/
data vilja_account;
set dwi_hypo.vilja_account;
bank_id='V';
rename account_owner_ssn=owner_id
			 account_type_txt=account_type_cd
			 product_name=account_type
				balance_amt=deposit_balance
			applicable_currency=currency_cd
;
balance_book_amt=balance_amt;
balance_book_amt_split=balance_amt;
total_owner_count=1;
account_id=account_number_official;
keep information_date bank_id account_owner_ssn account_id account_type_txt product_name balance_amt total_owner_count account_number_official applicable_currency
balance_book_amt balance_book_amt_split loaded_dt;
where information_date=&DATE_ACTIVE;
run;


data ACCOUNTS_exp_V_och_C;
set DWI_ACCOUNTS_LOAD
vilja_account;
run;

/*--- Start of code for "export data". --- */										   
									 
	%dwi_delete(
	del_lib=&dw_outlib,
	del_table=dwi_accounts,
	del_date=&date_active);

	%dwi_insert(
	from_lib=work,
	from_table=dwi_accounts_load,
	to_lib=&dw_outlib,
	to_table=dwi_accounts);

	%dwi_create_latest(lib=&dw_outlib,table=dwi_accounts);

	/*with vilja accounts*/
	%dwi_delete(
	del_lib=&dw_outlib,
	del_table=dwi_accounts_vilja_test,
	del_date=&date_active);

	%dwi_insert(
	from_lib=work,
	from_table=ACCOUNTS_exp_V_och_C,
	to_lib=&dw_outlib,
	to_table=dwi_accounts_vilja_test);

	%dwi_create_latest(lib=&dw_outlib,table=dwi_accounts_vilja_test);


 /*--- End of code for "export data". --- 

