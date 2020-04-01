library(rsconnect)

options(
    rsconnect.error.trace=TRUE
)

TOKEN <- Sys.getenv('SHINYAPPS_TOKEN')
SECRET <- Sys.getenv('SHINYAPPS_SECRET')

rsconnect::setAccountInfo(name='mishra-lab',
    token=TOKEN,
    secret=SECRET
)

rsconnect::deployApp(
    appDir='./app',
    # appFileManifest='./manifest',
    # appPrimaryDoc='./main.R',
    appName='covid-GTA-surge-planning',
    launch.browser=FALSE,
    logLevel='verbose'
)