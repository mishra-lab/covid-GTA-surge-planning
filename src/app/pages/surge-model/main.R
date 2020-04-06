import::from('./vm.R', setupParams, runSimulation, generateModelPlot)
import::from('./pages/surge-model/ui.R', ui)

# Load ui components
output$pageStub <- shiny::renderUI(ui)

# Server functionality
params <- shiny::reactive({setupParams(input)})
modelout <- shiny::reactive({runSimulation(input, params())})
output$modelPlot <- plotly::renderPlotly(generateModelPlot(modelout()))

# Add model results for download
shiny::observe({
	# shinyjs::toggleState('downloadCSV', !is.null(modelout()))
	# print(modelout())
})
output$downloadCSV <- shiny::downloadHandler(
	filename = 'model_results.csv',
	content = function(file) {
		write.csv(modelout(), file, row.names = FALSE)
	}
)