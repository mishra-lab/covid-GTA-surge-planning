options(repos=c(CRAN='http://cran.rstudio.com/'))

install.packages('remotes')
remotes::install_github('rstudio/renv')
renv::restore()