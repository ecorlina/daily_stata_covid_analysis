
cd "/Users/rickorlina/Dropbox/Rocinante Research/VOALA MBPro/Covid_19/covid_analysis_output/stata_analysis_output"

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



/* logistic function regression - CASES */
/* see https://en.wikipedia.org/wiki/Logistic_function for parameter interpretation */

gen date2 = date(date, "YMD")
format date2 %tdMon_DD

//nl log3: dph_cumulative_cases day_number
//predict cchat_log3

nl exp2: dph_cumulative_cases day_number
predict cchat

gen since_day_76 = 0
replace since_day_76 = 250000 if day_number >= 76

/* logistic function regression  - DEATHS */
/* see https://en.wikipedia.org/wiki/Logistic_function for parameter interpretation */

//nl log3: dph_cumulative_deaths day_number
//predict cdhat_log3

nl exp2: dph_cumulative_deaths day_number
predict cdhat

gen since_day_45 = 0
replace since_day_45 = 5750 if day_number >= 45


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


/* and new deaths */

replace past_14_days = 1 if past_14_days > 1
replace past_14_days = past_14_days * 95


/* cases and deaths moving averages plotted together */


/* Hospitalization charts */

gen in_icu = hospitalized_now * hospitalized_now_icu
gen on_ventilator = hospitalized_now * hospitalized_now_vent

replace past_14_days = 1 if past_14_days > 1
replace past_14_days = past_14_days * 2400


replace past_14_days = 1 if past_14_days > 1
replace past_14_days = past_14_days * 350


/* hospitalizations and cases moving averages plotted together */


/* hospitalizations and deaths moving averages plotted together */


/* cases, hospitalizations, and deaths moving averages plotted together */

twoway (line dph_counts_ma date2, sort color(navy)) || (line dph_hospitalized_ma date2, sort color(maroon)) || line dph_deaths_ma date2, sort color(green) yaxis(2) xtitle(Date) tline(25may2020, lpattern(shortdash) lwidth(thin) lcolor(gs10)) tline(04jul2020, lpattern(shortdash) lwidth(thin) lcolor(gs10)) tline(07sep2020, lpattern(shortdash) lwidth(thin) lcolor(gs10)) tline(31oct2020, lpattern(shortdash) lwidth(thin) lcolor(gs10)) tline(26nov2020, lpattern(shortdash) lwidth(thin) lcolor(gs10)) tline(25dec2020, lpattern(shortdash) lwidth(thin) lcolor(gs10)) ytitle(Cases & Hospitalizations, axis(1)) ytitle(Deaths, axis(2)) yscale(range(0 18000) axis(1)) yscale(range(0 600) axis(2)) ylabel(0(3000)18000, axis(1)) ylabel(0(100)600, axis(2)) title("COVID-19 in LA County - daily reported cases, hospitalizations, and deaths", size(med)) legend(rows(1) label(1 "cases 7-day-avg") label(2 "hospitalized 3-day-avg") label(3 "deaths 7-day-avg") symxsize(*.75) size(small))
graph display, xsize(6.5)
graph export "chd_7dayavgs-`date_string'.png", replace




/* stacked bar chart of tests vs positive tests */

gen dph_total_tested_est_k = dph_total_tested_est / 1000

gen tested_positive = round(dph_total_tested_est_k * test_positivity)
gen tested_negative = dph_total_tested_est_k - tested_positive



replace past_7_days = 1 if past_7_days > 1
replace past_7_days = past_7_days * 50000


/* PEH */

gen dph_cumulative_cases_unsheltered = dph_cumulative_cases_peh - dph_cumulative_cases_peh_housed

replace past_14_days = 1 if past_14_days > 1
replace past_14_days = past_14_days * 3000


/* today's test positivity rate */

replace past_7_days = 1 if past_7_days > 0
replace past_7_days = past_7_days * 0.35

//twoway (area past_7_days date2 if day_number >= 62, color(gs14)) || (bar today_test_positivity date2 if day_number >= 62, sort color(navy)) || line dph_daily_positivity_ma date2 if day_number >= 62, sort color(maroon) xtitle(Date) legend(order(2 3) label(3 "7-day-MA")) title(Daily test positivity (estimated) in LA County, size(med))

replace past_7_days = 1 if past_7_days > 0
replace past_7_days = past_7_days * 0.20



/* only when you're truly finished with the analysis and output */

cd "/Users/rickorlina/Documents/rprojects/Covid19/daily_stata_analysis"


/* JUST FOR CONVENIENCE, RUN THESE AGAIN AT THE END */

nl exp2: dph_cumulative_cases day_number

nl exp2: dph_cumulative_deaths day_number

//nl log3: dph_cumulative_cases day_number

//nl log3: dph_cumulative_deaths day_number



drop cumulative_cases_calc date2 max_day past_7_days past_14_days past_21_days /*cchat_log3*/ cchat since_day_76 /*cdhat_log3*/ cdhat since_day_45 delta_tests delta_hospitalizations dph_counts_ma dph_deaths_ma dph_hospitalized_ma dph_delta_tests_ma dph_delta_hosp_ma dph_reported_positivity_ma tested_positive tested_negative in_icu on_ventilator dph_cumulative_cases_unsheltered dph_total_tested_est_k today_test_positivity dph_daily_positivity_ma

