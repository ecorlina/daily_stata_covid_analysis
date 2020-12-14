/* *****************************************************************
   YOU NEED THESE COMMANDS IF YOU'RE STARTING WITH NOTHING IN MEMORY
   *****************************************************************

cd "/Users/rickorlina/Dropbox/Rocinante Research/VOALA MBPro/Covid_19/daily_Stata_analysis"
use "/Users/rickorlina/Dropbox/Rocinante Research/VOALA MBPro/Covid_19/daily_Stata_analysis/cases.dta", replace

*/


/* **********************************************************
   THESE ARE PLACEHOLDERS FOR MODIFYING "PAST X DAYS" SHADING
   **********************************************************

replace past_7_days = 1 if past_7_days > 1
replace past_7_days = past_7_days * 2200

replace past_14_days = 1 if past_14_days > 1
replace past_14_days = past_14_days * 2200

replace past_21_days = 1 if past_21_days > 1
replace past_21_days = past_21_days * 2200

*/



cd "/Users/rickorlina/Dropbox/Rocinante Research/VOALA MBPro/Covid_19/curves/new_stata_charts"

gen cumulative_cases_calc = sum(dph_new_cases)

egen max_day = max(day_number)

gen past_7_days = 0
replace past_7_days = 1 if day_number > max_day - 7

gen past_14_days = 0
replace past_14_days = 1 if day_number > max_day - 14

gen past_21_days = 0
replace past_21_days = 1 if day_number > max_day - 21


local c_date : display %td_CCYYNNDD date(c(current_date), "DMY")
local date_string = trim("`c_date'")



/* logistic function regression */
/* see https://en.wikipedia.org/wiki/Logistic_function for parameter interpretation */

gen date2 = date(date, "YMD")
format date2 %tdMon_DD

nl log3: dph_cumulative_cases day_number

predict cchat_log3

scatter dph_cumulative_cases date2 || line cchat_log3 date2, sort
graph display, xsize(6.5)
graph export "Cases-logistic-`date_string'.png", replace



/* edit the cases data as needed when new numbers are reported */

nl exp2: dph_cumulative_cases day_number

predict cchat

scatter dph_cumulative_cases date2 || line cchat date2, sort xtitle(Date) title(Confirmed cases of COVID-19 in LA County, size(med))
graph display, xsize(6.5)
graph export "Cases-`date_string'.png", replace


gen since_day_76 = 0
replace since_day_76 = 250000 if day_number >= 76

//regress dph_cumulative_cases day_number if day_number >= 76
//
//predict cchat_2
//
//replace cchat_2 = . if day_number <= 75
//
//twoway (area since_day_76 date2 if day_number >= 76, color(gs14)) || (scatter dph_cumulative_cases date2, sort mcolor(navy)) || line cchat_2 date2, sort lcolor(cranberry) xtitle(Date) legend(order(2 3)) title(Cumulative confirmed COVID-19 cases reported in LA County, size(med))
//
//graph export "Cases-Linear-`date_string'.png", replace


/* graph save Graph "/Users/rickorlina/Dropbox/Rocinante Research/VOALA MBPro/Covid_19/daily_Stata_analysis/Graph-v2.gph" */

/* logistic function regression */
/* see https://en.wikipedia.org/wiki/Logistic_function for parameter interpretation */

nl log3: dph_cumulative_deaths day_number

predict cdhat_log3

scatter dph_cumulative_deaths date2 || line cdhat_log3 date2, sort
graph display, xsize(6.5)
graph export "Deaths-logistic-`date_string'.png", replace


nl exp2: dph_cumulative_deaths day_number

predict cdhat

scatter dph_cumulative_deaths date2 || line cdhat date2, sort xtitle(Date) title(Deaths attributed to COVID-19 in LA County, size(med))
graph display, xsize(6.5)
graph export "Deaths-`date_string'.png", replace


gen since_day_45 = 0
replace since_day_45 = 5750 if day_number >= 45

//regress dph_cumulative_deaths day_number if day_number >= 45
//
//predict cdhat_2
//
//replace cdhat_2 = . if day_number <= 45
//
//twoway (area since_day_45 date2 if day_number >= 45, color(gs14)) || (scatter dph_cumulative_deaths date2, sort mcolor(navy)) || line cdhat_2 date2, sort lcolor(cranberry) xtitle(Date) legend(order(2 3)) title(Cumulative deaths attributed to COVID-19 in LA County, size(med))
//
//graph export "Deaths-Linear-`date_string'.png", replace


/* moving average chart, new cases */

tsset date2, daily

gen delta_tests = dph_total_tested_est - dph_total_tested_est[_n-1]

