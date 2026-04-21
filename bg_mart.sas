/* --- Start of code for "Program". --- */
%let start_ts=%sysfunc(datetime());
/* --- End of code for "Program". --- */

/* --- Start of code for "filter bg". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_DWI_CUSTOMER_LIST_L);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_DWI_CUSTOMER_LIST_L AS 
   SELECT t1.name, 
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
          t1.advisor1_name, 
          t1.advisor2_id, 
          t1.advisor2_name, 
          t1.AAB_employee_status_cd, 
          t1.age, 
          t1.sector_cd, 
          t1.sector, 
          t1.branch_cd, 
          t1.branch, 
          t1.pep_flag, 
          t1.risk_grade_cd, 
          t1.high_risk_country_flag, 
		  		t1.Hrtc_connection,
		  		t1.Hrtc_connection_ok,
					/*nya variabler, Miaomiao, 2022-05-17*/
					t1.crypto_trading,
					t1.crypto_mainly,
					t1.crypto_ok,
					t1.bo_check,
					t1.bo_checkUser,
					t1.bo_checkDate,

          t1.id_type, 
          t1.has_custody, 
          t1.has_depot_accounts_flag, 
          t1.has_digital_services, 
          t1.has_credit_cards, 
          t1.has_currency_accounts_flag, 
          t1.access_accounts_flag_corporate, 
          t1.access_accounts_flag_private, 
          t1.has_loans_flag, 
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
          /* new 20221004: */
	  t1.money_laundry_check_date,
          t1.kyc_expiration_date, 
          t1.profit_amt_ry, 
          t1.business_volume_eur, 
          t1.age_group, 
          t1.address_country_txt, 
          t1.adress_post_office, 
		  t1.address_street_1,  /*Adam 20230216*/
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
          t1.loaded_dt, 
          t1.mart_flags,
		  t1.pep_status_change_date /*Ny variabel Adam, 2023-06-05*/
      FROM DWI_HYPO.DWI_CUSTOMER_LIST_L t1;
QUIT;
/* --- End of code for "filter bg". --- */

/* --- Start of code for "Query Builder (8)". --- */
%_eg_conditional_dropds(WORK.BG_CUSTOMER_LIST_L);

PROC SQL;
   CREATE TABLE WORK.BG_CUSTOMER_LIST_L AS 
   SELECT t1.name, 
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
          t1.advisor1_name, 
          t1.advisor2_id, 
          t1.advisor2_name, 
          t1.AAB_employee_status_cd, 
          t1.age, 
          t1.sector_cd, 
          t1.sector, 
          t1.branch_cd, 
          t1.branch, 
          t1.pep_flag, 
		  t1.pep_status_change_date, /*Ny variabel Adam, 2023-06-05*/
          t1.risk_grade_cd, 
          t1.high_risk_country_flag,
	t1.Hrtc_connection,
	t1.Hrtc_connection_ok,
	/*nya variabler, Miaomiao, 2022-05-17*/
	t1.crypto_trading,
	t1.crypto_mainly,
	t1.crypto_ok,
	t1.bo_check,
	t1.bo_checkUser,
	t1.bo_checkDate,

          t1.id_type, 
          t1.has_custody, 
          t1.has_depot_accounts_flag, 
          t1.has_digital_services, 
          t1.has_credit_cards, 
          t1.has_currency_accounts_flag, 
          t1.access_accounts_flag_corporate, 
          t1.access_accounts_flag_private, 
          t1.has_loans_flag, 
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
          /* new 20221004: */
	  t1.money_laundry_check_date,
          t1.kyc_expiration_date,
          t1.profit_amt_ry, 
          t1.business_volume_eur, 
          t1.age_group, 
          t1.address_country_txt, 
          t1.adress_post_office, 
		  t1.address_street_1,  /*Adam 20230216*/
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
          t1.loaded_dt, 
          t1.mart_flags, 
          t1.profitability_class_r12, 
          t1.profitability_class_3m
      FROM WORK.QUERY_FOR_DWI_CUSTOMER_LIST_L t1;
QUIT;
/* --- End of code for "Query Builder (8)". --- */

