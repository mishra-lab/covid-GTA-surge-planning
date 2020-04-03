library(shiny)
library(shinyjs)
library(plotly)
library(dplyr)
library(reshape2)
library(ggplot2)

source('./model/vm.R')

server <- function(input, output) {
	# Run model and generate plot
	params <- reactive({setupParams(input)})
	modelout <- reactive({runSimulation(input, params())})
	output$modelPlot <- renderPlotly(generateModelPlot(modelout()))

	# Add model results for download
	observe({
		toggleState('downloadCSV', !is.null(modelout()))
	})
	output$downloadCSV <- downloadHandler(
		filename = 'model_results.csv',
		content = function(file) {
			write.csv(modelout(), file, row.names = FALSE)
		}
	)

	# Populate sensitivity analyses
	output$parameterTabs <- renderUI({
		files <- getSensitivityPlots()
		
		tabs <- list()
		for (i in 1:length(files)) {
			f <- files[[i]]
			tabTitle <- gsub('admitted_(.*)_90.png', '\\1', f)
			
			# Create tabPanel containing the plot
			tabs[[i]] <- tabPanel(
				tabTitle,
				br(),
				img(
					src=f, 
					width='55%', 
					height='55%', 
					style='margin-left: auto; margin-right: auto; display: block;'
				)
			)
		}
		do.call(tabsetPanel, tabs)
	})
}