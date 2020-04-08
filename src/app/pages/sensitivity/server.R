import::from('./vm.R', readDefault, readSensitivity, generateSensitivityPlot)

default <- shiny::reactive({readDefault()})
sensData <- shiny::reactive({readSensitivity(input, default())})
output$sensitivityPlot <- plotly::renderPlotly(generateSensitivityPlot(input, sensData()))

output$paramRangeUI <- shiny::renderUI({
    req(sensData())

    paramMin <- round(min(sensData()[[input$parameterSelect]]), digits=2)
    paramMax <- round(max(sensData()[[input$parameterSelect]]), digits=2)

    do.call(shiny::sliderInput, list(
        'parameterRange',
        label=sprintf('%s: parameter range', input$parameterSelect),
        value=c(paramMin, paramMax),
        min=paramMin,
        max=paramMax
    ))
})