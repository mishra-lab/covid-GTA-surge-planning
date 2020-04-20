########################################################
# COVID 2019 Project 
# Purpose: draw epidemic curve in other countries/regions
# Data: 
#   [open access] https://github.com/CSSEGISandData/COVID-19/blob/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv
#   model outputs
# Author: Linwei Wang, Huiting Ma
# Created on: March 9th
# Data date: March 12th
# Last update: Apr 16, 2020
# Figure 2 & 3
########################################################
rm(list=ls())

library(ggplot2)
library(dplyr)
library(reshape2)
library(tidyr)
library(stringr)
library(gridExtra)

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
# modelout<- read.csv("OneWaySens_ParmList2020-03-13.csv", header = T)
table(modelout$R0, exclude = NULL)
summary(modelout$pSet)
length(unique(modelout$pSet))

###############################################
#get default case
csvFileName<- paste("../data/ParmSet_Default",lastUpdateDate,".csv",sep="")
default_results<- read.csv(file=csvFileName)
# modelout<- read.csv("OneWaySens_ParmList2020-03-13.csv", header = T)
table(default_results$R0, exclude = NULL)
colnames(default_results)
colnames(modelout)

default_results$pSet = max(modelout$pSet) + 1

default_results$S/default_results$N


default_results$I_ch

subset(default_results, I_cicu >145 * 2)[1, c("time", "I_cicu")]
subset(default_results, I_cicu >231 * 2)[1, c("time", "I_cicu")]

default_LHS = rbind(modelout, default_results)
nrow(modelout)
nrow(default_LHS)


###############################################################################
##Caculate ED visits
###############################################################################
##Create a daily count from the cumulative variable 
table(default_LHS$CumED_ct, exclude = NULL)
table(subset(default_LHS, pSet == 1)$CumED_ct, exclude = NULL)
subset(default_LHS, pSet == 1)$CumED_ct

##Create a daily count from cumulative variable 
table(default_LHS$CumAdmit, exclude = NULL)

default_LHS = 
  default_LHS %>%
  group_by(pSet) %>%
  mutate(DailyED_ct = CumED_ct - lag(CumED_ct)) %>% ##Create a daily count from the cumulative variable 
  mutate(DailyAdmit = CumAdmit - lag(CumAdmit)) ##Create a daily count from cumulative variable 

subset(default_LHS, pSet == 1)[, c("CumED_ct", "DailyED_ct", "CumAdmit", "DailyAdmit")]

summary(default_LHS$DailyED_ct)
summary(default_LHS$DailyAdmit)
summary(default_LHS$pSet)

default_LHS$DailyED_ct = ifelse(is.na(default_LHS$DailyED_ct), 0 , default_LHS$DailyED_ct)
default_LHS$DailyAdmit = ifelse(is.na(default_LHS$DailyAdmit), 0 , default_LHS$DailyAdmit)

default_LHS$ED_visits = default_LHS$DailyED_ct + default_LHS$DailyAdmit 

default_LHS$case.per100k = default_LHS$Cumdx_tot/default_LHS$initpop * 100000


output_default_LHS = default_LHS
nrow(output_default_LHS)

output_default_LHS$Province.State = ifelse(output_default_LHS$pSet == max(modelout$pSet) + 1,
                                              "GTA, model default",
                                              "GTA, model")
table(output_default_LHS$Province.State, exclude = NULL)
output_default_LHS$Province.State.Set = paste(output_default_LHS$Province.State, output_default_LHS$pSet)


#################################################
###Read data from other countries
#################################################
epidemic_f = read.csv("../data/epidemic_f.csv", header = T)

epidemic_f$Province.State = ifelse(epidemic_f$Province.State == "Italy_Lombardy", "Lombardy, Italy",
                                   ifelse(epidemic_f$Province.State == "Canada_Toronto", "GTA, observed",
                                          ifelse(epidemic_f$Province.State == "China_Hong Kong", "Hong Kong, China",
                                                 as.character(epidemic_f$Province.State))))
                                          
