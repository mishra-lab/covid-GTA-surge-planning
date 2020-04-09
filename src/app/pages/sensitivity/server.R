import::from('./vm.R', readDefault, readSensitivity, generateSensitivityPlot)
import::from('./utils.R', getNumberOfDecimals)

default <- shiny::reactive({readDefault()})
sensData <- shiny::reactive({readSensitivity(input, default())})
output$sensitivityPlot <- plotly::renderPlotly(generateSensitivityPlot(input, sensData()))

output$paramRangeUI <- shiny::renderUI({
    req(sensData())

    paramMin <- min(sensData()[[input$parameterSelect]])
    paramMax <- max(sensData()[[input$parameterSelect]])

    do.call(shiny::sliderInput, list(
        'parameterRange',
        label=sprintf('%s: parameter range', input$parameterSelect),
        value=c(paramMin, paramMax),
        min=paramMin,
        max=paramMax
    ))
})