/* Tillfällig lösning för att skicka Villkorsändringar till Borgo för ICA, IKANO, S&P */

%let env=;
data _null_;
if "&syshostname"='aablprdsas11' then call symputx('env', 'prod', 'G');
else if "&syshostname"='aablstgsas21' then call symputx('env', 'test', 'G');
run;

libname dwi_hypo "/sasdw/&env./dwh/data/int/hypo";

/* Skicka bara filer på måndagar */
data _null_;
  checkMonday = weekday(today());
*4 är onsdag - testa en gång*;
  if checkMonday = 4 then call symputx('SEND_FILES_TODAY', 'YES');
  *if checkMonday = 2 then call symputx('SEND_FILES_TODAY', 'YES');
  else call symputx('SEND_FILES_TODAY', 'NO');
run;

%macro test;
  %if &SEND_FILES_TODAY=NO %then %do;
    %put No files will be sent today. Control set to: &SEND_FILES_TODAY.;
  %end;
  %else %do;
    %put Files will be sent today;


PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_BG_COLLATERAL_OBJECT_L AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t2.account_id, 
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
          t1.alternative_rule_amount, 
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
      FROM DWI_HYPO.BG_COLLATERAL_OBJECT_L t1
           LEFT JOIN DWI_HYPO.BG_CREDIT_OBJECT_LINK_L t2 ON (t1.internal_object_id = t2.internal_object_id);
QUIT;
/* --- End of code for "Query Builder". --- */

/* --- Start of code for "Program". --- */
data output_ds;
    retain serial;
    set dwi_hypo.DWI_ACCOUNT_OWNERS_L;
    by account_id;
    if first.account_id then serial = 0;
    serial = serial + 1;
run;
/* --- End of code for "Program". --- */

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_OUTPUT_DS AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.account_id, 
          t1.owner_id, 
          t1.customer_id, 
          t1.endowment_insurance_flag, 
          t1.active_insurance_restr_flag, 
          t1.main_account_customer_flag, 
          t1.main_account_owner_flag, 
          /* owner_id_1 */
            (Case when t1.serial=1 then t1.owner_id
            END) AS owner_id_1, 
          /* owner_id_2 */
            (Case when t1.serial=2 then t1.owner_id
            END) AS owner_id_2, 
          /* owner_id_3 */
            (Case when t1.serial=3 then t1.owner_id
            END) AS owner_id_3, 
          /* owner_id_4 */
            (Case when t1.serial=4 then t1.owner_id
            END) AS owner_id_4
      FROM WORK.OUTPUT_DS t1;
QUIT;
/* --- End of code for "Query Builder 3". --- */


PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_OUTPUT_DS_0000 AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.account_id, 
          /* owner_id_1 */
            (MAX(t1.owner_id_1)) AS owner_id_1, 
          /* owner_id_2 */
            (MAX(t1.owner_id_2)) AS owner_id_2, 
          /* owner_id_3 */
            (MAX(t1.owner_id_3)) AS owner_id_3, 
          /* owner_id_4 */
            (MAX(t1.owner_id_4)) AS owner_id_4
      FROM WORK.QUERY_FOR_OUTPUT_DS t1
      GROUP BY t1.information_date,
               t1.bank_id,
               t1.account_id;
QUIT;
/* --- End of code for "Query Builder 4". --- */


PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_OUTPUT_DS_0001 AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t2.business_area, 
          t1.account_id, 
          t1.owner_id_1, 
          t1.owner_id_2, 
          t1.owner_id_3, 
          t1.owner_id_4, 
          t2.name AS name_owner_1, 
          t2.ssn AS owner1_ssn
      FROM WORK.QUERY_FOR_OUTPUT_DS_0000 t1
           LEFT JOIN DWI_HYPO.BG_CUSTOMER_LIST_L t2 ON (t1.owner_id_1 = t2.customer_id);
