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

/* --- Start of code for "Latest date of CUSTOMER PAYMENT". --- */
PROC SQL noprint;
      SELECT /* MAX_of_information_date */
            (MAX(t1.information_date)) into :max_payment_date trimmed
      FROM &dw_paylib..PAY_CUSTOMER_PAYMENT_L t1 where information_date>(TODAY()-60);
QUIT;
/* --- End of code for "Latest date of CUSTOMER PAYMENT". --- */

/* --- Start of code for "get data". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_SEPA_TRANSACTION);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_SEPA_TRANSACTION AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.sepa_id, 
          t1.bulk_id, 
          t1.transaction_id, 
          t1.transaction_sub_id, 
          t1.registered_in_cd, 
          t1.payment_status_cd, 
          t1.direction_cd, 
          t1.document_type_cd, 
          t1.instruction_id, 
          t1.endtoendid, 
          t1.txid, 
          t1.rules_cd, 
          t1.local_instrument_proprietary_id, 
          t1.instruction_purpose_cd, 
          t1.currency_cd, 
          t1.instructed_amt, 
          t1.payment_date, 
          t1.charge_bearer_cd, 
          t1.instructing_agent_bic_id, 
          t1.ultimate_debtor_name, 
          t1.debtor_name, 
          t1.debtor_address1_txt, 
          t1.debtor_address2_txt, 
          t1.debtor_country_cd, 
          t1.debtor_iban_id, 
          t1.debtor_agent_bic_id, 
          t1.ultimate_creditor_name, 
          t1.creditor_name, 
          t1.creditor_address1_txt, 
          t1.creditor_address2_txt, 
          t1.creditor_country_cd, 
          t1.creditor_iban_id, 
          t1.creditor_agent_bic_id, 
          t1.returned_transaction_id, 
          t1.returned_amt, 
          t1.return_charge_bearer_cd, 
          t1.return_orig_agent_id, 
          t1.return_orig_customer_name, 
          t1.return_orig_party_bic_id, 
          t1.return_reason_cd, 
          t1.return_reason_txt, 
          t1.return_reason_step2_cd, 
          t1.return_reason_step2_txt, 
          t1.local_instrument, 
          t1.category_purpose_proprietary_cd, 
          t1.returned_instructed_amt LABEL='', 
          t1.return_charges_amt, 
          t1.return_charges_party_bic_id, 
          t1.counterparty_country_cd, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt
      FROM &dw_inlib..SEPA_TRANSACTION t1
      WHERE t1.information_date > &max_payment_date;
QUIT;

%_eg_conditional_dropds(WORK.QUERY_FOR_STIPS_PAYMENT);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_STIPS_PAYMENT AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.cbs_order_id, 
          t1.transaction_id, 
          t1.customer_account_id, 
          t1.customer_name, 
          t1.customer_address1_txt, 
          t1.customer_address2_txt, 
          t1.customer_address3_txt, 
          t1.customer_notify_flag, 
          t1.counterparty_account_id, 
          t1.counterparty_name, 
          t1.counterparty_address1_txt, 
          t1.counterparty_address2_txt, 
          t1.counterparty_address3_txt, 
          t1.counterparty_country_cd, 
          t1.counterparty_bank_country_cd, 
          t1.counterparty_bank_account_id, 
          t1.counterparty_bank_name, 
          t1.counterparty_bank_address1_txt, 
          t1.counterparty_bank_address2_txt, 
          t1.counterparty_bank_address3_txt, 
          t1.counterparty_bank_bic_cd, 
          t1.counterparty_bank_other_cd, 
          t1.payment_type_cd, 
          t1.payment_prod_type, 
          t1.order_reference_txt, 
          t1.payment_currency_cd, 
          t1.payment_amt, 
          t1.payment_exchange_rate, 
          t1.book_currency_cd, 
          t1.book_amt, 
          t1.customer_book_amt, 
          t1.customer_account_currency_cd, 
          t1.customer_account_amt, 
          t1.customer_account_exchange_rate, 
          t1.payment_reason1_txt, 
          t1.payment_reason2_txt, 
          t1.payment_reason3_txt, 
          t1.payment_reason4_txt, 
          t1.fee_type_cd, 
          t1.customer_fee_amt, 
          t1.fee_currency_cd, 
          t1.direction_cd, 
          t1.instructed_amt, 
          t1.original_currency_cd, 
          t1.settled_amt, 
          t1.settled_currency_cd, 
          t1.cross_exchange_rate, 
          t1.correspondent_bic_cd, 
          t1.receiver_sender_bic_cd, 
          t1.settlement_value_date, 
          t1.sender_reference_txt, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt
      FROM &dw_inlib..STIPS_PAYMENT t1
      WHERE information_date>&max_payment_date;
QUIT;

%_eg_conditional_dropds(WORK.QUERY_FOR_TRANSACTION1);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_TRANSACTION1 AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.transaction_id, 
          t1.transaction_sub_id, 
          t1.cbs_transaction_type_cd, 
          t1.main_account_id, 
          t1.counterparty_account_id, 
          t1.customer_account_id, 
          t1.booking_date, 
          t1.value_date, 
          t1.payment_date, 
          t1.creation_dt, 
          t1.teller_id, 
          t1.packet_id, 
          t1.cost_center_id, 
          t1.transaction_currency_cd, 
          t1.exchange_rate, 
          t1.user_id, 
          t1.reference_number_id, 
          t1.system_cd, 
          t1.registration_cd, 
          t1.account_type_cd, 
          t1.archive_code_cd, 
          t1.payment_system_cd, 
          t1.messages_cd, 
          t1.authentication_type_cd, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt, 
          t1.transaction_amt, 
          t1.book_amt
      FROM &dw_inlib..TRANSACTION t1
      WHERE t1.system_cd NOT IN 
           (
           'HBKA',
           'HBAV',
           'HBTY',
           'SEPA',
           'QUA1'
           ) AND t1.cbs_transaction_type_cd NOT IN 
           (
           'SCT'
           ) AND t1.registration_cd NOT IN 
           (
           'DK',
           'FK',
           'PI',
           'OTTS',
           'VXDK',
           'VXFK',
           'PU',
           'SWEP'
           ) AND not(
           (system_cd='KAME' and registration_cd='TRÖ') OR
           (system_cd='ANSV' and registration_cd='POR') OR
           (system_cd='KAUT' and registration_cd in ('CLIN','CLUT'))
           ) AND t1.transaction_amt NOT = 0 AND information_date>&max_payment_date;
QUIT;

%_eg_conditional_dropds(WORK.QUERY_FOR_SPM_PAYMENT);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_SPM_PAYMENT AS 
   SELECT t1.surrow_id LABEL='', 
          t1.information_date, 
          t1.bank_id, 
          t1.payment_id, 
          t1.local_unit_id, 
          t1.spm_payment_type_cd, 
          t1.transaction_type_cd, 
          t1.direction_cd, 
          t1.debtor_clearing_number_id, 
          t1.debtor_account_id, 
          t1.creditor_clearing_number_id, 
          t1.creditor_account_id, 
          t1.payment_currency_cd, 
          t1.payment_amt, 
          t1.book_amt, 
          t1.reference_txt, 
          t1.control_term_txt, 
          t1.transaction_id, 
          t1.archive_cd, 
          t1.payment_status_cd, 
          t1.order_id, 
          t1.recurrent_payment_id, 
          t1.primary_clearing_number_id, 
          t1.related_payment_id, 
          t1.ocr_reference_txt, 
          t1.payer_address_type_cd, 
          t1.payer_name, 
          t1.payer_company_name, 
          t1.payer_street_address_txt, 
          t1.payer_post_office_number_id, 
          t1.payer_city_name, 
          t1.payer_country_name, 
          t1.payer_country_code, 
          t1.payer_official_customer_id, 
          t1.receiver_address_type_cd, 
          t1.receiver_name, 
          t1.receiver_company_name, 
          t1.receiver_street_address_txt, 
          t1.receiver_post_office_number_id, 
          t1.receiver_city_name, 
          t1.receiver_country_name, 
          t1.receiver_country_code, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt
      FROM &dw_inlib..SPM_PAYMENT t1
      WHERE information_date>&max_payment_date;
QUIT;

%_eg_conditional_dropds(WORK.QUERY_FOR_ACCOUNT);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_ACCOUNT AS 
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
          t1.loaded_dt
      FROM &dw_inlib..ACCOUNT_L t1;
QUIT;

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
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt
      FROM &dw_inlib..CUSTOMER_L t1;
QUIT;
/* --- End of code for "get data". --- */

