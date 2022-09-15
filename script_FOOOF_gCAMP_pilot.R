library(reticulate) # Use python code in the R Studio environment
library(tidyverse) # data formating and graphing tools

# 1.0. Importing, merging, and relabeling, the data. 
setwd("C:/Users/kelop/Box/FOOOF_Keith/keith_workspace/")
getwd()

list.files("./data")


list.files("./data/")
MOUSE_LIST <- list.files("./data/")
MOUSE_LIST

test <- read.csv("./data/NREM_Mouse119_2_BSL_FFT.csv", 
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
?str_split()
str_split(MASTER$file_id, "_")[[1]]

MASTER$state <- factor(map_chr(str_split(MASTER$file_id, "_"), 1))
MASTER$mouse <- factor(map_chr(str_split(MASTER$file_id, "_"), 2))
MASTER$time <- factor(map_chr(str_split(MASTER$file_id, "_"), 4))

MASTER <- MASTER %>% relocate(file_id, mouse, state, time)
head(MASTER)

# Export the cleaned PSD data
write.csv(MASTER, "data_MASTER.csv")





# 2.0. Running FOOOF through the reticulate package ----
# First, let's visualize some of the power specta:
head(MASTER)
summary(MASTER$mouse)
summary(MASTER$Frequency)
summary(MASTER$state)

ggplot(MASTER, 
       aes(x = Frequency, y = Lesional)) +
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
  facet_wrap(~mouse+time, ncol=2) + 
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

M119_BSL <- MASTER %>% filter(mouse == "Mouse119" & time == "BSL")
M119_24 <- MASTER %>% filter(mouse == "Mouse119" & time == "TwentyfourHr")
M132_BSL <- MASTER %>% filter(mouse == "Mouse132" & time == "BSL")
M328A_BSL <- MASTER %>% filter(mouse == "Mouse328A" & time == "BSL")



fm$fit(freqs = np$ravel(M328A_BSL$Frequency), 
       power_spectrum = np$ravel(M328A_BSL$Lesional), 
       freq_range = c(0.1, 8))

fm$report()
fm$get_settings()
fm$get_results()
fm$aperiodic_params_
fm$plot
plt$show()

fm$fit(freqs = np$ravel(M119_24$Frequency), 
       power_spectrum = np$ravel(M119_24$Lesional), 
       freq_range = c(0.1, 8))

fm$report()
fm$get_settings()
fm$get_results()
fm$aperiodic_params_
fm$plot
plt$show()



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


# Setting up a matrix of searchable hyper-parameters
peak_width_min <- c(rep(c(rep(0.02, 18), rep(0.05, 18), rep(0.08, 18)),1))
peak_width_max <- c(rep(c(rep(0.5, 3), rep(1.0, 3), rep(1.5, 3)),6))
max_n_peaks <- c(rep(c(2, 4, 6), 18))
min_peak_height <- c(rep(0.1, length(peak_width_min)))
peak_threshold <- c(rep(1, length(peak_width_min)))
aperiodic_mode <- c(rep("knee", 54))

HYPER_PARAMS <- data.frame(peak_width_min, peak_width_max, max_n_peaks,
                           min_peak_height, peak_threshold, aperiodic_mode)

# Example of selecting hyperparameters from data frame
fm <- fooof$FOOOF(
  peak_width_limits = c(HYPER_PARAMS[1,"peak_width_min"], 
                        HYPER_PARAMS[1,"peak_width_max"]), 
  max_n_peaks = HYPER_PARAMS[1,"max_n_peaks"], 
  min_peak_height = HYPER_PARAMS[1,"min_peak_height"], 
  peak_threshold = HYPER_PARAMS[1,"peak_threshold"],
  aperiodic_mode = HYPER_PARAMS[1,"aperiodic_mode"],
  verbose = TRUE
)

head(MASTER_WIDE)
fm$fit(freqs = np$ravel(MASTER_WIDE[MASTER_WIDE$mouse=="Mouse119",]$Frequency), 
         power_spectrum = np$ravel(MASTER_WIDE[MASTER_WIDE$mouse=="Mouse119", "BSL_Lesional"]), 
         freq_range = c(0.1, 8))

fm$get_settings()
fm$report()
fm$plot
plt$show()






# Setting up the for-loop 
sub_list <- c(unique(MASTER_WIDE$mouse))
sub_list

freq_list <- colnames(MASTER_WIDE)[4:13]
freq_list
RESULTS <- vector(mode="list", length=0)

for(i in seq(1:nrow(HYPER_PARAMS))) {
  print(HYPER_PARAMS[i,])
  
  fm <- fooof$FOOOF(
    peak_width_limits = c(HYPER_PARAMS[i,"peak_width_min"], 
                          HYPER_PARAMS[i,"peak_width_max"]), 
    max_n_peaks = HYPER_PARAMS[i,"max_n_peaks"], 
    min_peak_height = HYPER_PARAMS[i,"min_peak_height"], 
    peak_threshold = HYPER_PARAMS[i,"peak_threshold"],
    aperiodic_mode = HYPER_PARAMS[i,"aperiodic_mode"],
    verbose = TRUE
  )
  
  for(s in sub_list) {
    print(s)
    
    SUB_WIDE <- MASTER_WIDE %>% filter(mouse == s)
  
    for(f in freq_list) {
      
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
}


head(HYPER_SEARCH)
HYPER_SEARCH$time <- factor(map_chr(str_split(HYPER_SEARCH$ps, "_"), 1))
HYPER_SEARCH$location <- factor(map_chr(str_split(HYPER_SEARCH$ps, "_"), 2))
head(HYPER_SEARCH)

write.csv(HYPER_SEARCH, "./example_hyper_params.csv")


ggplot(HYPER_SEARCH, 
       aes(x = location, y = r_squared)) +
  geom_point(aes(group=peak_width_LL, 
                 col=as.factor(peak_width_LL), 
                 shape=as.factor(setting_mnp)),
             position=position_jitterdodge(dodge.width = 0.5,
                                           jitter.height=0.0005),
             size=2, alpha=0.3) +
  facet_wrap(~time+mouse, ncol=3) + 
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





# Old Loop without Subject
for(i in seq(1:nrow(HYPER_PARAMS))) {
  print(HYPER_PARAMS[i,])
  
  fm <- fooof$FOOOF(
    peak_width_limits = c(HYPER_PARAMS[i,"peak_width_min"], 
                          HYPER_PARAMS[i,"peak_width_max"]), 
    max_n_peaks = HYPER_PARAMS[i,"max_n_peaks"], 
    min_peak_height = HYPER_PARAMS[i,"min_peak_height"], 
    peak_threshold = HYPER_PARAMS[i,"peak_threshold"],
    aperiodic_mode = HYPER_PARAMS[i,"aperiodic_mode"],
    verbose = TRUE
  )

  for(f in freq_list) {
  
  fm$fit(freqs = np$ravel(MASTER_WIDE$Frequency), 
         power_spectrum = np$ravel(MASTER_WIDE[,f]), 
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
  
  RESULTS_DF <- bind_rows(RESULTS, .id = "column_label")
  
  RESULTS_DF <-RESULTS_DF %>% unnest_wider(a_params) %>%
    rename_at(vars(contains("...")), ~ c("exponent", "knee", "offset"))
  
  RESULTS_DF <-RESULTS_DF %>% unnest_wider(setting_pwl) %>% 
    rename_at(vars(contains("...")), ~ c("peak_width_LL", "peak_width_UL"))
  
  #write.csv(RESULTS_DF, paste("./Mouse119_hyper_params_", i, ".csv", sep=""))
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

write.csv(HYPER_SEARCH, "./Mouse119_hyper_params.csv")

ggplot(HYPER_SEARCH, 
       aes(x = location, y = r_squared)) +
  geom_point(aes(group=peak_width_UL, 
                 col=as.factor(peak_width_UL), 
                 shape=as.factor(setting_mnp)),
             position=position_jitterdodge(dodge.width = 0.5,
                                           jitter.height=0.0005),
             size=2, alpha=0.3) +
  facet_wrap(~time) + 
  scale_x_discrete(name = "Location") +
  scale_y_continuous(name = "R-Squared") +
  theme_bw()+
  theme(axis.text=element_text(size=12, color="black"), 
        legend.text=element_text(size=12, color="black"),
        legend.title=element_text(size=12, face="bold"),
        axis.title=element_text(size=12, face="bold"),
        plot.title=element_text(size=12, face="bold", hjust=0.5),
        panel.grid.minor = element_blank(),
        strip.text = element_text(size=12, face="bold"),
        legend.position = "bottom")

# # Spectral Parameterization for Each Person ---- 
# head(MASTER)
# sum(MASTER==0)
# MASTER <- na_if(MASTER, 0)
# head(MASTER)
# 
# SUBJECT_LIST
# RESULTS <- vector(mode="list", length=0)
# 
# for(s in SUBJECT_LIST) {
#   print(s)
#   
#   # Select the appropriate rows based on the subject ID and
#   # drop columns with missing values for FOOOF
#   TEMP_DATA <- MASTER[MASTER$file_id==s,] %>% 
#     select_if(~ !any(is.na(.)))
#   
#   freq_list <- colnames(TEMP_DATA)[3:ncol(TEMP_DATA)]
#   
#   for(f in freq_list) {
#     print(f)
#     
#     fm$fit(freqs = np$ravel(TEMP_DATA$Hz), 
#          power_spectrum = np$ravel(TEMP_DATA[,f]), 
#          freq_range = c(1, 32))
#     
#     results <- fm$get_results()
#     
#     # nested tibble of model information
#     RESULTS[[paste(s, f, sep="")]] <- tibble::tibble(
#       ps = f,
#       a_params = list(results$aperiodic_params),
#       #p_params = list(results$peak_params), 
#       #g_params = list(results$gaussian_params), 
#       r_squared = results$r_squared,
#       error = results$error, 
#       setting_am = fm$aperiodic_mode,
#       setting_mnp = fm$max_n_peaks,
#       setting_mph = fm$min_peak_height,
#       setting_pt = fm$peak_threshold,
#       setting_pwl = list(fm$peak_width_limits)
#       )
#   }
# }
# 
# head(RESULTS)
# 
# 
# RESULTS_DF <- bind_rows(RESULTS, .id = "sub_elect")
# head(RESULTS_DF)
# 
# RESULTS_DF <-RESULTS_DF %>% unnest_wider(a_params) %>% 
#   rename_at(vars(contains("...")), ~ c("exponent", "offset"))
# 
# RESULTS_DF <-RESULTS_DF %>% unnest_wider(setting_pwl) %>% 
#   rename_at(vars(contains("...")), ~ c("peak_width_LL", "peak_width_UL"))
# 
# head(RESULTS_DF)
# 
# write.csv(RESULTS_DF, "./individual_subject_PSDs.csv")
# 
# hist(RESULTS_DF$r_squared, main="r^2 values")
# hist(RESULTS_DF$offset, main="Offsets")
# hist(RESULTS_DF$exponent, main="Exponents")
