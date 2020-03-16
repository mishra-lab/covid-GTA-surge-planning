library(shiny)

# Define UI for app that draws a histogram ----
ui <- fluidPage(
  # App title ----
  titlePanel("COVID-19 health-care surge model for GTA and GTA-area hospitals"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      sliderInput(
        inputId = 'catchment_ED',
        label = 'catchment area for hospital re: ED visits',
        value = 0.1,
        min = 0,
        max = 1
      ),
      sliderInput(
        inputId = 'catchment_hosp',
        label = 'catchment area for hospital re: hospitalizations',
        value = 0.1,
        min = 0,
        max = 1
      ),
      numericInput(
        inputId = 'inpatient_bed_max',
        label = 'maximum inpatient bed capacity',
        value = 450
      ),
      numericInput(
        inputId = 'ICU_bed_max',
        label = 'maximum ICU bed capacity',
        value = 30
      ),
      numericInput(
        inputId = 'baseline_inpt_perday',
        label = 'median number of occupied hospital (non-ICU) beds per day',
        value = 400
      ),
      numericInput(
        inputId = 'baseline_ICUpt_perday',
        label = 'median number of occupied hospital ICU beds per day',
        value = 26
      ),
      numericInput(
        inputId = 'baseline_EDvisits_perday',
        label = 'median number of ED vists per day',
        value = 56
      )
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel()
  )
)