#################################################
# vm.R - View Model
# - Exposes functions to be used in server logic
#################################################
library(plotly)
library(dplyr)
library(reshape2)
library(ggplot2)

source('./model/epid.R')

###FIXED############################################################################################
# number of days, eg. 300 days. fix interval = 1
times <-seq(0,300,1) 

###FIXED################ external (e.g. imported cases as a time series) ###########################
travel <- data.frame(times=times,import=rep(2,length(times))) #create an empty time-series of travel-related/imported cases
travel$import <- ifelse(travel$times>15,3,2)  #fill in the time-series of travel-related/imported cases
interp<- approxfun(travel,rule=2)  #create an interpolating function using approxfun
####################################################################################################

setupParams <- function (input) {
	# duration of infectiousness
	dur_inf = input$dur_subclinical + input$dur_symptomatic

    # convert to transition rates
	beta = input$R0 / dur_inf                      # transmission probability per capita
	omega = 1 / input$dur_latent                   # latency rate from exposure to infectious per capita
	alpha = 1 / input$dur_subclinical              # progression rate from subclinical to clinical per capita
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
		prob_admit = input$prob_admit,               # probability of admission once symptomatic (assuming also tested)
		rate_icu,                 		# rate of icu admission once admitted
		death_rate,               		# disease-attributable mortality rate
		drop_Reffective = input$drop_Reffective,          # factor by who much Reffective drops after outbreak takes off
		R0 = input$R0,                       # included here for ease of adding to the outputs
		seed_backCalc = input$seed_backCalc,            # initial seeding number
		initpop = input$initpop,                  # popualtion size of Toronto
		prop_travel_test = input$prop_travel_test,         # proportion travelers with COVID + symptoms who get tested/detected
		social_distancing = input$social_distancing,        # time in days from seeding, when social distancing measures reduce beta by "drop_Reffective"
		tau_1 = input$tau_1,                    # probability of testing patients [who do not need to be admitted] in the absence of travel history or epidemiological link
		tau_2 = input$tau_2,                    # probability of testing inpatients for COVID in the absence of travel history or epidemiological link
		tau_1_max = input$tau_1_max,                # increase rate to this probability of testing patients [who do not need to be admitted] in the absence of travel history or epidemiological link
		tau_2_max = input$tau_2_max,                # increase rate to this probability of testing inpatients for COVID in the absence of travel history or epidemiological link. but probability will not be 100%
		length_of_stay,           		# note, a calculated parameter that could also be calculated inside the model function
		Ncases_trigger = input$Ncases_trigger,           # number of detected cases that triggers the rise in testing
		event_ss = input$event_ss,                 # number of super-spreading events
		event_ss_modulo = input$event_ss_modulo,	        # frequency of super-spreading events
		baseline_inpt_perday = input$baseline_inpt_perday,
		baseline_ICUpt_perday = input$baseline_ICUpt_perday
	)

	paramMat
}

runSimulation <- function (input, paramMat) {
	modelout <- epid(paramMat)

	######################################################################################################
	# calculate daily true incidence (from cumulative incidence [subtract from previous day] CumIncid_tot)
	# calculate daily detected cases (from cumulative diagnoses [subtract from previous day] Cumdx_tot)
	# calculate daily ED visits      (from cumulative ED vistis and cumulative admissions, CumED_ct and CumAdmit)
	######################################################################################################

	DailyTrueIncid   <- diff(modelout$CumIncid_tot)
	DailyDetCases    <- diff(modelout$Cumdx_tot)
	DailyED_notadmit <- diff(modelout$CumED_ct)
	DailyED_admit    <- diff(modelout$CumAdmit)

	DailyTrueIncid   <- c(0,DailyTrueIncid) 
	DailyDetCases    <- c(0,DailyDetCases)
	DailyED_notadmit <- c(0,DailyED_notadmit)
	DailyED_admit    <- c(0,DailyED_admit )

	DailyED_total    <- DailyED_notadmit + DailyED_admit

	modelout$DailyTrueIncid <- DailyTrueIncid 
	modelout$DailyDetCases  <- DailyDetCases
	modelout$DailyED_total  <- DailyED_total 

	modelout$DailyED_total_hosp    <- modelout$DailyED_total * input$catchment_ED
	modelout$I_ch_hosp             <- modelout$I_ch          * input$catchment_hosp
	modelout$I_cicu_hosp           <- modelout$I_cicu        * input$catchment_hosp

	output_cityhosp <- tibble::tibble(
		time = modelout$time,
		'Daily True Incidence' = modelout$DailyTrueIncid,
		'Daily Detected Cases' = modelout$DailyDetCases,
		'Daily ED Total (GTA)' = modelout$DailyED_total,
		'Isolated in hospital (GTA)' = modelout$I_ch,
		'Isolated in ICU (GTA)' = modelout$I_cicu,
		'Daily ED Total (catchment)' = modelout$DailyED_total_hosp,
		'Isolated in hospital (catchment)' = modelout$I_ch_hosp,
		'Isolated in ICU (catchment)' = modelout$I_cicu_hosp,
		'Median occupied inpatient beds' = paramMat$baseline_inpt_perday,
		'Median occupied ICU beds' = paramMat$baseline_ICUpt_perday
	)

	output_cityhosp
}

generateModelPlot <- function (modelout) {
	df_cases <- modelout %>%
	select(
		'time',
		'Daily ED Total (catchment)',
		'Isolated in hospital (catchment)',
		'Isolated in ICU (catchment)'
	) %>%
	melt(
		id.vars = 'time',
		variable.name = 'cases_series',
		value.name = 'cases'
	)

	df_beds <- modelout %>%
	select(
		'time',
		'Median occupied inpatient beds',
		'Median occupied ICU beds'
	) %>%
	melt(
		id.vars = 'time',
		variable.name = 'beds_series',
		value.name = 'beds'
	)

	df <- merge(df_cases, df_beds, by='time')

	p = ggplot(
		df,
		aes(
			time,
			cases,
			colour = cases_series,
			# group = 1,
			# text = paste(
			# 	'Variable: ', cases_series,
			# 	'<br>Time: ', time,
			# 	'<br>Value: ', format(cases, digits = 1, scientific=FALSE)
			# )
		)
	) + 
	geom_line() + 
	geom_line(
		aes(
			time,
			beds,
			colour = beds_series,
			# group = 1,
			# text = paste(
			# 	'Variable: ', beds_series,
			# 	'<br>Time: ', time,
			# 	'<br>Value: ', format(beds, digits = 1, scientific=FALSE)
			# )
		),
		linetype = 'dashed',
		# group = 2
	) +
	labs(
		x = 'Time (days)',
		y = 'Number of cases'
	) + 
	theme(
		text = element_text(size = 10), 
		legend.title = element_blank()
	)

	ggplotly(
		p,
		tooltip = NULL, # TODO: fix tooltip to show correct series
		# tooltip = 'text',
		dynamicTicks = TRUE
	) 
}

getSensitivityPlots <- function () {
	list.files(path='./www', pattern='admitted_')
}