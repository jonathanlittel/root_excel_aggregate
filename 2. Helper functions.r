# ---------------------------------------------------------------
# -----------------  helper functions for 3. check and download files
check_if_xlsx <- function(x) {
  # checks if input character vector is either .xlsx, .xls or .xlsm
  valid_ending <- c('xlsx', '.xls', 'xlsm')
  checkname   <- substr(x, nchar(x)-3, nchar(x))
  if (checkname %in% valid_ending) return(TRUE)
  else return(FALSE)
}
# check_if_xlsx('test.xlsx')  # test

check_if_valid_template <- function(wb) {
  # verify that both export sheets are present
  sheet_names <- excel_sheets(wb)
  # requires xlxs library which requires java
  # sheet_names <- xlsx::getSheets(wb)
  required_sheets <- c('export_data', 'export_data_pricing')
  if (all(required_sheets %in% sheet_names)) return(TRUE)     
  else return(FALSE)
}

download_and_name <- function(link, account_id) {
  # download one file and rename it eg. 9876543.xlsm replacing the account no. and extension
  # and returns the new filename
  extension <- substr(link, nchar(link)-3, nchar(link))
  filename <- paste0(account_id, ".", extension) # create string "ACCOUNTID.Extension" for filename
  # note that if the extension is .xls, the result will be a filename of eg 987654..xls vs 987654.xlsx
  link_new <- paste0(link)
  # print(c(link, link_new, filename))
  download.file(url = link_new, destfile = filename, method = "auto")
  return(filename)
}

# ---------------------------------------------------------------
# -----------------  helper functions for 4. read/write data
read_validation <- function(file) {
  # reads the validation tab in excel file
  df <- read_excel(file, sheet = 'validation')
  return(df)
}  

check_valid_wb <- function(df, row = 1, col = 1) {
  # checks if the value of cell i, j is 1 or TRUE
  locs <- df[row, col]
  check_line <- sapply(locs, function(x) all(x, na.rm = TRUE)) # returns one row summarizing each checked column
  # print(check_line) 
  check <- all(check_line)  # returns single TRUE/FALSE value which is FALSE if any cell is false
  return(check)
}

check_valid_wb_tolerant<- function(df, row = 1, col = 1) {
  # returns a TRUE / FALSE value if it meets a certains tolerance
  locs <- df[row, col]
  threshold <- data.frame(   # use this to set the minimum number of TRUEs to pass the check
    # this allows for a 'tolerance' to have a certain number of non-TRUE values per column
    'passes check 1' = 80,
    'passes check 2' =  1,
    'passes check 3' = 80
  )
  check_subtotal <-   # gives count of # of TRUEs by column (uncomment 'print' line below for example)
    sapply(locs, function(x) sum(x, na.rm = TRUE))
  # cat(c('subtotal: ', check_subtotal, "end"))
  result <- threshold <= check_subtotal
  # print(result)
  # print(all(result))
  return(all(result))
}

# count_valid_wb_tolerant(df_test)
# check_valid_wb_tolerant(df_test, row = rows, col = cols)


read_account_no <- function(filename) {
  # reads the validation tab in excel file
  df <- read_excel(filename, sheet = 'Financial Spreads (USD or EUR)', 
                   col_names = FALSE, range = 'A1:E6')
  account_no <- df[[4, 3]]   # need double brackets to get the atomic item instead of dataframe
  return(account_no)
}

read_validation <- function(file) {
  # reads the validation tab in excel file
  df <- read_excel(file, sheet = 'validation')
  return(df)
}  
