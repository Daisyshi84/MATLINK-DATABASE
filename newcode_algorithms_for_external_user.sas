
%LET RC=%SYSFUNC(GRDSVC_ENABLE(_ALL_,RESOURCE=CSP_MNL )) ; %PUT RETURN CODE = &RC. ; SIGNON TASK1;
%let mypassword=CDCpword1;
PROC PWENCODE IN="&mypassword" ; run;


rsubmit;
libname nhcs20 oledb INIT_STRING="Integrated Security=SSPI;Persist Security Info=True;Initial Catalog=NHCS_2020_HCT;
Data Source=DSPV-INFC-CS161\prod;" PROVIDER=SQLNCLI11 PROMPT=NO
user="&sysuserid" password='{SAS002}6FE4B6262DA40AE917D7C0721A7867A2'
access=readonly access=readonly dbmax_text=32767;
endrsubmit;

rsubmit;
libname output "\\cdc.gov\csp_project\CIPSEA_DHCS_NHCS_PROJECTS\PCORTF_FY23\data\Final_Research_File_Tables";
endrsubmit;



/* one people click;*/
LIBNAME GRIDWORK REMOTE SERVER= TASK1  SLIBREF= WORK;


/* %include "\\cdc.gov\csp_project\CIPSEA_DHCS_NHCS_PROJECTS\PCORTF_FY23\Daisy\Code\revenue_table_recode.sas";
/* two people click after here ;*/

 
%macro create_output_table(CODE_SYSTEM=,dataType=,inputPath=,inputFileName=,columns_to_keep=, output_table_name=, code=, codesys_name=, searching_text=);

proc import out= code
    datafile =  "\\cdc.gov\csp_project\CIPSEA_DHCS_NHCS_PROJECTS\PCORTF_FY23\data\code_mapping.xlsx"
    dbms=xlsx replace;
    getnames=yes;
    sheet= "Sheet1";
    range = "A:AB";
run;

data code;
set code;
if CODE_SYSTEM = "&CODE_SYSTEM";
run;


%macro OPIOID_RXNORM(macro_variable,variable_name);

options nonotes;
%global &macro_variable ; 
proc sql noprint outobs=1500;
  select compress(quote(CODE),' ') into :&macro_variable separated by ', '  
  from code
  where &variable_name = 1;
quit;

%let len = %sysfunc(countw(%superq(&macro_variable), %str(,)));
%put &macro_variable Total code number is &len;
%put;



%put &&&macro_variable;
%mend;

%OPIOID_RXNORM(OPIOID_ANY_CODE_RXNORM1,OPIOID_ANY_CODE)



%macro OPIOID_RXNORM1(macro_variable,variable_name);

options nonotes;
%global &macro_variable ; 
proc sql noprint ;
  select compress(quote(CODE),' ') into :&macro_variable separated by ', '  
  from code
  where &variable_name = 1  and CODE NOT IN (&OPIOID_ANY_CODE_RXNORM1) ;
quit;

%let len = %sysfunc(countw(%superq(&macro_variable), %str(,)));
%put &macro_variable Total code number is &len;
%put;
%if &len =0 %then %do;
%let &macro_variable = ' ';
%end;

%mend;

%OPIOID_RXNORM1(OPIOID_ANY_CODE_RXNORM2,OPIOID_ANY_CODE)

/*
%macro OPIOID_ICD(macro_variable,variable_name);
options nonotes;
%global &macro_variable;
proc sql noprint;
  select compress(quote(CODE),' ') into :&macro_variable separated by ', '  
  from code
  where &variable_name = 1 and CODE_SYSTEM = 'ICD-10-CM';
quit;
%let len = %sysfunc(countw(%superq(&macro_variable), %str(,)));
%put &macro_variable Total code number is &len;
%put;
%if &len =0 %then %do;
%let &macro_variable = ' ';
%end;

%mend; 
 
%OPIOID_ICD(OPIOID_ANY_CODE_ICD,OPIOID_ANY_CODE) */





%macro sql_store_ICD(macro_variable,variable_name);
options nonotes;
%global &macro_variable;

proc sql noprint;
   select compress(quote(CODE),' ')  into : &macro_variable separated by ',' 
  from code
  where &variable_name = 1 
  order by CODE desc;
quit;

