import::from('../../utils.R', INPUT_PARAM_DESCRIPTIONS)

import::from(tidyr, '%>%')

sensitivityUI <- function () {
	ui <- fluidPage(
		shiny::sidebarLayout(
			shiny::sidebarPanel(
				shiny::h3('Model Parameters', style='margin-top: 0;'),
				br(),
				shiny::numericInput(
					inputId='popsize',
					label=INPUT_PARAM_DESCRIPTIONS[['initpop']],
					value=6196731,
					
				),
				shiny::sliderInput(
					inputId='sens_catchment_hosp',
					label=INPUT_PARAM_DESCRIPTIONS[['sens_catchment_hosp']],
					value=0.1,
					min=0,
					max=1
				),
				shiny::sliderInput(
					inputId='sens_catchment_ICU',
					label=INPUT_PARAM_DESCRIPTIONS[['sens_catchment_ICU']],
					value=0.1,
					min=0,
					max=1
				),
				shiny::numericInput(
					inputId = 'sens_inpatient_bed_max',
					label = INPUT_PARAM_DESCRIPTIONS[['sens_inpatient_bed_max']],
					value = 450
				),
				shiny::numericInput(
					inputId = 'sens_ICU_bed_max',
					label = INPUT_PARAM_DESCRIPTIONS[['sens_ICU_bed_max']],
					value = 30
				),
				shiny::selectInput(
					inputId='parameterSelect',
					label='parameter for plotting sensitivity analysis',
					c(
						INPUT_PARAM_DESCRIPTIONS[['seed_prop']],
						INPUT_PARAM_DESCRIPTIONS[['prob_admit']],
						INPUT_PARAM_DESCRIPTIONS[['drop_Reffective']],
						INPUT_PARAM_DESCRIPTIONS[['dur_admitted']],
						INPUT_PARAM_DESCRIPTIONS[['social_distancing']],
						INPUT_PARAM_DESCRIPTIONS[['prob_test_max']],
						INPUT_PARAM_DESCRIPTIONS[['R0']]
					)
				)
			),
			
			shiny::mainPanel(
				shiny::wellPanel(
					shiny::h3('Sensitivity Analysis Plot', style='margin-top: 0;'),
					br(),
					shiny::uiOutput('paramRangeUI'),
					plotly::plotlyOutput('hospSensitivityPlot') %>% shinycssloaders::withSpinner(),
					plotly::plotlyOutput('ICUSensitivityPlot') %>% shinycssloaders::withSpinner(),
				)
			)
		)
	)
}