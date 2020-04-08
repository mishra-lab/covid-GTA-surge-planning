server <- function (input, output, session) {
	observe({
		# Run each page's server code
		source('./pages/sensitivity/server.R', local=TRUE)
		source('./pages/surge-model/server.R', local=TRUE)
	})

	### TODO: remove
	shiny::updateTabsetPanel(session, 'navbar', 'sensitivity')
}