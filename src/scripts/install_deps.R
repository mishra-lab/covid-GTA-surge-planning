options(repos=c(CRAN='http://cran.rstudio.com/'))

install.packages('devtools')
install.packages('packrat')

packrat::restore()
devtools::install_github('rstudio/rsconnect')