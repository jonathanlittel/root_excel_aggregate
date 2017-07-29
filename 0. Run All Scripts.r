# source list of excel links
  # expects a file with the columns `RC Account Number`, `Account Name`, `Direct Link` in any order
  # where `Direct Link` is a *direct download* link to the financial spread file on box
  # it also needs to either be logged in using the box api, or with permissions set to read for anyone
  # with the link
  list_source_raw <- read_excel('data/external/List of financial workbook box links_v2.xlsx')

# save the wd to reset to root directory if needed
  wd <- getwd()
  setwd(wd)

# 1. Load Libraries and configure
# loads required libraries
# optional commented out section for box login
source('1. setup.r')

# 2. Load helper functions
# Loads various custom functions
source('2. Helper functions.r')

# 3. Load the list of file links and account numbers, and output list of valid/invalid files
# downloads financial templates to /data/wbs, and produces a validation report in data/output
source('3. Check and download files.r')

# 4. Read and aggregate excel files
# aggregates data and produces two csv files in /data/output
# every time you run this, it's going to take all the files download to data/wbs, aggregate them,
# and write over any existing aggregated file with today's date.
setwd(wd)
source('4. Read and aggregate excel files.r')