/* --- Start of code for "get code data". --- */
proc sql;
create table work.code_transaction as select * from &dw_inlib..codes_transaction_type_l;
create table work.code_account as select * from &dw_inlib..codes_account_types_l;
quit;
%_eg_conditional_dropds(WORK.QUERY_FOR_COUNTRY);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_COUNTRY AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.cbs_country_cd, 
          t1.country_cd, 
          t1.country_iso_numeric_cd, 
          t1.alpha3_cd, 
          t1.name_se_txt, 
          t1.name_fi_txt, 
          t1.name_en_txt, 
          t1.eu_flag, 
          t1.in_ees_flag, 
          t1.sepa_flag, 
          t1.high_risk_flag, 
          t1.crs_dac2_flag, 
          t1.sira_tiha_flag, 
          t1.stips_stp_flag, 
          t1.stips_eu_payment_flag, 
          t1.stips_iban_bic_flag, 
          t1.outgoing_cheques_cd, 
          t1.tariff_cd, 
          t1.strong_identification_flag, 
          t1.savings_directive_flag, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt
      FROM &dw_inlib..COUNTRY_L t1;
QUIT;
/* --- End of code for "get code data". --- */

/* --- Start of code for "1. Get transactions". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_TRANSACTION);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_TRANSACTION AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.transaction_id, 
          t1.transaction_sub_id, 
          t1.cbs_transaction_type_cd, 
          t5.long_name AS cbs_transaction_type_desc, 
          t1.main_account_id, 
          t1.counterparty_account_id, 
          t1.customer_account_id, 
          t1.booking_date, 
          t1.value_date, 
          t1.payment_date, 
          t1.creation_dt, 
          t1.teller_id, 
          t1.packet_id, 
          t1.cost_center_id, 
          t1.transaction_currency_cd, 
          t1.exchange_rate, 
          t1.user_id, 
          t1.reference_number_id, 
          t1.system_cd, 
          t1.registration_cd, 
          t1.account_type_cd, 
          t1.archive_code_cd, 
          t1.payment_system_cd, 
          t1.messages_cd, 
          t1.authentication_type_cd, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt, 
          t1.transaction_amt, 
          t1.book_amt, 
          t2.sepa_id, 
          t2.instructed_amt AS sepa_instructed_amt, 
          t3.payment_id AS spm_payment_id, 
          t3.local_unit_id AS spm_local_unit_id, 
          t3.payment_amt AS spm_payment_amt, 
          t3.book_amt AS spm_book_amt, 
          t4.cbs_order_id AS stips_cbs_order_id, 
          t4.payment_amt AS stips_payment_amt, 
          t4.book_amt AS stips_book_amt, 
          t4.customer_account_amt AS stips_customer_account_amt, 
          /* payment_type */
            (case when t2.transaction_id is not missing then 'SEPA' when t3.transaction_id is not missing then 
            t3.spm_payment_type_cd when t4.transaction_id is not missing then 'STIPS' ELSE 'OTHER' END) AS payment_type, 
          /* direction_cd */
            (case when
            t2.direction_cd is not missing then t2.direction_cd
            when t3.direction_cd is not missing then t3.direction_cd
            when t4.direction_cd is not missing then t4.direction_cd
            else ''
            end) AS direction_cd, 
          t2.debtor_country_cd AS sepa_debtor_country_cd, 
          t2.creditor_country_cd AS sepa_creditor_country_cd, 
          t2.counterparty_country_cd AS sepa_counterparty_country, 
          t3.receiver_country_code AS spm_receiver_country_code, 
          t3.payer_country_code AS spm_payer_country_code, 
          t4.counterparty_bank_country_cd AS stips_counterparty_country, 
          /* stips_main_bank_country */
            (case when t4.bank_id='A' then 'FI' else 'SE' end) AS stips_main_bank_country, 
          /* payer */
            (case 
            when t2.sepa_id is not missing then t2.debtor_name
            when t3.payment_id is not missing then t3.payer_name
            when t4.cbs_order_id is not missing then t4.customer_name
            else 'OTHER'
            end) AS payer, 
          /* receiver */
            (case 
            when t2.sepa_id is not missing then t2.creditor_name
            when t3.payment_id is not missing then t3.receiver_name
            when t4.cbs_order_id is not missing then t4.counterparty_name
            else 'OTHER'
            end) AS receiver
      FROM WORK.QUERY_FOR_TRANSACTION1 t1
           LEFT JOIN WORK.QUERY_FOR_SEPA_TRANSACTION t2 ON (t1.information_date = t2.information_date) AND 
          (t1.transaction_id = t2.transaction_id) AND (t1.bank_id = t2.bank_id)
           LEFT JOIN WORK.QUERY_FOR_SPM_PAYMENT t3 ON (t1.information_date = t3.information_date) AND (t1.bank_id = 
          t3.bank_id) AND (t1.transaction_id = t3.transaction_id)
           LEFT JOIN WORK.QUERY_FOR_STIPS_PAYMENT t4 ON (t1.information_date = t4.information_date) AND (t1.bank_id = 
          t4.bank_id) AND (t1.transaction_id = t4.transaction_id)
           LEFT JOIN WORK.CODE_TRANSACTION t5 ON (t1.bank_id = t5.bank_id) AND (t1.cbs_transaction_type_cd = t5.code_cd)
      WHERE t2.payment_status_cd NOT IN 
           (
           'BLOCKEDSCR',
           'DELETED',
           'REJECTED'
           ) AND t3.payment_status_cd NOT IN 
           (
           'CANCELLED',
           'BLOCKEDSCR',
           'REJECTED'
           );