table(epidemic_f$Province.State , exclude = NULL)


########################################################################################################################
##### Figure 2. Cumulative detected cases across constrained scenarios and 
##### observed data used for epidemic constraints. 
########################################################################################################################

#################################################
###Merge model outputs and othe countires data
epidemic_f = subset(epidemic_f,Province.State %in% c("GTA, observed", 
                                                     "Hong Kong, China",
                                                     "Singapore",
                                                     "Lombardy, Italy"))
output_default_LHS_combine = bind_rows(output_default_LHS, epidemic_f)
nrow(output_default_LHS)
nrow(epidemic_f)
nrow(output_default_LHS_combine)
output_default_LHS_combine$Province.State.Set = ifelse(is.na(output_default_LHS_combine$Province.State.Set),
                                                          output_default_LHS_combine$Province.State, 
                                                          output_default_LHS_combine$Province.State.Set)
table(output_default_LHS_combine$Province.State.Set)

table(output_default_LHS_combine$time, exclude = NULL)
table(output_default_LHS_combine$Province.State.Set, exclude = NULL)
summary(output_default_LHS_combine$case.per100k)
table(output_default_LHS_combine$Province.State, exclude = NULL)

output_default_LHS_combine$Province.State <- factor(output_default_LHS_combine$Province.State,
                                               levels = c("GTA, model",
                                                          "GTA, model default",
                                                          "GTA, observed",
                                                          #"South Korea",
                                                          "Hong Kong, China",
                                                          "Lombardy, Italy",
                                                          "Singapore"))

output_default_LHS_combine$Province.State.Set = factor(output_default_LHS_combine$Province.State.Set,
                                                  levels = c(paste("GTA, model", unique(output_default_LHS$pSet)),
                                                             "GTA, model default 198",
                                                             "GTA, observed",
                                                             #"South Korea",
                                                             "Hong Kong, China",
                                                             "Lombardy, Italy",
                                                             "Singapore"))
# library(scales)
# show_col(hue_pal()(20))


#lowerrangecut = subset(output_default_LHS_combine, Province.State == "China_Hong Kong" & time == 18)$case.per100k
lowerrangecut = round(subset(output_default_LHS_combine, 
                             Province.State == "Hong Kong, China" & time == 30)$case.per100k, 1)

output_default_LHS_combine$exclude = ifelse(output_default_LHS_combine$time == 30 & 
                                                 output_default_LHS_combine$Province.State.Set %in% paste("GTA, model", unique(output_default_LHS$pSet)) & 
                                                 output_default_LHS_combine$case.per100k < lowerrangecut, 1, 0)
table(output_default_LHS_combine$exclude, exclude = NULL)  

# write.csv(output_default_LHS_combine, "output_default_LHS_combine.csv", row.names = F)

output_default_LHS_combine_clean = subset(output_default_LHS_combine, 
                                             !(pSet %in% subset(output_default_LHS_combine, 
                                                                exclude == 1)$pSet))  
nrow(output_default_LHS_combine_clean)


ggplot(output_default_LHS_combine, aes(x = time, y = case.per100k, 
                                                group = Province.State.Set, 
                                                color = Province.State)) +
  ylab ("Number of detected cases of COVID-19 per 100,000 population") +  
  xlab ("Days since outbreak started\n(local transmission)") +
  geom_line(size = 1) +
  theme_bw(base_size = 14) + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black")) +
  scale_x_continuous(breaks = seq(0, 300, by = 30)) +  
  ylim(0, 5) +
  scale_color_manual(values=c("gray80",
                              "black",
                              "#D89000",
                              "#00BAE0",
                              "#FA62DB",
                              "#00BF7D",
                              "#FF6A98"))+
  theme(legend.title=element_blank())