/* Count the elements in &&&macro_variable */
%let len = %sysfunc(countw(%superq(&macro_variable), %str(,)));
%put &macro_variable Total code number is &len;
%put;
/* %put &&&macro_variable; /* list out each of the code in code mapping file*/

%if &len =0 %then %do;
%let &macro_variable = ' ';
%end;
%mend;


%sql_store_ICD(STIM_ANY_CODE,STIM_ANY_CODE)
%sql_store_ICD(DRUGSCREEN_CODE,DRUGSCREEN_CODE)
%sql_store_ICD(STIM_NON_TX_UNSP_CODE,STIM_NON_TX_UNSP_CODE)
%sql_store_ICD(STIM_TX_CODE,STIM_TX_CODE)
%sql_store_ICD(TX_METHYLPHENIDATE_CODE,TX_METHYLPHENIDATE_CODE)
%sql_store_ICD(TX_DEXTROAMPHETAMINE_CODE,TX_DEXTROAMPHETAMINE_CODE)
%sql_store_ICD(TX_AMPHETAMINE_CODE,TX_AMPHETAMINE_CODE)
%sql_store_ICD(TX_DEXMETHYLPHENIDATE_CODE,TX_DEXMETHYLPHENIDATE_CODE)
%sql_store_ICD(TX_LISDEXAMFETAMINE_CODE,TX_LISDEXAMFETAMINE_CODE)
%sql_store_ICD(TX_AMPHET_DEXTROAMPHET_CODE,TX_AMPHET_DEXTROAMPHET_CODE)
%sql_store_ICD(STIM_MISUSE_CODE,STIM_MISUSE_CODE)
%sql_store_ICD(MISUSE_METHYLPHENIDATE_CODE,MISUSE_METHYLPHENIDATE_CODE)
%sql_store_ICD(MISUSE_AMPHETAMINE_CODE,MISUSE_AMPHETAMINE_CODE)
%sql_store_ICD(STIM_ILLICIT_CODE,STIM_ILLICIT_CODE)
%sql_store_ICD(ILLICIT_COCAINE_CODE,ILLICIT_COCAINE_CODE)
%sql_store_ICD(ILLICIT_METHAMPHETAMINE_CODE,ILLICIT_METHAMPHETAMINE_CODE)
%sql_store_ICD(ILLICIT_MDMA_CODE,ILLICIT_MDMA_CODE)
%sql_store_ICD(OPIOID_MISUSE_CODE,OPIOID_MISUSE_CODE)
%sql_store_ICD(OPIOID_ILLICIT_CODE,OPIOID_ILLICIT_CODE)
%sql_store_ICD(OPIOID_NON_TX_UNSP_CODE,OPIOID_NON_TX_UNSP_CODE)


%let var = STIM_ANY_CODE DRUGSCREEN_CODE STIM_TX_CODE STIM_NON_TX_UNSP_CODE TX_METHYLPHENIDATE_CODE TX_DEXTROAMPHETAMINE_CODE
TX_AMPHETAMINE_CODE TX_DEXMETHYLPHENIDATE_CODE TX_LISDEXAMFETAMINE_CODE TX_AMPHET_DEXTROAMPHET_CODE
STIM_MISUSE_CODE MISUSE_METHYLPHENIDATE_CODE MISUSE_AMPHETAMINE_CODE STIM_ILLICIT_CODE
ILLICIT_COCAINE_CODE ILLICIT_METHAMPHETAMINE_CODE ILLICIT_MDMA_CODE OPIOID_ANY_CODE OPIOID_MISUSE_CODE 
OPIOID_ILLICIT_CODE OPIOID_NON_TX_UNSP_CODE 
STIM_ANY_NON_TX_CODE OPIOID_ANY_NON_TX_CODE;

%if %upcase(&dataType) eq DB %then %do;

data output(compress=yes);
%if "&inputFileName" = "labs" %then %do;
  set nhcs20.&inputFileName( KEEP= &columns_to_keep &code &codesys_name lab_qual_result);
  where &codesys_name = &searching_text and not missing(&code) and lab_qual_result in ('H','HH','A','POS');
%end;
%else %do;
  set nhcs20.&inputFileName( KEEP= &columns_to_keep &code &codesys_name);
  where &codesys_name = &searching_text and not missing(&code);
%end;

%end;


%else %if %upcase(&dataType) eq SAS %then %do;
libname out "&inputPath";
	data output;
	set out.&inputFileName( KEEP= &columns_to_keep &code &codesys_name);
	run;