QUIT;
/* --- End of code for "1. Get transactions". --- */

/* --- Start of code for "Add main account". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_TRANSACTION_0000);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_TRANSACTION_0000 AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.transaction_id, 
          t1.transaction_sub_id, 
          t1.payment_type, 
          t1.cbs_transaction_type_cd, 
          t1.cbs_transaction_type_desc, 
          t1.account_type_cd, 
          t4.description_internal_swe_txt AS account_type_desc, 
          t1.main_account_id, 
          t2.account_type_cd AS main_account_type, 
          t2.owner_id AS main_account_owner, 
          t2.currency_cd AS main_account_currency, 
          t1.counterparty_account_id, 
          t1.customer_account_id, 
          t1.booking_date, 
          t1.value_date, 
          t1.payment_date, 
          t1.creation_dt, 
          t1.teller_id, 
          t1.packet_id, 
          t1.cost_center_id, 
          t1.transaction_currency_cd, 
          t1.exchange_rate, 
          t1.user_id, 
          t1.reference_number_id, 
          t1.system_cd, 
          t1.registration_cd, 
          t1.archive_code_cd, 
          t1.payment_system_cd, 
          t1.messages_cd, 
          t1.authentication_type_cd, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt, 
          t1.transaction_amt, 
          t1.book_amt, 
          t1.sepa_id, 
          t1.sepa_instructed_amt, 
          t1.spm_payment_id, 
          t1.spm_local_unit_id, 
          t1.spm_payment_amt, 
          t1.spm_book_amt, 
          t1.stips_cbs_order_id, 
          t1.stips_payment_amt, 
          t1.stips_book_amt, 
          t1.stips_customer_account_amt, 
          t1.direction_cd, 
          t1.sepa_debtor_country_cd, 
          t1.sepa_creditor_country_cd, 
          t1.sepa_counterparty_country, 
          t1.spm_receiver_country_code, 
          t1.spm_payer_country_code, 
          t1.stips_counterparty_country, 
          t1.stips_main_bank_country, 
          t1.payer, 
          t1.receiver
      FROM WORK.QUERY_FOR_TRANSACTION t1
           LEFT JOIN WORK.QUERY_FOR_ACCOUNT t2 ON (t1.bank_id = t2.bank_id) AND (t1.main_account_id = t2.account_id)
           LEFT JOIN WORK.CODE_ACCOUNT t4 ON (t1.bank_id = t4.bank_id) AND (t1.account_type_cd = t4.account_type_cd);
QUIT;
/* --- End of code for "Add main account". --- */

/* --- Start of code for "2. Add counterparty account". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_TRANSACTION_0002);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_TRANSACTION_0002 AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.transaction_id, 
          t1.transaction_sub_id, 
          t1.payment_type, 
          t1.cbs_transaction_type_cd, 
          t1.cbs_transaction_type_desc, 
          t1.account_type_cd, 
          t1.account_type_desc, 
          t1.main_account_id, 
          t1.main_account_type, 
          t1.main_account_owner, 
          t1.main_account_currency, 
          t1.counterparty_account_id, 
          t2.account_type_cd AS counterparty_account_type, 
          t2.owner_id AS counterparty_account_owner, 
          t2.currency_cd AS counterparty_account_currency, 
          t1.customer_account_id, 
          t1.booking_date, 
          t1.value_date, 
          t1.payment_date, 
          t1.creation_dt, 
          t1.teller_id, 
          t1.packet_id, 
          t1.cost_center_id, 
          t1.transaction_currency_cd, 
          t1.exchange_rate, 
          t1.user_id, 
          t1.reference_number_id, 
          t1.system_cd, 
          t1.registration_cd, 
          t1.archive_code_cd, 
          t1.payment_system_cd, 
          t1.messages_cd, 
          t1.authentication_type_cd, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt, 
          t1.transaction_amt, 
          t1.book_amt, 
          t1.sepa_id, 
          t1.sepa_instructed_amt, 
          t1.spm_payment_id, 
          t1.spm_local_unit_id, 
          t1.spm_payment_amt, 
          t1.spm_book_amt, 
          t1.stips_cbs_order_id, 
          t1.stips_payment_amt, 
          t1.stips_book_amt, 
          t1.stips_customer_account_amt, 
          t1.direction_cd, 
          t1.sepa_debtor_country_cd, 
          t1.sepa_creditor_country_cd, 
          t1.sepa_counterparty_country, 
          t1.spm_receiver_country_code, 
          t1.spm_payer_country_code, 
          t1.stips_counterparty_country, 
          t1.stips_main_bank_country, 
          t1.payer, 
          t1.receiver
      FROM WORK.QUERY_FOR_TRANSACTION_0000 t1
           LEFT JOIN WORK.QUERY_FOR_ACCOUNT t2 ON (t1.bank_id = t2.bank_id) AND (t1.counterparty_account_id = 
          t2.account_id)
      ORDER BY t1.transaction_id;
QUIT;
/* --- End of code for "2. Add counterparty account". --- */

/* --- Start of code for "Create 1 outgoing leg for BLCT 1-legged transactions". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_TRANSACTION_000C);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_TRANSACTION_000C AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.transaction_id, 
          t1.transaction_sub_id, 
          t1.payment_type, 
          t1.cbs_transaction_type_cd, 
          t1.cbs_transaction_type_desc, 





          /* account_type_cd */
            (t1.counterparty_account_type) AS account_type_cd, 
          t1.account_type_desc, 
          /* main_account_id */
            (t1.counterparty_account_id) AS main_account_id, 
          /* main_account_type */
            (t1.counterparty_account_type) AS main_account_type, 
          /* main_account_owner */
            (t1.counterparty_account_owner) AS main_account_owner, 
          t1.main_account_currency, 
          /* counterparty_account_id */
            (t1.main_account_id) AS counterparty_account_id, 
          /* counterparty_account_type */
            (t1.account_type_cd) AS counterparty_account_type, 
          /* counterparty_account_owner */
            (main_account_owner) AS counterparty_account_owner, 
          t1.counterparty_account_currency, 
          t1.customer_account_id, 
          t1.booking_date, 
          t1.value_date, 
          t1.payment_date, 
          t1.creation_dt, 
          t1.teller_id, 

          t1.packet_id, 
          t1.cost_center_id, 
          t1.transaction_currency_cd, 
          t1.exchange_rate, 
          t1.user_id, 
          t1.reference_number_id, 
          t1.system_cd, 
          t1.registration_cd, 
          t1.archive_code_cd, 
          t1.payment_system_cd, 
          t1.messages_cd, 
          t1.authentication_type_cd, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt, 
          /* transaction_amt */
            (t1.transaction_amt*-1) AS transaction_amt, 
          /* book_amt */
            (t1.book_amt*-1) AS book_amt, 
          t1.sepa_id, 
          t1.sepa_instructed_amt, 
          t1.spm_payment_id, 
          t1.spm_local_unit_id, 
          t1.spm_payment_amt, 
          t1.spm_book_amt, 
          t1.stips_cbs_order_id, 
          t1.stips_payment_amt, 
          t1.stips_book_amt, 
          t1.stips_customer_account_amt, 
          t1.direction_cd, 
          t1.sepa_debtor_country_cd, 

          t1.sepa_creditor_country_cd, 
          t1.sepa_counterparty_country, 
          t1.spm_receiver_country_code, 
          t1.spm_payer_country_code, 
          t1.stips_counterparty_country, 
          t1.stips_main_bank_country, 
          t1.payer, 
          t1.receiver
      FROM WORK.QUERY_FOR_TRANSACTION_0002 t1
      WHERE t1.system_cd = 'BLCT' AND t1.payment_type = 'SEPA'
      GROUP BY t1.bank_id,
               t1.transaction_id
      HAVING (COUNT(t1.transaction_id)) = 1;