/* --- Start of code for "Query Builder (2)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_DWI_EVENTS);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_DWI_EVENTS AS 
   SELECT t1.information_date, 
          t1.event_date, 
          t1.bank_id, 
          t1.customer_id, 
          t1.account_id, 
          t1.account_type_cd, 
          t1.amount, 
          t1.user_name, 
          t1.event_type, 
          t1.event_text, 
          t1.event_created_date, 
          t1.loaded_dt
      FROM DWI_HYPO.DWI_EVENTS t1
      WHERE event_type in ('Spärrat konto','Spärrat konto p.g.a. KYC saknas','Övertrassering')
           OR
           event_date>intnx('month',today(),-3,'same');
QUIT;
/* --- End of code for "Query Builder (2)". --- */

/* --- Start of code for "Query Builder". --- */
%_eg_conditional_dropds(WORK.BG_EVENTS_L);

PROC SQL;
   CREATE TABLE WORK.BG_EVENTS_L AS 
   SELECT t1.information_date, 
          t1.event_date, 
          t1.bank_id, 
          t1.customer_id, 
          t1.account_id, 
          t1.account_type_cd, 
          t1.amount, 
          t1.user_name, 
          t1.event_type, 
          t1.event_text, 
          t1.event_created_date, 
          t1.loaded_dt
      FROM WORK.QUERY_FOR_DWI_EVENTS t1, WORK.QUERY_FOR_DWI_CUSTOMER_LIST_L t2
      WHERE (t1.bank_id = t2.bank_id AND t1.customer_id = t2.customer_id);
QUIT;
/* --- End of code for "Query Builder". --- */

/* --- Start of code for "Query Builder (5)". --- */
%_eg_conditional_dropds(WORK.BG_REMINDERS_L);

PROC SQL;
   CREATE TABLE WORK.BG_REMINDERS_L AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.customer_id, 
          t1.reminder_type, 
          t1.reminder_date, 
          t1.reminder_text, 
          t1.compliance_level, 
          t1.status, 
          t1.account_id, 
          t1.loaded_dt
      FROM DWI_HYPO.DWI_REMINDERS_L t1, WORK.QUERY_FOR_DWI_CUSTOMER_LIST_L t2
      WHERE (t1.bank_id = t2.bank_id AND t1.customer_id = t2.customer_id);
QUIT;
/* --- End of code for "Query Builder (5)". --- */

/* --- Start of code for "Query Builder (4)". --- */
%_eg_conditional_dropds(WORK.BG_PRODUCT_FACT_L);

PROC SQL;
   CREATE TABLE WORK.BG_PRODUCT_FACT_L AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.customer_id, 
          t1.service_cd, 
          t1.product_cd_key, 
          t1.account_id, 
          t1.open_date, 
          t1.change_date, 
          t1.loaded_dt
      FROM DWI_HYPO.DWI_PRODUCT_FACT_L t1, WORK.QUERY_FOR_DWI_CUSTOMER_LIST_L t2
      WHERE (t1.bank_id = t2.bank_id AND t1.customer_id = t2.customer_id);
QUIT;
/* --- End of code for "Query Builder (4)". --- */

/* --- Start of code for "Query Builder (4) - Copy". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_APPEND_TABLE_0000);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_APPEND_TABLE_0000 AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.customer_id, 
          t1.service_cd, 
          t1.product_cd_key, 
          t1.account_id, 
          t1.open_date, 
          t1.change_date, 
          t1.loaded_dt
      FROM DWI_HYPO.DWI_PRODUCT_FACT_L t1, WORK.QUERY_FOR_DWI_CUSTOMER_LIST_L t2
      WHERE (t1.bank_id = t2.bank_id AND t1.customer_id = t2.customer_id);
QUIT;
/* --- End of code for "Query Builder (4) - Copy". --- */

/* --- Start of code for "Query Builder (10)". --- */
%_eg_conditional_dropds(WORK.PRODUKTSPEC);

PROC SQL;
   CREATE TABLE WORK.PRODUKTSPEC AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.code_number_cd, 
          t1.code_cd, 
          t1.code_txt, 
          t1.product_name, 
          t1.product_type, 
          t1.product_area, 
          t1.product_cd_key, 
          t1.service_type, 
          t1.filter_flag, 
          t1.loaded_dt
      FROM DWI_HYPO.DWI_PRODUCT_DIM_L t1;
QUIT;
/* --- End of code for "Query Builder (10)". --- */

