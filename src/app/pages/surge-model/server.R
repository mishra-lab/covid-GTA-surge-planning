import::from('./vm.R', setupParams, runSimulation, generatePlotData, generateModelPlot)

# Server functionality
inputParams <- shiny::reactive({
	# Validate input
	shiny::validate(
		shiny::need(
			input$prob_test_max > input$prob_test, 
			'Proportion of testing under increased case detection must be greater than regular proportion of testing!'
		)
	)
	setupParams(input)
})
modelOut <- shiny::reactive({runSimulation(inputParams())})
plotData <- shiny::reactive({generatePlotData(input, modelOut())})
output$modelPlot <- plotly::renderPlotly(generateModelPlot(plotData()))

# Create button for downloading CSV; displayed only when modelout
# is computed
output$downloadUI <- shiny::renderUI({
	req(plotData())
	do.call(shiny::downloadButton, list('downloadCSV', 'Download model output as CSV'))
})

output$downloadCSV <- shiny::downloadHandler(
	filename = 'model_results.csv',
	content = function(file) {
		write.csv(plotData(), file, row.names = FALSE)
	}
)