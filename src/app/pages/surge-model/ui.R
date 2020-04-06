import::from(tidyr, '%>%')

hospitalParamsPanel <- function () {
	shiny::tabPanel('Hospital',
		shiny::br(),
		shiny::sliderInput(
			inputId = 'catchment_ED',
			label = 'catchment area for hospital re: ED visits',
			value = 0.1,
			min = 0,
			max = 1
		),
		shiny::sliderInput(
			inputId = 'catchment_hosp',
			label = 'catchment area for hospital re: hospitalizations',
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
			label = 'median number of ED vists per day',
			value = 56
		) 
	)
}

epidemiologyParamsPanel <- function () {
	shiny::tabPanel('Epidemiology',
		shiny::br(),
		shiny::numericInput(
			inputId = 'dur_latent',
			label = 'length of exposure (latent) period in days when infected but not infectious',
			value = 1.5
		),
		shiny::numericInput(
			inputId = 'dur_subclinical',
			label = 'duration (days) of subclinical prior to onset of clinical symptoms which would lead',
			value = 1.5
		),
		shiny::numericInput(
			inputId = 'dur_symptomatic',
			label = 'duration (days) symptomatic and infectious [if not isolated] when not severe prior to recovery',
			value = 6.0
		),
		shiny::numericInput(
			inputId = 'dur_admitted',
			label = 'duration (days) symptomatic and infectious [if not isolated] when hospitalized prior to recovery [and excluding those who died/ICU]',
			value = 8
		),
		shiny::numericInput(
			inputId = 'dur_icu',
			label = 'duration (days) symptomatic and infectious [if not isolated] in ICU prior to recovery [excluding those who died]',
			value = 8
		),
		shiny::sliderInput(
			inputId = 'prob_admit',
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
			label = 'R0 and Reffective',
			value = 2.4
		),
		shiny::numericInput(
			inputId = 'initpop',
			label = 'total population size',
			value = 6196731
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
			label = 'proportion of non-severe, symptomatic who get tested/detected or self-isolate without testing',
			value = 0.3,
			min = 0,
			max = 1
		),
		shiny::sliderInput(
			inputId = 'prop_travel_test',
			label = 'proportion of non-severe, symptomatic imported cases who will get tested/detected or self-isolate without testing',
			value = 0.5,
			min = 0,
			max = 1
		),
		shiny::sliderInput(
			inputId = 'drop_Reffective',
			label = 'by who much does social distancing reduce contact rates?',
			value = 0.2,
			min = 0,
			max = 1
		),
		shiny::numericInput(
			inputId = 'social_distancing',
			label = 'delay (days) in starting social distancing from start of outbreak',
			value = 20
		),
		shiny::sliderInput(
			inputId = 'tau_1',
			label = 'baseline proportion of non-severe who are tested if present to health-care facility or self-isolate',
			value = 0.02,
			min = 0,
			max = 1
		),
		shiny::sliderInput(
			inputId = 'tau_2',
			label = 'baseline proportion of hospitalized who are tested',
			value = 0.02,
			min = 0,
			max = 1
		),
		shiny::sliderInput(
			inputId = 'tau_1_max',
			label = 'maximum proportion tested among non-severe who present to health-care facility or self-isolate, after cases trigger increase in testing',
			value = 0.6,
			min = 0,
			max = 1
		),
		shiny::sliderInput(
			inputId = 'tau_2_max',
			label = 'maximum proportion tested among hospitalized, after cases trigger increase in testing',
			value = 0.9,
			min = 0,
			max = 1
		),
		shiny::numericInput(
			inputId = 'Ncases_trigger',
			label = 'number of cases detected (non-severe or severe) that trigger an increase in testing',
			value = 5
		),
		shiny::numericInput(
			inputId = 'event_ss',
			label = 'number of super-spreading events',
			value = 5
		),
		shiny::numericInput(
			inputId = 'event_ss_modulo',
			label = 'frequency of super-spreading events (e.g. every X days)',
			value = 11
		),
	)
}

ui <- fluidPage(
	shinyjs::useShinyjs(),
  	shiny::titlePanel('COVID-19 Healthcare Surge Model'),
	shiny::br(),
  
	shiny::sidebarLayout(
		shiny::sidebarPanel(
			shiny::h3('Modelling Parameters', style='margin-top: 0;'),
			shiny::tabsetPanel(
				hospitalParamsPanel(),
				epidemiologyParamsPanel(),
				interventionParamsPanel()
			)
		),
		
		shiny::mainPanel(
			shiny::wellPanel(
				shiny::h3('Modelling Output', style='margin-top: 0;'),
				plotly::plotlyOutput('modelPlot') %>% shinycssloaders::withSpinner(),
				shiny::br(),
				shiny::uiOutput('downloadUI')
			)
		)
	)
)