QUIT;
/* --- End of code for "Create 1 outgoing leg for BLCT 1-legged transactions". --- */

/* --- Start of code for "Append to transactions". --- */
%_eg_conditional_dropds(WORK.Append_Table);
PROC SQL;
CREATE TABLE WORK.Append_Table AS 
SELECT * FROM WORK.QUERY_FOR_TRANSACTION_0002
 OUTER UNION CORR 
SELECT * FROM WORK.QUERY_FOR_TRANSACTION_000C
;
Quit;

/* --- End of code for "Append to transactions". --- */

/* --- Start of code for "Add main customer". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_TRANSACTION_0005);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_TRANSACTION_0005 AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.transaction_id, 
          t1.transaction_sub_id, 
          t1.payment_type, 
          t1.cbs_transaction_type_cd, 
          t1.cbs_transaction_type_desc, 
          t1.account_type_cd, 
          t1.account_type_desc, 
          t1.main_account_id, 
          t1.main_account_type, 
          t1.main_account_currency, 
          t1.main_account_owner, 
          t2.name AS main_account_ownername, 
          t2.customer_type AS main_account_ownertype, 
          t1.counterparty_account_id, 
          t1.counterparty_account_type, 
          t1.counterparty_account_currency, 
          t1.counterparty_account_owner, 
          t1.customer_account_id, 
          t1.booking_date, 
          t1.value_date, 
          t1.payment_date, 
          t1.creation_dt, 
          t1.teller_id, 
          t1.packet_id, 
          t1.cost_center_id, 
          t1.transaction_currency_cd, 
          t1.exchange_rate, 
          t1.user_id, 
          t1.reference_number_id, 
          t1.system_cd, 
          t1.registration_cd, 
          t1.archive_code_cd, 
          t1.payment_system_cd, 
          t1.messages_cd, 
          t1.authentication_type_cd, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt, 
          t1.transaction_amt, 
          t1.book_amt, 
          t1.sepa_id, 
          t1.sepa_instructed_amt, 
          t1.spm_payment_id, 
          t1.spm_local_unit_id, 
          t1.spm_payment_amt, 
          t1.spm_book_amt, 
          t1.stips_cbs_order_id, 
          t1.stips_payment_amt, 
          t1.stips_book_amt, 
          t1.stips_customer_account_amt, 
          t1.direction_cd, 
          t1.sepa_debtor_country_cd, 
          t1.sepa_creditor_country_cd, 
          t1.sepa_counterparty_country, 
          t1.spm_receiver_country_code, 
          t1.spm_payer_country_code, 
          t1.stips_counterparty_country, 
          t1.stips_main_bank_country, 
          t2.result_office_id, 
          /* advisor1_id_f */
            (put(input(advisor1_id,Best5.),z5.)) AS advisor1_id_f, 
          /* advisor2_id_f */
            (put(input(advisor2_id,Best5.),z5.)) AS advisor2_id_f, 
          t1.payer, 
          t1.receiver, 
          t2.aab_employee_status_cd AS main_account_employee_status_cd
      FROM WORK.APPEND_TABLE t1
           LEFT JOIN WORK.QUERY_FOR_CUSTOMER t2 ON (t1.bank_id = t2.bank_id) AND (t1.main_account_owner = 
          t2.customer_id)
           LEFT JOIN DWI_FINA.BATCH_FILTERS t3 ON (t1.bank_id = t3.bank_id) AND (t1.main_account_owner = 
          t3.code_value_char AND (t3.target_column='customer_id'))
      WHERE t3.code_value_char IS MISSING OR t1.system_cd = 'BLCT';
QUIT;
/* --- End of code for "Add main customer". --- */

/* --- Start of code for "Add counterparty customer". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_TRANSACTION_0006);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_TRANSACTION_0006 AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.transaction_id, 
          t1.transaction_sub_id, 
          t1.payment_type, 
		  t2.name,   /* 2023-11-20 AÖ */
		  t2.ssn_id,  /* 2023-11-20 AÖ */
          t1.cbs_transaction_type_cd, 
          t1.cbs_transaction_type_desc, 
          t1.account_type_cd, 
          t1.account_type_desc, 
          t1.main_account_id, 
          t1.main_account_type, 
          t1.main_account_currency, 
          t1.main_account_owner, 
          t1.main_account_ownername, 
          t1.main_account_ownertype, 
          t1.counterparty_account_id, 
          t1.counterparty_account_type, 
          t1.counterparty_account_currency, 
          t1.counterparty_account_owner AS counterparty_account_owner, 
          t2.customer_type AS counterparty_account_ownertype, 
          t2.name AS counterparty_account_ownername, 
          t1.customer_account_id, 
          t1.booking_date, 
          t1.value_date, 
          t1.payment_date, 
          t1.creation_dt, 
          t1.teller_id, 
          t1.packet_id, 
          t1.cost_center_id, 
          t1.transaction_currency_cd, 
          t1.exchange_rate, 
          t1.user_id, 
          t1.reference_number_id, 
          t1.system_cd, 
          t1.registration_cd, 
          t1.archive_code_cd, 
          t1.payment_system_cd, 
          t1.messages_cd, 
          t1.authentication_type_cd, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt, 
          t1.transaction_amt, 
          t1.book_amt, 
          t1.sepa_id, 
          t1.sepa_instructed_amt, 
          t1.spm_payment_id, 
          t1.spm_local_unit_id, 
          t1.spm_payment_amt, 
          t1.spm_book_amt, 
          t1.stips_cbs_order_id, 
          t1.stips_payment_amt, 
          t1.stips_book_amt, 
          t1.stips_customer_account_amt, 
          t1.direction_cd, 
          t1.sepa_debtor_country_cd, 
          t1.sepa_creditor_country_cd, 
          t1.sepa_counterparty_country, 
          t1.spm_receiver_country_code, 
          t1.spm_payer_country_code, 
          t1.stips_counterparty_country, 
          t1.stips_main_bank_country, 
          t1.result_office_id, 
          t1.advisor1_id_f, 
          t1.advisor2_id_f, 
          t1.payer, 
          t1.receiver, 
          t1.main_account_employee_status_cd, 
          t2.aab_employee_status_cd AS counterparty_employee_status_cd
      FROM WORK.QUERY_FOR_TRANSACTION_0005 t1
           LEFT JOIN WORK.QUERY_FOR_CUSTOMER t2 ON (t1.bank_id = t2.bank_id) AND (t1.counterparty_account_owner = 
          t2.customer_id);
