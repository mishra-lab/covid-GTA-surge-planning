#################################################
# vm.R - View Model
# - Exposes functions to be used in server logic
#################################################

import::from('./model/epid.R', epid)
import::from('./utils.R', INPUT_PARAM_DESCRIPTIONS, OUTPUT_COLUMN_DESCRIPTIONS)

###FIXED############################################################################################
# number of days, eg. 300 days. fix interval = 1
times <- seq(0,300,1) 

###FIXED################ external (e.g. imported cases as a time series) ###########################
# @@@ imported cases read in from csv file = travel.csv, which comprise a linear extrapolation 
# we assume that imported cases continue via linear growth until our own epidemic peaks, thereafter zero imported cases
parm_import <- 'import_TO'
travel_read <- read.csv(file='./data/travel.csv', header=TRUE)
travel <- data.frame(times=times, import=rep(0, length(times)))
travel[2:nrow(travel),] <- data.frame(travel_read$times, travel_read[names(travel_read) == parm_import])
interp <- approxfun(travel, rule=2)  #create an interpolating function using approxfun
####################################################################################################

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# testing # [FIXED]
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# baseline proportion of non-severe who are tested if present to health-care facility or self-isolate
tau_1 <- 0.1     
# baseline proportion of hospitalized who are tested
tau_2 <- 0.6       
# maximum proportion tested among non-severe who present to health-care facility or self-isolate, after cases trigger increase in testing
tau_1_max <- 0.2
# maximum proportion tested among hospitalized, after cases trigger increase in testing
tau_2_max <- 0.9
# number of cases detected (non-severe or severe) that trigger an increase in testing
Ncases_trigger <- 31

setupParams <- function (input) {
	# duration of subclinical
	dur_subclinical = input$dur_incubation - input$dur_latent

	# duration of infectiousness
	dur_inf = dur_subclinical + input$dur_symptomatic

	# probability of admission among all infected
	prob_admit = input$prob_admit_diagnosed * input$prob_diagnosed

    # convert to transition rates
	beta = input$R0 / dur_inf                      # transmission probability per capita
	omega = 1 / input$dur_latent                   # latency rate from exposure to infectious per capita
	alpha = 1 / dur_subclinical              # progression rate from subclinical to clinical per capita
	g1 = 1 / input$dur_symptomatic                 # rate of recovery while symptomatic but not admitted
	g2 = 1 / input$dur_admitted                    # rate of recover/discharge while admitted
	g3 = 1 / input$dur_icu                         # rate of leaving ICU to medicine ward
	rate_icu = (-log(1 - input$condprob_icu) * g2) / ((1 + log(1 - input$condprob_icu))) #I think this is correct formula using prob admit to ICU, not my previous one
	death_rate = (-log(1 - input$condprob_cfr) * g3) /((1 + log(1 - input$condprob_cfr))) #I think this is the correct forumla using prob death among those in ICU, not my previous one
	length_of_stay = (1 / (g2 + rate_icu)) + (1 / (g3 + death_rate))   #average length of stay in days in hospital (admission + icu) [probably need to add those who returned from ICU, but ok for now

	##################################################################################
	# set parameter table as a matrix or data frame
	# the paramMat data.frame will be read in after being generated in another script
	##################################################################################
	paramMat = data.frame(
		beta,                     		# transmission probability per capita
		omega,                    		# latency rate from exposure to infectious per capita
		alpha,                    		# progression rate from subclinical to clinical per capita
		g1,                       		# rate of recovery while symptomatic but not admitted
		g2,                       		# rate of recover/discharge while admitted
		g3,                       		# rate of recovery/discharge while in icu
		prob_test = input$prob_test,                # probability of testing+detection once clinical symptoms
		prob_admit,              # probability of admission among all infected
		rate_icu,                 		# rate of icu admission once admitted
		death_rate,               		# disease-attributable mortality rate
		drop_Reffective = input$drop_Reffective,  # factor by who much Reffective drops after outbreak takes off
		R0 = input$R0,                       	  # included here for ease of adding to the outputs
		seed_backCalc = input$seed_backCalc,      # initial seeding number
		initpop = input$initpop,                  # popualtion size of Toronto
		prop_travel_test = input$prop_travel_test,         # proportion travelers with COVID + symptoms who get tested/detected
		social_distancing = input$social_distancing,       # time in days from seeding, when social distancing measures reduce beta by "drop_Reffective"
		tau_1,                    # probability of testing patients [who do not need to be admitted] in the absence of travel history or epidemiological link
		tau_2,                    # probability of testing inpatients for COVID in the absence of travel history or epidemiological link
		tau_1_max,                # increase rate to this probability of testing patients [who do not need to be admitted] in the absence of travel history or epidemiological link
		tau_2_max,                # increase rate to this probability of testing inpatients for COVID in the absence of travel history or epidemiological link. but probability will not be 100%
		when_test_increase = input$when_test_increase,	# days after oubtreak starts, when proportion detected or self-isolate increased via more case detection
		prob_test_max = input$prob_test_max,			# maximum proportion detected or self-isolate after time = when_test_increase
		length_of_stay,           # note, a calculated parameter that could also be calculated inside the model function
		Ncases_trigger,           # number of detected cases that triggers the rise in testing
		event_ss = input$event_ss,                 # number of super-spreading events
		event_ss_modulo = input$event_ss_modulo	        # frequency of super-spreading events
		# inpatient_bed_max = input$inpatient_bed_max,
		# ICU_bed_max = input$ICU_bed_max,
		# baseline_inpt_perday = input$baseline_inpt_perday,
		# baseline_ICUpt_perday = input$baseline_ICUpt_perday
	)

	paramMat
}

