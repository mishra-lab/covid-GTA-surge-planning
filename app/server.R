library(shiny)

source('../model/vm.R')

# Define server logic ----
server <- function(input, output) {
	params <- reactive({setupParams(input)})
	modelout <- reactive({runSimulation(params())})
	
	output$params <- renderTable(params())
	output$modelout <- renderTable(modelout())
}