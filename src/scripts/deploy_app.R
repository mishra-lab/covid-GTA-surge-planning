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

# TODO: figure out why we can't bundle model outside of app
rsconnect::deployApp(
    appDir='./app',
    appName='covid-GTA-surge-planning',
    launch.browser=FALSE,
    logLevel='verbose'
)