ggplot(output_default_LHS_combine_clean, aes(x = time, y = case.per100k, 
                                          group = Province.State.Set, 
                                          color = Province.State)) +
  ylab ("Number of detected cases of COVID-19 per 100,000 population") +  
  xlab ("Days since outbreak started\n(local transmission)") +
  geom_line(size = 1) +
  theme_bw(base_size = 14) + 
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.line = element_line(colour = "black")) +
  scale_x_continuous(breaks = seq(0, 300, by = 30)) +  
  # ylim(0, 1000) +
  scale_color_manual(values=c("gray80",
                              "black",
                              "#D89000",
                              "#00BAE0",
                              "#FA62DB",
                              "#00BF7D",
                              "#FF6A98"))+
  theme(legend.title=element_blank())


(Figure2 = 
    ggplot(output_default_LHS_combine_clean, aes(x = time, 
                                                    y = case.per100k, 
                                                    group = Province.State.Set, 
                                                    color = Province.State)) +
    ylab ("Number of detected cases of COVID-19 per 100,000 population") +  
    xlab ("Days since outbreak started\n(local transmission)") +
    geom_line(size = 1) +
    theme_bw(base_size = 14) + 
    theme(panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black")) +
    # scale_x_continuous(breaks = seq(0, 60, by = 5)) +  
    ylim(0, 5) + xlim(0, 60) +
    scale_color_manual(values=c("gray80",
                                "black",
                                "#D89000",
                                "#00BAE0",
                                "#FA62DB",
                                "#00BF7D",
                                "#FF6A98"))+
    theme(legend.title=element_blank()))
ggsave("../fig/Figure2_constraints.png", width = 12, height = 10)







########################################################################################################################
###Figure 3. Epidemic curves and health-care needs in the Greater Toronto Area (GTA) across three scenarios: default, fast/large, slow/small epidemics.  
########################################################################################################################
default_LHS_exclude = subset(default_LHS, !(pSet %in% subset(output_default_LHS_combine, exclude == 1)$pSet))  
#default_LHS_exclude = default_LHS
nrow(default_LHS_exclude)
nrow(default_LHS)

###### cumulative incidence of cases ######
# cumulative incidence (total cases, as well as for tPAF), 
# including imported cases and super-spreading events
# CumIncid_tot
# default_LHS_exclude = subset(default_LHS, !(pSet %in% subset(output_default_LHS_combine, exclude == 1)$pSet))  

default_LHS_exclude = 
  default_LHS_exclude %>%
  group_by(pSet) %>%
  mutate(DailyIncid_tot = CumIncid_tot - lag(CumIncid_tot),
         DailyAdmit = CumAdmit - lag(CumAdmit),
         DailyICU = CumICU - lag(CumICU),
         peakIncid = max(DailyIncid_tot, na.rm = T)) ##calculate the peak daily incidence
summary(default_LHS_exclude$DailyIncid_tot)
length(unique(default_LHS_exclude$pSet))

default_LHS_exclude$DailyIncid_tot = ifelse(is.na(default_LHS_exclude$DailyIncid_tot), 0,
                                            default_LHS_exclude$DailyIncid_tot)
default_LHS_exclude$DailyAdmit = ifelse(is.na(default_LHS_exclude$DailyAdmit), 0,
                                            default_LHS_exclude$DailyAdmit)
default_LHS_exclude$DailyICU = ifelse(is.na(default_LHS_exclude$DailyICU), 0,
                                            default_LHS_exclude$DailyICU)
summary(default_LHS_exclude$DailyIncid_tot)
default_LHS_exclude$incidence.per100k = default_LHS_exclude$DailyIncid_tot/default_LHS_exclude$initpop * 100000


####based on incidence peak to choose the epidemic
table(default_LHS_exclude$peakIncid, exclude = NULL)
summary(default_LHS_exclude$peakIncid)
default_LHS_exclude_uniquepSet = subset(default_LHS_exclude, time == 1)[, c("pSet", "peakIncid")]

maxpeakIncid_pSet = default_LHS_exclude_uniquepSet$pSet[which.max(default_LHS_exclude_uniquepSet$peakIncid)]
minpeakIncid_pSet = default_LHS_exclude_uniquepSet$pSet[which.min(default_LHS_exclude_uniquepSet$peakIncid)]
quantile_25peakIncid_pSet = default_LHS_exclude_uniquepSet$pSet[which.min(abs(default_LHS_exclude_uniquepSet$peakIncid - 
                                                                                quantile(default_LHS_exclude_uniquepSet$peakIncid, .25)))]
quantile_75peakIncid_pSet = default_LHS_exclude_uniquepSet$pSet[which.min(abs(default_LHS_exclude_uniquepSet$peakIncid - 
                                                                                quantile(default_LHS_exclude_uniquepSet$peakIncid, .75)))]
maxpeakIncid_pSet
minpeakIncid_pSet
quantile_25peakIncid_pSet
quantile_75peakIncid_pSet

# check = subset(default_LHS_exclude, pSet == maxpeakIncid_pSet)[, c("peakIncid", "DailyIncid_tot")]

epicurve_maxminIncid = subset(default_LHS_exclude, pSet %in% c(maxpeakIncid_pSet,
                                                               minpeakIncid_pSet,
                                                               quantile_25peakIncid_pSet,
                                                               quantile_75peakIncid_pSet,
                                                               max(modelout$pSet) + 1))
nrow(epicurve_maxminIncid)


epicurve_maxminIncid$Scenario = ifelse(epicurve_maxminIncid$pSet ==  maxpeakIncid_pSet, "min",
                                       ifelse(epicurve_maxminIncid$pSet ==  minpeakIncid_pSet, "max", 
                                              ifelse(epicurve_maxminIncid$pSet ==  quantile_75peakIncid_pSet, "fast/large", 
                                                     ifelse(epicurve_maxminIncid$pSet ==  quantile_25peakIncid_pSet, "slow/small", 
                                                            "default"))))

subset(default_LHS_exclude_uniquepSet, pSet %in% c(maxpeakIncid_pSet,
                                                   minpeakIncid_pSet,
                                                   quantile_25peakIncid_pSet,
                                                   quantile_75peakIncid_pSet))[, c("peakIncid", "pSet")]
                         
summary(default_LHS_exclude_uniquepSet$peakIncid)

write.csv(epicurve_maxminIncid, "epicurve_maxminIncid.csv", row.names = F)




########################################################################################################################
#######Figures based on peak incidence######################################################################
########################################################################################################################
# ##(A) modeled incidence of infection (diagnosed and undiagnosed) for the GTA;
(incidenceGTA_peakIncid = 
   ggplot(subset(epicurve_maxminIncid, pSet %in% c(quantile_25peakIncid_pSet,
                                                   quantile_75peakIncid_pSet, 
                                                   max(modelout$pSet) + 1)), 
          aes(x = time, y = incidence.per100k, group = Scenario, colour = Scenario)) +
   ylab ("Daily number of incident COVID-19 infection\n (diagnosed and undiagnosed) per 100,000 population") +  
   xlab ("Days since outbreak started\n(local transmission)") +
   geom_line(size = 1) + 
   theme_bw(base_size = 20) + 
   theme(panel.grid.major = element_blank(), 
         panel.grid.minor = element_blank(),
         panel.background = element_blank(),
         axis.line = element_line(colour = "black")) +
   scale_x_continuous(breaks = seq(0, 300, by = 30)) +
   scale_y_continuous(breaks = seq(0, 1400, by = 200)) +
   theme(legend.position = c(0, 1), 
         legend.justification = c(-0.1, 1.8),
         legend.direction = "vertical") +
   ggtitle("A)")
 )

ggsave("../fig/incidenceGTA_peakIncid.png", width = 12, height = 10)

###daily incidence use prevalence to change to daily (area bar) top and bottom for IQR
### (B) modeled daily number of hospital admissions for individuals with COVID-19 alongside pre-outbreak data on the daily median number of hospital admissions between March-August 2019 in the GTA; 
(DailyAdmisstionGTA_peakIncid = 
    ggplot(subset(epicurve_maxminIncid, pSet %in% c(quantile_25peakIncid_pSet,
                                                    quantile_75peakIncid_pSet, 
                                                    max(modelout$pSet) + 1)), 
           aes(x = time, y = DailyAdmit, group = Scenario, colour = Scenario)) +
    ylab ("Daily number of new hospital admission due to COVID infection") +  
    xlab ("Days since outbreak started\n(local transmission)") +
    geom_line(size = 1) + 
    theme_bw(base_size = 20) + 
    theme(panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black")) +
    scale_x_continuous(breaks = seq(0, 300, by = 30))  +
    scale_y_continuous(breaks = seq(0, 9000, by = 1500)) +
     theme(legend.position = c(0, 1), 
          legend.justification = c(-0.1, 1.8),
          legend.direction = "vertical") + 
    annotate("rect", xmin=0, xmax=300, ymin=1056,ymax=1653, alpha=0.2, fill="red") +
    ggtitle("B)")
)

ggsave("../fig/DailyAdmisstionGTA_peakIncid.png", width = 12, height = 10)
# Default S [1] 2388273

# 1,559 			 1,072 	 1,611 

## (C) modeled daily number of ICU admissions alongside pre-outbreak data on the daily median number of ICU admissions  between March-August 2019 in the GTA; 
(DailyICUGTA_peakIncid = 
    ggplot(subset(epicurve_maxminIncid, pSet %in% c(quantile_25peakIncid_pSet,
                                                    quantile_75peakIncid_pSet, 
                                                    max(modelout$pSet) + 1)),
           aes(x = time, y = DailyICU, group = Scenario, colour = Scenario)) +
    ylab ("Daily number of new ICU admission due to COVID infection") +  
    xlab ("Days since outbreak started\n(local transmission)") +
    geom_rect(aes(xmin = 0, xmax = 300, ymin = 145, ymax = 231),
              fill = "pink", colour = "white", alpha = 0.2) + 
    geom_line(size = 1) + 
    theme_bw(base_size = 20) + 
    theme(panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black")) +
    scale_x_continuous(breaks = seq(0, 300, by = 30)) +
    theme(legend.position = c(0, 1), 
          legend.justification = c(-0.1, 1.8),
          legend.direction = "vertical") + 
    ggtitle("C)")
  
)

ggsave("../fig/DailyICUGTA_peakIncid.png", width = 12, height = 10)


########################################################################################################################
########################################################################################################################
########################################################################################################################


###############################################################################
# Update Figure 2 with IQR
###############################################################################
quantile_25peakIncid_pSet
quantile_75peakIncid_pSet

table(output_default_LHS_combine_clean$Province.State, exclude = NULL)

output_default_LHS_combine_clean$Province.State = 
  ifelse(!is.na(output_default_LHS_combine_clean$pSet) &  
           output_default_LHS_combine_clean$pSet == quantile_75peakIncid_pSet, 
         "GTA, model fast/large",
       ifelse(!is.na(output_default_LHS_combine_clean$pSet) & 
                output_default_LHS_combine_clean$pSet == quantile_25peakIncid_pSet, 
              "GTA, model slow/small", 
              as.character(output_default_LHS_combine_clean$Province.State)))
table(output_default_LHS_combine_clean$Province.State, exclude = NULL)

output_default_LHS_combine_clean$Type = ifelse(output_default_LHS_combine_clean$Province.State %in% c("GTA, observed",
                                                                                                            "Hong Kong, China",
                                                                                                            "Lombardy, Italy",
                                                                                                            "Singapore"),
                                                  "Data",
                                                  "GTA, model")

output_default_LHS_combine_clean$Province.State.Set = factor(output_default_LHS_combine_clean$Province.State.Set,
                                                          levels = c(paste("GTA, model", 
                                                                           unique(output_default_LHS$pSet)[!unique(output_default_LHS$pSet) 
                                                                                                              %in% c(quantile_25peakIncid_pSet, 
                                                                                                                     quantile_75peakIncid_pSet)]),
                                                                     paste("GTA, model default" , max(modelout$pSet) + 1),
                                                                     paste("GTA, model" , quantile_25peakIncid_pSet),
                                                                     paste("GTA, model" , quantile_75peakIncid_pSet),
                                                                     "GTA, observed",
                                                                     #"South Korea",
                                                                     "Hong Kong, China",
                                                                     "Lombardy, Italy",
                                                                     "Singapore"))

#epidemic_f
table(output_default_LHS_combine_clean$Province.State, exclude = NULL)
output_default_LHS_combine_clean_sub_point = subset(output_default_LHS_combine_clean, 
                                                 Province.State %in% c("GTA, observed",
                                                                       "Hong Kong, China",
                                                                       "Lombardy, Italy")) #, "Singapore"

output_default_LHS_combine_clean_sub_line = subset(output_default_LHS_combine_clean, 
                                                       !(Province.State %in% c("GTA, observed",
                                                                             "Hong Kong, China",
                                                                             "Lombardy, Italy",
                                                                             "Singapore")))



(Figure2_update = 
    ggplot() +
    ylab ("Cumulative number of detected COVID-19 cases\n per 100,000 population") +  
    xlab ("Days since outbreak started\n(local transmission)") +
    geom_line(data =output_default_LHS_combine_clean_sub_line, aes(x = time, 
                                                                 y = case.per100k, 
                                                                 group = Province.State.Set, 
                                                                 color = Province.State), 
              size = 1) + 
    #scale_linetype_manual(values=c("dashed", "solid"))+
    theme_bw(base_size = 18) + 
    theme(panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black")) +
    # scale_x_continuous(breaks = seq(0, 60, by = 5)) +  
    ylim(0, 5) + xlim(0, 60) +
    scale_color_manual(values=c("gray80",
                                "#F8766D",
                                "#00BA38",
                                "#619CFF",
                                "black",
                                "#FA62DB",
                                #"#00C1A3",
                                "#A3A500"),
                       guide = guide_legend(override.aes = list(linetype = c(rep("solid", 4), 
                                                                             rep("blank", 3)),
                                                                shape = c(NA, NA, NA, NA, 16, 16, 16)))) + 
    theme(legend.title=element_blank()) +
  geom_point(data =output_default_LHS_combine_clean_sub_point, aes(x = time, 
                                                                     y = case.per100k, 
                                                                     color = Province.State), 
             size = 2)
  

  )
ggsave("../fig/Figure2_constraints_update_peakInsid_dot.png", width = 16, height = 10)


# write.csv(output_default_LHS_combine_clean, "Figure2.csv", row.names = F)


(Figure2_update_full_range = 
    ggplot() +
    ylab ("Cumulative number of detected COVID-19 cases\n per 100,000 population") +  
    xlab ("Days since outbreak started\n(local transmission)") +
    geom_line(data =output_default_LHS_combine_clean_sub_line, aes(x = time, 
                                                                   y = case.per100k, 
                                                                   group = Province.State.Set, 
                                                                   color = Province.State), 
              size = 1) + 
    scale_linetype_manual(values=c("dashed", "solid"))+
    theme_bw(base_size = 14) + 
    theme(panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black")) +
    scale_y_continuous(breaks = seq(0, 27000, by = 3000)) +
    scale_color_manual(values=c("gray80",
                                "#F8766D",
                                "#00BA38",
                                "#619CFF")) +#,
                                #"black",
                                #"#FA62DB",
                                #"#00C1A3",
                                #"#A3A500")) + 
    theme(legend.title=element_blank())# +
)
ggsave("../fig/Figure2_update_full_range.png", width = 14, height = 10)









