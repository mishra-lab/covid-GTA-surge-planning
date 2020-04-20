
#####################################################################################
# Function makeParmFile --> now calculate the parameters which require conversion
#####################################################################################
#################convert matrices of parameters into data frames#########################
# eg ParmRunName = "LHS_int_fix"
#########################################################################################


makeParmFile <- function(C,ParmRunName) {
  A = data.frame(C)
  #   A = data.frame(ParmSet_Default)
  ################################### calculated parameters ##########################################
  ##duration of subclinical
  A$dur_subclinical = A$dur_incubation - A$dur_latent
  ##duration of infectiousness
  A$dur_inf = A$dur_subclinical + A$dur_symptomatic
  ##convert to transition rates
  A$beta   =A$R0 / A$dur_inf                    # transmission probability per capita
  A$omega  =1/A$dur_latent                      # latency rate from exposure to infectious per capita
  A$alpha  =1/A$dur_subclinical                 # progression rate from subclinical to clinical per capita
  A$g1     =1/A$dur_symptomatic                 # rate of recovery while symptomatic but not admitted
  A$g2     =1/A$dur_admitted                    # rate of recover/discharge while admitted
  A$g3     =1/A$dur_icu                         # rate of leaving ICU to medicine ward
  A$rate_icu    = (-log(1-A$condprob_icu)*A$g2) / ((1+log(1-A$condprob_icu))) 
  A$death_rate  = (-log(1-A$condprob_cfr)*A$g3) /((1+log(1-A$condprob_cfr)))  
  ##generate length of stay for the probability of testing while admitted
  A$length_of_stay = (1/(A$g2 + A$rate_icu)) + (1/(A$g3+A$death_rate))        #average length of stay in days in hospital (admission + icu) [probably need to add those who returned from ICU, but ok for now
  A$parm_import    =ifelse(A$import_travel==1,"import_ON","import_BC")        #which imported time-series we want to use, from travel.csv
  
  A$prob_admit    = A$prob_admit_diagnosed * A$prob_diagnosed                    #calculate prob_admit (among all infected)
  
  ########### validity check serial interval #########################
  A$min_SI_calc    = A$dur_incubation - A$dur_subclinical     # minimum serial interval calculated from parameters 
  A$max_SI_calc    = A$dur_symptomatic + A$dur_incubation     # maximum serial interval calculated from parameters
  A$valid_si_check = FALSE #set to remove as a boolean
  
  SI_bound_lower =range_input$min[range_input$parameter=="serial_interval"] 
  SI_bound_upper =range_input$max[range_input$parameter=="serial_interval"]
  
  for(i in 1:nrow(A)){
    if(A$min_SI_calc[i] < SI_bound_upper && A$max_SI_calc[i] > SI_bound_lower){
      A$valid_si_check[i] <-TRUE      
    }
  }
  
  ########### validity check CFR among those diagnosed ###############
  A$validity_cfr_among_dx<-A$prob_admit_diagnosed * A$condprob_icu * A$condprob_cfr
  A$valid_cfr_check <-FALSE  # set to remove as a boolean
  
  cfr_bound_lower =range_input$min[range_input$parameter=="cfr_among_dx"]
  cfr_bound_upper =range_input$max[range_input$parameter=="cfr_among_dx"]
  
  for(i in 1:nrow(A)){
    if(A$validity_cfr_among_dx[i] > cfr_bound_lower && A$validity_cfr_among_dx[i] < cfr_bound_upper){
      A$valid_cfr_check[i] <-TRUE      
    }
  }
  
  
  ########### validity check tau_1_max, tau_2_max, prob_test_max ###############
  A$prob_test_max_valid = (A$prob_diagnosed - A$prob_admit)/(1-A$prob_admit)           #calculate the prob_test_max and prob_test that would be valid
  
  A$valid_prob_test_max_check <-TRUE
  for(i in 1:nrow(A)){
    if(A$prob_test_max[i] > A$prob_test_max_valid[i]){
      A$valid_prob_test_max_check[i] <-FALSE
    }
  }
  
  A$valid_tau_1_check <-TRUE    
  for(i in 1:nrow(A)){
    if(A$tau_1_max[i] < A$tau_1[i]){
      A$valid_tau_1_check[i] <-FALSE
    }
  }
  
  A$valid_tau_2_check <-TRUE    
  for(i in 1:nrow(A)){
    if(A$tau_2_max[i] < A$tau_2[i]){
      A$valid_tau_2_check[i] <-FALSE
    }
  }
  
  A$valid_prob_test_check <-TRUE    
  for(i in 1:nrow(A)){
    if(A$prob_test_max[i] < A$prob_test[i]){
      A$valid_prob_test_check[i] <-FALSE
    }
  }
  
  ################################create a variable that stores if all validity checks are TRUE ##############
  A$valid_keep = FALSE
  for(i in 1:nrow(A)){
    if(A$valid_si_check[i]==TRUE    &&
       A$valid_cfr_check[i]==TRUE   &&
       A$valid_prob_test_max_check[i]==TRUE  &&
       A$valid_tau_1_check[i]==TRUE &&
       A$valid_tau_2_check[i]==TRUE &&
       A$valid_prob_test_check[i] == TRUE){
      A$valid_keep[i] = TRUE        
    }
  }
  

A_keep <- A[A$valid_keep=="TRUE",]  #remove the parameter sets that do not pass validity check

############## export a parameter file to be read into the covid_model ##############################################
A_keep$LHS_seed = LHS_seed    # save the seed used in LHS, even though only used for the LHS samples
write.csv(A_keep,file=paste(ParmRunName,".csv",sep=""))   
}
