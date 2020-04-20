# COVID model
# Updated March 15, 2020
# epid function, which sets the initial conditions [based on parmlist] and calls the solver to run the model



###################################################################################################
epid <-function(parmlist)
{
  #list the inital values for each state-variable and each ODE model output (e.g. Cummulative Incidence, etc.)
  xstart_fxn<-c(
    S  = parmlist$initpop - parmlist$seed_backCalc, #seed_fxn), #susceptible, initpop - seeds
    E  = 0,                        #latent, exposed and infected, not infectious
    I_sc =0.5*(parmlist$seed_backCalc),              #infectious, subclinical      
    I_c  =0.5*(parmlist$seed_backCalc),              #infectious, symptomatic, not in isolation
    I_ct =0,                       #infected, detected, in isolation at home
    I_ch =0,                       #infected, detected, in isolation in hospital
    I_cicu =0,                     #infected, detected, in isolation in ICU
    death = 0,                     #track number of deaths
    R     = 0,                     #recovered, never detected
    R_ct  = 0,                     #recovered after isolation or hospitalization and now at home
    N_contact = parmlist$initpop,
    N = parmlist$initpop,
    CumIncid=0,                    #cumulative incidence of infection, excluding imported cases and superspreading events
    Cum_import =0,                 #cumulative incidence imported cases 
    Cum_ss =0,                     #cumulative incidence super spreading events
    CumIncid_tot=0,                #total cumulative incidence
    CumED_ct=0,                      #cumulative incidence of ED visit
    CumAdmit=0,                    #cumulative incidence of admission to hospital
    CumICU=0,                      #cumulative incidence of admission to ICU
    Cumdx_ct=0,                    #cumulative incidence of diagnoses among those in I_ct (home isolation or diagnosed but not admitted)
    Cumdx_admicu=0,                #cumulative incidence of diagnoses among those admitted or in ICU before death or discharge
    Cumdx_tot =0                   #cumulative incidence of diagnoses among those not-admitted and among those admitted or in ICU before death or discharge
    
  )  
  
  out_fxn <- as.data.frame(lsoda(xstart_fxn,times,covid_model_det,parmlist))  #run the model
  out_fxn <- merge(out_fxn, parmlist)                                         #merge the parmlist with model outputs
  return(out_fxn)
}

