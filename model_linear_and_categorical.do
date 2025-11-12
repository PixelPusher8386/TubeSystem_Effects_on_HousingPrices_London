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
scatter lnprice station_km, title("Distance to Nearest Station vs. Natural Logarithm of House Price")
drop if station_km > 100

** For column age, replace Y as 1 and N as 0. Base dummy is "newbuild is 1"
generate newbuild = 1 if age=="Y" 
replace newbuild = 0 if newbuild==.

// ------------------------------- Modeling ------------------------------------
** Model 3: Linear Model
** Control for (1) Area fixed effects & (2) Year fixed effects (3) Inherent Features of Property & Neighbourhood
** 1. for time-invariant unobservables specific to a particular area. 
** By controlling area fixed effects, we are now exploiting variation within area. 
** This is useful because we are comparing similar properties in the same area but with different exposure to the disamenity of interest
** the disamenity being distance from the nearest tube station.    
** 2. for general changes in house prices across areas over time.

** Model 3a: control for year & large-scale area (msoa11)
reghdfe lnprice station_km detached_dum semi_d_dum terrace_dum freehold newbuild thamesriv_dist dist_to_cbd bus_distnear grossannualpay jobdensity hoursworked unemployment, absorb(year msoa11) vce(robust)
est store reg3a
outreg using mydoc.doc, replace ctitle ("MSOA control")

// Model 3b: control for year & granular area (lsoa)
reghdfe lnprice station_km detached_dum semi_d_dum terrace_dum freehold newbuild thamesriv_dist dist_to_cbd bus_distnear grossannualpay jobdensity hoursworked unemployment, absorb(year lsoacode) vce(robust)
est store reg3b
outreg using mydoc.doc, append ctitle ("LSOA control")

** Model 5: Categorical Approach to Distance, by meter
** Distance from the nearest tube station may not affect House price linearly
** Intuitively, if one's nearest tube station is 1km away, one is unlikely to take the tube
** And hence, distance from station will affect house prices less than the case of the station being 100 meters away

generate walk1 = 1 if (station_km < 0.2)
generate walk2 = 1 if (station_km >= 0.2 & station_km < 0.4)
generate walk3 = 1 if (station_km >= 0.4 & station_km < 0.6)
generate walk4 = 1 if (station_km >= 0.6 & station_km < 0.8)
generate walk5 = 1 if (station_km >= 0.8 & station_km < 1)

recode walk1 walk2 walk3 walk4 walk5 (.=0)

//Repeating 3a & 3b
reghdfe lnprice walk1 walk2 walk3 walk4 walk5 detached_dum semi_d_dum terrace_dum freehold newbuild thamesriv_dist dist_to_cbd bus_distnear grossannualpay jobdensity hoursworked unemployment, absorb(year msoa11) vce(robust) if station_km<=1
outreg using categorical.doc, replace ctitle ("MSOA control")
reghdfe lnprice walk1 walk2 walk3 walk4 walk5 detached_dum semi_d_dum terrace_dum freehold newbuild thamesriv_dist dist_to_cbd bus_distnear grossannualpay jobdensity hoursworked unemployment, absorb(year lsoacode) vce(robust) if station_km<=1
outreg using categorical.doc, append ctitle ("LSOA control")
