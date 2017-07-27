# check that required packages are installed, and if not, install them
required_packages <- c('readxl', 'tidyverse')   # boxr
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

library(readxl)
library(tidyverse)

# optional: use the Box api to log in and authenticate a box id
# # need to use this if the box file permission isn't set to
# # 'users with link can download file'
# library(boxr)
# box_auth()     # this will produce a prompt for the box api user and secret
#                # it only needs to be done once (not once per session), and stored in the .renvir file