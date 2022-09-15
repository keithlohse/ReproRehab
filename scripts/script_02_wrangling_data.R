library(tidyverse) # data formatting and graphing tools


# 2.0. Wrangling Data 
setwd("~/GitHub/ReproRehab/")
list.files()
list.files("./data/")

DATA <- read.csv("./data/MASTER_EO_and_EC_EEG.csv",
                    header=TRUE, 
                    stringsAsFactors = TRUE)


# selecting specific columns
head(DATA)
?dplyr::select
DATA %>% select(subID, condition, Hz, Fz)
select(.data=DATA, subID, condition, Hz, Fz)

DATA %>% select(subID:F3)

DATA %>% select(-X)

DAT2 <- DATA %>% select(-X, -file_id)


# filtering specific rows
head(DAT2)
?dplyr::filter
DAT2 %>% filter(subID=="oa01")

DAT2 %>% filter(subID=="oa01" | subID=="oa02")

DAT2 %>% filter(subID=="oa01" & Hz==0.997)

summary(unique(DAT2$Hz))
hist(unique(DAT2$Hz))

DAT3 <- DAT2 %>% filter(Hz<=30)


# computing new variables
head(DAT3)

DAT3$Frontal <- (DAT3$F3 + DAT3$F7 + DAT3$Fz + DAT3$F4 + DAT3$F8)/5

?dplyr::mutate()
?dplyr::transmute()

? dplyr::rowwise
DAT3 <- DAT3 %>% rowwise %>%
  mutate(frontal = mean(c(F3, F7, Fz, F4, F8), na.rm=TRUE),
         central = mean(c(C3, Pz, C4), na.rm=TRUE),
         parietal = mean(c(P3, P7, Fz, P4, P8), na.rm=TRUE),
         occipital = mean(c(O1, Oz, O2), na.rm=TRUE)
  )

plot(DAT3$Frontal, DAT3$frontal)
cor(DAT3$Frontal, DAT3$frontal, use = "complete.obs")



# Selecting only the columns we want
head(DAT3)
DAT4 <- DAT3 %>% select(subID, condition, Hz,
                        frontal, central, parietal, occipital) %>%
  mutate(ln_Hz = log(Hz+1),
         ln_frontal = log(frontal),
         ln_central = log(central),
         ln_parietal = log(parietal),
         ln_occipital = log(occipital))

head(DAT4)

setwd("~/GitHub/ReproRehab/data/")
write.csv(DAT4, "data_PROCESSED_EEG.csv")
