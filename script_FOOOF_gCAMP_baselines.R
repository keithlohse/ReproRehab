library(reticulate) # Use python code in the R Studio environment
library(tidyverse) # data formating and graphing tools

# 1.0. Importing, merging, and relabeling, the data. 
setwd("C:/Users/kelop/Box/FOOOF_Keith/keith_workspace/")
getwd()

list.files("./data")

MOUSE_LIST <- list.files("./data/")
MOUSE_LIST

test <- read.csv("./data/NREM_Mouse119-2_BSL_FFT.csv", 
                    header=TRUE, 
                    stringsAsFactors = TRUE)

head(test)

for(m in MOUSE_LIST) {
  subject <- read.csv(paste("./data/", m, sep=""),
                      header=TRUE, 
                      stringsAsFactors = TRUE)
  
  # if the MASTER data set doesn't exist, create it
  if (!exists("MASTER")){
    MASTER <- data.frame(subject)
    MASTER$file_id <- factor(rep(m, nrow(MASTER)))
    #MASTER$Hz <- seq(1:nrow(MASTER))

  } else {
    # Create the temporary data file:
    temp_dataset <- data.frame(subject)
    temp_dataset$file_id <-  factor(rep(m, nrow(temp_dataset)))
    #temp_dataset$Hz <-  seq(1:nrow(temp_dataset))
    MASTER<-rbind(MASTER, temp_dataset)
    # Remove or "empty" the temporary data set
    rm(temp_dataset)
  }
}

head(MASTER)

# move the file ID and Hz columns to the front of the dataset
MASTER <- MASTER %>% relocate(file_id)
head(MASTER)

# Break the file id into mouse, time, and state labels
str_split(MASTER$file_id, "_")[[1]]

MASTER$state <- factor(map_chr(str_split(MASTER$file_id, "_"), 1))
MASTER$mouse <- factor(map_chr(str_split(MASTER$file_id, "_"), 2))
MASTER$time <- factor(map_chr(str_split(MASTER$file_id, "_"), 3))

MASTER <- MASTER %>% relocate(file_id, mouse, state, time)
head(MASTER)

# Export the cleaned PSD data
write.csv(MASTER, "data_BSL_MASTER.csv")





# 2.0. Running FOOOF through the reticulate package ----
# First, let's visualize some of the power specta:
head(MASTER)
summary(MASTER$mouse)
summary(MASTER$Frequency)
summary(MASTER$state)

ggplot(MASTER, 
       aes(x = Frequency, y = log(Lesional))) +
  geom_line(aes(group=time, col=time), lwd=0.75) +
  #stat_smooth(aes(group=elect_pair, col=elect_pair), method="loess", se=FALSE) + 
  facet_wrap(~mouse) + 
  #scale_x_continuous(name = expression(bold(Frequency~(log(Hz))))) +
  #scale_y_continuous(name = expression(bold(Power~(log(uV^2))))) +
  theme_bw()+
  theme(axis.text=element_text(size=12, color="black"), 
        legend.text=element_text(size=12, color="black"),
        legend.title=element_text(size=12, face="bold"),
        axis.title=element_text(size=12, face="bold"),
        plot.title=element_text(size=12, face="bold", hjust=0.5),
        panel.grid.minor = element_blank(),
        strip.text = element_text(size=12, face="bold"),
        legend.position = "bottom")

ggplot(MASTER, 
       aes(x = log(Frequency), y = log(Lesional))) +
  geom_line(aes(group=time, col=time), lwd=0.75) +
  #stat_smooth(aes(group=elect_pair, col=elect_pair), method="loess", se=FALSE) + 
  facet_wrap(~mouse) + 
  scale_x_continuous(name = expression(bold(Frequency~(log(Hz))))) +
  scale_y_continuous(name = expression(bold(Power~(log(uV^2))))) +
  theme_bw()+
  theme(axis.text=element_text(size=12, color="black"), 
        legend.text=element_text(size=12, color="black"),
        legend.title=element_text(size=12, face="bold"),
        axis.title=element_text(size=12, face="bold"),
        plot.title=element_text(size=12, face="bold", hjust=0.5),
        panel.grid.minor = element_blank(),
        strip.text = element_text(size=12, face="bold"),
        legend.position = "bottom")



head(MASTER)

MASTER_by_REGION <- MASTER %>% pivot_longer(cols=Lesional:WholebrainAvg, 
                                               names_to = "Region",
                                               values_to = "Power")
head(MASTER_by_REGION)
ggplot(MASTER_by_REGION, 
       aes(x = log(Frequency), y = log(Power))) +
  geom_line(aes(group=Region, col=Region), lwd=0.75) +
  #stat_smooth(aes(group=elect_pair, col=elect_pair), method="loess", se=FALSE) + 
  facet_wrap(~mouse+time, ncol=3) + 
  scale_x_continuous(name = expression(bold(Frequency~(log(Hz))))) +
  scale_y_continuous(name = expression(bold(Power~(log(uV^2))))) +
  theme_bw()+
  theme(axis.text=element_text(size=12, color="black"), 
        legend.text=element_text(size=12, color="black"),
        legend.title=element_text(size=12, face="bold"),
        axis.title=element_text(size=12, face="bold"),
        plot.title=element_text(size=12, face="bold", hjust=0.5),
        panel.grid.minor = element_blank(),
        strip.text = element_text(size=12, face="bold"),
        legend.position = "bottom")


