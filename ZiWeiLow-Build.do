*preliminaries

if c(username) == "ninalow" {
    global path "/Users/ninalow/Desktop/Predoc"
    global simulate "$path/simulate" 
	global data "$path/data" 
}

cd "$simulate"

clear all
set seed 123 
set obs 5000
gen unique_id = _n // unique identifier

*----BASELINE ------------------------------------------------------------------------------------------------------
// Generate basic demographic information 

// Age: Distribution based on reasonable assumptions for U.S. adult population
// Based on approximate U.S. demographics with Facebook usage patterns (sample skewed towards 30-49 y.o. group)
gen rand_age = runiform()
gen age = .
replace age = 18 + floor(runiform() * (29 - 18)) if rand_age < 0.20                      // 18-29: 25%
replace age = 30 + floor(runiform() * (49 - 30)) if rand_age >= 0.20 & rand_age < 0.55   // 30-49: 38%
replace age = 50 + floor(runiform() * (64 - 50)) if rand_age >= 0.55 & rand_age < 0.80   // 50-64: 27%
replace age = 65 + floor(runiform() * (90 - 65)) if rand_age >= 0.80                     // 65+: 20%
drop rand_age


// Gender: Based on approximate U.S. demographics
gen rand_gender = runiform()
gen gender = .
replace gender = 0 if rand_gender < 0.49      // Male: 49%
replace gender = 1 if rand_gender >= 0.49     // Female: 51%
drop rand_gender
label define gender_lbl 0 "Male" 1 "Female" 
label values gender gender_lbl

// Race/ethnicity: Based on approximate U.S. demographics
gen rand_race = runiform()
gen race = .
replace race = 1 if rand_race < 0.60                      // White (non-Hispanic): 50%
replace race = 2 if rand_race >= 0.60 & rand_race < 0.73  // Black: 24%
replace race = 3 if rand_race >= 0.73 & rand_race < 0.92  // Hispanic/Latino: 18%
replace race = 4 if rand_race >= 0.92 & rand_race < 0.98  // Asian: 6%
replace race = 5 if rand_race >= 0.98                     // Other/Multiple: 2%
drop rand_race
label define race_lbl 1 "White" 2 "Black" 3 "Hispanic/Latino" 4 "Asian" 5 "Other/Multiple"
label values race race_lbl

// Education: Based on approximate U.S. adult education levels
gen rand_edu = runiform()
gen education = .
replace education = 0 if rand_edu < 0.10                       // Less than high school: 10%
replace education = 1 if rand_edu >= 0.10 & rand_edu < 0.38    // High school: 28%
replace education = 2 if rand_edu >= 0.38 & rand_edu < 0.65    // Some college: 27%
replace education = 3 if rand_edu >= 0.65 & rand_edu < 0.85    // Bachelor's degree: 20%
replace education = 4 if rand_edu >= 0.85                      // Graduate degree: 15%
drop rand_edu
label define edu_lbl 0 "Less than high school" 1 "High school" 2 "Some college" 3 "Bachelor's degree" 4 "Graduate degree"
label values education edu_lbl

// Income brackets: Based on approximate U.S. household income distribution
gen rand_inc = runiform()
gen hhincome = .
replace hhincome = 1 if rand_inc < 0.20                     // <$25k: 20%
replace hhincome = 2 if rand_inc >= 0.20 & rand_inc < 0.40  // $25k-$50k: 20% 
replace hhincome = 3 if rand_inc >= 0.40 & rand_inc < 0.60  // $50k-$75k: 20%
replace hhincome = 4 if rand_inc >= 0.60 & rand_inc < 0.75  // $75k-$100k: 15%
replace hhincome = 5 if rand_inc >= 0.75                    // >$100k: 25%
drop rand_inc
label define inc_lbl 1 "Less than $25,000" 2 "$25,000-$49,999" 3 "$50,000-$74,999" 4 "$75,000-$99,999" 5 "$100,000 or more"
label values hhincome inc_lbl

