###### Helpers

# Swaps names and values of a list
swap_kv <- function(l) {
	new_list <- names(l)
	names(new_list) <- l

	new_list
}

###### Constants

INPUT_PARAM_DESCRIPTIONS <- list(
	########### Model tab inputs
	###### Hospital-specific
	initpop = 'total city population size',
	catchment_ED = 'catchment area for hospital emergency department visits (relative to population size)',
	catchment_hosp = 'catchment area for hospitalizations (relative to population size)',
	inpatient_bed_max = 'maximum inpatient bed capacity',
	ICU_bed_max = 'maximum ICU bed capacity',
	baseline_inpt_perday = 'number of occupied hospital (non-ICU) beds per day, pre-outbreak',
	baseline_ICUpt_perday = 'number of occupied hospital ICU beds per day, pre-outbreak',
	baseline_EDvisits_perday = 'number of emergency department visits per day, pre-outbreak',
	###### Epi
	dur_latent = 'duration (in days) of exposure (latent) period when infected but not infectious',
	dur_incubation = 'duration (in days) of incubation period, prior to onset of clinical symptoms [includes latent period which is not infectious and subclinical period which is infectious]',
	dur_symptomatic = 'duration (in days) of symptomatic and infectious [if not isolated] period when not severe, prior to recovery',
	dur_admitted = 'duration (in days) of symptomatic and infectious [if not isolated] period when hospitalized, prior to recovery [excluding those who died or in ICU]',
	dur_icu = 'duration (in days) of symptomatic and infectious [if not isolated] period in ICU, prior to recovery [excluding those who died]',
	prob_diagnosed = 'proportion who are symptomatic',
	prob_admit_diagnosed = 'proportion who are admitted to hospital among those infected',
	condprob_icu = 'proportion who go to ICU if admitted to hospital',
	condprob_cfr = 'proportion who die from COVID-19 if admitted to ICU',
	R0 = 'R0',
	seed_backCalc = 'size of epidemic / community transmission prior to detection (seeding)',
	###### Intervention
	prob_test = 'prior to increased case detection, proportion of non-severe, symptomatic cases who get tested or self-isolate without testing',
	prob_test_max = 'under increased case detection, proportion of non-severe, symptomatic cases who get tested or self-isolate without testing',
	when_test_increase = 'on which day after the outbreak starts does case detection increase?',
	prop_travel_test = 'proportion of non-severe, symptomatic imported cases who will get tested or self-isolate without testing',
	drop_Reffective = 'by how much does social distancing reduce contact rates?',
	social_distancing = 'on which day after the outbreak starts does social distancing begin?',
	event_ss = 'number of super-spreading events',
	event_ss_modulo = 'number of days between super-spreading events',
	###### Misc
	seed_prop = 'proportion of population with active infection at the start of the outbreak',
	########### Sensitivity tab inputs
	sens_catchment_ICU = 'catchment area for ICU patients (relative to population size)',
	sens_catchment_hosp = 'catchment area for hospitalizations (relative to population size)',
	sens_inpatient_bed_max = 'maximum inpatient bed capacity',
	sens_ICU_bed_max = 'maximum ICU bed capacity'
)

PLOT_OUTPUT_DESCRIPTIONS <- list(
	time = 'Days since outbreak started',
	DailyED_total_hosp = 'Daily number of new ED visits',
	I_ch_hosp = 'Prevalent number of non-ICU inpatients',
	I_cicu_hosp = 'Prevalent number of ICU patients',
	inpatient_bed_max = 'Non-ICU inpatient bed capacity',
	ICU_bed_max = 'ICU patient bed capacity'
)

OUTPUT_COLUMN_DESCRIPTIONS <- list(
	time = 'Days since outbreak started',
	DailyTrueIncid = 'Daily true incidence',
	DailyDetCases = 'Daily detected cases',
	DailyED_total = 'Daily ED visits, in city',
	I_ch = 'Prevalent number of non-ICU inpatients, in city',
	I_cicu = 'Prevalent number of ICU patients, in city',
	DailyED_total_hosp = 'Daily number of new ED visits, in hospital catchment area',
	I_ch_hosp = 'Prevalent number of non-ICU inpatients, in hospital catchment area',
	I_cicu_hosp = 'Prevalent number of ICU patients, in hospital catchment area',
	inpatient_bed_max = 'Non-ICU inpatient bed capacity',
	ICU_bed_max = 'ICU patient bed capacity'
)