%end;

%else %if %upcase(&dataType) eq EXCEL %then %do;
	proc import datafile= "&inputPath.\&inputFileName..xlsx";
		out=output
		dbms=xlsx replace;
	run;
%end;

%else %if %upcase(&dataType) eq CSV %then %do;
	proc import datafile= "&inputPath.\&inputFileName..csv";
		out=output
		dbms=csv replace;
	run;
%end;

%else %do;
    %put ERROR: Invalid data type specified. choose from (DB, SAS,EXCEL or CSV);
%end;

data output1(compress=yes);
 set output;
	array char[*] &columns_to_keep;	
	do i = 1 to dim(char);
		char[i] = put(char[i], $char.);
	end;

    &code = strip(put(&code,100.));
	
 	if (&code in: (&OPIOID_ANY_CODE_RXNORM1) AND &codesys_name =&searching_text) or (&code in: (&OPIOID_ANY_CODE_RXNORM2) AND &codesys_name =&searching_text) THEN  OPIOID_ANY_CODE=1 ; else OPIOID_ANY_CODE=0 ; 
	if &code  in: (&STIM_ANY_CODE) AND &codesys_name = &searching_text  THEN  STIM_ANY_CODE=1 ; else STIM_ANY_CODE=0 ;
	if &code  in: (&DRUGSCREEN_CODE) AND &codesys_name =&searching_text  THEN  DRUGSCREEN_CODE=1 ; else DRUGSCREEN_CODE=0 ;
	if &code  in: (&STIM_TX_CODE) AND &codesys_name =&searching_text  THEN  STIM_TX_CODE=1 ; else STIM_TX_CODE=0 ;
	if &code  in: (&STIM_NON_TX_UNSP_CODE) AND &codesys_name =&searching_text  THEN  STIM_NON_TX_UNSP_CODE=1 ; else STIM_NON_TX_UNSP_CODE=0 ;
	if &code  in: (&TX_METHYLPHENIDATE_CODE) AND &codesys_name = &searching_text  THEN  TX_METHYLPHENIDATE_CODE=1 ; else TX_METHYLPHENIDATE_CODE=0 ;
	if &code  in: (&TX_DEXTROAMPHETAMINE_CODE) AND &codesys_name =&searching_text  THEN  TX_DEXTROAMPHETAMINE_CODE=1 ; else TX_DEXTROAMPHETAMINE_CODE=0 ;
	if &code  in: (&TX_AMPHETAMINE_CODE) AND &codesys_name =&searching_text  THEN  TX_AMPHETAMINE_CODE=1 ; else TX_AMPHETAMINE_CODE=0 ;
	if &code  in: (&TX_DEXMETHYLPHENIDATE_CODE) AND &codesys_name = &searching_text  THEN  TX_DEXMETHYLPHENIDATE_CODE=1 ; else TX_DEXMETHYLPHENIDATE_CODE=0 ;
	if &code  in: (&TX_LISDEXAMFETAMINE_CODE) AND &codesys_name =&searching_text  THEN  TX_LISDEXAMFETAMINE_CODE=1 ; else TX_LISDEXAMFETAMINE_CODE=0 ;
	if &code  in: (&TX_AMPHET_DEXTROAMPHET_CODE) AND &codesys_name = &searching_text THEN  TX_AMPHET_DEXTROAMPHET_CODE=1 ; else TX_AMPHET_DEXTROAMPHET_CODE=0 ;
	if &code  in: (&STIM_MISUSE_CODE) AND &codesys_name =&searching_text  THEN  STIM_MISUSE_CODE=1 ; else STIM_MISUSE_CODE=0 ;
	if &code  in: (&MISUSE_METHYLPHENIDATE_CODE) AND &codesys_name =&searching_text  THEN  MISUSE_METHYLPHENIDATE_CODE=1 ; else MISUSE_METHYLPHENIDATE_CODE=0 ;
	if &code  in: (&MISUSE_AMPHETAMINE_CODE) AND &codesys_name =&searching_text  THEN  MISUSE_AMPHETAMINE_CODE=1 ; else MISUSE_AMPHETAMINE_CODE=0 ;
	if &code  in: (&STIM_ILLICIT_CODE) AND &codesys_name =&searching_text  THEN  STIM_ILLICIT_CODE=1 ; else STIM_ILLICIT_CODE=0 ;
	if &code  in: (&ILLICIT_COCAINE_CODE) AND &codesys_name = &searching_text  THEN  ILLICIT_COCAINE_CODE=1 ; else ILLICIT_COCAINE_CODE=0 ;
	if &code  in: (&ILLICIT_METHAMPHETAMINE_CODE) AND &codesys_name =&searching_text  THEN  ILLICIT_METHAMPHETAMINE_CODE=1 ; else ILLICIT_METHAMPHETAMINE_CODE=0 ;
	if &code  in: (&ILLICIT_MDMA_CODE) AND &codesys_name =&searching_text  THEN  ILLICIT_MDMA_CODE=1 ; else ILLICIT_MDMA_CODE=0 ;
	if &code  in: (&OPIOID_MISUSE_CODE) AND &codesys_name =&searching_text  THEN  OPIOID_MISUSE_CODE=1 ; else OPIOID_MISUSE_CODE=0 ;
	if &code  in: (&OPIOID_ILLICIT_CODE) AND &codesys_name =&searching_text  THEN  OPIOID_ILLICIT_CODE=1 ; else OPIOID_ILLICIT_CODE=0 ;
	if &code  in: (&OPIOID_NON_TX_UNSP_CODE) AND &codesys_name = &searching_text  THEN  OPIOID_NON_TX_UNSP_CODE=1 ; else OPIOID_NON_TX_UNSP_CODE=0 ;

