** Opening dataset 
u land_registry_tube.dta, clear

** Installing reghdfe - a statistical package that allows you to include fixed effects (area and/or time). ssc install allow us to install additional packages. The command capture: in front allow us avoid stopping despite facing errors.
capture: ssc install reghdfe

** Installing outreg2 - a package useful for exporting results. 
capture: ssc install outreg2

** Generating some variables
generate lnprice = ln(price) //generating the natural logarithm of house prices, ln() is the command. We conduct log transformation for ease of interpretation of coefficients. We can now interpret them as % changes.

generate newbuild = 1 if age=="Y" //generating a new build dummy that take the value of 1 if property is a newbuild
replace newbuild = 0 if newbuild==. //replacing the newbuild = 0 if the newbuild is missing (meaning it is not new build)

* Let's say you believe that people only pay for proximity to tube stations if it is within 200m from your house (walkable distance), we can recode this variables.
generate tube_near = 1 if tube_distnear<=200 //again, we are creating a dummy variable here: = 1 if it is within 200m from the tube station, 0 otherwise. 
replace tube_near = 0 if tube_near==. //now we are comparing those within 200m from those beyond 200m. You can change this parameter by changing the distance defined

generate bus_near = 1 if bus_distnear<=200 //again, we are creating a dummy variable here: = 1 if it is within 200m from the bus station, 0 otherwise. 
replace bus_near = 0 if bus_near==. //now we are comparing those within 200m from those beyond 200m. You can change this parameter by changing the distance defined

* Creating the natural logarithm of crime counts

local varlist "allcrime violent_crime propertycrime"
foreach x in `varlist'{
cap: g log_`x' =ln(`x')
