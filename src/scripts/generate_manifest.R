library(rsconnect)

rsconnect::writeManifest(
    appFiles=c(
        './app/app.R',
        './app/server.R',
        './app/ui.R',
        './model/covid_model_det.R',
        './model/epid.R',
        './model/vm.R'
    ),
    appPrimaryDoc='./app/app.R'
)