gen today_test_positivity = dph_new_cases / delta_tests

gen delta_hospitalizations = hospitalized_ever - hospitalized_ever[_n-1]

tssmooth ma dph_counts_ma = dph_new_cases , window(6 1)
tssmooth ma dph_deaths_ma = dph_new_deaths , window(6 1)
tssmooth ma dph_hospitalized_ma = hospitalized_now , window(2 1)
tssmooth ma dph_delta_tests_ma = delta_tests, window(6 1)
tssmooth ma dph_daily_positivity_ma = today_test_positivity, window(6 1)
tssmooth ma dph_delta_hosp_ma = delta_hospitalizations, window(6 1)
tssmooth ma dph_reported_positivity_ma = test_positivity, window(6 1)

tsset, clear

label variable dph_counts_ma "Cases 7-day-avg"
label variable dph_deaths_ma "Deaths 7-day-avg"
label variable dph_hospitalized_ma "7-day-avg"
label variable dph_delta_tests_ma "7-day-avg"
label variable dph_daily_positivity_ma "7-day-avg"
label variable dph_delta_hosp_ma "7-day-avg"


replace past_21_days = 1 if past_21_days > 1
replace past_21_days = past_21_days * 5000

twoway (area past_21_days date2, color(gs14)) || (bar dph_new_cases date2, sort color(navy)) || line dph_counts_ma date2, sort color(maroon) xtitle(Date) legend(order(2 3) label(3 "7-day-MA")) title(Daily new cases of COVID-19 reported in LA County, size(med))
graph display, xsize(6.5)
graph export "NewCases-`date_string'-7dayMA.png", replace

//twoway (area past_21_days date2, color(gs14)) || line dph_counts_ma date2, sort color(maroon) xtitle(Date) legend(off) title(New confirmed cases of COVID-19 reported daily in LA County, size(med))
//
//graph export "NewCases-`date_string'-7dayMAonly.png", replace


/* and new deaths */

replace past_14_days = 1 if past_14_days > 1
replace past_14_days = past_14_days * 95

twoway (area past_14_days date2, color(gs14)) || (bar dph_new_deaths date2, sort color(navy)) || line dph_deaths_ma date2, sort color(maroon) xtitle(Date) legend(order(2 3) label(3 "7-day-MA")) title(Daily new deaths attributed to COVID-19 reported in LA County, size(med))
graph display, xsize(6.5)
graph export "NewDeaths-`date_string'-7dayMA.png", replace


/* cases and deaths moving averages plotted together */

twoway (line dph_counts_ma date2, sort color(navy)) || line dph_deaths_ma date2, sort color(maroon) yaxis(2) xtitle(Date) tline(08may2020, lpattern(shortdash)) tline(29may2020, lpattern(dash)) ytitle(Cases, axis(1)) ytitle(Deaths, axis(2)) yscale(range(0 80) axis(2)) ylabel(0(25)100, axis(2)) title(COVID-19 in LA County - daily reported new cases vs new deaths, size(med))
graph display, xsize(6.5)
graph export "cases_v_deaths_7dayavgs-`date_string'.png", replace


/* Hospitalization charts */

/* ever hospitalized compared to total confirmed positive -- DO NOT NEED TO RUN ON WEEKENDS */

/* twoway (line dph_cumulative_cases date2, sort) (line hospitalized_ever date2, sort), xtitle(Date) */


gen in_icu = hospitalized_now * hospitalized_now_icu
gen on_ventilator = hospitalized_now * hospitalized_now_vent

replace past_14_days = 1 if past_14_days > 1
replace past_14_days = past_14_days * 2400

twoway (area past_14_days date2 if day_number >= 32, color(gs14)) || (bar hospitalized_now date2 if day_number >= 32,  ysc(r(0)) sort color(navy)) (line dph_hospitalized_ma date2 if day_number > 32, sort color(maroon)) (line in_icu date2 if day_number >= 42, sort lcolor(cyan)) (line on_ventilator date2 if day_number >= 42, sort lcolor(lime)), title(COVID-19 hospitalizations on day of DPH report, size(med)) xtitle(Date) legend(rows(1) order (2 3 4 5) label(2 "hospitalized") label(3 "3-day-MA") symxsize(*.75) size(small))
graph display, xsize(6.5)
graph export "Hospitalizations-`date_string'.png", replace


replace past_14_days = 1 if past_14_days > 1
replace past_14_days = past_14_days * 350