// Region: Based on approximate U.S. population distribution across regions
gen rand_region = runiform()
gen region = .
replace region = 1 if rand_region < 0.17                         // Northeast: 17%
replace region = 2 if rand_region >= 0.17 & rand_region < 0.38   // Midwest: 21%
replace region = 3 if rand_region >= 0.38 & rand_region < 0.75   // South: 37%
replace region = 4 if rand_region >= 0.75                        // West: 25%
drop rand_region
label define region_lbl 1 "Northeast" 2 "Midwest" 3 "South" 4 "West"
label values region region_lbl

// Urban/rural status: Based on approximate U.S. population distribution
gen rand_urban = runiform()
gen urban_rural = .
replace urban_rural = 0 if rand_urban < 0.50                        // Urban: 50%
replace urban_rural = 1 if rand_urban >= 0.50 & rand_urban < 0.80   // Suburban: 30%
replace urban_rural = 2 if rand_urban >= 0.80                       // Rural: 20%
drop rand_urban
label define urban_lbl 0 "Urban" 1 "Suburban" 2 "Rural"
label values urban_rural urban_lbl

// Employment status: Based on reasonable assumptions, conditional on age
// Combined data from BLS and adjusted for simulation purposes
gen rand_emp = runiform()

// Ages 18-24
gen employment = .
// Ages 18-24
replace employment = 1 if age >= 18 & age <= 24 & rand_emp < 0.40                        // Full-time: 40%
replace employment = 2 if age >= 18 & age <= 24 & rand_emp >= 0.40 & rand_emp < 0.65     // Part-time: 25%
replace employment = 3 if age >= 18 & age <= 24 & rand_emp >= 0.65 & rand_emp < 0.75     // Unemployed: 10%
replace employment = 4 if age >= 18 & age <= 24 & rand_emp >= 0.75 & rand_emp < 0.95     // Student: 20%
replace employment = 5 if age >= 18 & age <= 24 & rand_emp >= 0.95                       // Other: 5%

// Ages 25-54 (prime working age)
replace employment = 1 if age >= 25 & age <= 54 & rand_emp < 0.75                        // Full-time: 75%
replace employment = 2 if age >= 25 & age <= 54 & rand_emp >= 0.75 & rand_emp < 0.85     // Part-time: 10%
replace employment = 3 if age >= 25 & age <= 54 & rand_emp >= 0.85 & rand_emp < 0.90     // Unemployed: 5%
replace employment = 4 if age >= 25 & age <= 54 & rand_emp >= 0.90 & rand_emp < 0.93     // Student: 3%
replace employment = 5 if age >= 25 & age <= 54 & rand_emp >= 0.93                       // Other: 7%

// Ages 55-64
replace employment = 1 if age >= 55 & age <= 64 & rand_emp < 0.60                        // Full-time: 60%
replace employment = 2 if age >= 55 & age <= 64 & rand_emp >= 0.60 & rand_emp < 0.70     // Part-time: 10%
replace employment = 3 if age >= 55 & age <= 64 & rand_emp >= 0.70 & rand_emp < 0.75     // Unemployed: 5%
replace employment = 5 if age >= 55 & age <= 64 & rand_emp >= 0.75                       // Retired/Other: 25%

// Ages 65+
replace employment = 1 if age >= 65 & rand_emp < 0.10                                    // Full-time: 10%
replace employment = 2 if age >= 65 & rand_emp >= 0.10 & rand_emp < 0.20                 // Part-time: 10%
replace employment = 5 if age >= 65 & rand_emp >= 0.20                                   // Retired/Other: 80%

drop rand_emp
label define emp_lbl 1 "Full-time" 2 "Part-time" 3 "Unemployed" 4 "Student" 5 "Retired/Other"
label values employment emp_lbl

// Essential worker status: Reasonable assumptions based on COVID-19 pandemic
// Approximately 40-50% of workers were classified as essential during pandemic
gen rand_essential = runiform()
gen essential_worker = 0
replace essential_worker = 1 if employment == 1 & rand_essential < 0.50 // 50% of full-time workers
replace essential_worker = 1 if employment == 2 & rand_essential < 0.30 // 30% of part-time workers
drop rand_essential

