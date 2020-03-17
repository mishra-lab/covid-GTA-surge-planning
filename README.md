# covid-GTA-surge-planning
COVID-19 health-care surge model for Greater Toronto Area (GTA) and GTA-area hospitals (e.g. SMH)


## Running from source
If you haven't already, install the R `shiny` package: 

```R
install.packages('shiny')
```

Then, run the following to start a local `shiny` server:

```R
library(shiny)
runApp('src/app')
```