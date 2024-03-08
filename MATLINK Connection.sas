
/* specify the location where we can store output for MAT-LINK*/
libname output "\\cdc.gov\locker\NCBDDD_MAT_LINK\Data_Management_And_Analysis\Analyses_and_Tables\NCHS Stimulant Algorithm";


/* Establish OLE DB connection */
libname mydblib OLEDB
    provider="sqloledb"
    properties=("data source"="DSDV-INFC-1900"
                "Integrated Security"="SSPI"
                "Initial Catalog"="NCBDDD_MATLINK")
    schema=tier2
    access=readonly;

/* SQL query */
/* Data step with SET statement to retrieve top 10 rows */
data IDTesting1;
    set mydblib.IDTesting(obs=10);
run;

/* SQL query for PADCEncounters table */
proc sql;
    create table df as
    select DyadID, encounterID
    from mydblib.PADCEncounters;
quit;

/* SQL query for MATPostPartum table */
proc sql;
    create table df1 as
    select DyadID, RxNorm
    from mydblib.MATPostPartum;
quit;

/* SQL query for MATDuringCurrentPregnancy table */
proc sql;
    create table df2 as
    select *
    from mydblib.MATDuringCurrentPregnancy;
quit;

/* Merge tables and remove duplicates */
data DATA;
    merge df1 (in=a) df (in=b);
    by DyadID;
    if a and b;
run;

/* Remove duplicate rows */
proc sort data=DATA out=MATPostPartum  nodupkey;
    by _all_;
run;
/* Merge tables and remove duplicates */
data DATA2;
    merge df2 (in=a) df (in=b);
    by DyadID;
    if a and b;
run;
proc sort data=DATA2 out=MATDuringCurrentPregnancy  nodupkey;
    by _all_;
run;


DATA TEST1;
    SET mydblib.PADCDiagnoses(OBS=15);
     icdCodeValue = compress(icdCodeValue, '.');
RUN;




 


%macro create_output_table(CODE_SYSTEM=,dataType=,inputPath=,inputFileName=,columns_to_keep=, output_table_name=, code= );

proc import out= code1
    datafile =  "C:\Users\sse6\Desktop\MAT-LINK\code_mapping.xlsx"
    dbms=xlsx replace;
    getnames=yes;
    sheet= "Sheet1";
    range = "A:AB";
run;

data code;
set code1;
if CODE_SYSTEM = &CODE_SYSTEM;
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

%if &len =0 %then %do;
%let &macro_variable = ' ';
%end;

 
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
  set &inputFileName( KEEP= &columns_to_keep &code &codesys_name lab_qual_result);
  where &codesys_name = &searching_text and not missing(&code) and lab_qual_result in ('H','HH','A','POS');
