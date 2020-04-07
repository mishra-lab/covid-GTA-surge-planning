import::from('./ui.R', validPages)

server <- function (input, output, session) {
	# Parse query string
	pageName <- shiny::isolate(session$clientData$url_search)
	pageName <- substr(pageName, 2, nchar(pageName))
	if (pageName == '') {
		pageName <- 'home'
	} else if (!pageName %in% validPages) {
		 # 404 if page not found
		pageName <- 'not-found'
	}

	# Make selected tab active
	for (p in validPages) {
		code = sprintf('document.getElementById("%s").classList.remove("active")', p)
		shinyjs::runjs(code = code)
	}

	if (pageName != 'home') {
		code = sprintf('document.getElementById("%s").classList.add("active")', pageName)
		shinyjs::runjs(code = code)
	}

	# Render matching page UI
	source(sprintf('./pages/%s/main.R', pageName), local=TRUE)
}