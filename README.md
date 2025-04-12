# datatask
Effectiveness of Facebook Ad Campaigns on COVID-19 Vaccine Uptake

This repository contains Stata code to simulate and analyze data from a field experiment assessing the effectiveness of different Facebook ad campaigns in increasing COVID-19 vaccine uptake.

Overview: In this experiment, 5,000 participants across the US were randomly assigned to one of three groups:
	•	Control Group (no ad): 1/3 of participants
	•	Reason-based Ad: 1/3 of participants
	•	Emotion-based Ad: 1/3 of participants
All participants completed a baseline survey and received treatment. Only 4,500 completed an endline survey.
File Structure
1. ZiWeiLow_build.do # Generates baseline survey, treatment assignment, and endline survey data
2. ZiWeiLow_analysis.do #Merges data and conducts analysis
3. baseline_survey.dta #simulated baseline data
4. treatment_assignment.dta #simulated treatment data
5. endline_survey.dta #simulated endline data
6. merged_data.dta #merged dataset
5. Outputs
Dependencies
1. STATA (version 14 or higher)
2. estout #for table generation
3. Margins plot #for plotting marginal effects

Data simulation assumptions: 
The simulation uses reasonable demographic and psychographic distributions based on the following assumptions:
	1	Demographic Assumptions:
	◦	Age: 18-29 (20%), 30-49 (35%), 50-64 (25%), 65+ (20%)
	◦	Gender: Male (49%), Female (51%)
	◦	Race/ethnicity: White non-Hispanic (60%), Black (13%), Hispanic/Latino (19%), Asian (6%), Other/Multiple (2%)
	◦	Education: Less than high school (10%), High school (28%), Some college (27%), Bachelor's degree (20%), Graduate degree (15%)
	◦	Income: <$25k (20%), $25k-$50k (20%), $50k-$75k (20%), $75k-$100k (15%), >$100k (25%)
	◦	Geographic: Northeast (17%), Midwest (21%), South (37%), West (25%)
	◦	Urban (50%), Suburban (30%), Rural (20%)
	2	Treatment Assignment Approach:
	◦	Control Group: 1,668 participants (33.36%) #more students in control 
	◦	Reason-based ad Group: 1,666 participants (33.32%)
	◦	Emotion-based ad Group: 1,666 participants (33.32%)
	◦	Equal allocation was chosen to ensure balanced comparisons between all three groups, allowing for consistent statistical power across all possible comparisons (control vs. reason, control vs. emotion, and reason vs. emotion).
	3	Attrition Assumptions:
	◦	Exactly 10% attrition rate (500 participants)
	◦	Attrition is related to baseline vaccine intention (participants with lower initial vaccine intention are more likely to drop out)
	◦	Final analysis sample consists of 4,500 participants who completed both baseline and endline surveys
	◦	Race/ethnicity: White non-Hispanic (58.0%), Black (12.0%), Hispanic/Latino (18.5%), Asian (6.0%), Other/Multiple (5.5%)
	◦	Geographic: Northeast (17.2%), Midwest (20.9%), South (38.3%), West (23.6%)
	◦	Urban (52.1%), Suburban (26.8%), Rural (21.1%)
U.S. Bureau of Labor Statistics (2020):
	•	Employment by age:
	◦	Ages 18-24: Full-time (40%), Part-time (24%), Unemployed (8%), Student (20%), Other (8%)
	◦	Ages 25-54: Full-time (74%), Part-time (8%), Unemployed (4%), Student (3%), Other (11%)
	◦	Ages 55-64: Full-time (61%), Part-time (9%), Unemployed (3%), Retired/Other (27%)
	◦	Ages 65+: Full-time (11%), Part-time (7%), Retired/Other (82%)
	•	Essential workers: 50% of full-time workers, 30% of part-time workers
	•	Healthcare workers: 15% of essential workers, 3% of other employed workers
	2	Pew Research Center Social Media Data: Facebook user demographics by age:
	◦	Ages 18-29: 68% use Facebook
	◦	Ages 30-49: 78% use Facebook
	◦	Ages 50-64: 70% use Facebook
	◦	Ages 65+: 59% use Facebook
	3	CDC National Health Interview Survey (2019-2022): Health-related variables including self-rated health, COVID-19 risk factors, and healthcare access.
	4	Kaiser Family Foundation COVID-19 Vaccine Monitor (2022): COVID-19 attitudes, vaccine hesitancy reasons, and information sources.
	5	Gallup and Pew Research Political Surveys (2022): Political leaning distribution and its relationship to vaccine attitudes.
	6	Alsan, Duflo et al. (2021): Social norms and collective responsibility beliefs related to vaccination from "Building Trust in Science and Public Health" research.
These data sources were used to create realistic parameter distributions for the simulation model.
Treatment Assignment Data
	•	Treatment group: control, reason-based ad, emotion-based ad
	•	Implementation details: date assigned, ad exposures
	•	Engagement metrics: ad clicked, view time
Endline Survey Data
	•	Follow-up details: date of completion
	•	Primary outcomes: vaccine intention, vaccination status
	•	Ad-related outcomes: ad recall, persuasiveness, sharing
	•	Knowledge: COVID-19 vaccine knowledge score
Simulation Logic
Baseline Data Simulation
	•	Creates realistic demographic profiles
	•	Generates baseline vaccine attitudes and intentions
	•	Includes potential moderators (political leaning, education, etc.)
Treatment Assignment Simulation
	•	Randomly assigns participants to treatment groups
	•	Simulates implementation details (dates, exposure intensity)
	•	Generates engagement metrics based on realistic probabilities
Endline Data Simulation
	•	Models treatment effects with the following assumptions:
	◦	Reason-based ad increases vaccine intention by 0.8 points on average
	◦	Emotion-based ad increases vaccine intention by 1.2 points on average
	•	Incorporates heterogeneous treatment effects:
	◦	Reason-based ads more effective for liberals and more educated participants
	◦	Emotion-based ads more effective for those with moderate baseline attitudes
	•	Models realistic attrition patterns (10% overall)
	•	Generates vaccination outcomes based on intentions
Analysis Framework
The analysis examines:
	1	Primary outcomes:
	◦	Change in vaccine intention (continuous)
	◦	Increased vaccine intention (binary)
	◦	Vaccination status (binary)
	2	Treatment effect heterogeneity by:
	◦	Political leaning
	◦	Education level
	◦	Baseline vaccine attitudes
	3	Dose-response relationships:
	◦	Effect of ad exposure intensity
	◦	Impact of ad engagement (clicks, viewing time)
	4	Ad effectiveness metrics:
	◦	Recall and persuasiveness ratings
	◦	Content sharing behavior

