/*
This do-file creates tenure variables for the analysis data.
*/


********************************************************************************
*Generate tenure hours and weeks.
********************************************************************************
/*
Compute (tenure weeks) weeks passed since hired.
Start from the hire week and do not include the current week in the calcultion.
*/
gen tenure_wks = wk - hire_week

*For each worker, compute (tenure) cumulative hours worked.
*The calcultion does not include the current week.
bysort idx (wk): gen tenure_hrs = sum(hours)

*Create a lagged term for tenure hours.
gen tenure_hrs_lag = L.tenure_hrs
bysort idx: replace tenure_hrs_lag = 0 if (_n == 1) & missing(tenure_hrs_lag)
assert !missing(tenure_hrs_lag)


********************************************************************************
*Generate tenure indicator "wk": Number of weeks since hire (as of the beginning of the week).
********************************************************************************
forvalues ww = 4(4)12 { // Iterate over wk == 4, 8, 12.
	gen tnr_`ww'wks_wk = tenure_wks >= `ww' // Example: tenure_wks = 4 on 5th week since hire.
}


/*
********************************************************************************
*2. Generate FY-Specific tenure starting on Jan 1.
********************************************************************************
/*
Identify the first week of each calendar year: 13, 65, 117, 169.
Save the week before that: 12, 64, 116, 168.
*/
local counter = 0
global J1_weeks
global J1_week_befores

forvalues yy = 2017/2020 {
	global wk_of_`yy'J1 = 13 + 52 * `counter'
	global wk_before_`yy'J1 = ${wk_of_`yy'J1} - 1
	global J1_weeks = "$J1_weeks ${wk_of_`yy'J1}"
	global J1_week_befores = "$J1_week_befores ${wk_before_`yy'J1}"
	local counter = `counter' + 1
}
display "January 1 weeks: $J1_weeks"
display "Weeks before January 1: $J1_week_befores"


*2.1. Tenure indicator: -J1-, weeks passed.

*For each fiscal year, create a variable denoting the one week before the Jan 1.
gen fy_weekbeforeJ1 = $wk_before_2017J1 * (fy==2017) + $wk_before_2018J1 * (fy==2018) + ///
	$wk_before_2019J1 * (fy==2019) + $wk_before_2020J1 * (fy==2020)

assert !missing(fy_weekbeforeJ1) // Ensure that all observations got values

forvalues wk = 4(4)12 { // Iterate over wk == 4, 8, 12 (corresponds to 30, 60, 90 days.
	*J1: tenured == 1 if weeks passed since hire on Jan 1st of the fy > `wk' weeks
	gen tnr_`wk'wks_J1 = fy_weekbeforeJ1 >= (hire_week + `wk')
}


********************************************************************************
*2.2. Tenure indicator: -J1-, hours worked.

*Generate number of hours worked until Jan 1 of each fy.
gen tenure_hrs_J1 = tenure_hrs if inlist(wk, $wk_before_2017J1, $wk_before_2018J1, $wk_before_2019J1, $wk_before_2020J1)

*Assign separation_week experience for employees that quit before the week before Jan 1.
replace tenure_hrs_J1 = tenure_hrs if (separation_week < fy_weekbeforeJ1) & (wk == separation_week)

*Assign 0 if hired after the week before Jan 1.
replace tenure_hrs_J1 = 0 if (hire_week > fy_weekbeforeJ1) & (wk == hire_week)

*Check: Only want 1 non-missing value per employee-fiscal year
bys employee_id fy : egen k = sum(!missing(tenure_hrs_J1))
assert k == 1
drop k

*Replace missing values at the employee-fiscal year level.
bysort accpt_id_enc employee_id fy (tenure_hrs_J1): replace tenure_hrs_J1 = tenure_hrs_J1[1] if missing(tenure_hrs_J1)

assert !missing(tenure_hrs_J1) // Ensure that all observations got values.
*/


