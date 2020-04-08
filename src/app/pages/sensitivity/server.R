import::from('./vm.R', readDefault, readSensitivity, generateSensitivityPlot)
import::from('./utils.R', getNumberOfDecimals)

default <- shiny::reactive({readDefault()})
sensData <- shiny::reactive({readSensitivity(input, default())})
output$sensitivityPlot <- plotly::renderPlotly(generateSensitivityPlot(input, sensData()))

output$paramRangeUI <- shiny::renderUI({
    req(sensData())

    paramMin <- round(min(sensData()[[input$parameterSelect]]), digits=2)
    paramMax <- round(max(sensData()[[input$parameterSelect]]), digits=2)

    minDec <- getNumberOfDecimals(paramMin)
    maxDec <- getNumberOfDecimals(paramMax)

    # Adjust the min/max a little bit to show the full range in case of 
    # rounding error
    paramMin <- paramMin - 10 ^ (-minDec)
    paramMax <- paramMax + 10 ^ (-maxDec)

    do.call(shiny::sliderInput, list(
        'parameterRange',
        label=sprintf('%s: parameter range', input$parameterSelect),
        value=c(paramMin, paramMax),
        min=paramMin,
        max=paramMax
    ))
})