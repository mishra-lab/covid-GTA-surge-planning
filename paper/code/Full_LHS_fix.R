#####################################################################
# Examine one paramter while sampling the range of all others via LHS
#####################################################################
###########################################################################################################################
## set up latin hypercube sampling of all variables except intervention = drop_Reffective, while holding
## the others at their default values
###########################################################################################################################

Full_LHS_fix<-function(var1,nSections_lhs,numbersParameters){
  
  #nSections_lhs=100
  #numbersParameters=nParmsVary
  #ParToManualFix <-"R0" #var1  #e.g. "R0" or "drop_Reffective"
  
  ParToManualFix <-var1
  
  #latin hypercube samples using uniform (0,1) across numbersParameters parameters
  set.seed(LHS_seed)  #for now, save seed
  #nSections_lhs  = 100  #number of samples
  X <- randomLHS(nSections_lhs,numbersParameters)
  
  #create a matrix with column headings for the parameter table (or maybe data frame?)
  Y <- matrix(0, nrow=nSections_lhs, ncol=numbersParameters)
  
  # create a vector of names for the matrix from the file of parameters we read in
  names_columns <- c()
  for (i in 1:numbersParameters) {
    names_columns <- append(names_columns, as.character(range_input$parameter[i]))
  }
  
  colnames(Y)<-names_columns
  index_manualfix = which(colnames(Y)==ParToManualFix)
  
  # for now, all are uniform so don't need a function, but might if some distributions are not uniform
  for (i in 1:numbersParameters){
    if (range_input$distribution[i]=="uniform" && i!=index_manualfix){
      Y[,i] <- qunif(X[,i],range_input$min[i],range_input$max[i])
    } else {
      Y[,i]<-rep(range_input$default[i],length(nSections_lhs))
    }
  }
  
  return(Y)  #returns the matrix of LHS sampled across the distributions; fixed otherwise including the one we wanted to manually fix
}