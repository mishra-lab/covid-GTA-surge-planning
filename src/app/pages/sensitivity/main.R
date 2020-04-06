import::from('./vm.R', getSensitivityPlots)
import::from('./pages/sensitivity/ui.R', ui)

# Load ui components
output$pageStub <- shiny::renderUI(ui)

# # Populate sensitivity analyses
output$parameterTabs <- shiny::renderUI({
	files <- getSensitivityPlots()

	tabs <- list()
	for (i in 1:length(files)) {
		f <- files[[i]]
		tabTitle <- gsub('admitted_(.*)_90.png', '\\1', f)
	
		# Create tabPanel containing the plot
		tabs[[i]] <- shiny::tabPanel(
			tabTitle,
			shiny::br(),
			shiny::img(
				src=f, 
				width='55%', 
				height='55%', 
				style='margin-left: auto; margin-right: auto; display: block;'
			)
		)
	}
	do.call(shiny::tabsetPanel, tabs)
})

# data <- read.csv('./data/test.csv', colClasses=c('NULL', NA, 'NULL', NA))
data <- read.csv('./data/oneway_sensitivity.csv.gz', nrows=1, header=FALSE)#, colClasses=c('NULL', NA, 'NULL', NA))
print(head(data))