runSimulation <- function (paramMat) {
	modelOut <- epid(paramMat)

	######################################################################################################
	# calculate daily true incidence (from cumulative incidence [subtract from previous day] CumIncid_tot)
	# calculate daily detected cases (from cumulative diagnoses [subtract from previous day] Cumdx_tot)
	# calculate daily ED visits      (from cumulative ED vistis and cumulative admissions, CumED_ct and CumAdmit)
	######################################################################################################

	DailyTrueIncid   <- diff(modelOut$CumIncid_tot)
	DailyDetCases    <- diff(modelOut$Cumdx_tot)
	DailyED_notadmit <- diff(modelOut$CumED_ct)
	DailyED_admit    <- diff(modelOut$CumAdmit)

	DailyTrueIncid   <- c(0,DailyTrueIncid) 
	DailyDetCases    <- c(0,DailyDetCases)
	DailyED_notadmit <- c(0,DailyED_notadmit)
	DailyED_admit    <- c(0,DailyED_admit )

	DailyED_total    <- DailyED_notadmit + DailyED_admit

	modelOut$DailyTrueIncid <- DailyTrueIncid 
	modelOut$DailyDetCases  <- DailyDetCases
	modelOut$DailyED_total  <- DailyED_total

	modelOut$DailyED_total_hosp    <- modelOut$DailyED_total * input$catchment_ED
	modelOut$I_ch_hosp             <- modelOut$I_ch          * input$catchment_hosp
	modelOut$I_cicu_hosp           <- modelOut$I_cicu        * input$catchment_hosp

	modelOut
}

generatePlotData <- function (input, modelOut) {
	output_cityhosp <- tibble::tibble(
		time = modelOut$time,
		DailyTrueIncid = modelOut$DailyTrueIncid,
		DailyDetCases = modelOut$DailyDetCases,
		DailyED_total = modelOut$DailyED_total,
		I_ch = modelOut$I_ch,
		I_cicu = modelOut$I_cicu,
		DailyED_total_hosp = modelOut$DailyED_total_hosp,
		I_ch_hosp = modelOut$I_ch_hosp,
		I_cicu_hosp = modelOut$I_cicu_hosp,
		inpatient_bed_max = input$inpatient_bed_max,
		ICU_bed_max = input$ICU_bed_max
	)
	
	output_cityhosp
}

