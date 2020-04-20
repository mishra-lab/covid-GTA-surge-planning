########################################################
# COVID 2019 Project 
# Purpose: draw hospital specific data
# Data:
#   [open access] https://github.com/CSSEGISandData/COVID-19/blob/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv
#   model outputs
#   SMH/SJH hospital admissions
# Author: Linwei Wang, Huiting Ma
# Created on: March 9th
# Data date: March 12th
# Last update: Apr 16, 2020
# Figure 4
########################################################

# clear workspace
rm(list=ls(all.names=TRUE)) 

################ install & load all libraries/packages #########################

if(!"tidyverse" %in% rownames(installed.packages())){
  install.packages("tidyverse")
}

if(!"dplyr" %in% rownames(installed.packages())){
  install.packages("dplyr")
}
if(!"tidyr" %in% rownames(installed.packages())){
  install.packages("tidyr")
}
if(!"stringr" %in% rownames(installed.packages())){
  install.packages("stringr")
}
if(!"reshape2" %in% rownames(installed.packages())){
  install.packages("reshape2")
}
if(!"gridExtra" %in% rownames(installed.packages())){
  install.packages("gridExtra")
}
library(tidyr)
library(stringr)
library(tidyverse)
library(dplyr)
library(ggplot2)
library(reshape2)
library(gridExtra)


###############################################################################
# Step 0: Read in the model outputs
###############################################################################
currentDate <- Sys.Date()
lastUpdateDate <- currentDate
# lastUpdateDate <- "2020-04-08"
csvFileName<- paste("../data/LHS_int_fix_drop_Reffective",lastUpdateDate,".csv",sep="")
modelout<- read.csv(file=csvFileName)
# modelout<- read.csv("OneWaySens_ParmList2020-03-15.csv", header = T)
table(modelout$R0, exclude = NULL)

#total diagnosis
modelout$Cumdx_tot

####St.Michael's Hospital catchment
smh_inpatients = 0.04543
smh_ICU = 0.08676
smh_ED = 0.03103

####SJ Hospital catchment
sj_inpatients = 0.03974
sj_ICU = 0.02294
sj_ED = 0.04027

epicurve_maxminIncid <- read.csv("../data/epicurve_maxminIncid.csv")

###############################################################################
##Caculate ED visits
###############################################################################
##Create a daily count from the cumulative variable
table(modelout$CumED_ct, exclude = NULL)
table(subset(modelout, pSet == 1)$CumED_ct, exclude = NULL)
subset(modelout, pSet == 1)$CumED_ct

##Create a daily count from cumulative variable
table(modelout$CumAdmit, exclude = NULL)

modelout =
  modelout %>%
  group_by(pSet) %>%
  mutate(DailyED_ct = CumED_ct - lag(CumED_ct)) %>% ##Create a daily count from the cumulative variable
  mutate(DailyAdmit = CumAdmit - lag(CumAdmit)) ##Create a daily count from cumulative variable

subset(modelout, pSet == 1)[, c("CumED_ct", "DailyED_ct", "CumAdmit", "DailyAdmit")]

summary(modelout$DailyED_ct)
summary(modelout$DailyAdmit)
summary(modelout$pSet)

modelout$DailyED_ct = ifelse(is.na(modelout$DailyED_ct), 0 , modelout$DailyED_ct)
modelout$DailyAdmit = ifelse(is.na(modelout$DailyAdmit), 0 , modelout$DailyAdmit)

modelout$ED_visits = modelout$DailyED_ct + modelout$DailyAdmit

###############################################################################
###############################################################################
###Get default case
csvFileName<- paste("../data/ParmSet_Default",lastUpdateDate,".csv",sep="")
default_results<- read.csv(file=csvFileName)
# modelout<- read.csv("OneWaySens_ParmList2020-03-13.csv", header = T)
table(default_results$R0, exclude = NULL)
colnames(default_results)
colnames(modelout)

default_results$pSet = max(modelout$pSet) + 1

###############################################################################
###############################################################################
###SMH specific data
###############################################################################
SMH_admission = read.csv("/path/to/SMH_admission_long_March6.csv", header = T)
SMH_admission$DayMonthYear
colnames(SMH_admission)
SMH_admission$DayMonthYear = as.character(SMH_admission$DayMonthYear)

SMH_admission = SMH_admission %>% separate(DayMonthYear, c("Day", "Month", "Year"))
SMH_admission$Day = str_pad(SMH_admission$Day, 2, pad = "0")
SMH_admission$Month = str_pad(SMH_admission$Month, 2, pad = "0")