QUIT;
/* --- End of code for "Add counterparty customer". --- */

/* --- Start of code for "Add signs on transactions". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_TRANSACTION_0003);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_TRANSACTION_0003 AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.transaction_id, 
          t1.transaction_sub_id, 
          t1.payment_type, 
		  t1.name,  /* 2023-11-20 AÖ */
		  t1.ssn_id, /* 2023-11-20 AÖ */
          t1.cbs_transaction_type_cd, 
          t1.cbs_transaction_type_desc, 
          t1.account_type_cd, 
          t1.account_type_desc, 
          t1.main_account_id, 
          t1.main_account_type, 
          t1.main_account_currency, 
          t1.main_account_owner, 
          t1.main_account_ownername, 
          t1.main_account_ownertype, 
          t1.counterparty_account_id, 
          t1.counterparty_account_type, 
          t3.description_internal_swe_txt AS counterparty_account_type_desc, 
          t1.counterparty_account_currency, 
          t1.counterparty_account_owner, 
          t1.counterparty_account_ownername, 
          t1.counterparty_account_ownertype, 
          t1.customer_account_id, 
          t1.booking_date, 
          t1.value_date, 
          t1.payment_date, 
          t1.creation_dt, 
          t1.teller_id, 
          t1.packet_id, 
          t1.cost_center_id, 
          t1.transaction_currency_cd, 
          t1.exchange_rate, 
          t1.user_id, 
          t1.reference_number_id, 
          t1.system_cd, 
          t1.registration_cd, 
          t1.archive_code_cd, 
          t1.payment_system_cd, 
          t1.messages_cd, 
          t1.authentication_type_cd, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt, 
          t1.transaction_amt, 
          t1.book_amt, 
          t1.sepa_id, 
          t1.sepa_instructed_amt, 
          t1.spm_payment_id, 
          t1.spm_local_unit_id, 
          t1.spm_payment_amt, 
          t1.spm_book_amt, 
          t1.stips_cbs_order_id, 
          t1.stips_payment_amt, 
          t1.stips_book_amt, 
          t1.stips_customer_account_amt, 
          /* book_amt_sign */
            (case when book_amt > 0 then '+' when book_amt <0 then '-' else '0' end) AS book_amt_sign, 
          /* transaction_amt_sign */
            (case when transaction_amt > 0 then '+' when transaction_amt <0 then '-' else '0' end) AS 
            transaction_amt_sign, 
          t1.direction_cd, 
          t1.sepa_debtor_country_cd, 
          t1.sepa_creditor_country_cd, 
          t1.sepa_counterparty_country, 
          t1.spm_receiver_country_code, 
          t1.spm_payer_country_code, 
          t1.stips_counterparty_country, 
          t1.stips_main_bank_country, 
          t1.result_office_id, 
          t1.advisor1_id_f, 
          t1.advisor2_id_f, 
          t1.payer, 
          t1.receiver, 
          /* account_group */
            (case when substr(main_account_type,1,1)='5' then '5' else '4' end) AS account_group, 
          t1.main_account_employee_status_cd, 
          t1.counterparty_employee_status_cd
      FROM WORK.QUERY_FOR_TRANSACTION_0006 t1
           LEFT JOIN WORK.CODE_ACCOUNT t3 ON (t1.bank_id = t3.bank_id) AND (t1.counterparty_account_type = 
          t3.account_type_cd)
      ORDER BY t1.transaction_id;
QUIT;
/* --- End of code for "Add signs on transactions". --- */



/* --- Start of code for "Program". --- */
/* börjar med att använda åabs definitioner även för borgo. Kan ändras vid behov */
proc sql noprint;
create table work.paygroup as select * from &dw_paylib..PAY_ACCOUNT_GROUP_MAPPING;
create table work.paymapp as select * from &dw_paylib..PAY_TRANSACTION_TYPE_MAPPING;
create table work.payinstrument as select * from &dw_paylib..PAY_PAYMENT_INSTRUMENT_MAPPING;
quit;

%_eg_conditional_dropds(WORK.QUERY_FOR_PAR_CODES);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_PAR_CODES AS 
   SELECT *
      FROM &dw_outlib..PAR_CODES t1
      WHERE t1.code_type = 'TRANSACTION_TYPE';
QUIT;

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_PAR_CODES_0000 AS 
   SELECT *
      FROM &dw_outlib..PAR_CODES t1
      WHERE t1.code_type = 'PAYMENT_INSTRUMENT';
QUIT;

PROC SQL;
   CREATE TABLE WORK.ACCOUNT_FILTERS AS 
   SELECT *
      FROM &dw_outlib..BATCH_FILTERS t1
      WHERE t1.target_column = 'account_type_cd';
QUIT;
/* --- End of code for "Program". --- */

/* --- Start of code for "4. Count sub-transactions". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_TRANSACTION_0026);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_TRANSACTION_0026 AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.transaction_id, 
          t1.transaction_sub_id, 
          t1.payment_type, 
		  t1.name,    /* 2023-11-20 AÖ */
		  t1.ssn_id,  /* 2023-11-20 AÖ */
          t1.system_cd, 
          t1.registration_cd, 
          t1.cbs_transaction_type_cd AS cbs_transaction_cd_filtered, 
          t1.cbs_transaction_type_desc, 
          t1.account_type_cd, 
          t1.account_type_desc, 
          t1.main_account_id, 
          t1.main_account_type, 
          t1.main_account_currency, 
          t1.main_account_owner, 
          t1.main_account_ownername, 
          t1.main_account_ownertype, 
          t1.counterparty_account_id, 
          t1.counterparty_account_type, 
          t1.counterparty_account_type_desc, 
          t1.counterparty_account_currency, 
          t1.counterparty_account_owner, 
          t1.counterparty_account_ownername, 
          t1.counterparty_account_ownertype, 
          t1.customer_account_id, 
          t1.booking_date, 
          t1.value_date, 
          t1.payment_date, 
          t1.creation_dt, 
          t1.teller_id, 
          t1.packet_id, 
          t1.cost_center_id, 
          t1.transaction_currency_cd, 
          t1.exchange_rate, 
          t1.user_id, 
          t1.reference_number_id, 
          t1.archive_code_cd, 
          t1.payment_system_cd, 
          t1.messages_cd, 
          t1.authentication_type_cd, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt, 
          t1.transaction_amt, 
          t1.book_amt, 
          t1.sepa_id, 
          t1.sepa_instructed_amt, 
          t1.spm_payment_id, 
          t1.spm_local_unit_id, 
          t1.spm_payment_amt, 
          t1.spm_book_amt, 
          t1.stips_cbs_order_id, 
          t1.stips_payment_amt, 
          t1.stips_book_amt, 
          t1.stips_customer_account_amt, 
          t1.book_amt_sign, 
          t1.transaction_amt_sign, 
          t1.direction_cd, 
          t1.sepa_debtor_country_cd, 
          t1.sepa_creditor_country_cd, 
          t1.sepa_counterparty_country, 
          t1.spm_receiver_country_code, 
          t1.spm_payer_country_code, 
          t1.stips_counterparty_country, 
          t1.stips_main_bank_country, 
          /* find_payment_id */
            (case when sepa_id > 0 then put(sepa_id,8.)
            when stips_cbs_order_id ne '' then stips_cbs_order_id
            when spm_payment_id ne '' then spm_payment_id
            else transaction_id
            end) AS find_payment_id, 
          /* count_payment_id */
            (COUNT(transaction_id)) AS count_payment_id, 
          /* counterparty_country_cd */
            (case when payment_type='SEPA' then sepa_counterparty_country
            when payment_type='STIPS' then stips_counterparty_country
            when payment_type='SPM' or t1.bank_id='B' then 'SE'
            when t1.bank_id='A' then 'FI'
            end) AS counterparty_country_cd, 
          t1.result_office_id, 
          t1.advisor1_id_f, 
          t1.advisor2_id_f, 
          t1.payer, 
          t1.receiver, 
          /* account_group */
            (case when (substr(main_account_type,1,1)='5' OR main_account_type ='180') then '5' 
            when t2.account_group <>'' then t2.account_group
            else '4' end) AS account_group, 
          t1.main_account_employee_status_cd, 
          t1.counterparty_employee_status_cd
      FROM WORK.QUERY_FOR_TRANSACTION_0003 t1
           LEFT JOIN WORK.PAYGROUP t2 ON (t1.bank_id = t2.bank_id) AND (t1.account_type_cd = t2.account_type_cd)
      WHERE not ((system_cd='ANSV' and registration_cd in ('AVSE','IBEU')) OR (system_cd='AVSV' and registration_cd='TS'
           ))
      GROUP BY t1.bank_id,
               (CALCULATED find_payment_id);
