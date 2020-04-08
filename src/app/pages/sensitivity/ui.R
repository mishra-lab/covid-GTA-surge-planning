import::from(tidyr, '%>%')

sensitivityUI <- function () {
	ui <- fluidPage(
		shiny::sidebarLayout(
			shiny::sidebarPanel(
				shiny::h3('Model Parameters', style='margin-top: 0;'),
				br(),
				shiny::sliderInput(
					'catchmentProp',
					'catchment area for hospital',
					value=0.1,
					min=0,
					max=1
				),
				shiny::selectInput(
					'parameterSelect',
					'parameter for plotting sensitivity analysis',
					c(
						'prob_test',
						'prob_admit',
						'R0'
					)
				)
			),
			
			shiny::mainPanel(
				shiny::wellPanel(
					shiny::h3('Sensitivity Analysis Plot', style='margin-top: 0;'),
					br(),
					shiny::uiOutput('paramRangeUI'),
					plotly::plotlyOutput('sensitivityPlot') %>% shinycssloaders::withSpinner(),
				)
			)
		)
	)
}