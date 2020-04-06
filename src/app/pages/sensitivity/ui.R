ui <- fluidPage(
  	shiny::titlePanel('COVID-19 Healthcare Surge Model for Greater Toronto Area Hospitals'),
  	
	shiny::mainPanel(
		shiny::wellPanel(
			shiny::h3('Sensitivity Analysis', style='margin-top: 0;'),
			shiny::uiOutput('parameterTabs')
		)
	)
)