QUIT;
/* --- End of code for "4. Count sub-transactions". --- */

/* --- Start of code for "5. Filter transactions". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_TRANSACTION_000A__0002);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_TRANSACTION_000A__0002 AS 
   SELECT DISTINCT t1.information_date, 
          t1.bank_id, 
          t1.transaction_id, 
          t1.transaction_sub_id, 
          t1.payment_type, 
		  t1.name,   /* 2023-11-20 AÖ */
		  t1.ssn_id,  /* 2023-11-20 AÖ */
          t1.system_cd, 
          t1.registration_cd, 
          t1.cbs_transaction_cd_filtered LABEL='' AS cbs_transaction_cd, 
          t1.cbs_transaction_type_desc AS cbs_transaction_text, 
          t1.account_type_cd, 
          t1.account_type_desc, 
          t1.main_account_id, 
          t1.main_account_type, 
          t1.main_account_currency, 
          t1.main_account_owner, 
          t1.main_account_ownername, 
          t1.main_account_ownertype, 
          t1.counterparty_account_id, 
          t1.counterparty_account_type, 
          t1.counterparty_account_type_desc, 
          t1.counterparty_account_currency, 
          t1.counterparty_account_owner, 
          t1.counterparty_account_ownername, 
          t1.counterparty_account_ownertype, 
          t1.customer_account_id, 
          t1.booking_date, 
          t1.value_date, 
          t1.payment_date, 
          t1.creation_dt, 
          t1.teller_id, 
          t1.packet_id, 
          t1.cost_center_id, 
          t1.transaction_currency_cd, 
          t1.exchange_rate, 
          t1.user_id, 
          t1.reference_number_id, 
          t1.archive_code_cd, 
          t1.payment_system_cd, 
          t1.messages_cd, 
          t1.authentication_type_cd, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt, 
          t1.transaction_amt, 
          t1.book_amt, 
          t1.sepa_id, 
          t1.sepa_instructed_amt, 
          t1.spm_payment_id, 
          t1.spm_local_unit_id, 
          t1.spm_payment_amt, 
          t1.spm_book_amt, 
          t1.stips_cbs_order_id, 
          t1.stips_payment_amt, 
          t1.stips_book_amt, 
          t1.stips_customer_account_amt, 
          t1.book_amt_sign, 
          t1.transaction_amt_sign, 
          t1.direction_cd, 
          t1.sepa_debtor_country_cd, 
          t1.sepa_creditor_country_cd, 
          t1.sepa_counterparty_country, 
          t1.spm_receiver_country_code, 
          t1.spm_payer_country_code, 
          t1.stips_counterparty_country, 
          t1.stips_main_bank_country, 
          t1.find_payment_id, 
          t1.count_payment_id, 
          t1.counterparty_country_cd, 
          t2.in_ees_flag, 
          t1.result_office_id, 
          t1.advisor1_id_f, 
          t1.advisor2_id_f, 
          t1.payer, 
          t1.receiver, 
          /* after_filter_subtrans_count */
            (COUNT(t1.transaction_id)) AS after_filter_subtrans_count, 
          /* correction_flag */
            (case when t1.cbs_transaction_cd_filtered in ('14','15','KOK','KKO','DDF','DFR','KKR','MDR','PVK','810',
            '811','812','813','814','815','816','817','ÅTB') 
            OR (t1.bank_id='B' and cbs_transaction_cd_filtered in ('SAG','SAR','SBR','SKR','SMR','SRA','SRR','SUG','SUK'
            )) 
            then 1 else 0 end) AS correction_flag, 
          /* return_flag */
            (cbs_transaction_cd_filtered in ('RET','YJP','YOP','ÅFL') OR
            (t1.bank_id='B' and cbs_transaction_cd_filtered in ('SRE','SAB','SAX')) OR
            (t1.bank_id='A' and cbs_transaction_cd_filtered in ('REB'))) AS return_flag, 
          t1.account_group, 
          t1.main_account_employee_status_cd, 
          t1.counterparty_employee_status_cd
      FROM WORK.QUERY_FOR_TRANSACTION_0026 t1
           LEFT JOIN WORK.QUERY_FOR_COUNTRY t2 ON (t1.counterparty_country_cd = t2.country_cd) AND (t1.bank_id = 
          t2.bank_id)
      WHERE (
           	( t1.payment_type in ('BG','DCL','PG')
           	OR t1.payment_type = 'SEPA' 
           	OR ( t1.payment_type = 'STIPS' AND transaction_amt>0 
           		OR t1.stips_customer_account_amt=abs(t1.transaction_amt)
           		) 
           	OR ( t1.payment_type = 'OTHER' AND NOT (t1.system_cd='BLCT' and count_payment_id=1))
           	)
           AND 
           t1.account_type_cd not in (select code_value_char as account_type_cd from WORK.ACCOUNT_FILTERS where 
           bank_id=t1.bank_id)
           ) OR
           (t1.count_payment_id = 1 AND 
           	(
           		(t1.payment_type='SEPA' and t1.system_cd='BLCT' and t1.account_type_cd not in ('812','813','814','815',
           '816','817')) OR 
                   (t1.system_cd='OVSV' and t1.registration_cd='TRDI')
           	)
           )
      GROUP BY t1.bank_id,
               t1.transaction_id;
QUIT;
/* --- End of code for "5. Filter transactions". --- */

