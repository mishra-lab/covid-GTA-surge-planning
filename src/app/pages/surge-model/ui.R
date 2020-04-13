import::from(tidyr, '%>%')

hospitalParamsPanel <- function () {
	shiny::tabPanel('Hospital',
		shiny::br(),
		shiny::numericInput(
			inputId = 'initpop',
			label = 'total city population size',
			value = 6196731
		),
		shiny::sliderInput(
			inputId = 'catchment_ED',
			label = 'catchment area for hospital emergency department visits (relative to population size)',
			value = 0.1,
			min = 0,
			max = 1
		),
		shiny::sliderInput(
			inputId = 'catchment_hosp',
			label = 'catchment area for hospitalizations (relative to population size)',
			value = 0.1,
			min = 0,
			max = 1
		),
		shiny::numericInput(
			inputId = 'inpatient_bed_max',
			label = 'maximum inpatient bed capacity',
			value = 450
		),
		shiny::numericInput(
			inputId = 'ICU_bed_max',
			label = 'maximum ICU bed capacity',
			value = 30
		),
		shiny::numericInput(
			inputId = 'baseline_inpt_perday',
			label = 'median number of occupied hospital (non-ICU) beds per day',
			value = 400
		),
		shiny::numericInput(
			inputId = 'baseline_ICUpt_perday',
			label = 'median number of occupied hospital ICU beds per day',
			value = 26
		),
		shiny::numericInput(
			inputId = 'baseline_EDvisits_perday',
			label = 'median number of emergency department vists per day',
			value = 56
		) 
	)
}

epidemiologyParamsPanel <- function () {
	shiny::tabPanel('Epidemiology',
		shiny::br(),
		shiny::numericInput(
			inputId = 'dur_latent',
			label = 'duration (in days) of exposure (latent) period when infected but not infectious',
			value = 2.0
		),
		shiny::numericInput(
			inputId = 'dur_incubation',
			label = 'duration (in days) of subclinical but infectious [if not isolated] period, prior to onset of clinical symptoms',
			value = 5.2
		),
		shiny::numericInput(
			inputId = 'dur_symptomatic',
			label = 'duration (in days) of symptomatic and infectious [if not isolated] period when not severe, prior to recovery',
			value = 7.0
		),
		shiny::numericInput(
			inputId = 'dur_admitted',
			label = 'duration (in days) of symptomatic and infectious [if not isolated] period when hospitalized, prior to recovery [excluding those who died or in ICU]',
			value = 12
		),
		shiny::numericInput(
			inputId = 'dur_icu',
			label = 'duration (in days) of symptomatic and infectious [if not isolated] period in ICU, prior to recovery [excluding those who died]',
			value = 8
		),
		shiny::sliderInput(
			inputId = 'prob_diagnosed',
			label = 'proportion who are symptomatic',
			value = 0.55,
			min = 0,
			max = 1
		),
		shiny::sliderInput(
			inputId = 'prob_admit_diagnosed',
			label = 'proportion who are admitted to hospital among those infected',
			value = 0.1,
			min = 0,
			max = 1
		),
		shiny::sliderInput(
			inputId = 'condprob_icu',
			label = 'proportion who go to ICU if admitted to hospital',
			value = 0.08,
			min = 0,
			max = 1
		),
		shiny::sliderInput(
			inputId = 'condprob_cfr',
			label = 'proportion who die from COVID-19 if admitted to ICU',
			value = 0.4,
			min = 0,
			max = 1
		),
		shiny::numericInput(
			inputId = 'R0',
			label = 'R0',
			value = 2.4
		),
		shiny::numericInput(
			inputId = 'seed_backCalc',
			label = 'size of epidemic / community transmission prior to detection (seeding)',
			value = 100
		),
	)
}

interventionParamsPanel <- function () {
	shiny::tabPanel('Intervention',
		shiny::br(),
		shiny::sliderInput(
			inputId = 'prob_test',
			label = 'proportion of non-severe, symptomatic cases who get tested or self-isolate without testing',
			value = 0.1,
			min = 0,
			max = 1
		),
		shiny::sliderInput(
			inputId = 'prob_test_max',
			label = 'under increased case detection, proportion of non-severe, symptomatic cases who get tested or self-isolate without testing',
			value = 0.2,
			min = 0,
			max = 1
		),
		shiny::sliderInput(
			inputId = 'when_test_increase',
			label = 'on which day after the outbreak starts does case detection increase?',
			value = 40,
			min = 1,
			max = 300
		),
		shiny::sliderInput(
			inputId = 'prop_travel_test',
			label = 'proportion of non-severe, symptomatic imported cases who will get tested or self-isolate without testing',
			value = 0.5,
			min = 0,
			max = 1
		),
		shiny::sliderInput(
			inputId = 'drop_Reffective',
			label = 'by how much does social distancing reduce contact rates?',
			value = 0.2,
			min = 0,
			max = 1
		),
		shiny::numericInput(
			inputId = 'social_distancing',
			label = 'on which day after the outbreak starts does social distancing begin?',
			value = 20
		),
		shiny::numericInput(
			inputId = 'event_ss',
			label = 'number of super-spreading events',
			value = 5
		),
		shiny::numericInput(
			inputId = 'event_ss_modulo',
			label = 'number of days between super-spreading events',
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