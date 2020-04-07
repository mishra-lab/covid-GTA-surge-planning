import::from('./vm.R', readSensitivity, generateSensitivityPlot)

# generateSensitivityPlot('prob_test')
data <- shiny::reactive({readSensitivity(input)})
output$sensitivityPlot <- plotly::renderPlotly(generateSensitivityPlot(data()))