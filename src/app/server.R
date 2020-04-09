server <- function (input, output, session) {
	shinyBS::toggleModal(session, 'infoModal', toggle='open')

	shiny::observe({
		# Run each page's server code
		source('./pages/sensitivity/server.R', local=TRUE)
		source('./pages/surge-model/server.R', local=TRUE)
	})
}