// Healthcare worker status: Reasonable assumption based on workforce data
// Healthcare represents about 11-12% of U.S. workforce
gen rand_health = runiform()
gen healthcare_worker = 0
replace healthcare_worker = 1 if essential_worker == 1 & rand_health < 0.20                                       // 20% of essential workers
replace healthcare_worker = 1 if essential_worker == 0 & (employment == 1 | employment == 2) & rand_health < 0.05 // 5% of non-essential workers
drop rand_health

// Health insurance status: Based on Census Bureau Health Insurance Coverage data (2022)
// Source: U.S. Census Bureau, Health Insurance Coverage in the United States: 2022
gen health_insurance = rbinomial(1, 0.92)

// Political leaning: Based on Gallup and Pew Research data (2022)
// Source: Gallup Poll, Party Identification, 2022
gen political_leaning = .
replace political_leaning = 1 if runiform() < 0.07 // Very liberal: 7%
replace political_leaning = 2 if political_leaning==. & runiform() < 0.18 // Liberal: 16%
replace political_leaning = 3 if political_leaning==. & runiform() < 0.24 // Slightly liberal: 14%
replace political_leaning = 4 if political_leaning==. & runiform() < 0.33 // Moderate: 35%
replace political_leaning = 5 if political_leaning==. & runiform() < 0.43 // Slightly conservative: 14%
replace political_leaning = 6 if political_leaning==. & runiform() < 0.70 // Conservative: 22%
replace political_leaning = 7 if political_leaning==.                     // Very conservative: 8%
label var political_leaning "Political orientation (1=Very liberal, 7=Very conservative)"

// Facebook usage intensity among users (hours per day)
gen rand_hours = runiform()
gen facebook_hours = 0
replace facebook_hours = 0.5 if rand_hours < 0.25                     // <1 hour: ~25% of Facebook users
replace facebook_hours = 1 if rand_hours >= 0.25 & rand_hours < 0.50  // 1 hour: ~25% 
replace facebook_hours = 2 if rand_hours >= 0.50 & rand_hours < 0.70  // 2 hours: ~20%
replace facebook_hours = 3 if rand_hours >= 0.70 & rand_hours < 0.85  // 3 hours: ~15%
replace facebook_hours = runiform() * 3 + 4 if rand_hours >= 0.85     // 4+ hours: ~15%
drop rand_hours


// Self-rated health: Based on CDC National Health Interview Survey (2019)
gen rand_health = runiform()
gen self_rated_health = .
replace self_rated_health = 1 if rand_health < 0.03                         // Poor: 3% 
replace self_rated_health = 2 if rand_health >= 0.03 & rand_health < 0.12   // Fair: 9%
replace self_rated_health = 3 if rand_health >= 0.12 & rand_health < 0.40   // Good: 28%
replace self_rated_health = 4 if rand_health >= 0.40 & rand_health < 0.77   // Very good: 37%
replace self_rated_health = 5 if rand_health >= 0.77                        // Excellent: 23%
drop rand_health
label var self_rated_health "Self-rated health (1=Poor, 5=Excellent)"

// Risk factors for COVID-19 severity: Based on CDC data on comorbidities
gen rand_comorb = runiform()
gen health_conditions = .
replace health_conditions = 0 if rand_comorb < 0.60                         // None: 60%
replace health_conditions = 1 if rand_comorb >= 0.60 & rand_comorb < 0.80   // One: 20%
replace health_conditions = 2 if rand_comorb >= 0.80 & rand_comorb < 0.93   // Two: 13%
replace health_conditions = 3 if rand_comorb >= 0.93                        // Three+: 7%
drop rand_comorb
label var health_conditions "Number of COVID-19 risk conditions"

