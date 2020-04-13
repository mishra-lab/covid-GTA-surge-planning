import::from('../../utils.R', INPUT_PARAM_DESCRIPTIONS)

import::from(tidyr, '%>%')

hospitalParamsPanel <- function () {
	shiny::tabPanel('Hospital',
		shiny::br(),
		shiny::numericInput(
			inputId = 'initpop',
			label = INPUT_PARAM_DESCRIPTIONS[['initpop']],
			value = 6196731
		),
		shiny::sliderInput(
			inputId = 'catchment_ED',
			label = INPUT_PARAM_DESCRIPTIONS[['catchment_ED']],
			value = 0.1,
			min = 0,
			max = 1
		),
		shiny::sliderInput(
			inputId = 'catchment_hosp',
			label = INPUT_PARAM_DESCRIPTIONS[['catchment_hosp']],
			value = 0.1,
			min = 0,
			max = 1
		),
		shiny::numericInput(
			inputId = 'inpatient_bed_max',
			label = INPUT_PARAM_DESCRIPTIONS[['inpatient_bed_max']],
			value = 450
		),
		shiny::numericInput(
			inputId = 'ICU_bed_max',
			label = INPUT_PARAM_DESCRIPTIONS[['ICU_bed_max']],
			value = 30
		),
		shiny::numericInput(
			inputId = 'baseline_inpt_perday',
			label = INPUT_PARAM_DESCRIPTIONS[['baseline_inpt_perday']],
			value = 400
		),
		shiny::numericInput(
			inputId = 'baseline_ICUpt_perday',
			label = INPUT_PARAM_DESCRIPTIONS[['baseline_ICUpt_perday']],
			value = 26
		),
		shiny::numericInput(
			inputId = 'baseline_EDvisits_perday',
			label = INPUT_PARAM_DESCRIPTIONS[['baseline_EDvisits_perday']],
			value = 56
		) 
	)
}

epidemiologyParamsPanel <- function () {
	shiny::tabPanel('Epidemiology',
		shiny::br(),
		shiny::numericInput(
			inputId = 'dur_latent',
			label = INPUT_PARAM_DESCRIPTIONS[['dur_latent']],
			value = 2.0
		),
		shiny::numericInput(
			inputId = 'dur_incubation',
			label = INPUT_PARAM_DESCRIPTIONS[['dur_incubation']],
			value = 5.2
		),
		shiny::numericInput(
			inputId = 'dur_symptomatic',
			label = INPUT_PARAM_DESCRIPTIONS[['dur_symptomatic']],
			value = 7.0
		),
		shiny::numericInput(
			inputId = 'dur_admitted',
			label = INPUT_PARAM_DESCRIPTIONS[['dur_admitted']],
			value = 12
		),
		shiny::numericInput(
			inputId = 'dur_icu',
			label = INPUT_PARAM_DESCRIPTIONS[['dur_icu']],
			value = 8
		),
		shiny::sliderInput(
			inputId = 'prob_diagnosed',
			label = INPUT_PARAM_DESCRIPTIONS[['prob_diagnosed']],
			value = 0.55,
			min = 0,
			max = 1
		),
		shiny::sliderInput(
			inputId = 'prob_admit_diagnosed',
			label = INPUT_PARAM_DESCRIPTIONS[['prob_admit_diagnosed']],
			value = 0.1,
			min = 0,
			max = 1
		),
		shiny::sliderInput(
			inputId = 'condprob_icu',
			label = INPUT_PARAM_DESCRIPTIONS[['condprob_icu']],
			value = 0.08,
			min = 0,
			max = 1
		),
		shiny::sliderInput(
			inputId = 'condprob_cfr',
			label = INPUT_PARAM_DESCRIPTIONS[['condprob_cfr']],
			value = 0.4,
			min = 0,
			max = 1
		),
		shiny::numericInput(
			inputId = 'R0',
			label = INPUT_PARAM_DESCRIPTIONS[['R0']],
			value = 2.4
		),
		shiny::numericInput(
			inputId = 'seed_backCalc',
			label = INPUT_PARAM_DESCRIPTIONS[['seed_backCalc']],
			value = 100
		),
	)
}

interventionParamsPanel <- function () {
	shiny::tabPanel('Intervention',
		shiny::br(),
		shiny::sliderInput(
			inputId = 'prob_test',
			label = INPUT_PARAM_DESCRIPTIONS[['prob_test']],
			value = 0.1,
			min = 0,
			max = 1
		),
		shiny::sliderInput(
			inputId = 'prob_test_max',
			label = INPUT_PARAM_DESCRIPTIONS[['prob_test_max']],
			value = 0.2,
			min = 0,
			max = 1
		),
		shiny::sliderInput(
			inputId = 'when_test_increase',
			label = INPUT_PARAM_DESCRIPTIONS[['when_test_increase']],
			value = 40,
			min = 1,
			max = 300
		),
		shiny::sliderInput(
			inputId = 'prop_travel_test',
			label = INPUT_PARAM_DESCRIPTIONS[['prop_travel_test']],
			value = 0.5,
			min = 0,
			max = 1
		),
		shiny::sliderInput(
			inputId = 'drop_Reffective',
			label = INPUT_PARAM_DESCRIPTIONS[['drop_Reffective']],
			value = 0.2,
			min = 0,
			max = 1
		),
		shiny::numericInput(
			inputId = 'social_distancing',
			label = INPUT_PARAM_DESCRIPTIONS[['social_distancing']],
			value = 20
		),
		shiny::numericInput(
			inputId = 'event_ss',
			label = INPUT_PARAM_DESCRIPTIONS[['event_ss']],
			value = 5
		),
		shiny::numericInput(
			inputId = 'event_ss_modulo',
			label = INPUT_PARAM_DESCRIPTIONS[['event_ss_modulo']],
			value = 11
		),
	)
}

surgeModelUI <- function () {
	ui <- fluidPage(
		shiny::sidebarLayout(
			shiny::sidebarPanel(
				shiny::h3('Modeling Parameters', style='margin-top: 0;'),
				shiny::tabsetPanel(
					hospitalParamsPanel(),
					epidemiologyParamsPanel(),
					interventionParamsPanel()
				)
			),
			
			shiny::mainPanel(
				shiny::wellPanel(
					shiny::h3('Modeling Output', style='margin-top: 0;'),
					plotly::plotlyOutput('modelPlot') %>% shinycssloaders::withSpinner(),
					shiny::br(),
					shiny::uiOutput('downloadUI')
				)
			)
		)
	)

	ui
}