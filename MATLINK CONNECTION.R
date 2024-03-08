# Close the database connection
# odbcClose(db)

library(RODBC)
library(tidyverse)

# Connection string
conn_str <- "Driver={ODBC Driver 17 for SQL Server};Server=DSDV-INFC-1900.cdc.gov;Database=NCBDDD_MATLINK;Trusted_Connection=yes;"

# Establish connection
db <- odbcDriverConnect(conn_str)

# SQL query
select_string <- "SELECT [DyadID],[encounterID],[encounterDate]FROM [NCBDDD_MATLINK].[tier2].[PADCEncounters]"
# Execute query and read into a data frame
df <- sqlQuery(db, select_string)

# SQL query
select_string1 <- "SELECT [DyadID],[RxNorm] FROM [NCBDDD_MATLINK].[tier2].[MATPostPartum]"
df1 <- sqlQuery(db, select_string1)

# SQL query
select_string2 <- "SELECT [DyadID],[RxNorm] FROM [NCBDDD_MATLINK].[tier2].[MATDuringCurrentPregnancy]"
df2 <- sqlQuery(db, select_string2)

 
MATPostPartum<- df1 %>% left_join(df,by="DyadID") %>% unique()
MATDuringCurrentPregnancy<- df2 %>% left_join(df,by="DyadID") %>% unique()


AA<- DATA %>% group_by(DyadID,encounterID) %>% count(RxNorm)
BB<- DATA %>% group_by(encounterID) %>% count(RxNorm)


AA %>% filter(encounterID=='1021239')


nrow(unique(DATA %>% group_by(DyadID,encounterID)) %>% count(RxNorm))
nrow(unique(DATA %>% group_by(encounterID)) %>% count(RxNorm))



###############################################################################################################################
###############################################################################################################################

library(dplyr); library(purrr)
map<-readxl::read_excel("C:\\Users\\sse6\\Desktop\\MAT-LINK\\code_mapping.xlsx", sheet =  "Sheet1")
# List of variables to iterate over
variables <- c("DRUGSCREEN_CODE", "STIM_ANY_CODE", "STIM_ANY_NON_TX_CODE", "STIM_NON_TX_UNSP_CODE", 
               "STIM_TX_CODE", "TX_METHYLPHENIDATE_CODE", "TX_DEXTROAMPHETAMINE_CODE", "TX_AMPHETAMINE_CODE",
               "TX_DEXMETHYLPHENIDATE_CODE", "TX_LISDEXAMFETAMINE_CODE", "TX_AMPHET_DEXTROAMPHET_CODE", 
               "STIM_MISUSE_CODE", "MISUSE_METHYLPHENIDATE_CODE", "MISUSE_AMPHETAMINE_CODE", 
               "STIM_ILLICIT_CODE", "ILLICIT_COCAINE_CODE", "ILLICIT_METHAMPHETAMINE_CODE", 
               "ILLICIT_MDMA_CODE", "OPIOID_ANY_CODE", "OPIOID_ANY_NON_TX_CODE", "OPIOID_MISUSE_CODE", 
               "OPIOID_ILLICIT_CODE", "OPIOID_NON_TX_UNSP_CODE")

variables <- sort(aes(variables))

# Function to concatenate codes for a given variable
concatenate_codes <- function(data, variable) {
  codes <- data %>%
    filter({{ variable }} == 1) %>%
    pull(CODE)
  return(codes)
}

# Iterate over each variable and concatenate codes
codes_list <- map(variables, ~ concatenate_codes(map, !!sym(.x)))
# Create a named list with variable names as names
codes_list <- setNames(codes_list, variables)




setwd("//cdc.gov/private/M139/sse6/Opioid_SUD_MHI_MedCodes-master/data")

input_file<- "example_input_file.txt"
mapping_file<- "FY19_ICD10CM_mappings.txt"
columns_to_keep <- c("UNIQUE_ID","ID_SETTING","CODE")


# Read the input CSV file
data <- read.csv(input_file, stringsAsFactors = FALSE)
# Remove periods 
data$CODE <- gsub("\\.", "", data$CODE)

output <- data[, columns_to_keep]



# Iterate over each column in the lookup table
for (col in names(codes_list)) {
  # Create a column with zeros for the current category
  output[, col] <- 0
  
  # Find the matching codes and update the corresponding column
  matching_codes <- unlist(codes_list[[col]])
  output[data$CODE %in% matching_codes, col] <- 1
  
  # Check if condition columns exist in the data
  if(all(c("condition_codesys_name", "condition_codesys_name_r", "condition_code") %in% names(data))) {
    # Add conditions using case_when
    output <- output %>%
      mutate(
        # Exception condition
        ILLICIT_METHAMPHETAMINE_CODE = case_when(
          condition_codesys_name == 'SNOMED-CT' &
            condition_codesys_name_r == 'ICD-10-CM' &
            condition_code == '699449003' ~ 1,
          TRUE ~ ILLICIT_METHAMPHETAMINE_CODE  # Keep the existing value if the condition is not met
        ),
        STIM_UNSP_NONTX_CODE = case_when(
          condition_codesys_name == 'SNOMED-CT' &
            condition_codesys_name_r == 'ICD-10-CM' &
            condition_code == '699449003' ~ 0,
          TRUE ~ STIM_UNSP_NONTX_CODE
        )
      )
  }
  
  
}


# STIM_ANY_NON_TX_CODE logic  
output$STIM_ANY_NON_TX_CODE <- ifelse(output$STIM_NON_TX_UNSP_CODE == 1 |
                                        output$STIM_MISUSE_CODE == 1 |
                                        output$STIM_ILLICIT_CODE == 1, 1, 0)

# OPIOID_ANY_NON_TX_CODE logic  
output$OPIOID_ANY_NON_TX_CODE <- ifelse(output$OPIOID_NON_TX_UNSP_CODE == 1 |
                                          output$OPIOID_MISUSE_CODE == 1 |
                                          output$OPIOID_ILLICIT_CODE == 1, 1, 0)


#take out all 0 finding for each row; 
output_final<-  output %>%
  filter(rowSums(across(where(is.numeric))) != 0)



