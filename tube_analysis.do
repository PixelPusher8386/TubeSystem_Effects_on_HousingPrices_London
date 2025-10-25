// --------------------------- Load Neccessary Packages ------------------------
** Opening dataset 
//u land_registry_tube.dta, clear
. use "C:\Users\CHI011\Downloads\project_data\project_data\land_registry_tube.dta"

** Installing reghdfe - a statistical package that allows you to include fixed effects (area and/or time). ssc install allow us to install additional packages. The command capture: in front allow us avoid stopping despite facing errors.
capture: ssc install reghdfe

** Installing outreg2 - a package useful for exporting results. 
capture: ssc install outreg2

// ----------------------------- Data Cleaning ---------------------------------
// We will drop "tube_distnear" which has been declared obsolete
drop tube_distnear

** Generating log transformation so we can now interpret them as % changes
generate lnprice = ln(price)

** For column age, replace Y as 1 and N as 0. Base dummy is "newbuild is 1"
generate newbuild = 1 if age=="Y" 
replace newbuild = 0 if newbuild==.

* Let's say you believe that people only pay for proximity to tube stations if it is within 200m from your house (walkable distance), we can recode this variables.
generate tube_near = 1 if tube_distnear<=200 //again, we are creating a dummy variable here: = 1 if it is within 200m from the tube station, 0 otherwise. 
replace tube_near = 0 if tube_near==. //now we are comparing those within 200m from those beyond 200m. You can change this parameter by changing the distance defined

generate bus_near = 1 if bus_distnear<=200 //again, we are creating a dummy variable here: = 1 if it is within 200m from the bus station, 0 otherwise. 
replace bus_near = 0 if bus_near==. //now we are comparing those within 200m from those beyond 200m. You can change this parameter by changing the distance defined


// ------------------------------- Modeling ------------------------------------
** Simple model 1: assess only the structural characteristics of the house. 
reg lnprice detached_dum semi_d_dum terrace_dum freehold newbuild, robust
est store reg1

** Model 2: include all variables in Model 1, and adding on "station_km"
reg lnprice detached_dum semi_d_dum terrace_dum freehold newbuild station_km, robust
est store reg2

** Model 3: Area fixed effects control & Year fixed effects control
** 1. for time-invariant unobservables specific to a particular area. 
** By controlling area fixed effects, we are now exploiting within area variation. 
** For example, by adding in a Jurong West dummy, we are exploiting the variation of crime/air quality within Jurong West Area 
** This is useful because we are comparing similar properties in the same area but with different exposure to the disamenity of interest.    
** 2. for general changes in house prices across areas over time (recall how we plot the house price index).

** Model 3a: control for year & large-scale area (lsoa)
reghdfe lnprice detached_dum semi_d_dum terrace_dum freehold newbuild station_km thamesriv_dist dist_to_cbd bus_distnear grossannualpay jobdensity hoursworked unemployment, absorb(year lsoacode) vce(robust)
est store reg3

// Model 3b: control for year & granular area (msoa)
reghdfe lnprice detached_dum semi_d_dum terrace_dum freehold newbuild station_km thamesriv_dist dist_to_cbd bus_distnear grossannualpay jobdensity hoursworked unemployment, absorb(year msoa11) vce(robust)
est store reg4
