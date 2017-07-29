# --------------------------------------------------------------------------------
# 3. Load the list of file links and account numbers, and output list of valid/invalid files
# --------------------------------------------------------------------------------
# inputs: csv file with list of links to box files which can be direct downloaded without authentication
# tasks: verify that link works, is the correct version of the excel file, read 'validation' tab,
# read and compare the account number
# output: "validation_results_DATE.csv", all valid links are downloaded to /data

# read the source list of links and account numbers
# **moved to 'parameters' section of 0. Run all scripts**
# list_source_raw <- read_excel('data/external/List of financial workbook box links_v2.xlsx')

list_source <- list_source_raw %>%
  select(`RC Account Number`, `Account Name`, `Direct Link`)  %>% # TODO `Direct Link` may not be final name
  arrange(`RC Account Number`)

# create a place to store the result of the checks
list_source$valid_filename <- NA
list_source$valid_file_version <- NA
list_source$new_filename <- NA
setwd('data/wbs')


# --------------------------------------------------------------------------------
# download the files and perform the validation

# fill is the list of whether or not filename is valid, and if TRUE, download it
for (i in seq_along(list_source$`RC Account Number`)) {
  print(list_source$`Direct Link`[i])
  valid <- check_if_xlsx(list_source$`Direct Link`[i])
  list_source$valid_filename[i] <- valid
  if (valid) {
    # download the file and add the new filename to a dataframe column
    list_source$new_filename[i] <- download_and_name(
      list_source[i,"Direct Link"], list_source[i,"RC Account Number"])
  }
}

# check to see if each file is the correct template, and fill in that list
# first sort the list_source so that the invald file names are separated to the bottom
# only the valid links were downloaded, so the invalid ones will not be checked for templates
list_source <- list_source %>%
  arrange(desc(`valid_filename`), `RC Account Number`) # put the invalid filenames at the end

files_in_dir <- dir()
for (fi in seq_along(files_in_dir)) {
  list_source[fi, 'valid_file_version'] <- check_if_valid_template(files_in_dir[fi])
}

# --------------------------------------------------------------------------------
# Check which downloaded files have the correct template

# OPTION: [ALL FILES] / files passing validation
# # get list of files in data directory
# filenames_list <- dir()
# head(filenames_list)

# OPTION: ALL FILES / [files passing validation]
list_source_valid_version <- list_source %>%
  filter(valid_filename == TRUE & valid_file_version == TRUE)


# which cells should be looked at for true/false values on the 'validation' tab from excel file
# input two vectors of numbers with the row and column index of the cell to be checked
# eg to check cell B3, add 2 to the row vector (header's skipped), and 2 (for B) to the col vector
rows <- c(1:88)
cols <- c(9, 10, 11)

# tests:
# df_test <- read_validation(list_source_valid_version$new_filename[1])
# check_valid(df_test, rows, cols)
# check_valid_wb_tolerant(df_test)

# check which files pass validation (strict: ALL validation TRUE)
validation_list_strict <- sapply(list_source_valid_version$new_filename,
                    # function(x) check_valid(read_validation(x), 1, 12)  # to just check one cell: [12, 1]
                   function(x) check_valid_wb(read_validation(x), rows, cols)
)

# check which files pass validation 
list_source_valid_version$validation_wb_passes <- sapply(list_source_valid_version$new_filename,
                    function(x) check_valid_wb_tolerant(read_validation(x), rows, cols)
)

# check that typed in account number from financial spreads tab matches the one from the input list
list_source_valid_version$account_number_from_wb <- sapply(list_source_valid_version$new_filename,
                    read_account_no
)

# check that the account number from the input list matches the one from the data entry field in the workbook
list_source_valid_version$account_no_matches <- list_source_valid_version$`RC Account Number` == 
  list_source_valid_version$account_number_from_wb

# --------------------------------------------------------------------------------
# write the log of which files passed various validation

# select those that had an invalid link, filename or template version
failed_links <- list_source %>%
  filter(valid_filename == FALSE | valid_file_version == FALSE)

# join the failed links with info about those that passed
out <- full_join(list_source_valid_version, failed_links)

filename_out <- paste0('validation_results_', Sys.Date(), '.csv')
setwd('../output')
write.csv(out, filename_out, row.names = FALSE)
file.show(filename_out)