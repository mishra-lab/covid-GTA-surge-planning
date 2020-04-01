library(rsconnect)

options(
    rsconnect.error.trace=TRUE
)

rsconnect::deployApp(
    appDir='./app',
    # appFileManifest='./manifest',
    # appPrimaryDoc='./main.R',
    appName='covid-GTA-surge-planning',
    launch.browser=FALSE,
    logLevel='verbose'
)