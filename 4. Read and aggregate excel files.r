# -----------------  read data source list -----------------------
# read list of downloaded files with validation test results

# note that you can edit the location and source of this file
# OPTION: [AUTOMATIC SOURCE SELECTION] / MANUAL SOURCE SELECTION
# this will open the file "validation_results_DATE.csv" and use it as the source of what to aggregate
# NOTE: in between running files #3 and #4, you can manually edit the "validation_results_DATE.csv"
# to override anything that failed validation (ie change validation_wb_passes to TRUE)

input_file <- paste0('data/output/', filename_out)
list_source_valid_version <- read_csv(input_file)
# OPTION: AUTOMATIC SOURCE SELECTION / [MANUAL SOURCE SELECTION]
# uncomment this to select the folder 
# list_source_valid_version <- choose.dir(caption = "Select the folder with the list of files")

# -----------------  read data -----------------------------------

# filter only filenames that passed all checks
  filenames_list_validated <- 
    list_source_valid_version %>%
    filter(validation_wb_passes==TRUE) %>%
    select(new_filename) %>%
    as.matrix() %>%
    as.vector()

# ---------------------------------------------------------
# ---  read financial spreads tab ------
# ---------------------------------------------------------

setwd('data/wbs')
# ---  read all files and add to a list  ------
  data_list <- lapply(filenames_list_validated,
    function(x) read_excel(x, sheet = 'export_data')
    )

# remove rows for which the first column ('field') is NA
  data_list2 <- lapply(data_list,
    function(x) filter(x, !is.na(x[,1]), x[,1] != 0))

# add id column that's the RC Opp Number for each item in list
  for ( i in 1:length(data_list2) ) {
    id <- data_list2[[i]][60,2]                             # RC Opp number
    data_list2[[i]]$opp_number <- paste0(id)
    data_list2[[i]]$file_name <- filenames_list_validated[i]
  }
  
# append each data frame 
  appended_data <- data_list2[[1]]   # start the first one
  for ( i in 2:length(data_list2) ) {
    appended_data <- rbind(appended_data, data_list2[[i]])  
    # TODO more efficient to start this with defined object size rather than expansion
  }
  
  data_pricing_list <- lapply(filenames_list_validated,
                              function(x) read_excel(x, sheet = 'export_data_pricing')
  )
  
  # remove rows for which the first column ('field') is NA
  data_pricing_list2 <- lapply(data_pricing_list,
                               function(x) filter(x, !is.na(x[,1]), x[,1] != 0))
  
  # add id column that's the RC Opp Number for each item in list
  for ( i in 1:length(data_pricing_list2) ) {
    id <- data_pricing_list2[[i]][3,2]                             # RC Opp number
    data_pricing_list2[[i]]$opp_number <- paste0(id)
    data_pricing_list2[[i]]$file_name <- filenames_list_validated[i]
  }
  
  # append each data frame 
  appended_pricing_data <- data_pricing_list2[[1]]   # start the first one
  
  for ( i in 2:length(data_pricing_list2) ) {
    appended_pricing_data <- rbind(appended_pricing_data, data_pricing_list2[[i]])  
    # TODO more efficient to start this with defined object size rather than expansion
  }
  
# TO DO add check export that shows a) rc account number b) client name c) file name to compare to a SF export of the same data. 
  # purpose is to catch any error in data entry RC account numbers

# # create a validation log
# validation_log <- data.frame(
#   filename = filenames_list,
#   `passed_validation` = validation_list)

# ----------------------------------------------------------------------------
# ------- write output ----------------------
# ----------------------------------------------------------------------------
setwd('../output')
filename_out <- paste0('financial_spreads_', Sys.Date(), '.csv')
write.csv(appended_data, filename_out, row.names = FALSE)
filename_out <- paste0('pricing_', Sys.Date(), '.csv')
write.csv(appended_pricing_data, filename_out, row.names = FALSE)
  
# write.csv(validation_log, 'validation_log.csv', row.names = FALSE)
# file.show('validation_log.csv')