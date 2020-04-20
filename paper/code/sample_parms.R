###########################################
### sample parameters for covid model######
### version 1.3 ########################### 
### Mar 16, 2020 ##########################
### includes parameter validity checks ####
###########################################
# clear workspace
rm(list=ls(all.names=TRUE)) 
###########################################

###########################################
# call packages
###########################################

if(!"lhs" %in% rownames(installed.packages())){
  install.packages("lhs")
}

require(lhs)

###########################################
# call functions
###########################################
source("./Full_LHS_fix.R")
source("./makeParmFile.R")

###########################################
# set lhs seed
# note that in the parameter file outputs, 
# the LHS_seed number is included, even if not used (e.g. for one-way sensitivity analysis)
LHS_seed    = 2091
###########################################

###########################################
# input parameters in clinical & epi terms#
###########################################

# read in the file with parameter name, distribution, and range/values for sampling
range_input<-read.csv("../data/parametersForSampling.csv", header=TRUE)
nParmsVary = length(range_input$parameter)  #make sure no "extra" rows

names_columns <- c()  #get the column names for matrices that will be made for the parameter sets
for (i in 1:nParmsVary) {
  names_columns <- append(names_columns, as.character(range_input$parameter[i]))
}


#############################################
# DEFAULT EPIDEMIC ONLY
#############################################
# set up a parameter data.frame for default
# parameter set as per parametersForSampling
#############################################

ParmSet_Default <- matrix(0, nrow=1, ncol=nParmsVary)
colnames(ParmSet_Default)<-names_columns

for(i in 1:nParmsVary){
  ParmSet_Default[,i]<-range_input$default[i]
}

#############################################
# ONE WAY SENSITIVITY ANALYSIS
#############################################
# set up a parameter data.frame for one-way 
# sensitivity analyses across every key 
# parameter,while holding the others at their 
# default values
###############################################

nSections = 10  #number of samples for the one-way sensitivity analysis
Sens_1way <- matrix(0, nrow=0, ncol=nParmsVary)
colnames(Sens_1way)<-names_columns

for(i in 1:nParmsVary){
  S_0 <- matrix(0, nrow=nSections, ncol=nParmsVary)
  if(range_input$OneWay[i]=="Y"){
    S_0[,i] <-seq(range_input$min[i],range_input$max[i],length.out = nSections)
      for(j in 1:nParmsVary){
        if(j!=i){
        S_0[,j]<-rep(range_input$default[j],length(nSections))
      }
   }
  Sens_1way<-rbind(Sens_1way,S_0)
  }
}


#####################################################################
# Examine one paramter while sampling the range of all others via LHS
#####################################################################
###########################################################################################################################
## set up latin hypercube sampling of all variables except intervention = drop_Reffective, while holding
## the others at their default values
###########################################################################################################################

LHS_int_fix <-Full_LHS_fix(var1="drop_Reffective",nSections_lhs=200,numbersParameters=nParmsVary)

#################convert matrices of parameters into data frames#########################
# eg ParmRunName = "LHS_int_fix"
#########################################################################################

makeParmFile(C=ParmSet_Default,"../data/ParmSet_Default")
makeParmFile(C=Sens_1way,"../data/OneWaySens_ParmList")
makeParmFile(C=LHS_int_fix,"../data/LHS_int_fix_drop_Reffective")



