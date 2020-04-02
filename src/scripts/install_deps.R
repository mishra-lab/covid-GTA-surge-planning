options(repos=c(CRAN='http://cran.rstudio.com/'))

install.packages('remotes')
install.packages('packrat')

# TODO: switch to renv, so we can pull installed packages from global lib
renv::restore()
remotes::install_github('rstudio/rsconnect')