// Healthcare access difficulty
gen rand_access = runiform()
gen healthcare_access = .
replace healthcare_access = 1 if rand_access < 0.45                         // Very easy: 45%
replace healthcare_access = 2 if rand_access >= 0.45 & rand_access < 0.65   // Easy: 20%
replace healthcare_access = 3 if rand_access >= 0.65 & rand_access < 0.80   // Moderate: 15%
replace healthcare_access = 4 if rand_access >= 0.80 & rand_access < 0.92   // Difficult: 12%
replace healthcare_access = 5 if rand_access >= 0.92                        // Very difficult: 8%
drop rand_access
label var healthcare_access "Difficulty accessing healthcare (1=Very easy, 5=Very difficult)"

// Prior COVID infection: Based on CDC prevalence estimates (late 2022)
gen rand_covid = runiform()
gen prior_covid = .
replace prior_covid = 1 if rand_covid < 0.57                              // Yes: ~57% (CDC estimated by late 2022)
replace prior_covid = 0 if rand_covid >= 0.57 & rand_covid < 0.87         // No: ~30%
replace prior_covid = 2 if rand_covid >= 0.87                             // Unsure: ~13%
drop rand_covid
label define covid_lbl 0 "No" 1 "Yes" 2 "Unsure"
label values prior_covid covid_lbl

// Knows someone severely affected by COVID-19: Based on KFF surveys
// Source: Kaiser Family Foundation COVID-19 Vaccine Monitor, 2022
gen rand_prox = runiform()
gen covid_proximity = (rand_prox < 0.60) // 60% knew someone who was hospitalized or died
drop rand_prox
label var covid_proximity "Knows someone severely affected by COVID-19 (1=Yes)"

// Prior vaccination for other diseases: Based on CDC adult vaccination coverage
// Source: CDC, National Health Interview Survey, 2019
gen rand_vax = runiform()
gen prior_vaccines = .
replace prior_vaccines = 0 if rand_vax < 0.15                           // None: 15%
replace prior_vaccines = 1 if rand_vax >= 0.15 & rand_vax < 0.30        // One: 15% 
replace prior_vaccines = 2 if rand_vax >= 0.30 & rand_vax < 0.50        // Two: 20%
replace prior_vaccines = 3 if rand_vax >= 0.50 & rand_vax < 0.70        // Three: 20%
replace prior_vaccines = 4 if rand_vax >= 0.70 & rand_vax < 0.85        // Four: 15%
replace prior_vaccines = 5 if rand_vax >= 0.85                          // Five+: 15%
drop rand_vax
label var prior_vaccines "Number of regular vaccines received in past 5 years"

// COVID-19 information exposure: Based on KFF and Pew Research surveys
// Source: Pew Research Center, "Science and Health" survey, 2022
gen covid_info_exposure = round(rnormal(3, 1.5))
replace covid_info_exposure = 1 if covid_info_exposure < 1
replace covid_info_exposure = 7 if covid_info_exposure > 7
label var covid_info_exposure "COVID-19 information exposure (1-7 scale)"

// COVID-19 misinformation belief: Based on KFF COVID-19 Vaccine Monitor
// Source: Kaiser Family Foundation COVID-19 Vaccine Monitor, 2022
gen misinformation_belief = rbinomial(3, 0.12 + 0.03 * political_leaning)
label var misinformation_belief "Number of COVID-19 misinformation claims believed"

// Vaccination attitudes: Based on KFF and AP-NORC polling
// Source: Kaiser Family Foundation COVID-19 Vaccine Monitor, 2022
// Political leaning influences vaccination attitudes
gen vaccine_attitude = round(8 - 0.5*political_leaning + rnormal(0, 1))
replace vaccine_attitude = 1 if vaccine_attitude < 1
replace vaccine_attitude = 7 if vaccine_attitude > 7
label var vaccine_attitude "Attitude toward vaccines (1=Very negative, 7=Very positive)"

