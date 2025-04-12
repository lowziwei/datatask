*preliminaries

if c(username) == "ninalow" {
    global path "/Users/ninalow/Desktop/Predoc"
    global simulate "$path/simulate" 
	global data "$path/data" 
	global output "$path/output"
}

cd "$data"

clear all
set seed 12345
set linesize 100

*----MERGE DATASET--------------------------------------------------------------------------------------------------------

use baseline_survey.dta, clear
merge 1:1 unique_id using treatment_assignment.dta // Merge with treatment assignment data
drop _merge
merge 1:1 unique_id using endline_survey.dta // Merge with endline survey data (will have missing values for attrition cases)
label var completed_endline "Completed endline survey (1=Yes)"
drop _merge

// Create a score for vaccine attitude change
gen attitude_change = vaccine_attitude_endline - vaccine_attitude if completed_endline == 1
label var attitude_change "Change in vaccine attitude (endline - baseline)"

// Create binary outcome for improved attitude
gen improved_attitude = (attitude_change > 0) if attitude_change != .
label var improved_attitude "Increased vaccine attitude (1=Yes)"

// Create a binary vaccination outcome (combining vaccinated and scheduled)
gen any_vaccination = (vaccination_status == 1 | vaccination_status == 2) if vaccination_status != .
label var any_vaccination "Vaccinated or scheduled (1=Yes)"

// Create treatment indicators for regression analysis
gen treated = (treatment > 0)
label var treated "Any treatment (1=Yes)"

gen reason_ad = (treatment == 1)
label var reason_ad "Received reason-based ad (1=Yes)"

gen emotion_ad = (treatment == 2)
label var emotion_ad "Received emotion-based ad (1=Yes)"

// Save the merged dataset
cd "$data"
save merged_data.dta, replace


*----ANALYSIS----------------------------------------------------------------------------------------------------------------

*1. Descriptive statistics
// Sample characteristics for balanced randomization check
tabstat age gender education hhincome political_leaning vaccine_attitude vaccine_attitude prior_covid, ///
        by(treatment) statistics(mean sd n) columns(statistics) longstub