/* --- Start of code for "Query Builder (13)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_PRODUKTSPEC_0001);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_PRODUKTSPEC_0001 AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.code_number_cd, 
          t1.code_cd, 
          t1.code_txt, 
          t1.product_name, 
          t1.product_type, 
          t1.product_area, 
          t1.product_cd_key, 
          t1.service_type, 
          t1.filter_flag, 
          t1.loaded_dt
      FROM WORK.PRODUKTSPEC t1
      WHERE t1.service_type = 'Konto' AND t1.product_type in( 'Inlåning',
           'Utlåning',
           'Garanti');
QUIT;
/* --- End of code for "Query Builder (13)". --- */

/* --- Start of code for "Query Builder (3)". --- */
%_eg_conditional_dropds(WORK.BG_ACCOUNTS_L);

PROC SQL;
   CREATE TABLE WORK.BG_ACCOUNTS_L AS 
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
          t1.interest_start_date, 
          t1.interest_end_date, 
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
		  t1.close_date,
          t1.balance_book_amt_split, 
          t1.loaded_dt
      FROM DWI_HYPO.DWI_ACCOUNTS_L t1
           LEFT JOIN DWI_HYPO.BATCH_FILTERS t2 ON (t1.bank_id = t2.bank_id) AND (t1.account_id = t2.code_value_char AND 
          (t2.target_column='account_id'))
           INNER JOIN DWI_HYPO.DWI_ACCOUNT_OWNERS_L t4 ON (t1.bank_id = t4.bank_id) AND (t1.account_id = t4.account_id) 
          AND (t1.owner_id = t4.owner_id)
           INNER JOIN WORK.QUERY_FOR_DWI_CUSTOMER_LIST_L t5 ON (t4.bank_id = t5.bank_id) AND (t4.customer_id = 
          t5.customer_id)
           INNER JOIN WORK.QUERY_FOR_PRODUKTSPEC_0001 t3 ON (t1.bank_id = t3.bank_id) AND (t1.account_type_cd = 
          t3.code_cd)
      WHERE t2.code_value_char IS MISSING;
QUIT;
/* --- End of code for "Query Builder (3)". --- */

/* --- Start of code for "Query Builder (6)". --- */
%_eg_conditional_dropds(WORK.BG_ACCOUNT_OWNERS_L);

PROC SQL;
   CREATE TABLE WORK.BG_ACCOUNT_OWNERS_L AS 
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
      FROM DWI_HYPO.DWI_ACCOUNT_OWNERS_L t1, WORK.BG_ACCOUNTS_L t2, WORK.QUERY_FOR_DWI_CUSTOMER_LIST_L t3
      WHERE (t1.bank_id = t2.bank_id AND t1.account_id = t2.account_id AND t1.customer_id = t3.customer_id AND 
           t1.bank_id = t3.bank_id);
QUIT;
/* --- End of code for "Query Builder (6)". --- */

/* --- Start of code for "Query Builder (8) - Copy". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_APPEND_TABLE);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_APPEND_TABLE AS 
   SELECT DISTINCT t1.information_date, 
          t1.bank_id, 
          t1.customer_id, 
          t1.product_cd_key, 
          t2.product_name AS Produkt, 
          /* has_product */
            ('1') AS has_product
      FROM WORK.QUERY_FOR_APPEND_TABLE_0000 t1
           LEFT JOIN WORK.PRODUKTSPEC t2 ON (t1.bank_id = t2.bank_id) AND (t1.product_cd_key = t2.product_cd_key)
      WHERE t2.filter_flag = 1;
QUIT;
/* --- End of code for "Query Builder (8) - Copy". --- */

/* --- Start of code for "Query Builder (11)". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_APPEND_TABLE_0001);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_APPEND_TABLE_0001 AS 
   SELECT DISTINCT t1.information_date, 
          t1.bank_id, 
          t1.customer_id, 
          t2.product_type AS Produkt, 
          /* has_product */
            ('1') AS has_product
      FROM WORK.QUERY_FOR_APPEND_TABLE_0000 t1
           LEFT JOIN WORK.PRODUKTSPEC t2 ON (t1.bank_id = t2.bank_id) AND (t1.product_cd_key = t2.product_cd_key)
      WHERE t2.service_type = 'Konto' AND t2.product_type IN 
           (
           'Inlåning',
           'Utlåning'
           );
