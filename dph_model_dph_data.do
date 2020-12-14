cd "/Users/rickorlina/Dropbox/Rocinante Research/VOALA MBPro/confirmed_cases"

import delimited "./data/LA_County_Covid19_cases_deaths_date_table.csv", delimiter(comma) clear

egen max_day = max(v1)



/* logistic function regression */
/* see https://en.wikipedia.org/wiki/Logistic_function for parameter interpretation */

gen day_number = max_day - v1 + 1
sort day_number


gen date2 = date(date_use, "YMD")
format date2 %tdMon_DD

nl log3: total_cases day_number

predict cchat_log3

scatter total_cases date2 || line cchat_log3 date2, sort

graph display, xsize(6.5)

graph export "Cases-DPHdata-logistic-`date_string'.png", replace

