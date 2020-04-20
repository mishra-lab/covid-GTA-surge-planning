########################################################
# COVID 2019 Project 
# Purpose: draw epidemic curve in other countries/regions
# Data:
#     [open access] https://github.com/CSSEGISandData/COVID-19/blob/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv
#     model outputs
# Author: Linwei Wang, Huiting Ma
# Created on: March 9th
# Data date: March 12th
# Last update: Apr 16, 2020
# Figure 6 sensitivity analyses
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
Clibrary(tidyr)
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
lastUpdateDate <- "2020-04-08"
csvFileName<- paste("../data/OneWaySens_ParmList",lastUpdateDate,".csv",sep="")
modelout<- read.csv(file=csvFileName)
# modelout<- read.csv("OneWaySens_ParmList2020-03-13.csv", header = T)
table(modelout$R0, exclude = NULL)
table(modelout$prob_test_max, exclude = NULL)
csvFileName<- paste("../data/ParmSet_Default",lastUpdateDate,".csv",sep="")
default_results<- read.csv(file=csvFileName)
# modelout<- read.csv("OneWaySens_ParmList2020-03-13.csv", header = T)
table(default_results$R0, exclude = NULL)

####St.Michael's Hospital catchment
smh_inpatients =0.04543
smh_ICU =0.08676
smh_ED =0.03103


###############################################################################
###extract data
###############################################################################
#### Other parameters
# dur_latent
# dur_incubation
# dur_symptomatic
## dur_admitted
# dur_icu
# prob_test
# prob_admit_diagnosed
# condprob_icu
# condprob_cfr
## R0
# ####seed_backCalc
# prop_travel_test
# ####drop_Reffective
# ####social_distancing
# when_test_increase
# prob_diagnosed
# ####prob_test_max

table(modelout$R0, exclude = NULL)
modelresultsR0 = subset(modelout, R0 != unique(default_results$R0))
nrow(modelresultsR0)

###############################################################################
table(modelout$seed_backCalc, exclude = NULL)
modelresultsseed_backCalc = subset(modelout, seed_backCalc != unique(default_results$seed_backCalc))
nrow(modelresultsseed_backCalc)

###############################################################################
table(modelout$prob_admit, exclude = NULL)
modelresultsprob_admit = subset(modelout, prob_admit != unique(default_results$prob_admit))
nrow(modelresultsprob_admit)

###############################################################################
table(modelout$drop_Reffective, exclude = NULL)
modelresultsprob_drop_Reffective = subset(modelout, drop_Reffective != unique(default_results$drop_Reffective))
nrow(modelresultsprob_admit)

###############################################################################
table(modelout$dur_admitted, exclude = NULL)
modelresultsdur_admitted = subset(modelout, dur_admitted != unique(default_results$dur_admitted))
nrow(modelresultsdur_admitted)

###############################################################################
table(modelout$social_distancing, exclude = NULL)
modelresultssocial_distancing = subset(modelout, social_distancing != unique(default_results$social_distancing))
nrow(modelresultssocial_distancing)

###############################################################################
table(modelout$prob_test, exclude = NULL)
modelresultsprob_test= subset(modelout, prob_test != unique(default_results$prob_test))
nrow(modelresultsprob_test)

###############################################################################
table(modelout$prob_test_max, exclude = NULL)
modelresultsprob_test_max= subset(modelout, prob_test_max != unique(default_results$prob_test_max))
nrow(modelresultsprob_test_max)

###############################################################################
table(modelout$dur_inf, exclude = NULL)
# modelresultsR0 = subset(modelout, R0 != unique(default_results$R0))
# nrow(modelresultsR0)

###############################################################################
table(modelout$dur_icu, exclude = NULL)
modelresultsdur_icu= subset(modelout, dur_icu != unique(default_results$dur_icu))
nrow(modelresultsdur_icu)


###############################################################################
table(modelout$condprob_icu, exclude = NULL)
modelresultscondprob_icu= subset(modelout, condprob_icu != unique(default_results$condprob_icu))
nrow(modelresultscondprob_icu)



###############################################################################
#### Other parameters
# dur_latent
# dur_incubation
# dur_symptomatic
# dur_admitted
# dur_icu
# prob_test
# prob_admit_diagnosed
# condprob_icu
# condprob_cfr
# R0
# ####seed_backCalc
# prop_travel_test
# ####drop_Reffective
# ####social_distancing
# when_test_increase
# prob_diagnosed
# ####prob_test_max


###############################################################################

###############################################################################
## Figure 6 Inpatients#########################################################
###############################################################################
### (A) seeding (proportion of population already infected with COVID-19 just at the start of the outbreak);
###############################################################################
modelresultsseed_backCalc$seed_prop = modelresultsseed_backCalc$seed_backCalc/modelresultsseed_backCalc$initpop
summary(modelresultsseed_backCalc$seed_prop)
# (admitted_backCalc_90 = 
#     ggplot(subset(modelresultsseed_backCalc, time <= 90), 
#            aes(x = time, y = I_ch * smh_inpatients, group = seed_prop * 100, colour = seed_prop * 100)) +
#     ylab ("Number of non-ICU inpatients with COVID-19 at SMH") +  
#     xlab ("Days since outbreak started\n(local transmission)") +
#     geom_line(size = 1) + 
#     theme_bw(base_size = 24) + 
#     theme(panel.grid.major = element_blank(), 
#           panel.grid.minor = element_blank(),
#           panel.background = element_blank(),
#           axis.line = element_line(colour = "black")) +
#     scale_x_continuous(breaks = seq(0, 90, by = 5)) +
#     # scale_y_continuous(breaks = seq(0, 140, by = 10)) +
#     # annotate("text", label = "50% cases detected & home isolation\n10% catchment area for this hospital", 
#     #          x = 1, y = 200, size = 5, colour = "black", hjust = 0)+
#     scale_colour_gradient(low = "yellow", high = "red", 
#                           limits = c(0.001, 0.005), 
#                           labels = seq(0.001, 0.004, by = 0.0015), 
#                           breaks =  seq(0.001, 0.004, by = 0.0015)) +
#     labs(colour= expression("% of GTA with active\n infection at the start of the outbreak"^'a'))+
#     theme(legend.position = c(0, 1), 
#           legend.justification = c(-0.1, 1.8),
#           legend.direction = "vertical") + ggtitle("A)") 
  # 
  # )
 

