# TODO: maybe there's a better way to do this? programatically import all ui parts necessary
import::from('./pages/surge-model/ui.R', surgeModelUI)
import::from('./pages/sensitivity/ui.R', sensitivityUI)

ui <- shiny::tagList(
    shinyjs::useShinyjs(),
    shiny::navbarPage(
        id='navbar',
        theme='flatly.min.css',
        'COVID-19 Healthcare Surge Model',
        shiny::tabPanel(
            value='surge-model',
            icon=shiny::icon('play-circle'),
            'Run Model', 
            surgeModelUI()),
        shiny::tabPanel(
            value='sensitivity',
            icon=shiny::icon('chart-area'),
            'Sensitivity Analysis', 
            sensitivityUI())
    )
)