QUIT;
/* --- End of code for "Query Builder (11)". --- */

/* --- Start of code for "Query Builder (9) - Copy". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_PRODUKTSPEC);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_PRODUKTSPEC AS 
   SELECT DISTINCT t1.product_name AS Produkt
      FROM WORK.PRODUKTSPEC t1
      WHERE t1.filter_flag = 1;
QUIT;
/* --- End of code for "Query Builder (9) - Copy". --- */

/* --- Start of code for "Query Builder (10) - Copy". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_PRODUKTSPEC_0000);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_PRODUKTSPEC_0000 AS 
   SELECT t2.information_date, 
          t2.bank_id, 
          t2.customer_id, 
          t2.product_cd_key, 
          t2.Produkt, 
          t2.has_product
      FROM WORK.QUERY_FOR_PRODUKTSPEC t1
           LEFT JOIN WORK.QUERY_FOR_APPEND_TABLE t2 ON (t1.Produkt = t2.Produkt);
QUIT;
/* --- End of code for "Query Builder (10) - Copy". --- */

/* --- Start of code for "Append Table (2)". --- */
%_eg_conditional_dropds(WORK.APPEND_TABLE_0000);
PROC SQL;
CREATE TABLE WORK.APPEND_TABLE_0000 AS 
SELECT * FROM WORK.QUERY_FOR_PRODUKTSPEC_0000
 OUTER UNION CORR 
SELECT * FROM WORK.QUERY_FOR_APPEND_TABLE_0001
;
Quit;

/* --- End of code for "Append Table (2)". --- */

/* --- Start of code for "Query Builder (3) - Copy". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_RS_CUSTOMER_LIST_L);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_RS_CUSTOMER_LIST_L AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.customer_id, 
          t1.ssn, 
          t2.Produkt
      FROM WORK.QUERY_FOR_DWI_CUSTOMER_LIST_L t1
           LEFT JOIN WORK.QUERY_FOR_PRODUKTSPEC t2 ON (t1.ssn ^= t2.Produkt);
QUIT;
/* --- End of code for "Query Builder (3) - Copy". --- */

/* --- Start of code for "Query Builder (5) - Copy". --- */
%_eg_conditional_dropds(WORK.bg_product_group_fact_l);

PROC SQL;
   CREATE TABLE WORK.bg_product_group_fact_l AS 
   SELECT DISTINCT t2.information_date AS information_date, 
          t2.bank_id AS bank_id, 
          t2.customer_id, 
          t2.ssn, 
          t2.Produkt AS product_name, 
          /* has_product */
            (case when t3.customer_id is not missing then 1
            else 0
            end) AS has_product
      FROM WORK.APPEND_TABLE_0000 t3
           RIGHT JOIN WORK.QUERY_FOR_RS_CUSTOMER_LIST_L t2 ON (t3.bank_id = t2.bank_id) AND (t3.Produkt = t2.Produkt) 
          AND (t3.customer_id = t2.customer_id);
QUIT;
/* --- End of code for "Query Builder (5) - Copy". --- */

/* --- Start of code for "Query Builder (12)". --- */
%_eg_conditional_dropds(WORK.QUERY1);

PROC SQL;
   CREATE TABLE WORK.QUERY1 AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.code_number_cd, 
          t1.code_cd, 
          t1.code_txt AS code_txt, 
          t1.product_name AS product_name, 
          t1.product_type AS product_type, 
          t1.product_area AS product_area, 
          t1.product_cd_key AS product_cd_key, 
          t1.service_type AS service_type, 
          t1.filter_flag AS filter_flag
      FROM WORK.PRODUKTSPEC t1;
QUIT;
/* --- End of code for "Query Builder (12)". --- */