QUIT;
/* --- End of code for "Query Builder 5". --- */


PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_OUTPUT_DS_0002 AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.business_area, 
          t1.account_id, 
          t1.owner_id_1, 
          t1.owner_id_2, 
          t1.owner_id_3, 
          t1.owner_id_4, 
          t1.name_owner_1, 
          t2.name AS name_owner_2, 
          t1.owner1_ssn, 
          t2.ssn AS owner2_ssn
      FROM WORK.QUERY_FOR_OUTPUT_DS_0001 t1
           LEFT JOIN DWI_HYPO.BG_CUSTOMER_LIST_L t2 ON (t1.owner_id_2 = t2.customer_id);
QUIT;
/* --- End of code for "Query Builder 6". --- */


PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_OUTPUT_DS_0003 AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.business_area, 
          t1.account_id, 
          t1.owner_id_1, 
          t1.owner_id_2, 
          t1.owner_id_3, 
          t1.owner_id_4, 
          t1.name_owner_1, 
          t1.name_owner_2, 
          t2.name AS name_owner_3, 
          t1.owner1_ssn, 
          t1.owner2_ssn, 
          t2.ssn AS owner3_ssn
      FROM WORK.QUERY_FOR_OUTPUT_DS_0002 t1
           LEFT JOIN DWI_HYPO.BG_CUSTOMER_LIST_L t2 ON (t1.owner_id_3 = t2.customer_id);
QUIT;
/* --- End of code for "Query Builder 7". --- */

PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_OUTPUT_DS_0004 AS 
   SELECT t1.information_date, 
          t1.bank_id, 
          t1.business_area, 
          t1.account_id, 
          t3.account_type_cd, 
          t3.account_type, 
          t1.owner_id_1, 
          t1.owner_id_2, 
          t1.owner_id_3, 
          t1.owner_id_4, 
          t1.name_owner_1, 
          t1.name_owner_2, 
          t1.name_owner_3, 
          t2.name AS name_owner_4, 
          t1.owner1_ssn, 
          t1.owner2_ssn, 
          t1.owner3_ssn, 
          t2.ssn AS owner4_ssn
      FROM WORK.QUERY_FOR_OUTPUT_DS_0003 t1
           LEFT JOIN DWI_HYPO.BG_CUSTOMER_LIST_L t2 ON (t1.owner_id_4 = t2.customer_id)
           LEFT JOIN DWI_HYPO.BG_ACCOUNTS_L t3 ON (t1.account_id = t3.account_id);
QUIT;
/* --- End of code for "Query Builder 8". --- */


PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_BG_COLLATERAL_OBJ_0000 AS 
   SELECT t1.information_date, 
          t2.business_area, 
          t1.account_id, 
          t2.account_type_cd, 
          t2.account_type, 
          t1.internal_object_id, 
          t1.h_company_name, 
          t1.rp_plot_name, 
          t1.rp_block_id, 
          t1.object_type_cd, 
          t1.object_type_txt, 
          t1.object_category, 
          t2.owner_id_1, 
          t2.owner_id_2, 
          t2.owner_id_3, 
          t2.owner_id_4, 
          t2.owner1_ssn, 
          t2.owner2_ssn, 
          t2.owner3_ssn, 
          t2.owner4_ssn, 
          t2.name_owner_1, 
          t2.name_owner_2, 
          t2.name_owner_3, 
          t2.name_owner_4
      FROM WORK.QUERY_FOR_BG_COLLATERAL_OBJECT_L t1
           LEFT JOIN WORK.QUERY_FOR_OUTPUT_DS_0004 t2 ON (t1.account_id = t2.account_id);
QUIT;
/* --- End of code for "Query Builder 1". --- */


PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_BG_COLLATERAL_OBJ AS 
   SELECT t1.information_date, 
          t1.business_area, 
          t2.next_renegotiation_date, 
          t1.account_id, 
          t1.account_type_cd, 
          t1.account_type, 
          t3.account_number_official, 
          t1.internal_object_id, 
          t1.h_company_name, 
          t1.rp_plot_name, 
          t1.rp_block_id, 
          t1.object_type_cd, 
          t1.object_type_txt, 
          t1.object_category, 
          t1.owner1_ssn, 
          t1.owner2_ssn, 
          t1.owner3_ssn, 
          t1.owner4_ssn, 
          t1.name_owner_1, 
          t1.name_owner_2, 
          t1.name_owner_3, 
          t1.name_owner_4, 
          t2.balance_amount, 
          t2.ref_interest_fix_period_m, 
          t2.next_principal_payment_amount
      FROM WORK.QUERY_FOR_BG_COLLATERAL_OBJ_0000 t1
           INNER JOIN DWH_DW.LOAN_ADDITIONAL_DATA_L t2 ON (t1.account_id = t2.account_id)
           LEFT JOIN DWI_HYPO.BG_ACCOUNTS_L t3 ON (t2.account_id = t3.account_id)
      ORDER BY t2.next_renegotiation_date;
QUIT;
/* --- End of code for "Query Builder 2". --- */


PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_BG_COLLATERAL_OBJ_0001 AS 
   SELECT t1.information_date, 
          t1.business_area, 
          t1.next_renegotiation_date, 
          t1.account_id, 
          t1.account_type_cd, 
          t1.account_type, 
          t1.account_number_official, 
          t1.internal_object_id, 
          t1.object_type_cd, 
          t1.object_type_txt, 
          t1.object_category, 
          t1.owner1_ssn, 
          t1.owner2_ssn, 
          t1.owner3_ssn, 
          t1.owner4_ssn, 
          t1.name_owner_1, 
          t1.name_owner_2, 
          t1.name_owner_3, 
          t1.name_owner_4, 
          t1.balance_amount, 
          t1.ref_interest_fix_period_m, 
          t1.next_principal_payment_amount, 
          t2.co_name AS co_name, 
          t2.street_address AS street_address, 
          t2.street_address2 AS street_address2, 
          t2.post_office_number AS post_office_number, 
          t2.post_office_name AS post_office_name, 
          t2.country_cd AS country_cd
      FROM WORK.QUERY_FOR_BG_COLLATERAL_OBJ t1
           LEFT JOIN DWH_DW.CUSTOMER_L t2 ON (t1.owner1_ssn = t2.ssn_id);
QUIT;
/* --- End of code for "Query Builder 9". --- */


PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_BG_COLLATERAL_OBJ_0002 AS 
   SELECT t1.information_date, 
          t1.business_area, 
          t1.next_renegotiation_date, 
          t1.account_id, 
          t1.account_type_cd, 
          t1.account_type, 
          t1.account_number_official, 
          t1.internal_object_id, 
          t1.object_type_cd, 
          t1.object_type_txt, 
          t1.object_category, 
          t2.housing_association_name, 
          t2.apartment_number, 
          t1.owner1_ssn, 
          t1.owner2_ssn, 
          t1.owner3_ssn, 
          t1.owner4_ssn, 
          t1.name_owner_1, 
          t1.name_owner_2, 
          t1.name_owner_3, 
          t1.name_owner_4, 
          t1.balance_amount, 
          t1.ref_interest_fix_period_m, 
          t1.next_principal_payment_amount, 
          t1.co_name, 
          t1.street_address, 
          t1.street_address2, 
          t1.post_office_number, 
          t1.post_office_name, 
          t1.country_cd
      FROM WORK.QUERY_FOR_BG_COLLATERAL_OBJ_0001 t1
           LEFT JOIN DWH_DW.LOAN_COLL_OBJ_HOUSING_L t2 ON (t1.account_number_official = t2.official_account_number);
QUIT;
/* --- End of code for "Query Builder 10". --- */


PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_LOAN_COLL_OBJ_MORT_L AS 
   SELECT DISTINCT t1.information_date, 
          t1.official_account_number, 
          t1.real_property_name
      FROM DWH_DW.LOAN_COLL_OBJ_MORT_L t1;
QUIT;
/* --- End of code for "Query Builder 12". --- */


PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_BG_COLLATERAL_OBJ_0003 AS 
   SELECT t1.information_date, 
          t1.business_area, 
          t1.next_renegotiation_date, 
          t1.account_id, 
          t1.account_type_cd, 
          t1.account_type, 
          t1.account_number_official, 
          t1.internal_object_id, 
          t1.object_type_cd, 
          t1.object_type_txt, 
          t1.object_category, 
          t1.housing_association_name, 
          t1.apartment_number, 
          t2.real_property_name, 
          t1.owner1_ssn, 
          t1.owner2_ssn, 
          t1.owner3_ssn, 
          t1.owner4_ssn, 
          t1.name_owner_1, 
          t1.name_owner_2, 
          t1.name_owner_3, 
          t1.name_owner_4, 
          t1.balance_amount, 
          t1.ref_interest_fix_period_m, 
          t1.next_principal_payment_amount, 
          t1.co_name, 
          t1.street_address, 
          t1.street_address2, 
          t1.post_office_number, 
          t1.post_office_name, 
          t1.country_cd
      FROM WORK.QUERY_FOR_BG_COLLATERAL_OBJ_0002 t1
           LEFT JOIN WORK.QUERY_FOR_LOAN_COLL_OBJ_MORT_L t2 ON (t1.account_number_official = t2.official_account_number);
QUIT;
/* --- End of code for "Query Builder 11". --- */


PROC SQL;
   CREATE TABLE ICA_EXPORT_UNDERLAG AS 
   SELECT t1.information_date, 
          t1.business_area, 
          t1.next_renegotiation_date, 
          t1.account_id, 
          t1.account_number_official, 
          t1.internal_object_id, 
          t1.object_type_cd, 
          t1.object_type_txt, 
          t1.object_category, 
          t1.housing_association_name, 
          t1.apartment_number, 
          t1.real_property_name, 
          t1.owner1_ssn, 
          t1.owner2_ssn, 
          t1.owner3_ssn, 
          t1.owner4_ssn, 
          t1.name_owner_1, 
          t1.name_owner_2, 
          t1.name_owner_3, 
          t1.name_owner_4, 
          t1.balance_amount, 
          t1.ref_interest_fix_period_m, 
          t1.next_principal_payment_amount, 
          t1.co_name, 
          t1.street_address, 
          t1.street_address2, 
          t1.post_office_number, 
          t1.post_office_name, 
          t1.country_cd, 
          /* Antal dagar */
            (t1.next_renegotiation_date-t1.information_date) AS 'Antal dagar'n
      FROM WORK.QUERY_FOR_BG_COLLATERAL_OBJ_0003 t1
      WHERE t1.account_type = 'BOLÅN ICA'
      ORDER BY 'Antal dagar'n;
QUIT;
/* --- End of code for "ICA". --- */



PROC SQL;
   CREATE TABLE SoP_EXPORT_UNDERLAG AS 
   SELECT t1.information_date, 
          t1.business_area, 
          t1.next_renegotiation_date, 
          t1.account_id, 
          t1.account_number_official, 
          t1.internal_object_id, 
          t1.object_type_cd, 
          t1.object_type_txt, 
          t1.object_category, 
          t1.housing_association_name, 
          t1.apartment_number, 
          t1.real_property_name, 
          t1.owner1_ssn, 
          t1.owner2_ssn, 
          t1.owner3_ssn, 
          t1.owner4_ssn, 
          t1.name_owner_1, 
          t1.name_owner_2, 
          t1.name_owner_3, 
          t1.name_owner_4, 
          t1.balance_amount, 
          t1.ref_interest_fix_period_m, 
          t1.next_principal_payment_amount, 
          t1.co_name, 
          t1.street_address, 
          t1.street_address2, 
          t1.post_office_number, 
          t1.post_office_name, 
          t1.country_cd, 
          /* Antal dagar */
            (t1.next_renegotiation_date-t1.information_date) AS 'Antal dagar'n
      FROM WORK.QUERY_FOR_BG_COLLATERAL_OBJ_0003 t1
      WHERE t1.account_type = 'BOLÅN S&P'
      ORDER BY 'Antal dagar'n;
