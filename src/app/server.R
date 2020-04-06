server <- function (input, output, session) {
	validPages <- c('home', 'surge-model', 'sensitivity')
	names(validPages) <- c('Home', 'Surge Model', 'Sensitivity Analysis')
	headerStr <- ''

	# Build up header HTML
	for (i in 1:length(validPages)) {
		headerStr <- paste(
			headerStr, 
			sprintf(
				'<a href="?%s">%s</a><br>', 
				validPages[[i]],
				names(validPages)[[i]]
			)
		)
	}

	# Render header and page
	output$stub <- shiny::renderUI(shiny::tagList(
		shiny::fluidPage(
			shiny::fluidRow(
				shiny::HTML('<h3>', headerStr, '</h3>')
			),
			shiny::uiOutput('pageStub')
		)
	))

	# Parse query string
	pageName <- shiny::isolate(session$clientData$url_search)
	pageName <- substr(pageName, 2, nchar(pageName))
	if (pageName == '') {
		pageName <- 'home'
	}
	
	# 404 if page not found
	if (!pageName %in% validPages) {
		pageName <- 'not-found'
	}

	# Render matching page UI
	source(sprintf('./pages/%s/main.R', pageName), local=TRUE)
}