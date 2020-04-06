source('./ui.R')
source('./server.R')

shiny::shinyApp(ui = ui, server = server)