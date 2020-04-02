library(shiny)
library(shinyjs)
library(plotly)
library(dplyr)
library(reshape2)
library(ggplot2)

source('./model/vm.R')

# Define server logic ----
server <- function(input, output) {
	params <- reactive({setupParams(input)})
	modelout <- reactive({runSimulation(input, params())})

	observe({
		toggleState('downloadCSV', !is.null(modelout()))
	})

	output$mainplot <- renderPlotly(generatePlot(modelout()))
	output$downloadCSV <- downloadHandler(
		filename = 'model_results.csv',
		content = function(file) {
			write.csv(modelout(), file, row.names = FALSE)
		}
	)
}