twoway (area past_14_days date2 if day_number >= 30, color(gs14)) || (bar delta_hospitalizations date2 if day_number >= 30,  ysc(r(0)) sort color(navy)) (line dph_delta_hosp_ma date2 if day_number >= 30, sort color(maroon)), title(COVID-19 daily change in hospitalized (ever) on day of DPH report, size(sm)) xtitle(Date) legend(rows(1) order(2 3) label(2 "change in hospitalized_ever") label(3 "7-day-MA") symxsize(*.75) size(small))
graph display, xsize(6.5)
graph export "NewHospitalized-`date_string'-7dayMA.png", replace


/* hospitalizations and cases moving averages plotted together */

//twoway (line dph_counts_ma date2, sort color(navy)) || line dph_hospitalized_ma date2, sort color(maroon) yaxis(2) xtitle(Date) tline(08may2020, lpattern(shortdash)) tline(29may2020, lpattern(dash)) ytitle(Confirmed Cases, axis(1)) ytitle(Hospitalizations, axis(2)) title(COVID-19 in LA County - daily reported new cases v hospitalizations, size(med)) legend(rows(1) label(1 "Cases 7-day-MA") label(2 "Hospitalizations 3-day-MA") symxsize(*.75) size(small))

twoway (line dph_counts_ma date2, sort color(navy)) || line dph_hospitalized_ma date2, sort color(maroon) xtitle(Date) tline(08may2020, lpattern(shortdash)) tline(29may2020, lpattern(dash)) ytitle(Count) title(COVID-19 in LA County - daily reported new cases v hospitalizations, size(med)) legend(rows(1) label(1 "Cases 7-day-MA") label(2 "Hospitalizations 3-day-MA") symxsize(*.75) size(small))
graph display, xsize(6.5)
graph export "cases_v_hospitalizations_7dayavgs-`date_string'.png", replace



/* hospitalizations and deaths moving averages plotted together */

twoway (line dph_hospitalized_ma date2, sort color(navy)) || line dph_deaths_ma date2, sort color(maroon) yaxis(2) xtitle(Date) tline(08may2020, lpattern(shortdash)) tline(29may2020, lpattern(dash)) ytitle(Hospitalizations, axis(1)) ytitle(Deaths, axis(2)) yscale(range(0 80) axis(2)) ylabel(0(25)100, axis(2)) title(COVID-19 in LA County - daily reported hospitalizations vs new deaths, size(med)) legend(rows(1) label(1 "hospitalized 3-day-MA") label(2 "deaths 7-day-MA") symxsize(*.75) size(small))
graph display, xsize(6.5)
graph export "hospitalizations_v_deaths_7dayavgs-`date_string'.png", replace


//twoway (line dph_hospitalized_ma date2, sort color(navy)) || line dph_deaths_ma date2, sort color(maroon) yaxis(2) xtitle(Date) tline(08may2020, lpattern(shortdash)) tline(29may2020, lpattern(dash)) ytitle(Hospitalizations, axis(1)) ytitle(Deaths, axis(2)) title(COVID-19 in LA County - daily reported hospitalizations vs new deaths, size(med)) legend(rows(1) label(1 "hospitalized 3-day-MA") label(2 "deaths 7-day-MA") symxsize(*.75) size(small))
//
//graph export "hospitalizations_v_deaths_alt_7dayavgs-`date_string'.png", replace


/* stacked bar chart of tests vs positive tests */

gen dph_total_tested_est_k = dph_total_tested_est / 1000

gen tested_positive = round(dph_total_tested_est_k * test_positivity)
gen tested_negative = dph_total_tested_est_k - tested_positive

/* graph bar (asis) tested_positive tested_negative if day_number >= 32, over(date, label(labsize(small) angle(90))) stack title(Cumulative COVID-17 Tests Completed (estimated)) */

twoway (area dph_total_tested_est_k date2, sort) (area tested_positive date2, sort) if day_number >= 32, title(Cumulative COVID-17 Tests Completed (estimated)) xtitle(Date) ytitle(Test results for individuals (in thousands), size(small)) 
graph display, xsize(6.5)
graph export "Testing-`date_string'.png", replace


replace past_7_days = 1 if past_7_days > 1
replace past_7_days = past_7_days * 50000

twoway (area past_7_days date2 if day_number >= 32, color(gs14)) || (bar delta_tests date2 if day_number >= 32,  ysc(r(0)) sort color(navy)) (line dph_delta_tests_ma date2 if day_number >= 32, sort color(maroon)), title(COVID-19 daily change in total tested on day of DPH report, size(med)) xtitle(Date) legend(rows(1) order(2 3) label(2 "change in total tested") label(3 "7-day-MA") symxsize(*.75) size(small))
graph display, xsize(6.5)
graph export "NewTests-`date_string'-7dayMA.png", replace


/* PEH */

