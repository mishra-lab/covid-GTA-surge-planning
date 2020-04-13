import::from('./vm.R', readDefault, readSensitivity, generateSensitivityPlot)

shinyjs::disable('popsize')

default <- shiny::reactive({readDefault()})
selectedParameter <- shiny::reactive({
	names(INPUT_PARAM_DESCRIPTIONS)[INPUT_PARAM_DESCRIPTIONS == input$parameterSelect]
})
sensData <- shiny::reactive({readSensitivity(selectedParameter(), default())})
output$sensitivityPlot <- plotly::renderPlotly(generateSensitivityPlot(input, selectedParameter(), sensData()))

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