********************************************************************************
*Generate FY-Specific tenure starting on Oct 1 or Apr 1 (i.e. the first day of the FY).
********************************************************************************
foreach FY_base_month in oct apr jan jul {
	
	*Identify the first week of each policy year as well as the week before the first week.
	if inlist("`FY_base_month'", "oct", "jul") {
		gen fy = fy_`FY_base_month'
		local fy_range 2017/2020
	}
	else if inlist("`FY_base_month'", "apr") {
		gen fy = fy_`FY_base_month'
		local fy_range 2016/2019
	}
	else if inlist("`FY_base_month'", "jan") {
		gen fy = year(dofm(ym))
		local fy_range 2016/2020
	}
	
	global FY_weeks
	global FY_week_befores
	forvalues yy = `fy_range' {
		qui : summ wk if fy == `yy'
		global wk_of_`yy'FY = r(min)
		global wk_before_`yy'FY = r(min) - 1
		
		global FY_weeks = "$FY_weeks ${wk_of_`yy'FY}"
		global FY_week_befores = "$FY_week_befores ${wk_before_`yy'FY}"
	}
	display "1st weeks: $FY_weeks"
	display "Weeks before 1st weeks: $FY_week_befores"
	
	
	*Tenure indicator: -FY-, weeks passed.
	********************************************************************************
	*Create a variable denoting the week before the FY.
	if inlist("`FY_base_month'", "oct", "jul") {
		gen fy_weekbeforeFY`FY_base_month' = $wk_before_2017FY * (fy==2017) + $wk_before_2018FY * (fy==2018) + ///
			$wk_before_2019FY * (fy==2019) + $wk_before_2020FY * (fy==2020)
	}
	else if inlist("`FY_base_month'", "apr") {
		gen fy_weekbeforeFY`FY_base_month' = $wk_before_2016FY * (fy==2016) + $wk_before_2017FY * (fy==2017) + ///
			$wk_before_2018FY * (fy==2018) + $wk_before_2019FY * (fy==2019)
	}
	else if inlist("`FY_base_month'", "jan") {
		gen fy_weekbeforeFY`FY_base_month' = $wk_before_2016FY * (fy==2016) + $wk_before_2017FY * (fy==2017) + ///
			$wk_before_2018FY * (fy==2018) + $wk_before_2019FY * (fy==2019) + $wk_before_2020FY * (fy==2020)
	}
	tab fy_weekbeforeFY`FY_base_month'
	
	forvalues wk = 4(4)12 { // Iterate over wk == 4, 8, 12 (corresponds to 30, 60, 90 days.
		*FY: tenured == 1 if weeks passed since hire until the week before the FY > `wk' weeks.
		gen tnr_`wk'wks_FY`FY_base_month' = fy_weekbeforeFY`FY_base_month' >= (hire_week + `wk') if ///
			!missing(fy_weekbeforeFY`FY_base_month')
	}
	
	
	*Tenure indicator: -FY-, hours worked.
	********************************************************************************
	*Generate number of hours worked until the first day of the FY.
	gisid accpt_id_enc employee_id fy wk
	bysort accpt_id_enc employee_id fy (wk): gen tenure_hrs_FY`FY_base_month' = tenure_hrs_lag[1]
	assert !missing(tenure_hrs_FY`FY_base_month')
	
	
	********************************************************************************
	*Tenure quantiles.
	********************************************************************************
	/*
	Condition on this ID variable when calculting quantiles so that we count each employee only once per fiscal year.
	Since we now use employee's dominant job-pay type, no need to group by job and pay type.
	*/
	bysort accpt_id employee_id fy (wk): gen onerow_per_idfy = _n == 1
	foreach tt in FY`FY_base_month' { // J1
		
		*Compute quartile thresholds and propagate.
		gquantiles tempvar = tenure_hrs_`tt' if !(tenure_hrs_`tt' == 0) & onerow_per_idfy, ///
			xtile nquantiles(4) by(fy jobpay_emp_enc)
		
		gegen tnr_hrs_`tt'_quartile = max(tempvar), by(accpt_id employee_id fy jobpay_emp_enc)
		replace tnr_hrs_`tt'_quartile = 0 if missing(tnr_hrs_`tt'_quartile)
		assert !missing(tnr_hrs_`tt'_quartile)
		
		gegen k = nunique(tnr_hrs_`tt'_quartile), by(accpt_id employee_id fy jobpay_emp_enc) // To check.
		assert k == 1
		
		tab tnr_hrs_`tt'_quartile
		bysort fy jobpay_emp_enc tnr_hrs_`tt'_quartile: sum tenure_hrs_`tt', det
		drop tempvar k
		
		
		*Label the tenure variables.
		cap label define tnr_ptl_hrs_lab 0 "New Hire" 1 "Non-Tenured" 2 "Tenured"
		
		*Tenured if above quartile-threshold at the beginning of FY:
		gen tnr_p25hrs_`tt' = "Tenured":tnr_ptl_hrs_lab if tnr_hrs_`tt'_quartile >= 2
		gen tnr_p50hrs_`tt' = "Tenured":tnr_ptl_hrs_lab if tnr_hrs_`tt'_quartile >= 3
		gen tnr_p75hrs_`tt' = "Tenured":tnr_ptl_hrs_lab if tnr_hrs_`tt'_quartile >= 4
		
		*New hire if zero hours at the beginning of FY:
		replace tnr_p25hrs_`tt' = "New Hire":tnr_ptl_hrs_lab if tenure_hrs_`tt' == 0
		replace tnr_p50hrs_`tt' = "New Hire":tnr_ptl_hrs_lab if tenure_hrs_`tt' == 0
		replace tnr_p75hrs_`tt' = "New Hire":tnr_ptl_hrs_lab if tenure_hrs_`tt' == 0
		
		*Non-Tenured if less than quartile threshold at the beginning of FY and non-zero work experience:
		replace tnr_p25hrs_`tt' = "Non-Tenured":tnr_ptl_hrs_lab if missing(tnr_p25hrs_`tt')
		replace tnr_p50hrs_`tt' = "Non-Tenured":tnr_ptl_hrs_lab if missing(tnr_p50hrs_`tt')
		replace tnr_p75hrs_`tt' = "Non-Tenured":tnr_ptl_hrs_lab if missing(tnr_p75hrs_`tt')
		
		label values tnr_p*hrs_`tt' tnr_ptl_hrs_lab
		
		*Check.
		tab tnr_p25hrs_`tt' tnr_hrs_`tt'_quartile
		tab tnr_p50hrs_`tt' tnr_hrs_`tt'_quartile
		tab tnr_p75hrs_`tt' tnr_hrs_`tt'_quartile
		drop tnr_hrs_`tt'_quartile
		
		
		*Loop through numbers of quantiles wanted to group tenure.
		local number_of_qtile_bins 2 3 // 4
		foreach i of local number_of_qtile_bins {
			display "Quantile: `i'"
			
			/*
			Create quantile at each FY level.
			Condition on this when calculting quantiles so that we don't group zero-tenure employees with others into the same quantile.
			*/
			gquantiles tnr_hrs_`tt'_`i'qtile = tenure_hrs_`tt' if !(tenure_hrs_`tt' == 0) & onerow_per_idfy, ///
				xtile nquantiles(`i') by(fy jobpay_emp_enc)
			
			*Propagate quantiles over all weeks within the FY.
			bysort accpt_id employee_id fy jobpay_emp_enc (tnr_hrs_`tt'_`i'qtile): replace tnr_hrs_`tt'_`i'qtile = ///
				tnr_hrs_`tt'_`i'qtile[1] if missing(tnr_hrs_`tt'_`i'qtile)
			
			*Create a new quantile for zero-tenures.
			replace tnr_hrs_`tt'_`i'qtile = 0 if (tenure_hrs_`tt' == 0)
		}
		
		
		*Use the 2-quantile version of the tenure to check.
		tab tnr_p25hrs_`tt' tnr_hrs_`tt'_2qtile
		tab tnr_p50hrs_`tt' tnr_hrs_`tt'_2qtile
		tab tnr_p75hrs_`tt' tnr_hrs_`tt'_2qtile
		
		assert tnr_p50hrs_`tt' == tnr_hrs_`tt'_2qtile
		drop tnr_hrs_`tt'_2qtile
	}
	
	
	*For Oct or Jul based FYs, tenure is not well-defined in FY2017, so assign missing.
	if inlist("`FY_base_month'", "oct", "jul") local fy_tomissing = 2017
	
	*For Apr or Jan (CY) based FYs, tenure is not well-defined in FY2016.
	else if inlist("`FY_base_month'", "apr", "jan") local fy_tomissing = 2016
	
	foreach tnrvar of var tnr*FY*`FY_base_month'* {
		display "Assigning missing to `tnrvar' for FY`fy_tomissing'."
		assert !missing(`tnrvar')
		replace `tnrvar' = . if fy == `fy_tomissing'
	}
	drop onerow_per_id* fy // altfy
}