gen dph_cumulative_cases_unsheltered = dph_cumulative_cases_peh - dph_cumulative_cases_peh_housed

replace past_14_days = 1 if past_14_days > 1
replace past_14_days = past_14_days * 1750

twoway (area past_14_days date2 if day_number >= 45, color(gs14)) || (bar dph_cumulative_cases_peh date2 if day_number >= 45,  ysc(r(0)) sort color(navy*.7) lwidth(thin) lcolor(navy)) (bar dph_cumulative_cases_peh_housed date2 if day_number >= 45, sort color(maroon*.8) lwidth(thin) lcolor(maroon)), title(COVID-19 among PEH as reported by DPH, size(sm)) xtitle(Date) legend(rows(1) order(2 3) label(2 "unsheltered") label(3 "housed") symxsize(*.75) size(small))
graph display, xsize(6.5)
graph export "Cases_PEH-`date_string'.png", replace


/* today's test positivity rate */

replace past_7_days = 1 if past_7_days > 0
replace past_7_days = past_7_days * 0.35

twoway (area past_7_days date2 if day_number >= 62, color(gs14)) || (bar today_test_positivity date2 if day_number >= 62, sort color(navy)) || line dph_daily_positivity_ma date2 if day_number >= 62, sort color(maroon) xtitle(Date) legend(order(2 3) label(3 "7-day-MA")) title(Daily test positivity (estimated) in LA County, size(med))

replace past_7_days = 1 if past_7_days > 0
replace past_7_days = past_7_days * 0.20

twoway (area past_7_days date2 if day_number >= 32, color(gs14)) || line dph_reported_positivity_ma date2 if day_number >= 32, sort color(maroon) xtitle(Date) legend(order(2) label(2 "7-day-MA")) title(Cumulative test positivity (reported) in LA County, size(med))
graph display, xsize(6.5)
graph export "Reported_Positivity-`date_string'.png", replace




/* only when you're truly finished with the analysis and output */

cd "/Users/rickorlina/Dropbox/Rocinante Research/VOALA MBPro/Covid_19/daily_Stata_analysis"


/* JUST FOR CONVENIENCE, RUN THESE AGAIN AT THE END */

nl exp2: dph_cumulative_cases day_number

nl exp2: dph_cumulative_deaths day_number

nl log3: dph_cumulative_cases day_number

nl log3: dph_cumulative_deaths day_number




/* cases and deaths moving averages plotted together AS PCT */

egen max_dph_counts_ma = max(dph_counts_ma)
egen max_dph_deaths_ma = max(dph_deaths_ma)
egen max_dph_hospitalized_ma = max(dph_hospitalized_ma)

gen dph_counts_ma_pct = dph_counts_ma / max_dph_counts_ma
gen dph_deaths_ma_pct = dph_deaths_ma / max_dph_deaths_ma
gen dph_hospitalized_ma_pct = dph_hospitalized_ma / max_dph_hospitalized_ma

twoway (line dph_counts_ma_pct date2, sort color(navy)) || line dph_hospitalized_ma_pct date2, sort color(maroon) || line dph_deaths_ma_pct date2, sort color(green) tline(08may2020, lpattern(shortdash)) tline(29may2020, lpattern(dash)) ytitle(percent) title(COVID-19 in LA County - daily reported new cases vs new deaths, size(med))
graph display, xsize(6.5)



//drop cumulative_cases_calc date2 max_day past_7_days past_14_days past_21_days cchat_log3 cchat since_day_76 cchat_2 cdhat_log3 cdhat since_day_45 cdhat_2 delta_tests delta_hospitalizations dph_counts_ma dph_deaths_ma dph_hospitalized_ma dph_delta_tests_ma dph_delta_hosp_ma dph_reported_positivity_ma tested_positive tested_negative in_icu on_ventilator dph_cumulative_cases_unsheltered dph_total_tested_est_k today_test_positivity dph_daily_positivity_ma 

drop cumulative_cases_calc date2 max_day past_7_days past_14_days past_21_days cchat_log3 cchat since_day_76 cdhat_log3 cdhat since_day_45 delta_tests delta_hospitalizations dph_counts_ma dph_deaths_ma dph_hospitalized_ma dph_delta_tests_ma dph_delta_hosp_ma dph_reported_positivity_ma tested_positive tested_negative in_icu on_ventilator dph_cumulative_cases_unsheltered dph_total_tested_est_k today_test_positivity dph_daily_positivity_ma max_dph_counts_ma max_dph_deaths_ma max_dph_hospitalized_ma dph_counts_ma_pct dph_deaths_ma_pct dph_hospitalized_ma_pct