/* one exception in the condition table */
	if condition_codesys_name = 'SNOMED-CT' and condition_codesys_name_r = 'ICD-10-CM' and condition_code = '699449003' then do;
	    ILLICIT_METHAMPHETAMINE_CODE = 1;
	    STIM_UNSP_NONTX_CODE = 0;
	end;

/* STIM_ANY_NON_TX_CODE logic */
    if STIM_NON_TX_UNSP_CODE = 1 or STIM_MISUSE_CODE = 1 or STIM_ILLICIT_CODE = 1 then do;
        STIM_ANY_NON_TX_CODE = 1;
    end;
    else do;
        STIM_ANY_NON_TX_CODE = 0;
    end;

 /* OPIOID_ANY_NON_TX_CODE logic */
    if OPIOID_NON_TX_UNSP_CODE = 1 or OPIOID_MISUSE_CODE = 1 or OPIOID_ILLICIT_CODE = 1 then do;
        OPIOID_ANY_NON_TX_CODE = 1;
    end;
    else do;
        OPIOID_ANY_NON_TX_CODE = 0;
    end;



/* exclude encounter_id when all of the ouput variables "&var(output varibales)" are 0; i.e. if nothing found across all of the &var(output varibales), then we do not need to keep them in the file. */
array var_array[*] &var;

flag = 0;

do i = 1 to dim(var_array);
	if var_array[i] ne 0 then do;
		flag = 1;
		leave;
	end;
end;

if flag = 1;

KEEP &columns_to_keep  &var;
/* for each combination of the ENCOUNTER_ID ID_SETTING SOURCE HOSPID_A, calculating maximium values for the output variables 0 OR 1, the code will generate summary table of each unique encounter_id and only keep the max value,i.e. either 1 or 0 */
proc summary data = output1 nway;
  class &columns_to_keep;
  var &var;
  output out = &output_table_name(drop=_:) max=;
run;

%mend;




%create_output_table(CODE_SYSTEM = ICD-10-CM,
					dataType= DB,
					inputPath=  ,
					inputFileName= condition,
					columns_to_keep= ENCOUNTER_ID ID_SETTING SOURCE HOSPID_A,
					output_table_name= research_condition_table,
					code= condition_code_r,
					codesys_name= condition_codesys_name_r,
					searching_text= 'ICD-10-CM')


				
%create_output_table(CODE_SYSTEM = SNOMED ,
					dataType= DB,
					inputPath= ,
					inputFileName= condition,
					columns_to_keep= ENCOUNTER_ID ID_SETTING SOURCE HOSPID_A,
					output_table_name= research_condition_table2,
					code= condition_code,
					codesys_name= condition_codesys_name,
					searching_text= 'SNOMED-CT')



