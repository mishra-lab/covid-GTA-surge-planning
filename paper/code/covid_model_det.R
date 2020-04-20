# COVID model Phase-1
# updated March 15, 2020
# function defines a model with ODE, that gets called into the solver


###############################################################################
# define model (10 states, each with differential equation, plus 2 additional 'tracking' states)
covid_model_det<-function(t,x,parms){ 
  
  # name all the state-variables in ODE but also 
  # include calculated state-variables (e.g. N_contact) so that can
  # use within the model function to change parameters conditional on the value of a state-variable as well
  
  # ODE variables
  S             <-x[1]
  E             <-x[2]
  I_sc          <-x[3]      
  I_c           <-x[4]    
  I_ct          <-x[5]    
  I_ch          <-x[6]   
  I_cicu        <-x[7]    
  death         <-x[8]  
  R             <-x[9]  
  R_ct          <-x[10]
  
  # calculated state-variables
  N_contact     <-x[11]  # N_contact = S + E + I_sc + I_c + R + R_ct. denominator for contact rate is everyone who is not in isolation. #R and R_ct contribute to herd immunity
  N             <-x[12]   # N = <- S + E + I_sc + I_c + I_ct + I_ch + I_cicu + R + R_ct +death
  CumIncid      <-x[13]
  Cum_import    <-x[14]                 
  Cum_ss        <-x[15]                
  CumIncid_tot  <-x[16]
  CumED_ct      <-x[17]
  CumAdmit      <-x[18]
  CumICU        <-x[19]  
  Cumdx_ct      <-x[20]
  Cumdx_admicu  <-x[21]
  Cumdx_tot     <-x[22]
  
  with(as.list(parms),{
    
    ############# set up time-variant parameters#####################
    
    # contact rate reflected in beta changing over time, currently just a one-step change
    if (t>=social_distancing){
      beta <-beta*(1-drop_Reffective)
      R0   <-R0*(1-drop_Reffective)  #note, we use R0 within the function to denote the reproductive rate after epidemic starts
    }
    
    # proportion/probablity of testing among non-hospitalized and among hospitalized if have COVID19, triggered by Ncases detected
    if(Cumdx_tot>= Ncases_trigger ) {  
      tau_1 <- tau_1_max
      tau_2 <- tau_2_max
    }
    
    # super-spreading events, which occur at a regular frequency for now, and which stop once reproductive rate drops to <1
    
    if(t%%event_ss_modulo <2 && (R0*(S/N_contact)>1)){
      event_ss <- event_ss*1
    }else {
      event_ss <-0
    }
    
    ############# external (or imported) cases ######################nb: imported cases immediately subtracted from S
    imported <-input(t)
    
    #################################################################  
    #coupled ODE ####################################################
    #################################################################
    # susceptible
    dS<-  -S*beta  *(I_sc + I_c) /(S + E + I_sc + I_c + R + R_ct)                                                  -imported  -event_ss                                          
    # exposed/latent
    dE<-   S*beta  *(I_sc + I_c)/(S + E + I_sc + I_c + R + R_ct)   - omega*E                                                  +event_ss
    # infectious, subclinical
    dI_sc <-                                  omega*E    - alpha*I_sc
    # infectious, clinical not detected
    dI_c <-                                                alpha*(1-prob_test)*(1-prob_admit)*I_sc   -g1*I_c       +imported*(1-prop_travel_test)*(1-prob_admit)
    # infected, clinical, detected
    dI_ct <-                                               alpha*prob_test*(1-prob_admit)*I_sc       -g1*I_ct      +imported*(prop_travel_test)*(1-prob_admit)
    # infected, clinical, detected, admitted
    dI_ch <-   - rate_icu*I_ch                            +alpha*prob_admit*I_sc                     -g2*I_ch      +g3*I_cicu +imported*(prob_admit)
    # infected, clinical, detected, icu
    dI_cicu <- rate_icu*I_ch  - death_rate*I_cicu                                                    -g3*I_cicu
    # death state
    ddeath <- death_rate*I_cicu
    # recovered, never detected
    dR <- g1*I_c
    # recovered, detected [nb: proportion of I_ct only detected] and did not die
    dR_ct <-g1*I_ct + g2*I_ch 
    
    ##########################################################################################################################
    ######################## other states we want to keep track of but could also do outside of solver
    ######################## these below make the model runs slower, so later we can just do outside solver but easier for now
    ##########################################################################################################################
    # sum of states in denominator for contacts that could lead to transmission
    dN_contact<-dS + dE + dI_sc + dI_c + dR + dR_ct
    # sum of total population including death
    dN<-dS + dE + dI_sc + dI_c + dI_ct + dI_ch + dI_cicu + dR + dR_ct +ddeath
    
    ###### cumulative incidence of cases ######
    # cumulative incidence (total cases, as well as for tPAF), not including imported cases and not including super-spreading events
    dCumIncid <- S*beta  *(I_sc + I_c) /(S + E + I_sc + I_c + R + R_ct)
    # cumulative imported cases
    dCum_import <- imported
    # cumuliatve super-spreading events
    dCum_ss     <- event_ss
    # cumulative incidence total
    dCumIncid_tot <- dCumIncid + dCum_import + dCum_ss
    
    ###### cumulative incidence of admissions ######
    # cumulative ED/assessment visits (incidence)
    dCumED_ct <-  alpha*prob_test*(1-prob_admit)*I_sc + imported*(prop_travel_test)*(1-prob_admit)
    # cumulative hospital admissions (incidence)
    dCumAdmit <- alpha*prob_admit*I_sc                + imported*(prob_admit)
    # cumulative ICU admissions (incidence)
    dCumICU   <- rate_icu*I_ch
    
    # cumulative diagnosed but not admitted
    dCumdx_ct <- (-log(1-tau_1)/(1/g1))* I_ct # I_ct*((tau_1 * g1)/(1-tau_1))  # rate of testing within I_ct before leaving I_ct = ((tau_1 * g1)/(1-tau_1))
    # cumulative diagnosed and admitted (diagnosed at or during admission and prior to death; assume all who died were already diagnosed or dx at death)
    dCumdx_admicu <- (-log(1-tau_2)/length_of_stay)*(I_ch + I_cicu)  #rate of testing while admitted in hospital but prior to death or discharge = log(1-tau_2)/length_of_stay 
    # cumulative diagnosed total (non-hosptialized and hosptialized)
    dCumdx_tot    <- dCumdx_ct + dCumdx_admicu
    
    ##################################################################
    #return results [everything we want to capture]###################
    #so output has to have an initial value, including CumIncid#######
    ##################################################################  
    results <-c(dS,                #x[1]
                dE,                #x[2]
                dI_sc,             #x[3]
                dI_c,              #x[4]
                dI_ct,             #x[5]
                dI_ch,             #x[6]
                dI_cicu,           #x[7]
                ddeath,            #x[8]
                dR,                #x[9]
                dR_ct,             #x[10] 
                dN_contact,        #x[11]
                dN,                #x[12]
                dCumIncid,         #x[13]
                dCum_import,       #x[14]
                dCum_ss,           #x[15]
                dCumIncid_tot,     #x[16]
                dCumED_ct,         #x[17]
                dCumAdmit,         #x[18]
                dCumICU,           #x[19]
                dCumdx_ct,         #x[20]
                dCumdx_admicu,     #x[21]
                dCumdx_tot         #x[22]
    )
    list(results)
  }) 
}

##########################################################################
##########################################################################
