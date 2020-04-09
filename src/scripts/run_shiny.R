library(shiny)

options(
    shiny.autoreload = TRUE,
    shiny.autoreload.pattern = glob2rx("*.R"),
    shiny.launch.browser = TRUE
)
runApp('./app')