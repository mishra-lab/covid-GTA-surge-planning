import::from('./vm.R', readSensitivity, generateSensitivityPlot)
import::from('./pages/sensitivity/ui.R', ui)

# Load ui components
output$pageStub <- shiny::renderUI(ui)

# generateSensitivityPlot('prob_test')
data <- shiny::reactive({readSensitivity(input)})
output$sensitivityPlot <- plotly::renderPlotly(generateSensitivityPlot(data()))