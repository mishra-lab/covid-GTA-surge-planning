library(shiny)
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

	output$modelout <- renderTable(modelout())
	output$mainplot <- renderPlotly(generatePlot(modelout_melted()))
}