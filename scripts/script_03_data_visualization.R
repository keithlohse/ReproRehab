library(tidyverse) # data formatting and graphing tools


# 2.0. Wrangling Data 
setwd("~/GitHub/ReproRehab/")
list.files()
list.files("./data/")

DATA <- read.csv("./data/data_PROCESSED_EEG.csv",
                    header=TRUE, 
                    stringsAsFactors = TRUE)



