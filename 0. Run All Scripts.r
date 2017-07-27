# parameters

# optional holding spot for any parameters; eg root directory, or skipping validation, or whatever

# save the wd to reset if needed
wd <- getwd()
setwd(wd)

# 1. Load Libraries and configure
# loads required libraries
source('1. setup.r')

# 2. Load helper functions
# Loads various custom functions
source('2. Helper functions.r')

# 3. Load the list of file links and account numbers, and output list of valid/invalid files
source('3. Check and download files.r')

# 4. Read and aggregate excel files
setwd(wd)
source('4. Read and aggregate excel files.r')