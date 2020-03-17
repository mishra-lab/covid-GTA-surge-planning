library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)

source('../model/vm.R')

# Define server logic ----
server <- function(input, output) {
	params <- reactive({setupParams(input)})
	modelout <- reactive({runSimulation(input, params())})
	
	output$modelout <- renderTable(modelout())
	output$mainplot <- renderPlotly(
		ggplotly(
			ggplot(modelout(), aes(time)) + 
			# theme(text = element_text(size=15)) + 
			geom_line(aes(y=I_ch_hosp, colour='I_ch_hosp')) + 
			geom_line(aes(y=I_cicu_hosp, colour='I_cicu_hosp')) + 
			geom_line(aes(y=DailyED_total_hosp, colour='DailyED_total_hosp'))
		)
	)
}