QUIT;
/* --- End of code for "S&P". --- */


PROC SQL;
   CREATE TABLE IKANO_EXPORT_UNDERLAG AS 
   SELECT t1.information_date, 
          t1.business_area, 
          t1.next_renegotiation_date, 
          t1.account_id, 
          t1.account_number_official, 
          t1.internal_object_id, 
          t1.object_type_cd, 
          t1.object_type_txt, 
          t1.object_category, 
          t1.housing_association_name, 
          t1.apartment_number, 
          t1.real_property_name, 
          t1.owner1_ssn, 
          t1.owner2_ssn, 
          t1.owner3_ssn, 
          t1.owner4_ssn, 
          t1.name_owner_1, 
          t1.name_owner_2, 
          t1.name_owner_3, 
          t1.name_owner_4, 
          t1.balance_amount, 
          t1.ref_interest_fix_period_m, 
          t1.next_principal_payment_amount, 
          t1.co_name, 
          t1.street_address, 
          t1.street_address2, 
          t1.post_office_number, 
          t1.post_office_name, 
          t1.country_cd, 
          /* Antal dagar */
            (t1.next_renegotiation_date-t1.information_date) AS 'Antal dagar'n
      FROM WORK.QUERY_FOR_BG_COLLATERAL_OBJ_0003 t1
      WHERE t1.account_type = 'BOLÅN IKANO'
      ORDER BY 'Antal dagar'n;
QUIT;
/* --- End of code for "IKANO". --- */




proc export data=ICA_EXPORT_UNDERLAG outfile='/home/sasbatch/Villkorsändringsdatum ICA.xlsx' replace dbms=xlsx;
run; 
proc export data=SoP_EXPORT_UNDERLAG outfile='/home/sasbatch/Villkorsändringsdatum SoP.xlsx' replace dbms=xlsx;
run; 
proc export data=IKANO_EXPORT_UNDERLAG outfile='/home/sasbatch/Villkorsändringsdatum IKANO.xlsx' replace dbms=xlsx;
run; 


%let mailaTill=%str(jenny.espling@alandsbanken.se);

/* %let mailaTill=%str("jonas.ed@borgohypotek.se" "linnea.sigot@borgohypotek.se" "petter.damberg@borgohypotek.se"); */
/* mats.dahlfors@alandsbanken.fi */

%let mailaTill=%str(jenny.espling@alandsbanken.se);
filename epost email 
  to=(&MailaTill.)
  from=('SAS DW <sasbatch@aablprdsas11.crosskey.fi>')
  cc=(jenny.espling@alandsbanken.se)
  subject="Extra text att mail funkar: Filer med Villkorsändring"
  attach=("/home/sasbatch/Villkorsändringsdatum ICA.xlsx" 
         '/home/sasbatch/Villkorsändringsdatum SoP.xlsx'
         "/home/sasbatch/Villkorsändringsdatum IKANO.xlsx");

data _null_;
  file epost;
  put "Hej,";
  put ;
  put 'Senast uppdaterade filerna med villkorsändringar bifogas.';
  put ;
  put 'Denna epost-adress är inte bevakad. Vid eventuella frågor maila till data@alandsbanken.fi.';
  put ;
  put "Vänliga hälsningar,";
  put "SAS DW";
run;

  %end;

%mend;
%test;

