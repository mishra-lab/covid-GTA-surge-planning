library(shiny)

options(
    shiny.autoreload = TRUE, # TODO: figure out why this doesn't work...
    shiny.autoreload.pattern = glob2rx("*.R"),
    shiny.launch.browser = TRUE
)
runApp('../app')