(admitted_backCalc_90 = 
    ggplot() +
    ylab ("Number of non-ICU inpatients with COVID-19 at SMH") +  
    xlab ("Days since outbreak started\n(local transmission)") +
    geom_line(data = subset(modelresultsseed_backCalc, time <= 90), 
              aes(x = time, y = I_ch * smh_inpatients, group = seed_prop * 100, colour = seed_prop * 100),
              size = 1, show.legend = T) + 
    theme_bw(base_size = 24) + 
    theme(panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black")) +
    scale_x_continuous(breaks = seq(0, 90, by = 5)) +
    # scale_y_continuous(breaks = seq(0, 140, by = 10)) +
    # annotate("text", label = "50% cases detected & home isolation\n10% catchment area for this hospital", 
    #          x = 1, y = 200, size = 5, colour = "black", hjust = 0)+
    scale_colour_gradientn(colors = c(low = "yellow", high = "red"),
                          limits = c(0.001, 0.005), 
                          labels = seq(0.001, 0.004, by = 0.0015), 
                          breaks =  seq(0.001, 0.004, by = 0.0015),
                          name = expression("% of GTA with active\n infection at the start of the outbreak"^'a')) +
    # labs(colour= expression("% of GTA with active\n infection at the start of the outbreak"^'a'))+
    theme(legend.position = c(0, 1), 
          legend.justification = c(-0.1, 1.8),
          legend.direction = "vertical") + ggtitle("A)") +
    geom_line(data = subset(default_results, time <= 90), 
              aes(x = time, y = I_ch * smh_inpatients, fill = "Default scenario"), size = 1, color = "black") +
    scale_fill_manual("", values=c(1),
                      guide=guide_legend(override.aes = list(colour=c("black"))))+
    guides(
      color = guide_colorbar(order = 1),
      fill = guide_legend(order = 0))
)




ggsave("../fig/admitted_backCalc_90.png", width = 12, height = 12)


### (B) clinical severity (proportion of individuals infected with COVID-19 who require hospitalization) The influence of increasing or delayed start of interventions in the GTA on one hospital's surge: 
###############################################################################
(admitted_prob_admit_90 = 
    ggplot() +
    ylab ("Number of non-ICU inpatients with COVID-19 at SMH") +  
    xlab ("Days since outbreak started\n(local transmission)") +
    geom_line(data = subset(modelresultsprob_admit, time <= 90),
              aes(x = time, y = I_ch * smh_inpatients, group = prob_admit * 100, colour = prob_admit * 100),
              size = 1, show.legend = T) + 
    theme_bw(base_size = 24) + 
    theme(panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black")) +
    scale_x_continuous(breaks = seq(0, 90, by = 5)) +
    # scale_y_continuous(breaks = seq(0, 140, by = 10)) +
    # annotate("text", label = "50% cases detected & home isolation\n10% catchment area for this hospital", 
    #          x = 1, y = 200, size = 5, colour = "black", hjust = 0)+
    scale_colour_gradientn(colors = c(low = "yellow", high = "red"),
                           name = "Proportion (%) with COVID-19\n who develop severe infection\n requiring hospital admission") +
    # labs(colour="Proportion (%) with COVID-19\n who develop severe infection\n requiring hospital admission")+ 
   # scale_fill_continuous(guide = guide_legend()) +
  theme(legend.position = c(0, 1), 
        legend.justification = c(-0.1, 1.8),
        legend.direction = "vertical") + ggtitle("B)")+
   geom_line(data = subset(default_results, time <= 90), 
             aes(x = time, y = I_ch * smh_inpatients, fill = "Default scenario"), size = 1, color = "black") +
   scale_fill_manual("", values=c(1),
                     guide=guide_legend(override.aes = list(colour=c("black"))))+
   guides(
     color = guide_colorbar(order = 1),
     fill = guide_legend(order = 0))
 )


ggsave("../fig/admitted_prob_admit_90.png", width = 12, height = 12)


### (C) earlier or later initiation of physical distancing (from start of outbreak to 60 days after outbreak started); 
###############################################################################
###############################################################################
###C1 social_distancing
(admitted_social_distancing_90 =
    ggplot() +
    ylab ("Number of non-ICU inpatients with COVID-19 at SMH") +
    xlab ("Days since outbreak started\n(local transmission)") +
    geom_line(data = subset(modelresultssocial_distancing, time <= 90),
              aes(x = time, y = I_ch * smh_inpatients, group = social_distancing, colour = social_distancing),
              size = 1, show.legend = T) +
    theme_bw(base_size = 24) +
    theme(panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black")) +
    scale_x_continuous(breaks = seq(0, 90, by = 5)) +
    scale_y_continuous(breaks = seq(0, 1400, by = 200)) +
    # annotate("text", label = "50% cases detected & home isolation\n10% catchment area for this hospital",
    #          x = 1, y = 200, size = 5, colour = "black", hjust = 0)+
   scale_colour_gradientn(colors = c(low = "yellow", high = "red"), 
                          name = "Delay (in days) in initiating physical\n distancing from onset of outbreak") +
    # labs(colour="Delay (in days) in initiating physical\n distancing from onset of outbreak") +
    theme(legend.position = c(0, 1),
          legend.justification = c(-0.1, 1.8),
          legend.direction = "vertical") + ggtitle("C)")+
   geom_line(data = subset(default_results, time <= 90), 
             aes(x = time, y = I_ch * smh_inpatients, fill = "Default scenario"), size = 1, color = "black") +
   scale_fill_manual("", values=c(1),
                     guide=guide_legend(override.aes = list(colour=c("black"))))+
   guides(
     color = guide_colorbar(order = 1),
     fill = guide_legend(order = 0))
 ) 


ggsave("../fig/admitted_social_distancing_90.png", width = 12, height = 12)


###C2 drop_Reffective
(admitted_prob_drop_Reffective_90 = 
    ggplot() +
    ylab ("Number of non-ICU inpatients with COVID-19 at SMH") +  
    xlab ("Days since outbreak started\n(local transmission)") +
    geom_line(data = subset(modelresultsprob_drop_Reffective, time <= 90), 
              aes(x = time, y = I_ch * smh_inpatients, group = drop_Reffective* 100,  colour = drop_Reffective * 100),
              size = 1, show.legend = T) + 
    theme_bw(base_size = 24) + 
    theme(panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black")) +
    scale_x_continuous(breaks = seq(0, 90, by = 5)) +
    scale_y_continuous(breaks = seq(0, 1400, by = 200)) +
    # annotate("text", label = "50% cases detected & home isolation\n10% catchment area for this hospital", 
    #          x = 1, y = 200, size = 5, colour = "black", hjust = 0)+
    theme(legend.position = c(0, 1),
          legend.justification = c(-0.1, 1.8),
          legend.direction = "vertical")+ggtitle("B)")+
    scale_colour_gradientn(colors = c(low = "yellow", high = "red"), 
                           name = "% reduction in contact\n rates via social distancing,\n 30 days after outbreak starts") +
    geom_line(data = subset(default_results, time <= 90), 
              aes(x = time, y = I_ch * smh_inpatients, fill = "Default scenario"), size = 1, color = "black") +
    scale_fill_manual("", values=c(1),
                      guide=guide_legend(override.aes = list(colour=c("black"))))+
    guides(
      color = guide_colorbar(order = 1),
      fill = guide_legend(order = 0)))

ggsave("../fig/admitted_prob_drop_Reffective_90.png", width = 12, height = 12)



### (D) proportion of individuals with non-severe COVID-19 who are diagnosed and/or self-isolate (e.g. due to increase capacity in testing in the community).
###############################################################################
###############################################################################
###############################################################################
(admitted_prob_test_max_90 =
    ggplot() +
    ylab ("Number of non-ICU inpatients with COVID-19 at SMH") +
    xlab ("Days since outbreak started\n(local transmission)") +
    geom_line(data = subset(modelresultsprob_test_max, time <= 90),
              aes(x = time, y = I_ch * smh_inpatients, group = prob_test_max * 100, colour = prob_test_max * 100),
              size = 1, show.legend = T) +
    theme_bw(base_size = 24) +
    theme(panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black")) +
    scale_x_continuous(breaks = seq(0, 90, by = 5)) +
    scale_y_continuous(breaks = seq(0, 290, by = 40)) +
    # annotate("text", label = "50% cases detected & home isolation\n10% catchment area for this hospital",
    #          x = 1, y = 200, size = 5, colour = "black", hjust = 0)+
   scale_colour_gradientn(colors = c(low = "yellow", high = "red"), 
                          name = "% of non-severe COVID-19 cases \nwho are detected and/or self-isolate,\n 30 days after outbreak starts") +
    # labs(colour="% of non-severe COVID-19 cases\n who are detected and/or self-isolate") +
    theme(legend.position = c(0, 1),
          legend.justification = c(-0.1, 1.8),
          legend.direction = "vertical") +
 ggtitle("D)")+
   geom_line(data = subset(default_results, time <= 90), 
             aes(x = time, y = I_ch * smh_inpatients, fill = "Default scenario"), size = 1, color = "black") +
   scale_fill_manual("", values=c(1),
                     guide=guide_legend(override.aes = list(colour=c("black"))))+
   guides(
     color = guide_colorbar(order = 1),
     fill = guide_legend(order = 0)))

ggsave("../fig/admitted_prob_test_max_90.png", width = 12, height = 12)


grid.arrange(admitted_backCalc_90,
             admitted_prob_admit_90,
             admitted_social_distancing_90,
             admitted_prob_test_max_90, nrow = 2)


# 2800 2200






###############################################################################
###Appendix
###############################################################################
###R0 < 2.0 >= 2.0
(admitted_R0_L2.0_90 =
   ggplot() +
   ylab ("Number of non-ICU inpatients with COVID-19 at SMH") +
   xlab ("Days since outbreak started\n(local transmission)") +
   geom_line(data = subset(modelresultsR0, time <= 90 & R0 < 2.0),
             aes(x = time, y = I_ch * smh_inpatients, group = R0, colour = R0),
             size = 1, show.legend = T) +
   theme_bw(base_size = 24) +
   theme(panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         panel.background = element_blank(),
         axis.line = element_line(colour = "black")) +
   scale_x_continuous(breaks = seq(0, 90, by = 5)) +
   scale_y_continuous(breaks = seq(0, 35, by = 5)) +
   # annotate("text", label = "50% cases detected & home isolation\n10% catchment area for this hospital",
   #          x = 1, y = 200, size = 5, colour = "black", hjust = 0)+
   scale_colour_gradientn(colors = c(low = "yellow", high = "red"), 
                          name = "R0", breaks = c(1.4, 1.7, 1.9)) +
   # labs(colour="% of non-severe COVID-19 cases\n who are detected and/or self-isolate") +
   theme(legend.position = c(0, 1),
         legend.justification = c(-0.1, 1.8),
         legend.direction = "vertical") +
   ggtitle("C)")+
   # geom_line(data = subset(default_results, time <= 90), 
   #           aes(x = time, y = I_ch * smh_inpatients, fill = "Default scenario"), size = 1, color = "black") +
   # scale_fill_manual("", values=c(1),
   #                   guide=guide_legend(override.aes = list(colour=c("black"))))+
   guides(
     color = guide_colorbar(order = 1),
     fill = guide_legend(order = 0)))

ggsave("../fig/admitted_R0_L2.0_90.png", width = 12, height = 12)


###############################################################################
(admitted_R0_M2.0_90 =
    ggplot() +
    ylab ("Number of non-ICU inpatients with COVID-19 at SMH") +
    xlab ("Days since outbreak started\n(local transmission)") +
    geom_line(data = subset(modelresultsR0, time <= 90 & R0 >= 2.0),
              aes(x = time, y = I_ch * smh_inpatients, group = R0, colour = R0),
              size = 1, show.legend = T) +
    theme_bw(base_size = 24) +
    theme(panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black")) +
    scale_x_continuous(breaks = seq(0, 90, by = 5)) +
    # scale_y_continuous(breaks = seq(0, 290, by = 40)) +
    # annotate("text", label = "50% cases detected & home isolation\n10% catchment area for this hospital",
    #          x = 1, y = 200, size = 5, colour = "black", hjust = 0)+
    scale_colour_gradientn(colors = c(low = "yellow", high = "red"), 
                           name = "R0") +
    # labs(colour="% of non-severe COVID-19 cases\n who are detected and/or self-isolate") +
    theme(legend.position = c(0, 1),
          legend.justification = c(-0.1, 1.8),
          legend.direction = "vertical") +
    ggtitle("D)")+
    geom_line(data = subset(default_results, time <= 90), 
              aes(x = time, y = I_ch * smh_inpatients, fill = "Default scenario"), size = 1, color = "black") +
    scale_fill_manual("", values=c(1),
                      guide=guide_legend(override.aes = list(colour=c("black"))))+
    guides(
      color = guide_colorbar(order = 1),
      fill = guide_legend(order = 0)))

ggsave("../fig/admitted_R0_M2.0_90.png", width = 12, height = 12)


###############################################################################
(admitted_dur_admitted_90 =
    ggplot() +
    ylab ("Number of non-ICU inpatients with COVID-19 at SMH") +
    xlab ("Days since outbreak started\n(local transmission)") +
    geom_line(data = subset(modelresultsdur_admitted, time <= 90),
              aes(x = time, y = I_ch * smh_inpatients, group = dur_admitted, colour = dur_admitted),
              size = 1, show.legend = T) +
    theme_bw(base_size = 24) +
    theme(panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black")) +
    scale_x_continuous(breaks = seq(0, 90, by = 5)) +
    # scale_y_continuous(breaks = seq(0, 290, by = 40)) +
    # annotate("text", label = "50% cases detected & home isolation\n10% catchment area for this hospital",
    #          x = 1, y = 200, size = 5, colour = "black", hjust = 0)+
    scale_colour_gradientn(colors = c(low = "yellow", high = "red"), 
                           name = "Average length of non-ICU\n hospitalization (days)") +
    # labs(colour="% of non-severe COVID-19 cases\n who are detected and/or self-isolate") +
    theme(legend.position = c(0, 1),
          legend.justification = c(-0.1, 1.8),
          legend.direction = "vertical") +
    ggtitle("E)")+
    geom_line(data = subset(default_results, time <= 90), 
              aes(x = time, y = I_ch * smh_inpatients, fill = "Default scenario"), size = 1, color = "black") +
    scale_fill_manual("", values=c(1),
                      guide=guide_legend(override.aes = list(colour=c("black"))))+
    guides(
      color = guide_colorbar(order = 1),
      fill = guide_legend(order = 0)))

ggsave("../fig/admitted_dur_admitted_90.png", width = 12, height = 12)


###############################################################################
(admitted_prob_test_90 =
    ggplot() +
    ylab ("Number of non-ICU inpatients with COVID-19 at SMH") +
    xlab ("Days since outbreak started\n(local transmission)") +
    geom_line(data = subset(modelresultsprob_test, time <= 90),
              aes(x = time, y = I_ch * smh_inpatients, group = prob_test * 100, colour = prob_test * 100),
              size = 1, show.legend = T) +
    theme_bw(base_size = 24) +
    theme(panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black")) +
    scale_x_continuous(breaks = seq(0, 90, by = 5)) +
    # scale_y_continuous(breaks = seq(0, 290, by = 40)) +
    # annotate("text", label = "50% cases detected & home isolation\n10% catchment area for this hospital",
    #          x = 1, y = 200, size = 5, colour = "black", hjust = 0)+
    scale_colour_gradientn(colors = c(low = "yellow", high = "red"), 
                           name = "% of non-severe COVID-19 cases \nwho are detected and/or self-isolate,\n within 30 days after outbreak starts") +
    # labs(colour="% of non-severe COVID-19 cases\n who are detected and/or self-isolate") +
    theme(legend.position = c(0, 1),
          legend.justification = c(-0.1, 1.8),
          legend.direction = "vertical") +
    ggtitle("A)")+
    geom_line(data = subset(default_results, time <= 90), 
              aes(x = time, y = I_ch * smh_inpatients, fill = "Default scenario"), size = 1, color = "black") +
    scale_fill_manual("", values=c(1),
                      guide=guide_legend(override.aes = list(colour=c("black"))))+
    guides(
      color = guide_colorbar(order = 1),
      fill = guide_legend(order = 0)))

ggsave("../fig/admitted_prob_test_90.png", width = 12, height = 12)


grid.arrange(admitted_prob_test_90,
             admitted_prob_drop_Reffective_90,
             admitted_R0_L2.0_90,
             admitted_R0_M2.0_90,
             admitted_dur_admitted_90,
             ncol = 2)






###############################################################################
## Figure 6 ICU################################################################
###############################################################################

###############################################################################
### (A) seeding (proportion of population already infected with COVID-19 just at the start of the outbreak);
###############################################################################
(ICU_seed_backCalc_90 = 
   ggplot() +
   ylab ("Number of ICU inpatients with COVID-19 at SMH") +  
   xlab ("Days since outbreak started\n(local transmission)") +
   geom_line(data = subset(modelresultsseed_backCalc, time <= 90), 
             aes(x = time, y = I_cicu * smh_ICU, group = seed_prop * 100, colour = seed_prop * 100),
             size = 1, show.legend = T) + 
   theme_bw(base_size = 24) + 
   theme(panel.grid.major = element_blank(), 
         panel.grid.minor = element_blank(),
         panel.background = element_blank(),
         axis.line = element_line(colour = "black")) +
   scale_x_continuous(breaks = seq(0, 90, by = 5)) +
   scale_y_continuous(breaks = seq(0, 140, by = 20)) +
   # annotate("text", label = "50% cases detected & home isolation\n10% catchment area for this hospital", 
   #          x = 1, y = 200, size = 5, colour = "black", hjust = 0)+
   scale_colour_gradientn(colors = c(low = "yellow", high = "red"), 
                          name = expression("% of GTA with active\n infection at the start of the outbreak"^'a'),
                          limits = c(0.001, 0.005), 
                          labels = seq(0.001, 0.004, by = 0.0015), 
                          breaks =  seq(0.001, 0.004, by = 0.0015)) +
   # labs(colour= expression("% of GTA with active\n infection at the start of the outbreak"^'a'))+
   theme(legend.position = c(0, 1), 
         legend.justification = c(-0.1, 1.8),
         legend.direction = "vertical") + ggtitle("A)")+
   geom_line(data = subset(default_results, time <= 90), 
             aes(x = time, y = I_cicu * smh_ICU, fill = "Default scenario"), size = 1, color = "black") +
   scale_fill_manual("", values=c(1),
                     guide=guide_legend(override.aes = list(colour=c("black"))))+
   guides(
     color = guide_colorbar(order = 1),
     fill = guide_legend(order = 0)))


ggsave("../fig/ICU_seed_backCalc_90.png", width = 12, height = 12)




### (B) clinical severity (proportion of individuals infected with COVID-19 who require hospitalization) The influence of increasing or delayed start of interventions in the GTA on one hospital's surge: 
###############################################################################
(ICU_prob_admit_90 = 
   ggplot() +
   ylab ("Number of ICU inpatients with COVID-19 at SMH") +  
   xlab ("DDays since outbreak started\n(local transmission)") +
   geom_line(data = subset(modelresultsprob_admit, time <= 90), 
             aes(x = time, y = I_cicu * smh_ICU, group = prob_admit * 100, colour = prob_admit * 100),
             size = 1, show.legend = T) + 
   theme_bw(base_size = 24) + 
   theme(panel.grid.major = element_blank(), 
         panel.grid.minor = element_blank(),
         panel.background = element_blank(),
         axis.line = element_line(colour = "black")) +
   scale_x_continuous(breaks = seq(0, 90, by = 5)) +
   # scale_y_continuous(breaks = seq(0, 140, by = 10)) +
   # annotate("text", label = "50% cases detected & home isolation\n10% catchment area for this hospital", 
   #          x = 1, y = 200, size = 5, colour = "black", hjust = 0)+
   scale_colour_gradientn(colors = c(low = "yellow", high = "red"), 
                          name ="Proportion (%) with COVID-19\n who develop severe infection\n requiring hospital admission")+ scale_fill_continuous(guide = guide_legend()) +
   theme(legend.position = c(0, 1), 
         legend.justification = c(-0.1, 1.8),
         legend.direction = "vertical") + ggtitle("B)")+
   geom_line(data = subset(default_results, time <= 90), 
             aes(x = time, y = I_cicu * smh_ICU, fill = "Default scenario"), size = 1, color = "black") +
   scale_fill_manual("", values=c(1),
                     guide=guide_legend(override.aes = list(colour=c("black"))))+
   guides(
     color = guide_colorbar(order = 1),
     fill = guide_legend(order = 0)))


ggsave("../fig/ICU_prob_admit_90.png", width = 12, height = 12)



### (C) earlier or later initiation of physical distancing (from start of outbreak to 60 days after outbreak started); 
###############################################################################
###############################################################################
(ICU_social_distancing_90 =
   ggplot() +
   ylab ("Number of ICU inpatients with COVID-19 at SMH") +
   xlab ("Days since outbreak started\n(local transmission)") +
   geom_line(data = subset(modelresultssocial_distancing, time <= 90), 
             aes(x = time, y = I_cicu * smh_ICU, group = social_distancing, colour = social_distancing),
             size = 1, show.legend = T) +
   theme_bw(base_size = 24) +
   theme(panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         panel.background = element_blank(),
         axis.line = element_line(colour = "black")) +
   scale_x_continuous(breaks = seq(0, 90, by = 5)) +
   scale_y_continuous(breaks = seq(0, 450, by = 50)) +
   # annotate("text", label = "50% cases detected & home isolation\n10% catchment area for this hospital",
   #          x = 1, y = 200, size = 5, colour = "black", hjust = 0)+
   scale_colour_gradientn(colors = c(low = "yellow", high = "red"),
                          name = "Delay (in days) in initiating physical distancing\n from onset of outbreak") +
   theme(legend.position = c(0, 1),
         legend.justification = c(-0.1, 1.8),
         legend.direction = "vertical") + ggtitle("C)")+
   geom_line(data = subset(default_results, time <= 90), 
             aes(x = time, y = I_cicu * smh_ICU, fill = "Default scenario"), size = 1, color = "black") +
   scale_fill_manual("", values=c(1),
                     guide=guide_legend(override.aes = list(colour=c("black"))))+
   guides(
     color = guide_colorbar(order = 1),
     fill = guide_legend(order = 0)))

ggsave("../fig/ICU_social_distancing_90.png", width = 12, height = 12)


###C2 drop_Reffective
(ICU_prob_drop_Reffective_90 = 
    ggplot() +
    ylab ("Number of ICU inpatients with COVID-19 at SMH") +  
    xlab ("Days since outbreak started\n(local transmission)") +
    geom_line(data = subset(modelresultsprob_drop_Reffective, time <= 90), 
              aes(x = time, y = I_cicu * smh_ICU, group = drop_Reffective* 100,  colour = drop_Reffective * 100), 
              size = 1, show.legend = T) + 
    theme_bw(base_size = 24) + 
    theme(panel.grid.major = element_blank(), 
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black")) +
    scale_x_continuous(breaks = seq(0, 90, by = 5)) +
    scale_y_continuous(breaks = seq(0, 450, by = 50)) +
    # annotate("text", label = "50% cases detected & home isolation\n10% catchment area for this hospital", 
    #          x = 1, y = 200, size = 5, colour = "black", hjust = 0)+
    scale_colour_gradientn(colors = c(low = "yellow", high = "red"),
                           name = "% reduction in contact\n rates via social distancing,\n 30 days after outbreak starts") +
    # labs(colour="") +
    theme(legend.position = c(0, 1),
          legend.justification = c(-0.1, 1.8),
          legend.direction = "vertical") + ggtitle("F)")+
    geom_line(data = subset(default_results, time <= 90), 
              aes(x = time, y = I_cicu * smh_ICU, fill = "Default scenario"), size = 1, color = "black") +
    scale_fill_manual("", values=c(1),
                      guide=guide_legend(override.aes = list(colour=c("black"))))+
    guides(
      color = guide_colorbar(order = 1),
      fill = guide_legend(order = 0)))

ggsave("../fig/ICU_prob_drop_Reffective_90.png", width = 12, height = 12)




### (D) proportion of individuals with non-severe COVID-19 who are diagnosed and/or self-isolate (e.g. due to increase capacity in testing in the community).
###############################################################################
###############################################################################
###############################################################################
(ICU_prob_test_max_90 =
   ggplot() +
   ylab ("Number of ICU inpatients with COVID-19 at SMH") +
   xlab ("Days since outbreak started\n(local transmission)") +
   geom_line(data = subset(modelresultsprob_test_max, time <= 90),
             aes(x = time, y = I_cicu * smh_ICU, group = prob_test_max * 100, colour = prob_test_max * 100),
             size = 1, show.legend = T) +
   theme_bw(base_size = 24) +
   theme(panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         panel.background = element_blank(),
         axis.line = element_line(colour = "black")) +
   scale_x_continuous(breaks = seq(0, 90, by = 5)) +
   scale_colour_gradientn(colors = c(low = "yellow", high = "red"),
                          name = "% of non-severe COVID-19 cases \nwho are detected and/or self-isolate,\n 30 days after outbreak starts") +
   theme(legend.position = c(0, 1),
         legend.justification = c(-0.1, 1.8),
         legend.direction = "vertical")+ ggtitle("D)")+
   geom_line(data = subset(default_results, time <= 90), 
             aes(x = time, y = I_cicu * smh_ICU, fill = "Default scenario"), size = 1, color = "black") +
   scale_fill_manual("", values=c(1),
                     guide=guide_legend(override.aes = list(colour=c("black"))))+
   guides(
     color = guide_colorbar(order = 1),
     fill = guide_legend(order = 0)))


ggsave("../fig/ICU_prob_test_max_90.png", width = 12, height = 12)


grid.arrange(ICU_seed_backCalc_90,
             ICU_prob_admit_90,
             ICU_social_distancing_90,
             ICU_prob_test_max_90, nrow = 2)



###############################################################################
(ICU_dur_admitted_90 =
   ggplot() +
   ylab ("Number of ICU inpatients with COVID-19 at SMH") +
   xlab ("Days since outbreak started\n(local transmission)") +
   geom_line(data = subset(modelresultsdur_admitted, time <= 90),
             aes(x = time, y = I_cicu * smh_ICU, group = dur_admitted, colour = dur_admitted),
             size = 1, show.legend = T) +
   theme_bw(base_size = 24) +
   theme(panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         panel.background = element_blank(),
         axis.line = element_line(colour = "black")) +
   scale_x_continuous(breaks = seq(0, 90, by = 5)) +
   scale_colour_gradientn(colors = c(low = "yellow", high = "red"), 
                          name = "Average length of non-ICU\n hospitalization (days)") +
   # labs(colour="% of non-severe COVID-19 cases\n who are detected and/or self-isolate") +
   theme(legend.position = c(0, 1),
         legend.justification = c(-0.1, 1.8),
         legend.direction = "vertical") +
   ggtitle("F)")+
   geom_line(data = subset(default_results, time <= 90), 
             aes(x = time, y = I_cicu * smh_ICU, fill = "Default scenario"), size = 1, color = "black") +
   scale_fill_manual("", values=c(1),
                     guide=guide_legend(override.aes = list(colour=c("black"))))+
   guides(
     color = guide_colorbar(order = 1),
     fill = guide_legend(order = 0)))

ggsave("../fig/ICU_dur_admitted_90.png", width = 12, height = 12)



###############################################################################
###Appendix
(ICU_R0_L2.0_90 =
   ggplot() +
   ylab ("Number of ICU inpatients with COVID-19 at SMH") +
   xlab ("Days since outbreak started\n(local transmission)") +
   geom_line(data = subset(modelresultsR0, time <= 90 & R0 < 2.0),
             aes(x = time, y = I_cicu * smh_ICU, group = R0, colour = R0),
             size = 1, show.legend = T) +
   theme_bw(base_size = 24) +
   theme(panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         panel.background = element_blank(),
         axis.line = element_line(colour = "black")) +
   scale_x_continuous(breaks = seq(0, 90, by = 5)) +
   scale_y_continuous(breaks = seq(0, 12, by = 3)) +
   # annotate("text", label = "50% cases detected & home isolation\n10% catchment area for this hospital",
   #          x = 1, y = 200, size = 5, colour = "black", hjust = 0)+
   scale_colour_gradientn(colors = c(low = "yellow", high = "red"), 
                          name = "R0", breaks = c(1.4, 1.7, 1.9)) +
   # labs(colour="% of non-severe COVID-19 cases\n who are detected and/or self-isolate") +
   theme(legend.position = c(0, 1),
         legend.justification = c(-0.1, 1.8),
         legend.direction = "vertical") +
     ggtitle("G)")) #+


ggsave("../fig/ICU_R0_L2.0_90.png", width = 12, height = 12)


###############################################################################
(ICU_R0_M2.0_90 =
    ggplot() +
    ylab ("Number of ICU inpatients with COVID-19 at SMH") +
    xlab ("Days since outbreak started\n(local transmission)") +
    geom_line(data = subset(modelresultsR0, time <= 90 & R0 >= 2.0),
              aes(x = time, y = I_cicu * smh_ICU, group = R0, colour = R0),
              size = 1, show.legend = T) +
    theme_bw(base_size = 24) +
    theme(panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black")) +
    scale_x_continuous(breaks = seq(0, 90, by = 5)) +
    scale_y_continuous(breaks = seq(0, 900, by = 100)) +
    # annotate("text", label = "50% cases detected & home isolation\n10% catchment area for this hospital",
    #          x = 1, y = 200, size = 5, colour = "black", hjust = 0)+
    scale_colour_gradientn(colors = c(low = "yellow", high = "red"), 
                           name = "R0") +
    # labs(colour="% of non-severe COVID-19 cases\n who are detected and/or self-isolate") +
    theme(legend.position = c(0, 1),
          legend.justification = c(-0.1, 1.8),
          legend.direction = "vertical") +
    ggtitle("H)")+
    geom_line(data = subset(default_results, time <= 90), 
              aes(x = time, y = I_cicu * smh_ICU, fill = "Default scenario"), size = 1, color = "black") +
    scale_fill_manual("", values=c(1),
                      guide=guide_legend(override.aes = list(colour=c("black"))))+
    guides(
      color = guide_colorbar(order = 1),
      fill = guide_legend(order = 0)))

ggsave("../fig/ICU_R0_M2.0_90.png", width = 12, height = 12)








###############################################################################
table(modelout$dur_icu, exclude = NULL)
# modelresultsdur_icu= subset(modelout, dur_icu != unique(default_results$dur_icu))
# nrow(modelresultsdur_icu)
(ICU_dur_icu_90 =
    ggplot() +
    ylab ("Number of ICU inpatients with COVID-19 at SMH") +
    xlab ("Days since outbreak started\n(local transmission)") +
    geom_line(data = subset(modelresultsdur_icu, time <= 90),
              aes(x = time, y = I_cicu * smh_ICU, group = dur_icu, colour = dur_icu),
              size = 1, show.legend = T) +
    theme_bw(base_size = 24) +
    theme(panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black")) +
    scale_x_continuous(breaks = seq(0, 90, by = 5)) +
    # scale_y_continuous(breaks = seq(0, 290, by = 40)) +
    # annotate("text", label = "50% cases detected & home isolation\n10% catchment area for this hospital",
    #          x = 1, y = 200, size = 5, colour = "black", hjust = 0)+
    scale_colour_gradientn(colors = c(low = "yellow", high = "red"), 
                           name = "Average length of ICU admission (days)") +
    # labs(colour="% of non-severe COVID-19 cases\n who are detected and/or self-isolate") +
    theme(legend.position = c(0, 1),
          legend.justification = c(-0.1, 1.8),
          legend.direction = "vertical") +
    ggtitle("I)")+
    geom_line(data = subset(default_results, time <= 90), 
              aes(x = time, y = I_cicu * smh_ICU, fill = "Default scenario"), size = 1, color = "black") +
    scale_fill_manual("", values=c(1),
                      guide=guide_legend(override.aes = list(colour=c("black"))))+
    guides(
      color = guide_colorbar(order = 1),
      fill = guide_legend(order = 0)))

ggsave("../fig/ICU_dur_icu_90.png", width = 12, height = 12)



###############################################################################
table(modelout$condprob_icu, exclude = NULL)
modelresultscondprob_icu= subset(modelout, condprob_icu != unique(default_results$condprob_icu))
nrow(modelresultscondprob_icu)

(ICU_condprob_icu_90 =
    ggplot() +
    ylab ("Number of ICU inpatients with COVID-19 at SMH") +
    xlab ("Days since outbreak started\n(local transmission)") +
    geom_line(data = subset(modelresultscondprob_icu, time <= 90),
              aes(x = time, y = I_cicu * smh_ICU, group = condprob_icu * 100, colour = condprob_icu * 100),
              size = 1, show.legend = T) +
    theme_bw(base_size = 24) +
    theme(panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black")) +
    scale_x_continuous(breaks = seq(0, 90, by = 5)) +
    scale_y_continuous(breaks = seq(0, 270, by = 30)) +
    # annotate("text", label = "50% cases detected & home isolation\n10% catchment area for this hospital",
    #          x = 1, y = 200, size = 5, colour = "black", hjust = 0)+
    scale_colour_gradientn(colors = c(low = "yellow", high = "red"), 
                           name = "Proportion (%) with severe COVID-19 who require ICU care") +
    # labs(colour="% of non-severe COVID-19 cases\n who are detected and/or self-isolate") +
    theme(legend.position = c(0, 1),
          legend.justification = c(-0.1, 1.8),
          legend.direction = "vertical") +
    ggtitle("J)")+
    geom_line(data = subset(default_results, time <= 90), 
              aes(x = time, y = I_cicu * smh_ICU, fill = "Default scenario"), size = 1, color = "black") +
    scale_fill_manual("", values=c(1),
                      guide=guide_legend(override.aes = list(colour=c("black"))))+
    guides(
      color = guide_colorbar(order = 1),
      fill = guide_legend(order = 0)))

ggsave("../fig/ICU_condprob_icu_90.png", width = 12, height = 12)






###############################################################################
(ICU_prob_test_90 =
    ggplot() +
    ylab ("Number of ICU inpatients with COVID-19 at SMH") +
    xlab ("Days since outbreak started\n(local transmission)") +
    geom_line(data = subset(modelresultsprob_test, time <= 90),
              aes(x = time, y = I_cicu * smh_ICU, group = prob_test * 100, colour = prob_test * 100),
              size = 1, show.legend = T) +
    theme_bw(base_size = 24) +
    theme(panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.line = element_line(colour = "black")) +
    scale_x_continuous(breaks = seq(0, 90, by = 5)) +
    # scale_y_continuous(breaks = seq(0, 290, by = 40)) +
    # annotate("text", label = "50% cases detected & home isolation\n10% catchment area for this hospital",
    #          x = 1, y = 200, size = 5, colour = "black", hjust = 0)+
    scale_colour_gradientn(colors = c(low = "yellow", high = "red"), 
                           name = "% of non-severe COVID-19 cases \nwho are detected and/or self-isolate,\n within 30 days after outbreak starts") +
    # labs(colour="% of non-severe COVID-19 cases\n who are detected and/or self-isolate") +
    theme(legend.position = c(0, 1),
          legend.justification = c(-0.1, 1.8),
          legend.direction = "vertical") +
    ggtitle("E)")+
    geom_line(data = subset(default_results, time <= 90), 
              aes(x = time, y = I_cicu * smh_ICU, fill = "Default scenario"), size = 1, color = "black") +
    scale_fill_manual("", values=c(1),
                      guide=guide_legend(override.aes = list(colour=c("black"))))+
    guides(
      color = guide_colorbar(order = 1),
      fill = guide_legend(order = 0)))

ggsave("../fig/ICU_prob_test_90.png", width = 12, height = 12)

grid.arrange(ICU_seed_backCalc_90,
             ICU_prob_admit_90,
             ICU_social_distancing_90,
             ICU_prob_test_max_90,
             ICU_prob_test_90,
             ICU_prob_drop_Reffective_90,
             # ICU_dur_admitted_90,
             ncol = 2)

grid.arrange(ICU_R0_L2.0_90,
             ICU_R0_M2.0_90,
             ICU_dur_icu_90,
             ICU_condprob_icu_90,
             ncol = 2)