// Public health trust: Based on Pew Research Center data
// Source: Pew Research Center, "Americans' Confidence in Major U.S. Institutions", 2022
gen public_health_trust = round(7 - 0.5*political_leaning + rnormal(0, 1))
replace public_health_trust = 1 if public_health_trust < 1
replace public_health_trust = 7 if public_health_trust > 7
label var public_health_trust "Trust in public health institutions (1-7 scale)"

// Perceived COVID-19 risk: Based on Gallup and KFF surveys
// Source: Kaiser Family Foundation COVID-19 Vaccine Monitor, 2022
gen covid_risk_perception = round(6.5 - 0.5*political_leaning + rnormal(0, 1.2))
replace covid_risk_perception = 1 if covid_risk_perception < 1
replace covid_risk_perception = 7 if covid_risk_perception > 7
label var covid_risk_perception "Perceived personal risk from COVID-19 (1-7 scale)"

// Perceived COVID-19 vaccine benefit: Based on KFF surveys
// Source: Kaiser Family Foundation COVID-19 Vaccine Monitor, 2022
gen vaccine_benefit = round(7 - 0.5*political_leaning + rnormal(0, 1.2))
replace vaccine_benefit = 1 if vaccine_benefit < 1
replace vaccine_benefit = 7 if vaccine_benefit > 7
label var vaccine_benefit "Perceived COVID-19 vaccine benefit (1-7 scale)"

// Social norms perception
gen rand_norms = runiform()
gen social_norms = .
replace social_norms = round(3 + rand_norms * 3 + (4-political_leaning/7*3))
replace social_norms = 1 if social_norms < 1
replace social_norms = 7 if social_norms > 7
drop rand_norms
label var social_norms "Perceived vaccination norms in social circle (1-7 scale)"

// Trust in traditional news media - correlated with political leaning
gen rand_news = runiform()
gen trust_news = round(5 - 0.4 * political_leaning + rand_news * 2)
replace trust_news = 1 if trust_news < 1
replace trust_news = 7 if trust_news > 7
drop rand_news
label var trust_news "Trust in traditional news media (1-7 scale)"

// Trust in social media - higher among younger people, less correlated with politics
gen rand_social = runiform()
gen trust_social = round(3 + rand_social * 3 - 0.03 * (age - 18))
replace trust_social = 1 if trust_social < 1
replace trust_social = 7 if trust_social > 7
drop rand_social
label var trust_social "Trust in social media (1-7 scale)"

// Trust in government - strongly correlated with political leaning
gen rand_gov = runiform()
gen trust_government = round(5.5 - 0.6 * political_leaning + rand_gov * 2)
replace trust_government = 1 if trust_government < 1
replace trust_government = 7 if trust_government > 7
drop rand_gov
label var trust_government "Trust in government (1-7 scale)"

// Trust in healthcare providers - generally high across demographics
gen rand_health = runiform()
gen trust_healthcare = round(5 + rand_health * 2 - 0.1 * misinformation_belief)
replace trust_healthcare = 1 if trust_healthcare < 1
replace trust_healthcare = 7 if trust_healthcare > 7
drop rand_health
label var trust_healthcare "Trust in healthcare providers (1-7 scale)"

// Trust in personal network - higher among those with similar-minded social circles
gen rand_personal = runiform()
gen trust_personal = round(4 + rand_personal * 2 + 0.2 * (social_norms - 4))
replace trust_personal = 1 if trust_personal < 1
replace trust_personal = 7 if trust_personal > 7
drop rand_personal
label var trust_personal "Trust in personal network (1-7 scale)"

// Trust in religious leaders - higher among more religious people and conservatives
gen rand_relig = runiform()
// Create a proxy for religiosity (correlated with conservatism but with variation)
gen religiosity = round(2 + 0.3 * political_leaning + runiform() * 3)
gen trust_religious = round(2 + rand_relig * 2 + 0.5 * religiosity)
replace trust_religious = 1 if trust_religious < 1
replace trust_religious = 7 if trust_religious > 7
drop rand_relig religiosity
label var trust_religious "Trust in religious leaders (1-7 scale)"