Num_inpatient_medicine =
  SMH_admission %>%
  group_by(Month, Day) %>%
  summarize(low_inpatients_anyservice = min(Number.of.Inpatients.on.Any.Service.Per.Day),
            med_inpatients_anyservice = median(Number.of.Inpatients.on.Any.Service.Per.Day),
            high_inpatients_anyservice = max(Number.of.Inpatients.on.Any.Service.Per.Day),
            
            low_inpatients_medicine = min(Number.of.Inpatients.on.Medicine.Per.Day),
            med_inpatients_medicine = median(Number.of.Inpatients.on.Medicine.Per.Day),
            high_inpatients_medicine = max(Number.of.Inpatients.on.Medicine.Per.Day),
            
            low_inpatients_ICU = min(Number.of.Inpatients.in.an.ICU.Per.Day),
            med_inpatients_ICU = median(Number.of.Inpatients.in.an.ICU.Per.Day),
            high_inpatients_ICU = max(Number.of.Inpatients.in.an.ICU.Per.Day),
            
            low_inpatients_ED = min(Individuals.Seen.in.ED.Per.Day),
            med_inpatients_ED = median(Individuals.Seen.in.ED.Per.Day),
            high_inpatients_ED = max(Individuals.Seen.in.ED.Per.Day),
            
            low_inpatients_Negative.Pressure.Rooms = min(Number.of.Inpatients.in.Negative.Pressure.Rooms.per.Day),
            med_inpatients_Negative.Pressure.Rooms = median(Number.of.Inpatients.in.Negative.Pressure.Rooms.per.Day),
            high_inpatients_Negative.Pressure.Rooms = max(Number.of.Inpatients.in.Negative.Pressure.Rooms.per.Day))

Num_inpatients = as.data.frame(arrange(Num_inpatient_medicine, Month, Day))
Num_inpatients$time = as.numeric(rownames(Num_inpatients)) - 1

summary(Num_inpatients$med_inpatients_anyservice)
summary(Num_inpatients$med_inpatients_ICU)

###############################################################################
###Figure 4. Estimated surge and capacity for hospitalization and intensive care at 
###two acute care hospitals in the Greater Toronto Area. 
###############################################################################
library(directlabels)

nrow(epicurve_maxminIncid)
epicurve_maxminIncid$time
table(epicurve_maxminIncid$Scenario, exclude = NULL)

modelresults = subset(epicurve_maxminIncid, time <= 90)

###################################################
###4A) Inpatients with SMH data
###################################################
modelresults_FSD = subset(modelresults, Scenario %in% c("fast/large", "slow/small", "default"))

(anyserivces_90_predict = 
   ggplot() +
   geom_line(data = subset(modelresults, Scenario %in% c("fast/large", "slow/small", "default")), 
             aes(x = time, y = I_ch *smh_inpatients + 
                   subset(Num_inpatients, time <= 90)$med_inpatients_anyservice, 
                 group = Scenario, colour = Scenario), size = 1.2) +
   xlab('Days since outbreak started') +
   ylab('Prevalent number of non-ICU inpatients at SMH,\n including patients with and without COVID-19')+ 
   theme_bw(base_size = 18) + 
   theme(panel.grid.major = element_blank(), 
         panel.grid.minor = element_blank(),
         panel.background = element_blank(),
         axis.line = element_line(colour = "black")) +
   scale_x_continuous(breaks = seq(0, 90, by = 5))+
   # scale_y_continuous(breaks = seq(0, 510, by = 10))+
   # ylim(300, 700) + ##bed limit 476
   geom_hline(yintercept=476, linetype="dashed", color = "red", size = 1.2)+ 
   geom_text(aes(15, 476, label="Inpatient bed capacity", vjust=-1), color = "red", size = 6)+ 
   # guides(color = FALSE, size = FALSE) +
   ggtitle("A)")  + 
   geom_line(aes(x = subset(Num_inpatients, time <= 90)$time, 
                 y = subset(Num_inpatients, time <= 90)$med_inpatients_anyservice, 
                 color = "pre-outbreak non-COVID\n non-ICU inpatients*"), size = 1.2) +
    scale_color_manual(breaks = c("default", 
                                  "fast/large", 
                                  "slow/small",
                                  "pre-outbreak non-COVID\n non-ICU inpatients*"),
                       values = c("default" = "#F8766D", 
                                  "fast/large" = "#00BA38", 
                                  "slow/small" = "#619CFF", 
                                  "pre-outbreak non-COVID\n non-ICU inpatients*" = "black")))