/* --- Start of code for "Add transaction codes". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_TRANSACTION_000A1);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_TRANSACTION_000A1 AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.transaction_id, 
          t1.transaction_sub_id, 
          t1.payment_type, 
		  t1.name,     /* 2023-11-20 AÖ */
		  t1.ssn_id,   /* 2023-11-20 AÖ */
          t1.system_cd, 
          t1.registration_cd, 
          t1.cbs_transaction_cd, 
          t1.cbs_transaction_text, 
          t1.account_type_cd, 
          t1.account_type_desc, 
          t1.main_account_id, 
          t1.main_account_type, 
          t1.main_account_currency, 
          t1.main_account_owner, 
          t1.main_account_ownername, 
          t1.main_account_ownertype, 
          t1.counterparty_account_id, 
          t1.counterparty_account_type, 
          t1.counterparty_account_type_desc, 
          t1.counterparty_account_currency, 
          t1.counterparty_account_owner, 
          t1.counterparty_account_ownername, 
          t1.counterparty_account_ownertype, 
          t1.customer_account_id, 
          t1.booking_date, 
          t1.value_date, 
          t1.payment_date, 
          t1.creation_dt, 
          t1.teller_id, 
          t1.packet_id, 
          t1.cost_center_id, 
          t1.transaction_currency_cd, 
          t1.exchange_rate, 
          t1.user_id, 
          t1.reference_number_id, 
          t1.archive_code_cd, 
          t1.payment_system_cd, 
          t1.messages_cd, 
          t1.authentication_type_cd, 
          t1.source_system_cd, 
          t1.extracted_dt, 
          t1.loaded_dt, 
          t1.transaction_amt, 
          t1.book_amt, 
          t1.sepa_id, 
          t1.sepa_instructed_amt, 
          t1.spm_payment_id, 
          t1.spm_local_unit_id, 
          t1.spm_payment_amt, 
          t1.spm_book_amt, 
          t1.stips_cbs_order_id, 
          t1.stips_payment_amt, 
          t1.stips_book_amt, 
          t1.stips_customer_account_amt, 
          t1.book_amt_sign, 
          t1.transaction_amt_sign, 
          t1.direction_cd, 
          t1.sepa_debtor_country_cd, 
          t1.sepa_creditor_country_cd, 
          t1.sepa_counterparty_country, 
          t1.spm_receiver_country_code, 
          t1.spm_payer_country_code, 
          t1.stips_counterparty_country, 
          t1.stips_main_bank_country, 
          t1.find_payment_id, 
          t1.count_payment_id, 
          t1.counterparty_country_cd, 
          t1.in_ees_flag, 
          t1.result_office_id, 
          t1.advisor1_id_f, 
          t1.advisor2_id_f, 
          t1.payer, 
          t1.receiver, 
          t1.after_filter_subtrans_count, 
          t1.correction_flag AS correction_flag_old, 
          t2.correction_flag AS correction_flag, 
          t1.return_flag, 
          t1.account_group, 
          /* aab_transaction_type_cd */
            (case when t4.code_cd is missing then 99 else t4.code_cd end) AS aab_transaction_type_cd, 
          t4.text_eng AS aab_transaction_text, 
          t4.text_swe AS aab_transaction_text_swe, 
          t1.main_account_employee_status_cd, 
          t1.counterparty_employee_status_cd
      FROM WORK.QUERY_FOR_TRANSACTION_000A__0002 t1
           LEFT JOIN WORK.PAYMAPP t2 ON (t1.system_cd = t2.system_cd) AND (t1.registration_cd = t2.registration_cd) AND 
          (t1.account_group = t2.account_group AND (t1.count_payment_id ge t2.min_trans_count AND 
          t1.count_payment_id le t2.max_trans_count AND
          (t2.payment_type = '' OR t2.payment_type = t1.payment_type) AND
          (
          t2.text_cd = '' OR
          (substr(t2.text_cd,1,2)="<>" AND 
          	index(trim(t2.text_cd),trim(t1.cbs_transaction_cd))=0) OR
          (t2.text_cd <> ''  AND
          substr(t2.text_cd,1,2)<>"<>" AND 
          	index(trim(t2.text_cd),trim(t1.cbs_transaction_cd))>0
          )
          ))) AND (t1.transaction_amt_sign = t2.transaction_sign)
           LEFT JOIN WORK.QUERY_FOR_PAR_CODES t4 ON (t2.aab_transaction_type_cd = t4.code_cd);
QUIT;
/* --- End of code for "Add transaction codes". --- */

/* --- Start of code for "6 & 7. Distinct values + final filters". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_TRANSACTION_000A_0004);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_TRANSACTION_000A_0004 AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.payment_type, 
		  t1.name,  /* 2023-11-20 AÖ */
		  t1.ssn_id, /* 2023-11-20 AÖ */
          t1.system_cd, 
          t1.registration_cd, 
          t1.cbs_transaction_cd, 
          t1.cbs_transaction_text, 
          t1.booking_date, 
          t1.value_date, 
          t1.payment_date, 
          t1.user_id, 
          t1.reference_number_id, 
          t1.archive_code_cd, 
          t1.payment_system_cd, 
          t1.authentication_type_cd, 
          t1.source_system_cd, 
          t1.direction_cd, 
          t1.sepa_debtor_country_cd, 
          t1.sepa_creditor_country_cd, 
          t1.spm_receiver_country_code, 
          t1.spm_payer_country_code, 
          t1.stips_counterparty_country, 
          t1.stips_main_bank_country, 
          t1.transaction_id, 
          t1.transaction_currency_cd, 
          t1.exchange_rate, 
          t1.sepa_id, 
          t1.stips_cbs_order_id, 
          t1.spm_payment_id, 
          t1.count_payment_id, 
          /* abs_book_amt */
            (abs(book_amt)) AS abs_book_amt, 
          /* abs_trans_amt */
            (abs(transaction_amt)) AS abs_trans_amt, 
          /* abs_book_amt_eur */
            (case when t1.bank_id='A' then abs(book_amt)
            else abs(book_amt)*t2.mid_rate
            end) AS abs_book_amt_eur, 
          t1.book_amt, 
          /* book_amt_eur */
            (case when t1.bank_id='A' then book_amt
            else book_amt*t2.mid_rate
            end) AS book_amt_eur, 
          t1.transaction_amt AS transaction_amt, 
          t1.transaction_amt_sign, 
          t1.sepa_instructed_amt, 
          t1.spm_payment_amt, 
          t1.spm_book_amt, 
          t1.stips_payment_amt, 
          t1.stips_book_amt, 
          t1.stips_customer_account_amt, 
          t1.counterparty_country_cd, 
          /* region_country_cd */
            (case
            when t1.in_ees_flag is missing then ''
            when t1.bank_id='A' and counterparty_country_cd='FI' then 'IN_COUNTRY'
            when t1.bank_id='B' and counterparty_country_cd='SE' then 'IN_COUNTRY'
            when t1.in_ees_flag=1 then 'IN_EES'
            else 'OUTSIDE_EES'
            end) AS region_country_cd, 
          t1.main_account_id, 
          t1.account_type_cd AS main_account_type, 
          t1.main_account_currency, 
          t1.main_account_owner, 
          t1.main_account_ownername, 
          t1.main_account_ownertype, 
          t1.counterparty_account_id, 
          t1.counterparty_account_type, 
          t1.counterparty_account_type_desc, 
          t1.counterparty_account_currency, 
          t1.counterparty_account_owner, 
          t1.counterparty_account_ownername, 
          t1.counterparty_account_ownertype, 
          t1.result_office_id, 
          t1.advisor1_id_f, 
          t1.advisor2_id_f, 
          t1.payer, 
          t1.receiver, 
          t1.correction_flag, 
          t1.return_flag, 
          t1.aab_transaction_type_cd, 
          t1.aab_transaction_text, 
          t1.aab_transaction_text_swe, 
          t3.payment_instrument_cd, 
          t5.text_eng AS payment_instrument_text, 
          t5.text_swe AS payment_instrument_text_swe, 
          t1.account_group, 
          t1.main_account_employee_status_cd, 
          t1.counterparty_employee_status_cd
      FROM WORK.QUERY_FOR_TRANSACTION_000A1 t1
           LEFT JOIN DW_DW.EXCHANGE_RATES t2 ON (t1.booking_date = t2.information_date AND (t1.bank_id='B' and 
          t2.currency_cd='EUR')) AND (t1.bank_id = t2.bank_id)
           LEFT JOIN WORK.PAYINSTRUMENT t3 ON (t1.system_cd = t3.system_cd) AND (t1.registration_cd = 
          t3.registration_cd AND (t3.account_type_cd='' OR
          (substr(t3.account_type_cd,1,2)='<>' AND 
          	index(t3.account_type_cd,trim(t1.account_type_cd))=0) OR
          (t3.account_type_cd <>'' AND 
          	substr(t3.account_type_cd,1,2)<>'<>' AND 
          	index(trim(t3.account_type_cd),trim(t1.account_type_cd))>0
          )))
           LEFT JOIN WORK.QUERY_FOR_PAR_CODES_0000 t5 ON (t3.payment_instrument_cd = t5.code_cd)
      WHERE t1.aab_transaction_type_cd NOT IS MISSING;