%end;
%else %do;
  set &inputFileName( KEEP= &columns_to_keep &code );
  where not missing(&code);
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

    /*&code = strip(put(&code,100.));
	&code = strip(tranwrd(put(&code, 100.), '.', '')); 
	&code = compress(strip(tranwrd(tranwrd(put(&code, 100.), '.', ''), ' ', '')));*/

	&code = compress(&code, '.');
  
	
 	if &code  in: (&OPIOID_ANY_CODE_RXNORM1)  or &code in: (&OPIOID_ANY_CODE_RXNORM2) THEN  OPIOID_ANY_CODE=1 ; else OPIOID_ANY_CODE=0 ; 
	if &code  in: (&STIM_ANY_CODE)   THEN  STIM_ANY_CODE=1 ; else STIM_ANY_CODE=0 ;
	if &code  in: (&DRUGSCREEN_CODE)  THEN  DRUGSCREEN_CODE=1 ; else DRUGSCREEN_CODE=0 ;
	if &code  in: (&STIM_TX_CODE)   THEN  STIM_TX_CODE=1 ; else STIM_TX_CODE=0 ;
	if &code  in: (&STIM_NON_TX_UNSP_CODE)  THEN  STIM_NON_TX_UNSP_CODE=1 ; else STIM_NON_TX_UNSP_CODE=0 ;
	if &code  in: (&TX_METHYLPHENIDATE_CODE)  THEN  TX_METHYLPHENIDATE_CODE=1 ; else TX_METHYLPHENIDATE_CODE=0 ;
	if &code  in: (&TX_DEXTROAMPHETAMINE_CODE)  THEN  TX_DEXTROAMPHETAMINE_CODE=1 ; else TX_DEXTROAMPHETAMINE_CODE=0 ;
	if &code  in: (&TX_AMPHETAMINE_CODE)  THEN  TX_AMPHETAMINE_CODE=1 ; else TX_AMPHETAMINE_CODE=0 ;
	if &code  in: (&TX_DEXMETHYLPHENIDATE_CODE)   THEN  TX_DEXMETHYLPHENIDATE_CODE=1 ; else TX_DEXMETHYLPHENIDATE_CODE=0 ;
	if &code  in: (&TX_LISDEXAMFETAMINE_CODE)   THEN  TX_LISDEXAMFETAMINE_CODE=1 ; else TX_LISDEXAMFETAMINE_CODE=0 ;
	if &code  in: (&TX_AMPHET_DEXTROAMPHET_CODE)  THEN  TX_AMPHET_DEXTROAMPHET_CODE=1 ; else TX_AMPHET_DEXTROAMPHET_CODE=0 ;
	if &code  in: (&STIM_MISUSE_CODE) THEN  STIM_MISUSE_CODE=1 ; else STIM_MISUSE_CODE=0 ;
	if &code  in: (&MISUSE_METHYLPHENIDATE_CODE)  THEN  MISUSE_METHYLPHENIDATE_CODE=1 ; else MISUSE_METHYLPHENIDATE_CODE=0 ;
	if &code  in: (&MISUSE_AMPHETAMINE_CODE)  THEN  MISUSE_AMPHETAMINE_CODE=1 ; else MISUSE_AMPHETAMINE_CODE=0 ;
	if &code  in: (&STIM_ILLICIT_CODE)   THEN  STIM_ILLICIT_CODE=1 ; else STIM_ILLICIT_CODE=0 ;
	if &code  in: (&ILLICIT_COCAINE_CODE)  THEN  ILLICIT_COCAINE_CODE=1 ; else ILLICIT_COCAINE_CODE=0 ;
	if &code  in: (&ILLICIT_METHAMPHETAMINE_CODE)  THEN  ILLICIT_METHAMPHETAMINE_CODE=1 ; else ILLICIT_METHAMPHETAMINE_CODE=0 ;
	if &code  in: (&ILLICIT_MDMA_CODE) THEN  ILLICIT_MDMA_CODE=1 ; else ILLICIT_MDMA_CODE=0 ;
	if &code  in: (&OPIOID_MISUSE_CODE)  THEN  OPIOID_MISUSE_CODE=1 ; else OPIOID_MISUSE_CODE=0 ;
	if &code  in: (&OPIOID_ILLICIT_CODE)   THEN  OPIOID_ILLICIT_CODE=1 ; else OPIOID_ILLICIT_CODE=0 ;
	if &code  in: (&OPIOID_NON_TX_UNSP_CODE)  THEN  OPIOID_NON_TX_UNSP_CODE=1 ; else OPIOID_NON_TX_UNSP_CODE=0 ;

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




%create_output_table(CODE_SYSTEM = "ICD-10-CM",
					dataType= DB,
					inputPath=  ,
					inputFileName= mydblib.PADCDiagnoses,
					columns_to_keep= DyadID ,
					output_table_name= a,
					code= icdCodeValue)
 
%create_output_table(CODE_SYSTEM = "RXNORM",
					dataType= DB,
					inputPath=  ,
					inputFileName= mydblib.MATDuringCurrentPregnancy,
					columns_to_keep= DyadID ,
					output_table_name= b,
					code= RxNorm)

 
%create_output_table(CODE_SYSTEM = "HCPCS",
					dataType= DB,
					inputPath=  ,
					inputFileName= mydblib.PADCProcedures,
					columns_to_keep= DyadID ,
					output_table_name= c,
					code= icdCodeValue)


