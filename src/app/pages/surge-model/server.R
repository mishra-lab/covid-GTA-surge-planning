import::from('./vm.R', setupParams, runSimulation, generateModelPlot)

# Validate input
shiny::validate(
	shiny::need(input$prob_test_max > input$prob_test, 'Increased case detection must be greater than proportion who get tested!')
)

# Server functionality
params <- shiny::reactive({setupParams(input)})
modelout <- shiny::reactive({runSimulation(input, params())})
output$modelPlot <- plotly::renderPlotly(generateModelPlot(modelout()))

# Create button for downloading CSV; displayed only when modelout
# is computed
output$downloadUI <- shiny::renderUI({
	req(modelout())
	do.call(shiny::downloadButton, list('downloadCSV', 'Download model output as CSV'))
})

output$downloadCSV <- shiny::downloadHandler(
	filename = 'model_results.csv',
	content = function(file) {
		write.csv(modelout(), file, row.names = FALSE)
	}
)