generateModelPlot <- function (modelOut) {
	fig <- plotly::plot_ly(modelOut, x=~time)
	fig <- fig %>% plotly::add_trace(
		y=~DailyED_total_hosp,
		name=OUTPUT_COLUMN_DESCRIPTIONS[['DailyED_total_hosp']],
		mode='lines', 
		type='scatter'
	)
	fig <- fig %>% plotly::add_trace(
		y=~I_ch_hosp,
		name=OUTPUT_COLUMN_DESCRIPTIONS[['I_ch_hosp']], 
		mode='lines', 
		type='scatter'
	)
	fig <- fig %>% plotly::add_trace(
		y=~I_cicu_hosp,
		name=OUTPUT_COLUMN_DESCRIPTIONS[['I_cicu_hosp']],
		mode='lines', 
		type='scatter'
	)
	fig <- fig %>% plotly::add_trace(
		y=~inpatient_bed_max,
		name=OUTPUT_COLUMN_DESCRIPTIONS[['inpatient_bed_max']],
		mode='lines', 
		type='scatter', 
		line=list(dash='dash')
	)
	fig <- fig %>% plotly::add_trace(
		y=~ICU_bed_max,
		name=OUTPUT_COLUMN_DESCRIPTIONS[['ICU_bed_max']],
		mode='lines', 
		type='scatter', 
		line=list(dash='dash')
	)
	# TODO: try to figure out optimal position of legend, based on
	# functions peaks?
	fig <- fig %>% plotly::layout(
		xaxis=list(title=OUTPUT_COLUMN_DESCRIPTIONS[['time']]),
		yaxis=list(title='Counts', hoverformat='.0f'),
		legend=list(
			orientation='v',
			x=0.7,
			y=0.9
		)
	)

	fig
}

# Reads default parameter settings for sensitivity analysis
readDefault <- function () {
	default <- read.csv('./data/default.csv')
	default
}

readSensitivity <- function (selectedParameter, default) {
	# Figure out which column to import based on selectedParameter
	header <- read.csv('./data/oneway_sensitivity.csv.gz', nrows=1, header=FALSE)
	selectedIdx <- which(header == selectedParameter)[[1]]
	chIdx <- which(header == 'I_ch')[[1]]
	cicuIdx <- which(header == 'I_cicu')[[1]]
	timeIdx <- which(header == 'time')[[1]]
	colClasses <- rep('NULL', length(header))

	colClasses[[selectedIdx]] <- NA
	colClasses[[chIdx]] <- NA
	colClasses[[cicuIdx]] <- NA
	colClasses[[timeIdx]] <- NA

	# Read data, importing only necessary columns
	data <- tibble::tibble(read.csv('./data/oneway_sensitivity.csv.gz', colClasses=colClasses))

	# Cut to 90 days, and remove default value of selectedParameter
	data <- data %>%
		dplyr::filter(time <= 90, data[[selectedParameter]] != unique(default[[selectedParameter]]))

	data
}

generateHospSensitivityPlot <- function (input, selectedParameter, data) {
	paramRange <- input$parameterRange

	if (!is.null(paramRange)) {
		data <- data %>% dplyr::filter(dplyr::between(data[[selectedParameter]], paramRange[[1]], paramRange[[2]]))
	}

	figHosp <- data %>%
		plotly::plot_ly(
			x=~time, 
			y=~I_ch * input$sens_catchment_hosp, 
			type='scatter',
			color=~data[[selectedParameter]],
			split=~data[[selectedParameter]],
			colors=c('yellow', 'red'), 
			mode='lines',
			showlegend=FALSE
		) %>%
		plotly::colorbar(
			title=''
		) %>%
		plotly::layout(
			xaxis=list(title='Days since outbreak started\n(local transmission)'),
			yaxis=list(title='Number of non-ICU inpatients with COVID-19 in catchment area', hoverformat='.0f')
		)

	figHosp
}

generateICUSensitivityPlot <- function (input, selectedParameter, data) {
	paramRange <- input$parameterRange

	if (!is.null(paramRange)) {
		data <- data %>% dplyr::filter(dplyr::between(data[[selectedParameter]], paramRange[[1]], paramRange[[2]]))
	}

	figICU <- data %>%
		plotly::plot_ly(
			x=~time, 
			y=~I_cicu * input$sens_catchment_ICU, 
			type='scatter',
			color=~data[[selectedParameter]],
			split=~data[[selectedParameter]],
			colors=c('yellow', 'red'), 
			mode='lines',
			showlegend=FALSE
		) %>%
		plotly::colorbar(
			title=''
		) %>%
		plotly::layout(
			xaxis=list(title='Days since outbreak started\n(local transmission)'),
			yaxis=list(title='Number of ICU inpatients with COVID-19 in catchment area', hoverformat='.0f')
		)

	figICU
}