// Trust in scientists - high among liberals, college educated
gen rand_sci = runiform()
gen trust_scientists = round(5 - 0.3 * political_leaning + 0.3 * (education >= 3) + rand_sci * 2)
replace trust_scientists = 1 if trust_scientists < 1
replace trust_scientists = 7 if trust_scientists > 7
drop rand_sci
label var trust_scientists "Trust in scientists (1-7 scale)"

// Collective responsibility belief
gen rand_coll = runiform()
gen collective_belief = round(6 - 0.5*political_leaning + rnormal(0, 1))
replace collective_belief = 1 if collective_belief < 1
replace collective_belief = 7 if collective_belief > 7
drop rand_coll
label var collective_belief "Belief in collective responsibility for public health (1-7 scale)"

// Save the baseline data
cd "$data"
save baseline_survey.dta, replace


*----ASSIGNMENT ------------------------------------------------------------------------------------------------------
*- Group 0: Control (no ad)
*- Group 1: Reason-based ad
*- Group 2: Emotion-based ad

cd "$simulate"

clear all
set seed 1234 

// Load the baseline data
use baseline_survey.dta, clear

// Generate treatment assignment for exactly 5,000 participants
// Group 0 Control (no ad): 1,668 participants (33.36%)
// Group 1 Reason-based ad: 1,666 participants (33.32%)
// Group 2 Emotion-based ad: 1,666 participants (33.32%)
gen treatment = .
replace treatment = 0 if _n <= 1668
replace treatment = 1 if _n > 1668 & _n <= 3334
replace treatment = 2 if _n > 3334
label define treatment_lbl 0 "Control" 1 "Reason-based ad" 2 "Emotion-based ad" 
label values treatment treatment_lbl

// Set ad exposures
gen ad_exposures = 25 if inlist(treatment, 1, 2)
replace ad_exposures = 0 if treatment == 0
label var ad_exposures "Number of ad exposures (25 for treatment groups)"

// Create engagement metrics
// Number of ads clicked increases monotonically with Facebook hours for treatment groups
gen ad_clicked = 0
replace ad_clicked = round(25 * (facebook_hour / 7)) if inlist(treatment, 1, 2) //scale facebook_hour based on number of ads clicked

// Ensure ads_clicked is between 0 and 25
replace ad_clicked = 0 if ad_clicked < 0
replace ad_clicked = 25 if ad_clicked > 25
	
// Time spent viewing the ad 
gen view_time = 0
replace view_time = ad_clicked * (0.5 + (runiform() * 9.5)) if inlist(treatment, 1, 2)

label var view_time "Total time spent viewing ad content (minutes)"
	
	
// Keep only relevant variables for the assignment dataset
keep unique_id treatment ad_exposures ad_clicked ad_clicked view_time 

// Save the assignment data
cd "$data"
save treatment_assignment.dta, replace	
	

*----ENDLINE ------------------------------------------------------------------------------------------------------

cd "$simulate"

clear all
set seed 12345 

use baseline_survey.dta, clear
merge 1:1 unique_id using treatment_assignment.dta
drop _merge

// Set up parameters for treatment effects
// Reason-based ad increases vaccine intention by 0.8 points on average
// Emotion-based ad increases vaccine intention by 1.2 points on average
local reason_effect = 0.7
local emotion_effect = 1.3

// Heterogeneous treatment effects by baseline characteristics
// Political leaning moderates treatment effect (reason-based ads has a stronger effect for liberals)
// Prior vaccine attitude moderates treatment effect (exposure to ads has a stronger effect for those with moderate attitudes)
// Essential worker status, education, race/ethnicity, and social norms also moderate effects

// Simulate attrition (10% of participants don't complete endline survey)
// Attrition is related to baseline vaccine intention (those with low intention are more likely to drop out)
gen rand_attrition = runiform()
gen attrition_score = 0.05 + 0.1 * (1 - (vaccine_attitude / 7))  // Higher score = higher dropout probability 
sort attrition_score, stable
gen attrition_rank = _n

