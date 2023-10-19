/*
This do-file generates and tsfills variables.
*/

clear all
set more off, perm
cap log close
est clear

qui do "$codedir/make_globals.do"

*Create a log file.
log using "$logdir/MinWage_sample1.log", replace
display "Start executing MinWage_sample1.do: $S_DATE $S_TIME"


********************************************************************************
*Load in data.
use "$interdir/employee_wk.dta", clear

*Tsfill missing weeks at the facility-employee-week level and fillin necessary variables.
xtset, clear
gegen idx = group(accpt_id_enc employee_id)
xtset idx wk

gen tsfilled = 0
tsfill
replace tsfilled = 1 if missing(tsfilled)


********************************************************************************
*Fill in tsfilled variables that are necessary for creating tsfilled vars (scheduling volatility, payroll).
foreach vv of var accpt_id_enc employee_id  hire_week separation_week *_hours_emp *_emp_enc {
	bysort idx (tsfilled): replace `vv' = `vv'[1] if tsfilled
}
foreach vv of var fy* ym {
	bysort wk (tsfilled): replace `vv' = `vv'[1] if tsfilled
}
foreach vv of var hours* days_empwk *_hours_empwk *_days_empwk *_hoursot_empwk {
	replace `vv' = 0 if missing(`vv')
}
foreach vv of var *_empwk_enc {
	bys idx (wk) : carryforward `vv', replace
}
foreach i of varlist _all {
	di "`i'"
	assert !missing(`i')
}


********************************************************************************
*Create employee-week level scheduling volatility variables.
gsort idx wk // Must re-sort to use L.

*Numerator: Absolute deviation.
gen hours_absD_i = abs(hours_dow0 - L.hours_dow0) ///
	+ abs(hours_dow1 - L.hours_dow1) + abs(hours_dow2 - L.hours_dow2) ///
	+ abs(hours_dow3 - L.hours_dow3) + abs(hours_dow4 - L.hours_dow4) ///
	+ abs(hours_dow5 - L.hours_dow5) + abs(hours_dow6 - L.hours_dow6)

*Numerator: Sum of squared deviations.
gen hours_SSD_i = (hours_dow0 - L.hours_dow0)^2 ///
	+ (hours_dow1 - L.hours_dow1)^2 + (hours_dow2 - L.hours_dow2)^2 ///
	+ (hours_dow3 - L.hours_dow3)^2 + (hours_dow4 - L.hours_dow4)^2 ///
	+ (hours_dow5 - L.hours_dow5)^2 + (hours_dow6 - L.hours_dow6)^2

*Numerator: Dot-product of hours.
gen hours_dotprod_i = (hours_dow0 * L.hours_dow0) ///
	+ (hours_dow1 * L.hours_dow1) + (hours_dow2 * L.hours_dow2) ///
	+ (hours_dow3 * L.hours_dow3) + (hours_dow4 * L.hours_dow4) ///
	+ (hours_dow5 * L.hours_dow5) + (hours_dow6 * L.hours_dow6)


*Create weights for scheduling volatility (lambdas in github issue #94).
gen wgt_mlt = hours * L.hours
gen wgt_add = hours + L.hours

*Create L1 and L2 norms.
gen L1_norm = hours
gen L2_norm = sqrt(hours_dow0^2 + hours_dow1^2 + hours_dow2^2 ///
	+ hours_dow3^2 + hours_dow4^2 + hours_dow5^2 + hours_dow6^2)


*Create cosine(theta) and theta as the measure of weekly scheduling volatility measure.
gen cos_theta = hours_dotprod_i / (L2_norm * L.L2_norm) // Note that when one week is missing, this is missing.

*Fix floating precision that causes cos_theta to be greater than 1 (has issue when computing acos(.)).
replace cos_theta = 1 if cos_theta > 1 & !missing(cos_theta)

*We want to apply cos(theta)=0 when one of the weeks is missing, and it is not the first week or during a 2+ week break.
bysort accpt_id employee_id (wk): replace cos_theta = 0 if missing(cos_theta) & (_n != 1) /// Must be missing and not first week.
	& !(tsfilled & tsfilled[_n-1]) /// And can't be part of a two-week absence.
	& !(tsfilled & tsfilled[_n+1] & (_n < _N)) /// And can't be part of a two-week absence.
	& !(tsfilled[_n-1] & tsfilled[_n-2] & _n > 2) // And can't be the first day back after a 2+ week absence.

*Generate arccosine.
gen theta = acos(cos_theta)
assert missing(cos_theta) if missing(theta)

*Want them to have the same cleaning rules applied to the cosine theta as above (Footnote 1), for other measures of volatility (GitHub #210).
replace hours_SSD_i = . if missing(cos_theta)
replace hours_absD_i = . if missing(cos_theta)


*Create scheduling volatility numerator variables to be summed when collapsing to the facility level.
gen theta_wgt_mlt = wgt_mlt * theta
gen theta_wgt_add = wgt_add * theta
gen cos_wgt_mlt = wgt_mlt * cos_theta
gen cos_wgt_add = wgt_add * cos_theta

*Drop variables no longer needed.
drop *dow* *_norm


********************************************************************************
*3. Create Tenure Variable
********************************************************************************
do "$codedir/MinWage_sample2.do"


qui compress
save "$interdir/employee_tenure.dta", replace


display "Finished executing MinWage_sample1.do: $S_DATE $S_TIME"
cap log close