# Import python packages
fooof <- import("fooof")
np <- import("numpy")
plt <- import("matplotlib.pyplot")

# if you don't already have these installed
# reticulate::py_install("fooof")

# should set directory for you 
# path <- dirname(rstudioapi::getActiveDocumentContext()$path)
# dat <- read.csv(paste0(path, "/data/a02_pre_resting_Average B1_transposed.csv"))

# same as python syntax, but use $ instead of . to initialize/access methods and attributes of a class
# see how R types are converted to Python here: https://rstudio.github.io/reticulate/
fm <- fooof$FOOOF(
  peak_width_limits = c(0.08, 2.0), 
  max_n_peaks = 6, 
  min_peak_height = 0.1, 
  peak_threshold = 1,
  aperiodic_mode = "knee",
  verbose = T
)

# need to use np$ravel to get data into format required for fooof module
summary(MASTER$mouse)
summary(MASTER$time)


# Iteratively walking through different parameters ----
head(MASTER)
summary(MASTER$time)
summary(MASTER$state)
table(MASTER$state, MASTER$time)

MASTER_WIDE <- MASTER %>% select(-file_id) %>%  
  pivot_wider(names_from = time ,
              names_glue = "{time }_{.value}",
              values_from = c(Lesional, Perilesional, Contralesional, Control, WholebrainAvg)
              )
head(MASTER_WIDE)


# Setting up the for-loop 
sub_list <- c(unique(MASTER_WIDE$mouse))
sub_list

freq_list <- colnames(MASTER_WIDE)[4:8]
freq_list
RESULTS <- vector(mode="list", length=0)

for(s in sub_list) {
    print(s)
    
    SUB_WIDE <- MASTER_WIDE %>% filter(mouse == s)
  
    for(f in freq_list) {
      fm <- fooof$FOOOF(
        peak_width_limits = c(0.08, 2.0), 
        max_n_peaks = 6, 
        min_peak_height = 0.1, 
        peak_threshold = 1,
        aperiodic_mode = "knee",
        verbose = T
      )
      
      fm$fit(freqs = np$ravel(SUB_WIDE$Frequency), 
             power_spectrum = np$ravel(SUB_WIDE[,f]), 
             freq_range = c(0.1, 8))
      
      results <- fm$get_results()
      
      print(f)
      
      # nested tibble of model information
      RESULTS[[f]] <- tibble::tibble(
        ps = f,
        a_params = list(results$aperiodic_params),
        #p_params = list(results$peak_params),
        #g_params = list(results$gaussian_params),
        r_squared = results$r_squared,
        error = results$error,
        setting_am = fm$aperiodic_mode,
        setting_mnp = fm$max_n_peaks,
        setting_mph = fm$min_peak_height,
        setting_pt = fm$peak_threshold,
        setting_pwl = list(fm$peak_width_limits)
      )
      
    }
    
    # Subject Level
    RESULTS_DF <- bind_rows(RESULTS, .id = "column_label")
    
    RESULTS_DF <-RESULTS_DF %>% unnest_wider(a_params) %>%
      rename_at(vars(contains("...")), ~ c("exponent", "knee", "offset"))
    
    RESULTS_DF <-RESULTS_DF %>% unnest_wider(setting_pwl) %>%
      rename_at(vars(contains("...")), ~ c("peak_width_LL", "peak_width_UL"))
    
    RESULTS_DF$mouse <- c(rep(s, nrow(RESULTS_DF)))
    
    #write.csv(RESULTS_DF, paste("./", s, "_hyper_params_", i, ".csv", sep=""))
    if (!exists("HYPER_SEARCH")){
      HYPER_SEARCH <- data.frame(RESULTS_DF)
      
      
    } else {
      HYPER_SEARCH<-rbind(HYPER_SEARCH, RESULTS_DF)
  }
}


head(HYPER_SEARCH)
HYPER_SEARCH$time <- factor(map_chr(str_split(HYPER_SEARCH$ps, "_"), 1))
HYPER_SEARCH$location <- factor(map_chr(str_split(HYPER_SEARCH$ps, "_"), 2))
head(HYPER_SEARCH)

write.csv(HYPER_SEARCH, "./hyper_params_PT1.csv")


ggplot(HYPER_SEARCH, 
       aes(x = location, y = r_squared)) +
  geom_point(aes(group=mouse, 
                 col=mouse),
             position=position_jitterdodge(dodge.width = 0.1,
                                           jitter.height=0.0005),
             size=2, alpha=0.8) +
  scale_x_discrete(name = "Location") +
  scale_y_continuous(name = "R-Squared") +
  theme_bw()+
  theme(axis.text=element_text(size=12, color="black"),
        axis.text.x=element_text(angle = 90),
        legend.text=element_text(size=12, color="black"),
        legend.title=element_text(size=12, face="bold"),
        axis.title=element_text(size=12, face="bold"),
        plot.title=element_text(size=12, face="bold", hjust=0.5),
        panel.grid.minor = element_blank(),
        strip.text = element_text(size=12, face="bold"),
        legend.position = "bottom")




