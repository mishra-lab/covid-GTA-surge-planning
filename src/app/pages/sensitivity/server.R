import::from('./vm.R', readSensitivity, generateSensitivityPlot)

data <- shiny::reactive({readSensitivity(input)})
output$sensitivityPlot <- plotly::renderPlotly(generateSensitivityPlot(data(), input))