gen completed_endline = 1
replace completed_endline = 0 if attrition_rank <= 500
count if completed_endline == 0 //make sure exactly 4500 is in endline sample
label var completed_endline "Completed endline survey"

// Create new dataset with only those who completed the endline survey
keep if completed_endline == 1


// Treatment effect is conditional on actual ad exposure
gen effective_treatment = 0
replace effective_treatment = 1 if treatment == 1 & view_time > 25   // Reason-based & saw ad
replace effective_treatment = 2 if treatment == 2 & view_time > 25  // Emotion-based & saw ad
label var effective_treatment "Effective treatment (accounting for Facebook usage)"
label define effect_lbl 0 "No exposure" 1 "Reason-based exposure" 2 "Emotion-based exposure" 
label values effective_treatment effect_lbl


// Generate endline vaccine intention
gen attitude_change = 0

// Add main effects
// Reason-based ad effect
replace attitude_change = `reason_effect' if treatment == 1

// Emotion-based ad effect
replace attitude_change = `emotion_effect' if treatment == 2

// Add heterogeneous effects for reason-based ads
replace attitude_change = attitude_change + 0.3 * (4 - political_leaning) / 3 if treatment == 1  // Stronger for liberals
replace attitude_change = attitude_change + 0.2 * education / 4 if treatment == 1  // Stronger for educated
replace attitude_change = attitude_change + 0.2 * essential_worker if treatment == 1  // Stronger for essential workers
replace attitude_change = attitude_change + 0.2 * health_insurance if treatment == 1  // Stronger with insurance
replace attitude_change = attitude_change - 0.2 * (healthcare_access / 5) if treatment == 1  // Weaker with poor access
replace attitude_change = attitude_change + 0.2 * (social_norms / 7) if treatment == 1  // Stronger with pro-vax norms

// Add heterogeneous effects for emotion-based ads
replace attitude_change = attitude_change + 0.4 * (1 - abs(vaccine_attitude - 4) / 3) if treatment == 2  // Stronger for moderates
replace attitude_change = attitude_change + 0.3 * covid_proximity if treatment == 2  // Stronger if knows affected person
replace attitude_change = attitude_change + 0.2 * (social_norms / 7) if treatment == 2  // Stronger with pro-vax norms
replace attitude_change = attitude_change + 0.3 * (collective_belief / 7) if treatment == 2  // Stronger with collective values
replace attitude_change = attitude_change - 0.3 * (misinformation_belief / 3) if treatment == 2  // Weaker with misinfo

// Stronger effect for those who clicked on ads and spent more time
replace attitude_change = attitude_change * (1 + 0.2 * ad_clicked) if treatment > 0
replace attitude_change = attitude_change * (1 + 0.01 * view_time / 10) if ad_clicked == 1

// Stronger effect with more exposures (diminishing returns)
replace attitude_change = attitude_change * (1 + 0.1 * sqrt(ad_exposures) / sqrt(10)) if treatment > 0

// Add random noise to the change
gen rand_noise = rnormal(0, 0.8)
replace attitude_change = attitude_change + rand_noise
drop rand_noise

// Calculate new vaccine attitude
gen vaccine_attitude_endline = vaccine_attitude + attitude_change
replace vaccine_attitude_endline = 1 if vaccine_attitude_endline < 1
replace vaccine_attitude_endline = 7 if vaccine_attitude_endline > 7
replace vaccine_attitude_endline = round(vaccine_attitude_endline)
label var vaccine_attitude_endline "COVID-19 vaccine intention at endline (1-7 scale)"
                		
