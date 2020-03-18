library(shiny)
library(shinyjs)
library(plotly)
library(dplyr)
library(reshape2)
library(ggplot2)

source('../model/vm.R')

# Define server logic ----
server <- function(input, output) {
	params <- reactive({setupParams(input)})
	modelout <- reactive({runSimulation(input, params())})

	modelout_melted <- reactive({
		modelout() %>% melt(id.vars = 'time', variable.name = 'series')
	})

	observe({
		toggleState('downloadCSV', !is.null(modelout()))
	})

	# output$modelout <- renderTable(modelout())
	output$mainplot <- renderPlotly(generatePlot(modelout_melted()))
	output$downloadCSV <- downloadHandler(
		filename = 'model_results.csv',
		content = function(file) {
			write.csv(modelout(), file, row.names = FALSE)
		}
	)
}