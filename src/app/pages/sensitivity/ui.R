import::from(tidyr, '%>%')

ui <- fluidPage(
  	shiny::titlePanel('COVID-19 Healthcare Surge Model: Sensitivity Analysis'),
	shiny::br(),

	shiny::sidebarLayout(
		shiny::sidebarPanel(
			shiny::h3('Model Parameters', style='margin-top: 0;'),
			shiny::selectInput(
				'parameterSelect',
				'Select a parameter for the sensitivity analysis',
				c('prob_test')
			)
		),
		
		shiny::mainPanel(
			shiny::wellPanel(
				shiny::h3('Sensitivity Analysis Plot', style='margin-top: 0;'),
				plotly::plotlyOutput('sensitivityPlot') %>% shinycssloaders::withSpinner(),
			)
		)
	)
)