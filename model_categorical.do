// --------------------------- Load Neccessary Packages ------------------------
** Opening dataset 
//u land_registry_tube.dta, clear
. use "D:\Documents\project_data\land_registry_tube.dta"

** Installing reghdfe - a statistical package that allows you to include fixed effects (area and/or time). ssc install allow us to install additional packages. The command capture: in front allow us avoid stopping despite facing errors.
capture: ssc install reghdfe

** Installing outreg2 - a package useful for exporting results. 
capture: ssc install outreg2
ssc install ftools

// ----------------------------- Data Cleaning ---------------------------------
// We will drop "tube_distnear" which has been declared obsolete
drop tube_distnear day OA01CD OA11CD postcode LA area_code descriptio code_year _merge

** Generating log transformation so we can now interpret them as % changes
generate lnprice = ln(price)

// Based on a quick linear regression of the independent and dependent, we identify outliers
drop if station_km > 100

** For column age, replace Y as 1 and N as 0. Base dummy is "newbuild is 1"
generate newbuild = 1 if age=="Y" 
replace newbuild = 0 if newbuild==.

** Model 5: Categorical Approach to Distance, by meter
** Distance from the nearest tube station may not affect House price linearly
** Intuitively, if one's nearest tube station is 1km away, one is unlikely to take the tube
** And hence, distance from station will affect house prices less than the case of the station being 100 meters away

generate walk1 = 1 if (station_km < 0.2)
generate walk2 = 1 if (station_km >= 0.2 & station_km < 0.4)
generate walk3 = 1 if (station_km >= 0.4 & station_km < 0.6)
generate walk4 = 1 if (station_km >= 0.6 & station_km < 0.8)
generate walk5 = 1 if (station_km >= 0.8 & station_km < 1)
generate walk0 = 1 if (station_km >= 1 & station_km < 2)

recode walk1 walk2 walk3 walk4 walk5 walk0 (.=0)

reghdfe lnprice walk1 walk2 walk3 walk4 walk5 walk0 detached_dum semi_d_dum terrace_dum freehold newbuild thamesriv_dist dist_to_cbd bus_distnear grossannualpay jobdensity hoursworked unemployment if station_km<=2, absorb(year msoa11) vce(robust)
// outreg2 using mycat.doc, replace ctitle ("MSOA control")
reghdfe lnprice walk1 walk2 walk3 walk4 walk5 walk0 detached_dum semi_d_dum terrace_dum freehold newbuild thamesriv_dist dist_to_cbd bus_distnear grossannualpay jobdensity hoursworked unemployment if station_km<=2, absorb(year lsoacode) vce(robust)
// outreg2 using mycat.doc, append ctitle ("LSOA control")
