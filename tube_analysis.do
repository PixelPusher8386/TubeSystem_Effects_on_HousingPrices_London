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

// ------------------------------- Modeling ------------------------------------
** Simple model 1: assess only the structural characteristics of the house. 
reg lnprice detached_dum semi_d_dum terrace_dum freehold newbuild, robust
est store reg1

Linear regression                               Number of obs     =  1,182,574
                                                F(5, 1182568)     =   21802.32
                                                Prob > F          =     0.0000
                                                R-squared         =     0.0885
                                                Root MSE          =     .57486

------------------------------------------------------------------------------
             |               Robust
     lnprice |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
detached_dum |    .656717   .0052019   126.25   0.000     .6465215    .6669125
  semi_d_dum |   .1576852   .0045829    34.41   0.000     .1487029    .1666676
 terrace_dum |   .0831779   .0044907    18.52   0.000     .0743762    .0919796
    freehold |   .1266005   .0044615    28.38   0.000      .117856    .1353449
    newbuild |   .1031277   .0018303    56.34   0.000     .0995403    .1067151
       _cons |   12.49529   .0007933  1.6e+04   0.000     12.49373    12.49684
------------------------------------------------------------------------------

** Model 2: include all variables in Model 1, and adding on "station_km"
reg lnprice detached_dum semi_d_dum terrace_dum freehold newbuild station_km, robust
est store reg2

Linear regression                               Number of obs     =  1,182,574
                                                F(6, 1182567)     =   18276.44
                                                Prob > F          =     0.0000
                                                R-squared         =     0.1228
                                                Root MSE          =     .56394

------------------------------------------------------------------------------
             |               Robust
     lnprice |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
detached_dum |   .7167866   .0089888    79.74   0.000     .6991688    .7344044
  semi_d_dum |   .2006401   .0066507    30.17   0.000     .1876049    .2136753
 terrace_dum |   .0985848   .0044768    22.02   0.000     .0898103    .1073592
    freehold |   .1499552   .0071409    21.00   0.000     .1359593    .1639511
    newbuild |   .0934145   .0023391    39.94   0.000     .0888299    .0979992
  station_km |  -.2064287   .0323807    -6.38   0.000    -.2698938   -.1429637
       _cons |   12.61579   .0188947   667.69   0.000     12.57876    12.65283
------------------------------------------------------------------------------

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


