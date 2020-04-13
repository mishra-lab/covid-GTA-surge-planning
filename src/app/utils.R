# Constants
INPUT_PARAM_DESCRIPTIONS <- list(
	###### Hospital-specific
	initpop = 'total city population size',
	catchment_ED = 'catchment area for hospital emergency department visits (relative to population size)',
	catchment_hosp = 'catchment area for hospitalizations (relative to population size)',
	inpatient_bed_max = 'maximum inpatient bed capacity',
	ICU_bed_max = 'maximum ICU bed capacity',
	baseline_inpt_perday = 'median number of occupied hospital (non-ICU) beds per day',
	baseline_ICUpt_perday = 'median number of occupied hospital ICU beds per day',
	baseline_EDvisits_perday = 'median number of emergency department vists per day',
	###### Epi
	dur_latent = 'duration (in days) of exposure (latent) period when infected but not infectious',
	dur_incubation = 'duration (in days) of subclinical but infectious [if not isolated] period, prior to onset of clinical symptoms',
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
	prob_test = 'proportion of non-severe, symptomatic cases who get tested or self-isolate without testing',
	prob_test_max = 'under increased case detection, proportion of non-severe, symptomatic cases who get tested or self-isolate without testing',
	when_test_increase = 'on which day after the outbreak starts does case detection increase?',
	prop_travel_test = 'proportion of non-severe, symptomatic imported cases who will get tested or self-isolate without testing',
	drop_Reffective = 'by how much does social distancing reduce contact rates?',
	social_distancing = 'on which day after the outbreak starts does social distancing begin?',
	event_ss = 'number of super-spreading events',
	event_ss_modulo = 'number of days between super-spreading events',
	###### Misc
	seed_prop = 'proportion of population with active infection at the start of the outbreak'
)