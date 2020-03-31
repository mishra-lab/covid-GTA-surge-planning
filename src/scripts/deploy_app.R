library(rsconnect)

rsconnect::deployApp(
    appFileManifest='./manifest.json',
    appPrimaryDoc='./app/app.R',
    appName='covid-GTA-surge-planning',
    launch.browser=FALSE
)