// Generate actual vaccination behavior (0=Not vaccinated, 1=Vaccinated, 2=Scheduled appointment)
// Probability based on endline vaccine intention
gen rand_vax = runiform()
gen p_vaccinated = (vaccine_attitude_endline / 7) ^ 1.5  // Non-linear relation to intention
gen vaccination_status_endline = .
replace vaccination_status_endline = 1 if rand_vax < p_vaccinated  // Actually got vaccinated
replace vaccination_status_endline = 2 if rand_vax >= p_vaccinated & rand_vax < (p_vaccinated + 0.15)  // Scheduled (15% chance if not vaccinated)
replace vaccination_status_endline = 0 if vaccination_status == .  // Not vaccinated or scheduled
drop rand_vax p_vaccinated
label var vaccination_status "COVID-19 vaccination status"
//label define vax_status 0 "Not vaccinated" 1 "Vaccinated" 2 "Scheduled appointment"
label values vaccination_status vax_status

// Information recall about seeing ads 
gen rand_recall = runiform()
gen ad_recall = 0
replace ad_recall = (rand_recall < (0.2 + 0.06 * ad_exposures + 0.3 * ad_clicked)) if treatment > 0 // Higher chance of recall with more exposures and if they clicked
drop rand_recall
label var ad_recall "Recalls seeing the ad (1=Yes)"

// Ad persuasiveness rating (1-7 scale, only for those who recall seeing the ad)
gen rand_persuasive = runiform()
gen ad_persuasiveness = .
// Reason-based ads rated differently than emotion-based
replace ad_persuasiveness = round(3 + rand_persuasive * 4) if ad_recall == 1 & treatment == 1  // Reason: ~4.0 average
replace ad_persuasiveness = round(3.5 + rand_persuasive * 4) if ad_recall == 1 & treatment == 2  // Emotion: ~4.5 average
drop rand_persuasive
label var ad_persuasiveness "Perceived ad persuasiveness (1-7 scale)"

// Ad sharing behavior (1=Shared with others, 0=Did not share)
gen rand_share = runiform()
gen ad_shared = 0
replace ad_shared = (rand_share < 0.05 * (ad_persuasiveness / 7) * (1 + ad_clicked)) if ad_recall == 1 // More likely to share if found persuasive and clicked
drop rand_share
label var ad_shared "Shared the ad with others (1=Yes)"

// Knowledge about COVID-19 vaccines (0-5 scale, assessed through quiz questions)
gen rand_know = runiform()
gen knowledge_score = .
// Knowledge affected by treatment type
replace knowledge_score = round(rand_know * 3 + 1) if effective_treatment == 0    // Control: 1-4 range
replace knowledge_score = round(rand_know * 3 + 2) if effective_treatment == 1    // Reason: 2-5 range (+1 boost)
replace knowledge_score = round(rand_know * 3 + 1.5) if effective_treatment == 2  // Emotion: 1.5-4.5 range (+0.5 boost)
drop rand_know
label var knowledge_score "COVID-19 vaccine knowledge score (0-5)"


// Change in public health trust
gen rand_trust = runiform()
gen public_health_trust_endline = .
replace public_health_trust_endline = public_health_trust + (attitude_change * 0.4) + rnormal(0, 0.8) // Trust change is about 40% of attitude change, plus noise
replace public_health_trust_endline = 1 if public_health_trust_endline < 1
replace public_health_trust_endline = 7 if public_health_trust_endline > 7
replace public_health_trust_endline = round(public_health_trust_endline)
drop rand_trust
label var public_health_trust_endline "Trust in public health at endline (1-7 scale)"

// Willingness to recommend vaccination to others
gen rand_recommend = runiform()
gen recommend_vaccination = round(4 + (vaccine_attitude_endline - 4) * 1.2)
replace recommend_vaccination = 1 if recommend_vaccination < 1
replace recommend_vaccination = 7 if recommend_vaccination > 7
drop rand_recommend
label var recommend_vaccination "Willingness to recommend vaccination (1-7 scale)"

// Keep only relevant variables for the endline dataset
keep unique_id completed_endline effective_treatment vaccine_attitude_endline vaccination_status_endline ad_recall ///
     ad_persuasiveness ad_shared knowledge_score ///
     public_health_trust_endline recommend_vaccination

// Save the endline data
cd "$data"
save endline_survey.dta, replace


