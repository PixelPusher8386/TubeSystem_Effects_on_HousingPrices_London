// --------------------------- Load Neccessary Packages ------------------------
** Opening dataset 
//u land_registry_tube.dta, clear
. use "C:\Users\CHI011\Downloads\project_data\land_registry_tube.dta"
capture: ssc install reghdfe
capture: ssc install outreg2
ssc install ftools

// ----------------------------- Data Cleaning ---------------------------------
// We will drop "tube_distnear" which has been declared obsolete
drop tube_distnear day OA01CD OA11CD postcode LA area_code descriptio code_year _merge

** Generating log transformation so we can now interpret them as % changes
generate lnprice = ln(price)

// Based on a quick linear regression of the independent and dependent, we identify outliers
** scatter lnprice station_km, title("Distance to Nearest Station vs. Natural Logarithm of House Price")
** drop if station_km > 100

** For column age, replace Y as 1 and N as 0. Base dummy is "newbuild is 1"
generate newbuild = 1 if age=="Y" 
replace newbuild = 0 if newbuild==.

** Model 7a&7b: square of distance
// sq_dist msoa11 absorbed
reghdfe lnprice sq_dist station_km detached_dum semi_d_dum terrace_dum freehold newbuild thamesriv_dist dist_to_cbd bus_distnear grossannualpay jobdensity hoursworked unemployment, absorb(year msoa11) vce(robust)
reghdfe lnprice sq_dist station_km detached_dum semi_d_dum terrace_dum freehold newbuild thamesriv_dist dist_to_cbd bus_distnear grossannualpay jobdensity hoursworked unemployment, absorb(year lsoacode) vce(robust)
