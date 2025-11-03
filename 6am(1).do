// --------------------------- Load Neccessary Packages ------------------------
** Opening dataset 
//u land_registry_tube.dta, clear
. use "C:\Users\CHI011\Downloads\project_data\land_registry_tube.dta"

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
** Simple model 1: assess only the structural characteristics of the house. 
reg lnprice detached_dum semi_d_dum terrace_dum freehold newbuild, robust
est store reg1

** Model 2: include all variables in Model 1, and adding on "station_km"
reg lnprice station_km detached_dum semi_d_dum terrace_dum freehold newbuild, robust
est store reg2

** Model 3: Control for (1) Area fixed effects & (2) Year fixed effects
** 1. for time-invariant unobservables specific to a particular area. 
** By controlling area fixed effects, we are now exploiting variation within area. 
** This is useful because we are comparing similar properties in the same area but with different exposure to the disamenity of interest
** the disamenity being distance from the nearest tube station.    
** 2. for general changes in house prices across areas over time.

** Model 3a: control for year & large-scale area (msoa11)
reghdfe lnprice station_km detached_dum semi_d_dum terrace_dum freehold newbuild thamesriv_dist dist_to_cbd bus_distnear grossannualpay jobdensity hoursworked unemployment, absorb(year msoa11) vce(robust)
est store reg3a

// Model 3b: control for year & granular area (lsoa)
reghdfe lnprice station_km detached_dum semi_d_dum terrace_dum freehold newbuild thamesriv_dist dist_to_cbd bus_distnear grossannualpay jobdensity hoursworked unemployment, absorb(year lsoacode) vce(robust)
est store reg3b

** Model 4: Categorical Approach to Distance, by kilometer
** Distance from the nearest tube station may not affect House price linearly
** Intuitively, if one's nearest tube station is 8km away, one is unlikely to take the tube
** And hence, distance from station will affect house prices less than the case of the station being 100 meters away
** Taking inspiration from Gibbons' transport innovation method (2km is the walkable distance)

generate dist1 = 1 if (station_km <= 2)
replace dist1 = 0 if dist1==.

// Repeating Model 3a
reghdfe lnprice dist1 detached_dum semi_d_dum terrace_dum freehold newbuild thamesriv_dist dist_to_cbd bus_distnear grossannualpay jobdensity hoursworked unemployment, absorb(year msoa11) vce(robust)
reghdfe lnprice dist1 detached_dum semi_d_dum terrace_dum freehold newbuild thamesriv_dist dist_to_cbd bus_distnear grossannualpay jobdensity hoursworked unemployment, absorb(year lsoacode) vce(robust)

** Model 5: Categorical Approach to Distance, by meter
** Distance from the nearest tube station may not affect House price linearly
** Intuitively, if one's nearest tube station is 1km away, one is unlikely to take the tube
** And hence, distance from station will affect house prices less than the case of the station being 100 meters away

generate walk1 = 1 if (station_km < 0.2)
generate walk2 = 1 if (station_km >= 0.2 & station_km < 0.4)
generate walk3 = 1 if (station_km >= 0.4 & station_km < 0.6)
generate walk4 = 1 if (station_km >= 0.6 & station_km < 0.8)
generate walk5 = 1 if (station_km >= 0.8 & station_km < 1)
generate walk6 = 1 if (station_km >= 1 & station_km < 1.2)
generate walk7 = 1 if (station_km >= 1.2 & station_km < 1.4)
generate walk8 = 1 if (station_km >= 1.4 & station_km < 1.6)
generate walk9 = 1 if (station_km >= 1.6 & station_km < 1.8)
generate walk10 = 1 if (station_km >= 1.8 & station_km < 2)

recode walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10 (.=0)

//Repeating 3a & 3b
reghdfe lnprice walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 detached_dum semi_d_dum terrace_dum freehold newbuild thamesriv_dist dist_to_cbd bus_distnear grossannualpay jobdensity hoursworked unemployment, absorb(year msoa11) vce(robust) if station_km<=2
reghdfe lnprice walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 detached_dum semi_d_dum terrace_dum freehold newbuild thamesriv_dist dist_to_cbd bus_distnear grossannualpay jobdensity hoursworked unemployment, absorb(year lsoacode) vce(robust) if station_km<=2

** Model 6a&6b: square of distance
// sq_dist msoa11 absorbed
generate sq_dist = station_km*station_km
scatter lnprice sq_dist
reghdfe lnprice sq_dist station_km detached_dum semi_d_dum terrace_dum freehold newbuild thamesriv_dist dist_to_cbd bus_distnear grossannualpay jobdensity hoursworked unemployment, absorb(year msoa11) vce(robust)
reghdfe lnprice sq_dist station_km detached_dum semi_d_dum terrace_dum freehold newbuild thamesriv_dist dist_to_cbd bus_distnear grossannualpay jobdensity hoursworked unemployment, absorb(year lsoacode) vce(robust)