// Test for balance across treatment groups
foreach var of varlist age gender education hhincome political_leaning vaccine_attitude vaccine_attitude prior_covid {
    display "Testing balance for: `var'"
    oneway `var' treatment, tabulate
}

*2. Attrition analysis
logit completed_endline i.treatment age i.gender i.education vaccine_attitude, or
margins i.treatment, post

*3. Analyze primary outcomes
// 3.1 Change in vaccine intention
reg attitude_change i.treatment, robust
margins treatment, post

// 3.2 Binary increased intention
logit improved_attitude i.treatment, or robust
margins treatment, post

// 3.3 Vaccination status
logit any_vaccination i.treatment, or robust
margins treatment, post

*4. Heterogeneity analysis
// 4.1 By political leaning
reg attitude_change i.treatment##c.political_leaning, robust
margins treatment, at(political_leaning=(1(1)7)) post

// 4.2 By education level
reg attitude_change i.treatment##i.education, robust
margins treatment, at(education=(0(1)4)) post

// 4.3 By baseline vaccine attitude
reg attitude_change i.treatment##c.vaccine_attitude, robust
margins treatment, at(vaccine_attitude=(1(1)7)) post

// 4.4 By race/ethnicity (based on Duflo's research)
reg attitude_change i.treatment##i.race, robust
margins treatment, at(race=(1(1)5)) post

// 4.5 By healthcare access
reg attitude_change i.treatment##i.healthcare_access, robust
margins treatment, at(healthcare_access=(1(1)5)) post

// 4.6 By essential worker status
reg attitude_change i.treatment##i.essential_worker, robust
margins treatment, at(essential_worker=(0/1)) post

// 4.7 By COVID-19 proximity
reg attitude_change i.treatment##i.covid_proximity, robust
margins treatment, at(covid_proximity=(0/1)) post

// 4.8 By misinformation belief
reg attitude_change i.treatment##c.misinformation_belief, robust
margins treatment, at(misinformation_belief=(0(1)3)) post

// 4.9 By collective responsibility belief
reg attitude_change i.treatment##c.collective_belief, robust
margins treatment, at(collective_belief=(1(2)7)) post

// 4.11 By Facebook usage intensity (hours per day)
reg attitude_change i.treatment##c.facebook_hours, robust
margins treatment, at(facebook_hours=(0.5(0.5)3.5)) post

*5. Ad exposure and engagement analysis
// 5.1 Dose-response relationship for ad exposures
reg attitude_change i.treatment##c.ad_exposures if treatment > 0, robust

// 5.2 Effect of clicking on the ad
reg attitude_change i.treatment##i.ad_clicked if treatment > 0, robust

*6. Create visualizations
cd "$output"
// 6.1 Main treatment effects on vaccine intention change
graph bar attitude_change, over(treatment) ///
      ytitle("Mean change in vaccine attitudes") ///
      note("Note: Positive values indicate increased vaccination attitude") ///
      blabel(bar, format(%4.2f)) ///
      bar(1, color(navy)) bar(2, color(forest_green)) bar(3, color(maroon))
	  
	  //title("Effect of Facebook Ads on Vaccine Attitude") ///
	  
graph export attitude_change.png, replace width(1000)

// 6.2 Vaccination rates by treatment group
graph bar any_vaccination, over(treatment) ///
      ytitle("Proportion vaccinated or scheduled") ///
      blabel(bar, format(%4.2f)) ///
      bar(1, color(navy)) bar(2, color(forest_green)) bar(3, color(maroon))
	  
	  //title("Effect of Facebook Ads on Vaccination Rates") ///
	  
graph export vaccination_rates.png, replace width(1000)

// 6.3 Treatment effects by political leaning
// First run the model and store the margins
reg attitude_change i.treatment##c.political_leaning, robust
margins treatment, at(political_leaning=(1(1)7)) saving(margins_pol)
marginsplot, ///
    ytitle("Predicted Change in Vaccine Intention") ///
    xtitle("Political Leaning (1=Very Liberal, 7=Very Conservative)") ///
    note("Note: Positive values indicate increased vaccination attitudes")
	title("") ///
	
graph export treatment_by_politics.png, replace width(1000)

// 6.4 Treatment effects by education
reg attitude_change i.treatment##i.education, robust
margins treatment, at(education=(0(1)4)) saving(margins_edu)
marginsplot, ///
    ytitle("Predicted Change in Vaccine Intention") ///
    xtitle("Education Level") ///
    note("Note: Positive values indicate increased vaccination attitudes")
	
	// title("Treatment Effects by Education Level") ///
	
graph export treatment_by_education.png, replace width(1000)

ssc install estout
*7. Create summary tables for export
// 7.1 Main treatment effects table
eststo clear
// Intention change
eststo: reg attitude_change reason_ad emotion_ad, robust
// Increased intention
eststo: logit improved_attitude reason_ad emotion_ad, or robust
// Vaccination
eststo: logit any_vaccination reason_ad emotion_ad, or robust
// Export to LaTeX
esttab using "treatment_effects.tex", ///
       replace label title("Treatment Effects on Primary Outcomes") ///
       mtitles("Intention Change" "Increased Intention (OR)" "Vaccination (OR)") ///
       star(* 0.10 ** 0.05 *** 0.01) ///
       b(%9.3f) se compress

// 7.2 Heterogeneity tables
eststo clear
// Table 1: Standard demographics
// By political leaning
eststo: reg attitude_change reason_ad##c.political_leaning emotion_ad##c.political_leaning, robust
// By education
eststo: reg attitude_change reason_ad##i.education emotion_ad##i.education, robust
// By baseline attitude
eststo: reg attitude_change reason_ad##c.vaccine_attitude emotion_ad##c.vaccine_attitude, robust
// Export to LaTeX
esttab using "heterogeneity_effects_demographics.tex", ///
       replace label title("Heterogeneity in Treatment Effects: Demographics") ///
       mtitles("Political Leaning" "Education" "Baseline Attitude") ///
       star(* 0.10 ** 0.05 *** 0.01) ///
       b(%9.3f) se compress

// Table 2: Duflo-inspired variables
eststo clear
// By race/ethnicity
eststo: reg attitude_change reason_ad##i.race emotion_ad##i.race, robust
// By essential worker status
eststo: reg attitude_change reason_ad##i.essential_worker emotion_ad##i.essential_worker, robust
// By healthcare access
eststo: reg attitude_change reason_ad##i.healthcare_access emotion_ad##i.healthcare_access, robust
// Export to LaTeX
esttab using "heterogeneity_effects_duflo.tex", ///
       replace label title("Heterogeneity in Treatment Effects: Duflo-inspired Characteristics") ///
       mtitles("Race/Ethnicity" "Essential Worker" "Healthcare Access") ///
       star(* 0.10 ** 0.05 *** 0.01) ///
       b(%9.3f) se compress

// Table 4: Facebook-specific variables
eststo clear
// By Facebook hours
eststo: reg attitude_change reason_ad##c.facebook_hours emotion_ad##c.facebook_hours, robust
// Export to LaTeX
esttab using "heterogeneity_effects_facebook.tex", ///
       replace label title("Heterogeneity in Treatment Effects: Facebook Variables") ///
       mtitles("Facebook Usage Hours") ///
       star(* 0.10 ** 0.05 *** 0.01) ///
       b(%9.3f) se compress
	   
reg attitude_change reason_ad##c.facebook_hours emotion_ad##c.facebook_hours, robust
