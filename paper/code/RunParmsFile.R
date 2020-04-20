#############################################################################################
# (1) can call in the parameter files,and save accordingly
# set up as a function RunParmsFile which has argument = the parameter file name in ""
# set up a function RunParmsFile_SampleImportCases if we want to vary sampling of travel-related cases
#############################################################################################
#############################################################################################
#############################################################################################
RunParmsFile<-function(Pfile){
  #  Pfile<-"ParmSet_Default"
  nameOfParmFile <- paste(Pfile,".csv",sep="")
  params_A  <-read.csv(nameOfParmFile,header=TRUE)
  names(params_A)[1]  <-"pSet"
  nSims2   <-nrow(params_A)

  out_all <-data.frame()
  
  for(i in 1:nSims2){
    out_each <-epid(parmlist=params_A[i,])
    out_all <-rbind(out_all,out_each)
  }
  
  currentDate <- Sys.Date()
  csvFileName <- paste(Pfile,currentDate,".csv",sep="")
  write.csv(out_all, file=csvFileName)
}