QUIT;
/* --- End of code for "6 & 7. Distinct values + final filters". --- */

/* --- Start of code for "ÅAB customers". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_TRANSACTION_000A_0008);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_TRANSACTION_000A_0008 AS 
   SELECT DISTINCT t1.bank_id, 
          t1.main_account_owner, 
          t1.main_account_ownername, 
          t1.main_account_type, 
          t1.main_account_id
      FROM WORK.QUERY_FOR_TRANSACTION_000A_0004 t1
      WHERE t1.main_account_ownername CONTAINS 'ÅLANDSBANKEN' OR t1.main_account_ownername CONTAINS 'COMPASS CARD' AND 
           t1.main_account_ownername CONTAINS 'CROSSKEY' AND t1.main_account_ownername = 'ÅLANDSBANKEN FONDBOLAG';
QUIT;
/* --- End of code for "ÅAB customers". --- */

/* --- Start of code for "Export transaction data". --- */
%_eg_conditional_dropds(WORK.QUERY_FOR_TRANSACTION_000A1_0001);

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_TRANSACTION_000A1_0001(compress=yes) AS 
   SELECT DISTINCT t1.bank_id, 
          t1.information_date, 
          t1.booking_date, 
          t1.payment_type, 
          t1.direction_cd, 
          t1.system_cd, 
          t1.registration_cd, 
          t1.cbs_transaction_cd, 
          t1.cbs_transaction_text, 
          t1.main_account_id, 
          t1.main_account_type, 
          t1.main_account_owner AS main_account_owner_id, 
          t1.main_account_ownertype AS main_account_owner_type, 
          t1.counterparty_account_id, 
          t1.counterparty_account_type, 
          t1.counterparty_account_owner, 
          t1.counterparty_country_cd, 
          t1.region_country_cd, 
          t1.aab_transaction_type_cd, 
          t1.aab_transaction_text_swe AS aab_transaction_text, 
          t1.payment_instrument_cd, 
          t1.payment_instrument_text_swe AS payment_instrument_text, 
          t1.transaction_id, 
          t1.transaction_amt, 
          t1.book_amt LABEL='', 
          t1.book_amt_eur, 
          t1.exchange_rate, 
          t1.transaction_currency_cd, 
          /* payer */
            (case when payer='OTHER' and transaction_amt<0 then main_account_ownername
            when payer='OTHER' and transaction_amt>0 then counterparty_account_ownername 
            else payer end) AS payer, 
          /* receiver */
            (case when receiver='OTHER' and transaction_amt<0 then counterparty_account_ownername 
            when receiver='OTHER' and transaction_amt>0 then main_account_ownername 
            else receiver end) AS receiver, 
          t1.correction_flag, 
          t1.return_flag,
		  t1.name, /* 2023-11-20 AÖ */
		  t1.ssn_id as ssn  /* 2023-11-20 AÖ */
      FROM WORK.QUERY_FOR_TRANSACTION_000A_0004 t1, C_CTRL.PAR_BANK_DAYS_L t5
      WHERE (t1.information_date = t5.information_date AND t1.bank_id = t5.bank_id) AND (t1.aab_transaction_text NOT IS 
           MISSING AND NOT (t1.cbs_transaction_cd in ('LÖN','107','SES') AND (t1.main_account_employee_status_cd<>'' OR 
           t1.counterparty_employee_status_cd<>'')));
QUIT;
/* --- End of code for "Export transaction data". --- */

/* --- Start of code for "Insert latest payments". --- */
%if &tenant=aab %then %do; 
	libname dwiaffs "/sasdw/&env/dw/data/int/affstod";
%end;
%else %do; 
	libname dwiaffs "/sasdw/&env/dwh/data/int/&tenant";
%end;


proc sql;
INSERT INTO dwiaffs.PAY_CUSTOMER_PAYMENT_L
SELECT* FROM WORK.QUERY_FOR_TRANSACTION_000A1_0001;

proc sql noprint;
SELECT max(information_date) into :latest_payment_date trimmed from dwiaffs.PAY_CUSTOMER_PAYMENT_L;
quit;
proc sql;
DELETE FROM dwiaffs.PAY_CUSTOMER_PAYMENT_L t1 WHERE 
(intck('day',t1.booking_date,&latest_payment_date,'continuous'))>40;
quit;
%symdel latest_payment_date;

proc sql;
INSERT INTO dwiaffs.PAY_CUSTOMER_PAYMENT
SELECT * FROM WORK.QUERY_FOR_TRANSACTION_000A1_0001;
quit;

/* --- End of code for "Insert latest payments". --- */

/* --- Start of code for "log". --- */

%dwi_log(lib=&dw_outlib,str1="dwi_customer_payment",str2="", timestamp_start=&timestamp_start,timestamp_end=%sysfunc(datetime()),user="&_metauser",tenant="&tenant");



/* --- End of code for "log". --- */

*  Begin EG generated code (do not edit this line);
;*';*";*/;quit;
%STPEND;

*  End EG generated code (do not edit this line);

