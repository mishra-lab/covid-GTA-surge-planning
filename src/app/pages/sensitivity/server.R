import::from('./vm.R', readDefault, readSensitivity, generateHospSensitivityPlot, generateICUSensitivityPlot)

shinyjs::disable('popsize')

# Load sensitivity data
default <- shiny::reactive({readDefault()})
selectedParameter <- shiny::reactive({
	names(INPUT_PARAM_DESCRIPTIONS)[INPUT_PARAM_DESCRIPTIONS == input$parameterSelect]
})
sensData <- shiny::reactive({readSensitivity(selectedParameter(), default())})

# Generate sensitivity plots
hospPlot <- shiny::reactive({generateHospSensitivityPlot(input, selectedParameter(), sensData())})
ICUPlot <- shiny::reactive({generateICUSensitivityPlot(input, selectedParameter(), sensData())})
output$hospSensitivityPlot <- plotly::renderPlotly(hospPlot())
output$ICUSensitivityPlot <- plotly::renderPlotly(ICUPlot())

# Set sensitivity parameter range from user
output$paramRangeUI <- shiny::renderUI({
    req(sensData())

    paramMin <- min(sensData()[[selectedParameter()]])
    paramMax <- max(sensData()[[selectedParameter()]])

    do.call(shiny::sliderInput, list(
        'parameterRange',
        label=sprintf('parameter range', input$parameterSelect),
        value=c(paramMin, paramMax),
        min=paramMin,
        max=paramMax
    ))
})