ggsave("../fig/anyserivces_90_predict_SMH.png", width = 14, height = 10)

(anyserivces_90_predict_cuty = 
    ggplot() +
    geom_line(data = subset(modelresults, Scenario %in% c("fast/large", "slow/small", "default")), 
              aes(x = time, y = I_ch *smh_inpatients + 
                    subset(Num_inpatients, time <= 90)$med_inpatients_anyservice, 
                  group = Scenario, colour = Scenario), size = 1.2) +
    xlab('Days since outbreak started') +
    # ylab('Number of inpatients at SMH,\n including patients with COVID-19')+ 
    ylab('')+
    theme_bw(base_size = 24) + 
    theme(panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black")) +
    scale_x_continuous(breaks = seq(0, 90, by = 5))+
    # scale_y_continuous(breaks = seq(0, 510, by = 10))+
    ylim(300, 700) + ##bed limit 476
    geom_hline(yintercept=476, linetype="dashed", color = "red", size = 1.2)+ 
    geom_text(aes(15, 476, label="Inpatient bed capacity", vjust=-1), color = "red", size = 6)+ 
    # guides(color = FALSE, size = FALSE) +
    ggtitle("B)")  + 
    geom_line(aes(x = subset(Num_inpatients, time <= 90)$time, 
                  y = subset(Num_inpatients, time <= 90)$med_inpatients_anyservice, 
                  color = "pre-outbreak non-COVID non-ICU inpatients*"), size = 1.2) +
    scale_color_manual(breaks = c("default", 
                                  "fast/large", 
                                  "slow/small",
                                  "pre-outbreak non-COVID non-ICU inpatients*"),
                       values = c("default" = "#F8766D", 
                                  "fast/large" = "#00BA38", 
                                  "slow/small" = "#619CFF", 
                                  "pre-outbreak non-COVID non-ICU inpatients*" = "black"))+ 
    theme(legend.position = "none"))


ggsave("../fig/anyserivces_90_predict_SMH_cuty.png", width = 12, height = 10)


###################################################
#### ICU with SMH data
###################################################
(ICU_90_predict = 
   ggplot() +
   geom_line(data = subset(modelresults, Scenario %in% c("fast/large", "slow/small", "default")), 
             aes(x = time, y = I_cicu *smh_ICU + 
                   subset(Num_inpatients, time <= 90)$med_inpatients_ICU,
                 group = Scenario, colour = Scenario), size = 1.2) +
   xlab('Days since outbreak started') +
   ylab('Prevalent number of ICU inpatients at SMH,\n including patients with and without COVID-19')+ 
   theme_bw(base_size = 18) + 
   theme(panel.grid.major = element_blank(), 
         panel.grid.minor = element_blank(),
         panel.background = element_blank(),
         axis.line = element_line(colour = "black")) +
   scale_x_continuous(breaks = seq(0, 90, by = 5))+
   # scale_y_continuous(breaks = seq(0, 510, by = 10))+
   # ylim(300, 700) + ##bed limit 476
   geom_hline(yintercept=71, linetype="dashed", color = "red", size = 1.2)+ 
   geom_text(aes(10, 71, label="ICU bed capacity", vjust=-1), colour = "red",  size = 6)+ 
   # guides(color = FALSE, size = FALSE) +
   ggtitle("A)")  + 
   geom_line(aes(x = subset(Num_inpatients, time <= 90)$time, 
                 y = subset(Num_inpatients, time <= 90)$med_inpatients_ICU, 
                 color = "pre-outbreak non-COVID\n ICU inpatients*"), size = 1.2) +
   scale_color_manual(breaks = c("default", 
                                 "fast/large", 
                                 "slow/small",
                                 "pre-outbreak non-COVID\n ICU inpatients*"),
                      values = c("default" = "#F8766D", 
                                 "fast/large" = "#00BA38", 
                                 "slow/small" = "#619CFF", 
                                 "pre-outbreak non-COVID\n ICU inpatients*" = "black")))

ggsave("../fig/ICU_90_predict_SMH.png", width = 14, height = 10)



(ICU_90_predict_cuty = 
    ggplot() +
    geom_line(data = subset(modelresults, Scenario %in% c("fast/large", "slow/small", "default")), 
              aes(x = time, y = I_cicu *smh_ICU + 
                    subset(Num_inpatients, time <= 90)$med_inpatients_ICU, group = Scenario, colour = Scenario), size = 1.2) +
    xlab('Days since outbreak started') + 
    ylab('')+
    theme_bw(base_size = 24) + 
    theme(panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black")) +
    scale_x_continuous(breaks = seq(0, 90, by = 5))+
    # scale_y_continuous(breaks = seq(0, 510, by = 10))+
    ylim(0, 200) + ##bed limit 476
    geom_hline(yintercept=71, linetype="dashed", color = "red", size = 1.2)+ 
    geom_text(aes(10, 71, label="ICU bed capacity", vjust=-1), colour = "red",  size = 6)+ 
    # guides(color = FALSE, size = FALSE) +
    ggtitle("B)")  + 
    geom_line(aes(x = subset(Num_inpatients, time <= 90)$time, 
                  y = subset(Num_inpatients, time <= 90)$med_inpatients_ICU, 
                  color = "pre-outbreak non-COVID ICU inpatients"), size = 1.2) +
    scale_color_manual(breaks = c("default", 
                                  "fast/large", 
                                  "slow/small",
                                  "pre-outbreak median\n(March-May, 2014-2019)"),
                       values = c("default" = "#F8766D", 
                                  "fast/large" = "#00BA38", 
                                  "slow/small" = "#619CFF", 
                                  "pre-outbreak non-COVID ICU inpatients" = "black")) + 
    theme(legend.position = "none"))
ggsave("../fig/ICU_90_predict_SMH_cuty.png", width = 12, height = 10)

#anyserivces_90 & icu 90
SMH_figure4 = subset(modelresults, Scenario %in% c("fast/large", "slow/small", "default"))
SMH_figure4$SMH_inpatients = SMH_figure4$I_cicu * smh_ICU
SMH_figure4$SMH_ICUinpatients = SMH_figure4$I_ch * smh_inpatients

write.csv(SMH_figure4, "../data/SMH_figure4.csv")

GTA = subset(modelresults, time == 90 & 
               Scenario %in% c("fast/large", "slow/small", "default"))[, c("Scenario", "I_ch", "I_cicu")]
GTA$I_ch_SMH = GTA$I_ch * smh_inpatients
GTA$I_cicu_SMH = GTA$I_cicu * smh_ICU
GTA$I_ch_SJ = GTA$I_ch * sj_inpatients
GTA$I_cicu_SJ = GTA$I_cicu * sj_ICU



###############################################################################
###############################################################################
###SJ specific data
###############################################################################
SJ_admission = read.csv("/path/to/SJ_admission_long.csv", header = T)
SJ_admission$DayMonthYear
colnames(SJ_admission)
SJ_admission$DayMonthYear = as.character(SJ_admission$DayMonthYear)

SJ_admission = SJ_admission %>% separate(DayMonthYear, c("Day", "Month", "Year"))
SJ_admission$Day = str_pad(SJ_admission$Day, 2, pad = "0")
SJ_admission$Month = str_pad(SJ_admission$Month, 2, pad = "0")

Num_inpatient_medicine_SJ =
  SJ_admission %>%
  group_by(Month, Day) %>%
  summarize(low_inpatients_anyservice = min(Number.of.Inpatients.on.Any.Service.Per.Day),
            med_inpatients_anyservice = median(Number.of.Inpatients.on.Any.Service.Per.Day),
            high_inpatients_anyservice = max(Number.of.Inpatients.on.Any.Service.Per.Day),
            
            low_inpatients_medicine = min(Number.of.Inpatients.on.Medicine.Per.Day),
            med_inpatients_medicine = median(Number.of.Inpatients.on.Medicine.Per.Day),
            high_inpatients_medicine = max(Number.of.Inpatients.on.Medicine.Per.Day),
            
            low_inpatients_ICU = min(Number.of.Inpatients.in.an.ICU.Per.Day),
            med_inpatients_ICU = median(Number.of.Inpatients.in.an.ICU.Per.Day),
            high_inpatients_ICU = max(Number.of.Inpatients.in.an.ICU.Per.Day),
            
            low_inpatients_ED = min(Individuals.Seen.in.ED.Per.Day),
            med_inpatients_ED = median(Individuals.Seen.in.ED.Per.Day),
            high_inpatients_ED = max(Individuals.Seen.in.ED.Per.Day),
            
            low_inpatients_Negative.Pressure.Rooms = min(Number.of.Inpatients.in.Negative.Pressure.Rooms.per.Day),
            med_inpatients_Negative.Pressure.Rooms = median(Number.of.Inpatients.in.Negative.Pressure.Rooms.per.Day),
            high_inpatients_Negative.Pressure.Rooms = max(Number.of.Inpatients.in.Negative.Pressure.Rooms.per.Day))

Num_inpatients_SJ = as.data.frame(arrange(Num_inpatient_medicine_SJ, Month, Day))
Num_inpatients_SJ$time = as.numeric(rownames(Num_inpatients_SJ)) - 1

summary(Num_inpatient_medicine_SJ$med_inpatients_anyservice)
summary(Num_inpatient_medicine_SJ$med_inpatients_ICU)

######################################################################################################
######################################################################################################
###################################################
###Appendix 4A Inpatients with SJ data
###################################################
(anyserivces_90_predict_SJ = 
   ggplot() +
   geom_line(data = subset(modelresults, Scenario %in% c("fast/large", "slow/small", "default")), 
             aes(x = time, y = I_ch *sj_inpatients + 
                   subset(Num_inpatients_SJ, time <= 90)$med_inpatients_anyservice, group = Scenario, colour = Scenario), size = 1.2) +
   xlab('Days since outbreak started') +
   ylab('Prevalent number of non-ICU inpatients at SJH,\n including patients with and without COVID-19')+ 
   theme_bw(base_size = 18) + 
   theme(panel.grid.major = element_blank(), 
         panel.grid.minor = element_blank(),
         panel.background = element_blank(),
         axis.line = element_line(colour = "black")) +
   scale_x_continuous(breaks = seq(0, 90, by = 5))+
   # scale_y_continuous(breaks = seq(0, 510, by = 10))+
   # ylim(300, 700) + ##bed limit 439 = 415 + 24
   geom_hline(yintercept=439, linetype="dashed", color = "red", size = 1.2)+ 
   geom_text(aes(15, 439, label="Inpatient bed capacity", vjust=-1), color = "red", size = 6)+ 
   # guides(color = FALSE, size = FALSE) +
   ggtitle("A)")  + 
   geom_line(aes(x = subset(Num_inpatients_SJ, time <= 90)$time, 
                 y = subset(Num_inpatients_SJ, time <= 90)$med_inpatients_anyservice, 
                 color = "pre-outbreak non-COVID\n non-ICU inpatients*"), size = 1.2) +
   scale_color_manual(breaks = c("default", 
                                 "fast/large", 
                                 "slow/small",
                                 "pre-outbreak non-COVID\n non-ICU inpatients*"),
                      values = c("default" = "#F8766D", 
                                 "fast/large" = "#00BA38", 
                                 "slow/small" = "#619CFF", 
                                 "pre-outbreak non-COVID\n non-ICU inpatients*" = "black")))

ggsave("../fig/anyserivces_90_predict_SJ.png", width = 14, height = 10)


(anyserivces_90_predict_SJ_cuty = 
    ggplot() +
    geom_line(data = subset(modelresults, Scenario %in% c("fast/large", "slow/small", "default")), 
              aes(x = time, y = I_ch *sj_inpatients + 
                    subset(Num_inpatients_SJ, time <= 90)$med_inpatients_anyservice, group = Scenario, colour = Scenario), size = 1.2) +
    xlab('Days since outbreak started') +
    ylab('')+ 
    theme_bw(base_size = 24) + 
    theme(panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black")) +
    scale_x_continuous(breaks = seq(0, 90, by = 5))+
    # scale_y_continuous(breaks = seq(0, 510, by = 10))+
    ylim(200, 600) + ##bed limit 439 = 415 + 24
    geom_hline(yintercept=439, linetype="dashed", color = "red", size = 1.2)+ 
    geom_text(aes(15, 439, label="Inpatient bed capacity", vjust=-1), color = "red", size = 6)+ 
    # guides(color = FALSE, size = FALSE) +
    ggtitle("B)")  + 
    geom_line(aes(x = subset(Num_inpatients_SJ, time <= 90)$time, 
                  y = subset(Num_inpatients_SJ, time <= 90)$med_inpatients_anyservice, 
                  color = "pre-outbreak non-COVID\n non-ICU inpatients*"), size = 1.2) +
    scale_color_manual(breaks = c("default", 
                                  "fast/large", 
                                  "slow/small",
                                  "pre-outbreak non-COVID\n non-ICU inpatients*"),
                       values = c("default" = "#F8766D", 
                                  "fast/large" = "#00BA38", 
                                  "slow/small" = "#619CFF", 
                                  "pre-outbreak non-COVID\n non-ICU inpatients*" = "black"))+ 
    theme(legend.position = "none")
  )

ggsave("../fig/anyserivces_90_predict_SJ_cuty.png", width = 12, height = 10)


###################################################
###4D) ICU with SJ data
###################################################
(ICU_90_predict_SJ = 
   ggplot() +
   geom_line(data = subset(modelresults, Scenario %in% c("fast/large", "slow/small", "default")), 
             aes(x = time, y = I_cicu *sj_ICU + 
                   subset(Num_inpatients_SJ, time <= 90)$med_inpatients_ICU, 
                 group = Scenario, colour = Scenario), size = 1.2) +
   xlab('Days since outbreak started') +
   ylab('Prevalent number of ICU inpatients at SJH,\n including patients with and without COVID-19')+ 
   theme_bw(base_size = 18) + 
   theme(panel.grid.major = element_blank(), 
         panel.grid.minor = element_blank(),
         panel.background = element_blank(),
         axis.line = element_line(colour = "black")) +
   scale_x_continuous(breaks = seq(0, 90, by = 5))+
   # scale_y_continuous(breaks = seq(0, 510, by = 10))+
   # ylim(300, 700) + ##bed limit 476
   geom_hline(yintercept=32, linetype="dashed", color = "red", size = 1.2)+ 
   geom_text(aes(10, 32, label="ICU bed capacity", vjust=-1), colour = "red", size = 6)+ 
   # guides(color = FALSE, size = FALSE) +
   ggtitle("A)")  + 
   geom_line(aes(x = subset(Num_inpatients_SJ, time <= 90)$time, 
                 y = subset(Num_inpatients_SJ, time <= 90)$med_inpatients_ICU, 
                 color = "pre-outbreak non-COVID\n ICU inpatients*"), size = 1.2) +
   scale_color_manual(breaks = c("default", 
                                 "fast/large", 
                                 "slow/small",
                                 "pre-outbreak non-COVID\n ICU inpatients*"),
                      values = c("default" = "#F8766D", 
                                 "fast/large" = "#00BA38", 
                                 "slow/small" = "#619CFF", 
                                 "pre-outbreak non-COVID\n ICU inpatients*" = "black")))

ggsave("../fig/ICU_90_predict_SJ.png", width = 14, height = 10)


(ICU_90_predict_SJ_cuty = 
    ggplot() +
    geom_line(data = subset(modelresults, Scenario %in% c("fast/large", "slow/small", "default")), 
              aes(x = time, y = I_cicu *sj_ICU + 
                    subset(Num_inpatients_SJ, time <= 90)$med_inpatients_ICU, 
                  group = Scenario, colour = Scenario), size = 1.2) +
    xlab('Days since outbreak started') +
    ylab('')+ 
    theme_bw(base_size = 24) + 
    theme(panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black")) +
    scale_x_continuous(breaks = seq(0, 90, by = 5))+
    # scale_y_continuous(breaks = seq(0, 510, by = 10))+
    ylim(0, 60) + ##bed limit 476
    geom_hline(yintercept=32, linetype="dashed", color = "red", size = 1.2)+ 
    geom_text(aes(10, 32, label="ICU bed capacity", vjust=-1), colour = "red", size = 6)+ 
    # guides(color = FALSE, size = FALSE) +
    ggtitle("B)")  + 
    geom_line(aes(x = subset(Num_inpatients_SJ, time <= 90)$time, 
                  y = subset(Num_inpatients_SJ, time <= 90)$med_inpatients_ICU, 
                  color = "pre-outbreak median\n(March-May, 2014-2019)"), size = 1.2) +
    scale_color_manual(breaks = c("default", 
                                  "fast/large", 
                                  "slow/small",
                                  "pre-outbreak median\n(March-May, 2014-2019)"),
                       values = c("default" = "#F8766D", 
                                  "fast/large" = "#00BA38", 
                                  "slow/small" = "#619CFF", 
                                  "pre-outbreak median\n(March-May, 2014-2019)" = "black")) + 
    theme(legend.position = "none"))

ggsave("../fig/ICU_90_predict_SJ_cuty.png", width = 12, height = 10)



#anyserivces_90 & icu 90
SJ_figure4 = subset(modelresults, Scenario %in% c("fast/large", "slow/small", "default"))
SJ_figure4$SMH_inpatients = SJ_figure4$I_cicu * sj_ICU
SJ_figure4$SMH_ICUinpatients = SJ_figure4$I_ch * sj_inpatients

write.csv(SJ_figure4, "../data/SJ_figure4.csv")