%create_output_table(CODE_SYSTEM = RXNORM,
					dataType= DB,
					inputPath=  ,
					inputFileName= medication,
					columns_to_keep= ENCOUNTER_ID ID_SETTING SOURCE HOSPID_A,
					output_table_name= research_medication_table,
					code= medication_code,
					codesys_name= medication_codesys_name,
					searching_text= 'RXNORM')


%create_output_table(CODE_SYSTEM = LOINC,
					dataType= DB,
					inputPath=  ,
					inputFileName= labs,
					columns_to_keep= ENCOUNTER_ID ID_SETTING SOURCE HOSPID_A,
					output_table_name= research_labs_table,
					code= lab_testcode,
					codesys_name= lab_codesys_name,
					searching_text= 'LOINC')



%create_output_table(CODE_SYSTEM = HCPCS ,
					dataType= SAS,
					inputPath= \\cdc.gov\csp_project\CIPSEA_DHCS_NHCS_PROJECTS\PCORTF_FY23\data\Final_Research_File_Tables\revenue_recode,
					inputFileName= revenue_hcpcs,
					columns_to_keep= ENCOUNTER_ID ID_SETTING SOURCE HOSPID_A,
					output_table_name= research_revenue_hcpcs,
					code= REV_PDS,
					codesys_name= procedure_codesys_name,
					searching_text= 'Healthcare Common Procedure Coding System (HCPCS)')

%create_output_table(CODE_SYSTEM = CPT,
					dataType= SAS,
					inputPath= \\cdc.gov\csp_project\CIPSEA_DHCS_NHCS_PROJECTS\PCORTF_FY23\data\Final_Research_File_Tables\revenue_recode,
					inputFileName= revenue_cpt,
					columns_to_keep= ENCOUNTER_ID ID_SETTING SOURCE HOSPID_A,
					output_table_name= research_revenue_cpt,
					code= REV_PDS,
					codesys_name= procedure_codesys_name,
					searching_text= 'Current Procedural Terminology (CPT)')


/* no need to search for procedure table %create_output_table(table= procedure_table,db_table= nhcs20.procedure,code= procedure_code_r,codesys_name= procedure_codesys_name_r,text= 'ICD-10-PCS') /* Need to confirm with Nikki most of the code _r and sys_namr_r are null*/




/* 20,631,827  obs from nhcs20.medication, 1,555,470 unique encounter_id */  
/* 71,458,356  obs from nhcs20.condition, 9,438,466 unique encounter_id */  
/* 296,184,150  obs from nhcs20.labs, 3,072,358 unique encounter_id */  
/* 9,848,731  obs from nhcs20.procedure, 2,349,850 unique encounter_id */
/* output.revenue is the cleaned version from database,output.revenueNOTE: There were 6641197 observations read from the data set WORK.P11_FINAL.
      WHERE procedure_codesys_name='Healthcare Common Procedure Coding System (HCPCS)';
NOTE: The data set OUTPUT.REVENUE has 6641197 observations and 9 variables.

 */
 

%macro AggregateAndExport(columns_to_keep=, outputType=, outputPath=, datasets=, outputFileName= );

%let var = STIM_ANY_CODE DRUGSCREEN_CODE STIM_TX_CODE STIM_NON_TX_UNSP_CODE TX_METHYLPHENIDATE_CODE TX_DEXTROAMPHETAMINE_CODE
TX_AMPHETAMINE_CODE TX_DEXMETHYLPHENIDATE_CODE TX_LISDEXAMFETAMINE_CODE TX_AMPHET_DEXTROAMPHET_CODE
STIM_MISUSE_CODE MISUSE_METHYLPHENIDATE_CODE MISUSE_AMPHETAMINE_CODE STIM_ILLICIT_CODE
ILLICIT_COCAINE_CODE ILLICIT_METHAMPHETAMINE_CODE ILLICIT_MDMA_CODE OPIOID_ANY_CODE OPIOID_MISUSE_CODE 
OPIOID_ILLICIT_CODE OPIOID_NON_TX_UNSP_CODE 
STIM_ANY_NON_TX_CODE OPIOID_ANY_NON_TX_CODE;

  /* Data Aggregation Step */
  /*data AggregatedData(compress=yes);
    set
    %do i = 1 %to %sysfunc(countw(&datasets));
      %scan(&datasets, &i)
    %end;
    ;
  run;*/

 data AggregatedData(compress=yes);
    set &datasets;
 
  run;


  proc summary data = AggregatedData nway;
  class &columns_to_keep;
  var &var;
  output out = AggregatedData(drop=_:) max=;
	run;

  /* Export Step */
  %if %upcase(&outputType) eq CSV %then %do;
    proc export data=AggregatedData
                outfile=" &outputPath.\&outputFileName..csv"
                dbms=csv replace;
    run;
  %end;

  %else %if %upcase(&outputType) eq EXCEL %then %do;
  %put outfile= &outputPath.\&outputFileName..xlsx;

    proc export data=AggregatedData
                outfile= " &outputPath.\&outputFileName..xlsx"
                dbms=xlsx replace;
    run;
  %end;

  %else %if %upcase(&outputType) eq SAS %then %do;
    /* Save the aggregated data as a permanent SAS dataset */
    libname output  " &outputPath. ";
    data output.&outputFileName;
      set AggregatedData;
    run;
  %end;

  %else %do;
    %put ERROR: Invalid output type specified.;
  %end;

