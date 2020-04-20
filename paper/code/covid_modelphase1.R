# covid-19 health-care surge model for GTA & SMH
# initiated feb 28 2020
# last update mar 17, 2020
# version 1.10 Phase-1 Model
# deterministic
# this script calls the function, imports the travel-related cases, and runs the parameter files

# clear workspace
rm(list=ls(all.names=TRUE)) 

################ install & load all libraries/packages #########################

if(!"deSolve" %in% rownames(installed.packages())){
  install.packages("deSolve")
}

require(deSolve)

#################### call functions###################################
source("./covid_model_det.R")
source("./epid.R")
source("./RunParmsFile.R")
#############################################################################################
#################imported cases (travel-related) daily cases  ###############################
#############################################################################################
#############################################################################################
# set number of time steps and intervals in days (i.e. 300 days)
times <-seq(0,300,1) 

parm_import<-"import_TO"
travel_read <- read.csv(file="../data/travel.csv",header=TRUE)
travel <-data.frame(times=times,import=rep(0,length(times)))
travel[2:nrow(travel),]<-data.frame(travel_read$times,travel_read[names(travel_read)==parm_import])
input<-approxfun(travel,rule=2)  #create an interpolating function using approxfun

#############################################################################################
#############################################################################################
# Run function by calling in each parameter file we want to run
# If fixing the imported cases to "import_ON" from the travel.csv file, then use 
# RunParmsFile
# If varying the imported cases as per paramsForSampling, then use 
# RunParmsFile_SampleImportedCases
############################################################################################
RunParmsFile("../data/ParmSet_Default")
RunParmsFile("../data/OneWaySens_ParmList")
RunParmsFile("../data/LHS_int_fix_drop_Reffective")