%create_output_table(CODE_SYSTEM = "RXNORM",
					dataType= DB,
					inputPath=  ,
					inputFileName= mydblib.MATPostPartum,
					columns_to_keep= DyadID ,
					output_table_name= d,
					code= RxNorm)

 
%create_output_table(CODE_SYSTEM = "RXNORM",
					dataType= DB,
					inputPath=  ,
					inputFileName= mydblib.MaternalDeliveryMedications,
					columns_to_keep= DyadID ,
					output_table_name= e,
					code= RxNorm)

 
%create_output_table(CODE_SYSTEM = "RXNORM",
					dataType= DB,
					inputPath=  ,
					inputFileName= mydblib.MaternalEpiduralMedications,
					columns_to_keep= DyadID ,
					output_table_name= f,
					code= RxNorm)

 
%create_output_table(CODE_SYSTEM = "RXNORM",
					dataType= DB,
					inputPath=  ,
					inputFileName= mydblib.MaternalPrescriptionMedications,
					columns_to_keep= DyadID ,
					output_table_name= g,
					code= RxNorm)



 

%macro AggregateAndExport(columns_to_keep=, outputType=, outputPath=, datasets=, outputFileName= );

%let var = STIM_ANY_CODE DRUGSCREEN_CODE STIM_TX_CODE STIM_NON_TX_UNSP_CODE TX_METHYLPHENIDATE_CODE TX_DEXTROAMPHETAMINE_CODE
TX_AMPHETAMINE_CODE TX_DEXMETHYLPHENIDATE_CODE TX_LISDEXAMFETAMINE_CODE TX_AMPHET_DEXTROAMPHET_CODE
STIM_MISUSE_CODE MISUSE_METHYLPHENIDATE_CODE MISUSE_AMPHETAMINE_CODE STIM_ILLICIT_CODE
ILLICIT_COCAINE_CODE ILLICIT_METHAMPHETAMINE_CODE ILLICIT_MDMA_CODE OPIOID_ANY_CODE OPIOID_MISUSE_CODE 
OPIOID_ILLICIT_CODE OPIOID_NON_TX_UNSP_CODE 
STIM_ANY_NON_TX_CODE OPIOID_ANY_NON_TX_CODE;


 data AggregatedData1(compress=yes);
    set &datasets;
  run;

proc summary data=AggregatedData1 nway;
  class &columns_to_keep;
  var &var;
  output out=AggregatedData(drop=_: DyadID rename=(_type_=_)) max=;
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

%AggregateAndExport(columns_to_keep= DyadID,
					outputType= SAS, 
					outputPath= \\cdc.gov\locker\NCBDDD_MAT_LINK\Data_Management_And_Analysis\Analyses_and_Tables\NCHS Stimulant Algorithm, 
					datasets= a b c d e f g,  
					outputFileName= MATLINK_Research_File);




%let var = STIM_ANY_CODE DRUGSCREEN_CODE STIM_TX_CODE STIM_NON_TX_UNSP_CODE TX_METHYLPHENIDATE_CODE TX_DEXTROAMPHETAMINE_CODE
TX_AMPHETAMINE_CODE TX_DEXMETHYLPHENIDATE_CODE TX_LISDEXAMFETAMINE_CODE TX_AMPHET_DEXTROAMPHET_CODE
STIM_MISUSE_CODE MISUSE_METHYLPHENIDATE_CODE MISUSE_AMPHETAMINE_CODE STIM_ILLICIT_CODE
ILLICIT_COCAINE_CODE ILLICIT_METHAMPHETAMINE_CODE ILLICIT_MDMA_CODE OPIOID_ANY_CODE OPIOID_MISUSE_CODE 
OPIOID_ILLICIT_CODE OPIOID_NON_TX_UNSP_CODE STIM_ANY_NON_TX_CODE OPIOID_ANY_NON_TX_CODE;
%put &var;

 

proc means data= output.MATLINK_Research_File sum;
var &var;
output out=  output.summary_MATLINK_Research_File (drop=_type_ _freq_) sum=;
run;
 