%mend;

/* Example of how to call the macro */
/* %AggregateAndExport(columns_to_keep= ENCOUNTER_ID ID_SETTING SOURCE HOSPID_A,
					outputType= SAS, 
					outputPath= \\cdc.gov\csp_project\CIPSEA_DHCS_NHCS_PROJECTS\PCORTF_FY23\data\Final_Research_File_Tables, 
					datasets= output.research_revenue_cpt output.research_revenue_hcpcs output.research_condition_table output.research_medication_table output.research_labs_table,  
					outputFileName= FY23_Research_File);

				/*  columns_to_keep must equal to the columns_to_keep defined from macro %create_output_table;   
					outputType can choose from CSV,EXCEL or SAS; 
					datasets must equal to the output_table_name defined from macro %create_output_table; 
					*/

%AggregateAndExport(columns_to_keep= ENCOUNTER_ID ID_SETTING SOURCE HOSPID_A,
					outputType= SAS, 
					outputPath= \\cdc.gov\csp_project\CIPSEA_DHCS_NHCS_PROJECTS\PCORTF_FY23\data\Final_Research_File_Tables, 
					datasets= research_revenue_cpt research_revenue_hcpcs research_condition_table research_condition_table2 research_medication_table research_labs_table,  
					outputFileName= FY23_Research_File);






%let var = STIM_ANY_CODE DRUGSCREEN_CODE STIM_TX_CODE STIM_NON_TX_UNSP_CODE TX_METHYLPHENIDATE_CODE TX_DEXTROAMPHETAMINE_CODE
TX_AMPHETAMINE_CODE TX_DEXMETHYLPHENIDATE_CODE TX_LISDEXAMFETAMINE_CODE TX_AMPHET_DEXTROAMPHET_CODE
STIM_MISUSE_CODE MISUSE_METHYLPHENIDATE_CODE MISUSE_AMPHETAMINE_CODE STIM_ILLICIT_CODE
ILLICIT_COCAINE_CODE ILLICIT_METHAMPHETAMINE_CODE ILLICIT_MDMA_CODE OPIOID_ANY_CODE OPIOID_MISUSE_CODE 
OPIOID_ILLICIT_CODE OPIOID_NON_TX_UNSP_CODE 
STIM_ANY_NON_TX_CODE OPIOID_ANY_NON_TX_CODE;
%put &var;

 

proc means data=research_labs_table sum;
 var &var;
 output out= output.sums_labs_table(drop=_type_ _freq_) sum=;
 run;

proc means data=research_medication_table sum;
 var &var;
 output out= output.sums_medication_table(drop=_type_ _freq_) sum=;
 run;

 
proc means data=research_condition_table sum;
 var &var;
 output out= output.sums_research_condition_table(drop=_type_ _freq_) sum=;
 run;

 proc means data=research_condition_table2 sum;
 var &var;
 output out= output.sums_research_condition_table2(drop=_type_ _freq_) sum=;
 run;

 
proc means data=research_revenue_cpt sum;
 var &var;
 output out= output.sums_research_revenue_cpt(drop=_type_ _freq_) sum=;
 run;
 
proc means data=research_revenue_hcpcs sum;
 var &var;
 output out= output.sums_research_revenue_hcpcs(drop=_type_ _freq_) sum=;
run;

proc means data=output.FY23_Research_File sum;
 var &var;
 output out= output.sums_FY23_Research_File(drop=_type_ _freq_) sum=;
 run; 



 