/* --- Start of code for "Query Builder (9)". --- */
%_eg_conditional_dropds(WORK.BG_CUSTOMER_PAYMENT_L);
PROC SQL;
   CREATE TABLE WORK.BG_CUSTOMER_PAYMENT_L AS
   SELECT t1.bank_id,
          t1.information_date,
          t1.booking_date,
          t1.payment_type,
		  t1.name,   /*Aö 23-11-21 */
		  t1.ssn_id as ssn,    /*Aö 23-11-21 */
          t1.direction_cd,
          t1.system_cd,
          t1.registration_cd,
          t1.cbs_transaction_cd,
          t1.cbs_transaction_text,
          t1.main_account_id,
          t1.main_account_type,
          t1.main_account_owner_id,
          t1.main_account_owner_type,
          t1.counterparty_account_id,
          t1.counterparty_account_type,
          t1.counterparty_account_owner,
          t1.counterparty_country_cd,
          t1.region_country_cd,
          t1.aab_transaction_type_cd,
          t1.aab_transaction_text,
          t1.payment_instrument_cd,
          t1.payment_instrument_text,
          t1.transaction_id,
          t1.transaction_amt,
          t1.book_amt,
          t1.book_amt_eur,
          t1.exchange_rate,
          t1.transaction_currency_cd,
          t1.payer,
          t1.receiver,
          t1.correction_flag,
          t1.return_flag
      FROM DWI_HYPO.PAY_CUSTOMER_PAYMENT_L t1
      WHERE t1.main_account_type not like "8%" AND
           main_account_type not like "3%" AND
           main_account_type not like "7%" AND t1.cbs_transaction_cd NOT IN
           (
           '800',
           '801'
           );
quit;

PROC SQL;
   CREATE TABLE WORK.BG_CUSTOMER_PAYMENT_HIST AS 
   SELECT t1.bank_id, 
          t1.information_date, 
          t1.booking_date, 
          t1.payment_type, 
		  t1.name,   /*Aö 23-11-21 */
		  t1.ssn,    /*Aö 23-11-21 */
          t1.direction_cd, 
          t1.system_cd, 
          t1.registration_cd, 
          t1.cbs_transaction_cd, 
          t1.cbs_transaction_text, 
          t1.main_account_id, 
          t1.main_account_type, 
          t1.main_account_owner_id, 
          t1.main_account_owner_type, 
          t1.counterparty_account_id, 
          t1.counterparty_account_type, 
          t1.counterparty_account_owner, 
          t1.counterparty_country_cd, 
          t1.region_country_cd, 
          t1.aab_transaction_type_cd, 
          t1.aab_transaction_text, 
          t1.payment_instrument_cd, 
          t1.payment_instrument_text, 
          t1.transaction_id, 
          t1.transaction_amt, 
          t1.book_amt, 
          t1.book_amt_eur, 
          t1.exchange_rate, 
          t1.transaction_currency_cd, 
          t1.payer, 
          t1.receiver, 
          t1.correction_flag, 
          t1.return_flag
      FROM DWI_HYPO.PAY_CUSTOMER_PAYMENT t1
      WHERE t1.main_account_type not like "8%" AND
           main_account_type not like "3%" AND
           main_account_type not like "7%" AND t1.cbs_transaction_cd NOT IN 
           (
           '800',
           '801'
           )AND information_date >= today()-365 /*Aö, 2023-11-21. innehåller data 12 mån bakåt */  ;
QUIT;
/* --- End of code for "Query Builder (9)". --- */

/* --- Start of code for "export to dw". --- */
proc copy inlib=work outlib=dwi_hypo;
	select bg_account_owners_L;
quit;

proc copy inlib=work outlib=dwi_hypo;
	select bg_customer_list_L;
quit;

proc copy inlib=work outlib=dwi_hypo;

	select bg_accounts_L;
quit;

proc copy inlib=work outlib=dwi_hypo;
	select bg_reminders_L;
quit;

proc copy inlib=work outlib=dwi_hypo;
	select bg_events_L;
quit;

proc copy inlib=work outlib=dwi_hypo;
	select bg_product_fact_L;
quit;

proc copy inlib=work outlib=dwi_hypo;
	select bg_product_group_fact_L;
quit;

proc copy inlib=work outlib=dwi_hypo;
	select bg_customer_payment_L;
quit;

proc copy inlib=work outlib=dwi_hypo;
	select bg_customer_payment_hist;
quit;

/* --- End of code for "export to dw". --- */

/* --- Start of code for "log - Copy". --- */
proc sql noprint;
insert into dwi_fina.BATCH_LOG values ("aab","bg_mart","", &start_ts,%sysfunc(datetime()),"&_metauser");
quit;
/* --- End of code for "log - Copy". --- */

*  Begin EG generated code (do not edit this line);
;*';*";*/;quit;
%STPEND;

*  End EG generated code (do not edit this line);

