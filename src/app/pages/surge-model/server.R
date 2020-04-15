import::from('./vm.R', setupParams, runSimulation, generatePlotData, generateModelPlot)
import::from('./utils.R', swap_kv, OUTPUT_COLUMN_DESCRIPTIONS)

import::from(tidyr, '%>%')
import::from(dplyr, rename)

# Server functionality
inputParams <- shiny::reactive({
	# Validate input
	shiny::validate(
		shiny::need(
			input$prob_test_max >= input$prob_test, 
			'Proportion of testing under increased case detection must be greater than or equal to regular proportion of testing!'
		),
		shiny::need(
			input$dur_incubation > input$dur_latent,
			'Duration of incubation period must be greater than duration of latent period!'
		)
	)
	setupParams(input)
})
modelOut <- shiny::reactive({runSimulation(inputParams())})
plotData <- shiny::reactive({generatePlotData(input, modelOut())})
output$modelPlot <- plotly::renderPlotly(generateModelPlot(plotData()))

# Create button for downloading CSV; displayed only when plotData
# is computed
output$downloadUI <- shiny::renderUI({
	req(plotData())
	do.call(shiny::downloadButton, list('downloadCSV', 'Download model output as CSV'))
})

output$downloadCSV <- shiny::downloadHandler(
	filename = 'model_results.csv',
	content = function(file) {
		outputData <- plotData() %>% rename(!!! swap_kv(OUTPUT_COLUMN_DESCRIPTIONS))
		write.csv(outputData, file, row.names = FALSE)
	}
)