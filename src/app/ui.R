# TODO: maybe there's a better way to do this? programatically import all ui parts necessary
import::from('./pages/surge-model/ui.R', surgeModelUI)
import::from('./pages/sensitivity/ui.R', sensitivityUI)

navbarPageWithInputs <- function(..., inputs) {
	navbar <- navbarPage(...)
	form <- tags$form(class = "navbar-form", inputs)
	navbar[[3]][[1]]$children[[1]] <- htmltools::tagAppendChild(
	navbar[[3]][[1]]$children[[1]], form)
	navbar
}

ui <- shiny::tagList(
	shinyjs::useShinyjs(),
	navbarPageWithInputs(
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
			sensitivityUI()),
		inputs=
			list(
				shiny::actionButton(
					'infoButton',
					icon=shiny::icon('info'),
					'Info'
				),
				'-', # separator
				shiny::actionButton(
					'codeButton',
					icon=shiny::icon('github'),
					'Code',
					onclick='window.open(\'https://github.com/mishra-lab/covid-GTA-surge-planning\', \'_blank\')'
				)
			)
			
	),
	shinyBS::bsModal(
		id='infoModal', 
		title='COVID-19 Healthcare Surge Model',
		trigger='infoButton',
		size='large',
		"This tool provides estimates of hospital and ICU admissions
		due to COVID-19 for hospitals in the Greater Toronto Area.
		The tool implements a parameterized mechanistic transmission
		model and can simulate a range of plausible scenarios 
		based on the provided input parameters.",
		br(), br(),
		"To run the model, visit the ", htmltools::tags$b("Run Model"), " tab and specify
		the parameters you want to model.",
		br(), br(),
		"To view the effect of changing particular parameters in
		the model, visit the ", htmltools::tags$b("Sensitivity Analysis"), " tab.",
		br(), br(),
		"To view this message again, click on the ", htmltools::tags$b("Info"), " tab.",
		br(), br(),
		"If you have used this tool for your work, please consider
		citing it: [TBD - Citation]" #TODO: add citation
	),
	hr(),
	shiny::div(
		style='text-align: center',
		'Created by the Mishra Modeling Team: ',
		shiny::HTML('<a href=\'https://mishra-lab.ca/\' target=\'_blank\'>https://mishra-lab.ca/</a>')
	),
	br()
)