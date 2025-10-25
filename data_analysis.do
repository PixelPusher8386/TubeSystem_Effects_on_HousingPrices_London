
/*
Introduction:
- Two datasets will be provided in the zipped folder. Crime: land_registry_crime.dta and pollution dataset: land_registry_pollution.dta . Depending on the variable of interest your group has chosen, you will be using the respective dataset for your project 
- This do-file summarizes a set of codes that allow you to use the data, generate some variables, and run the regression. Finally, there will be a set of codes guiding you how to plot the regression results to create the index.
- So what exactly is a do-file? We keep a dofile to record the codes for our statistical analysis. This is very useful because we can 1. keep track of our mistakes if there are any, 2. manage data on stata and keep our original data in the raw form and 3. repeat and make changes to our analysis.   
- The dofile will be structured in the following way - the first part covers pollution while the second part covers the crime dataset. Take note that you only need to focus on the dataset related to your variable of interest.
- Some important key points here: (1) Once you unzipped the zip file, always double click on the dofile (to open using stata) to run the codes (2) the text in green (including this section) entails the comments for each command (3) regression output (e.g results in excel) can be found in the same zip folder
- Please take some time to understand how each line of code works.  
*/


set more off, perm // setting an option that allows your codes to run continuously

****************************************
************ Pollution *****************
****************************************

** In case you are facing problems reading the files, you can uncomment this (take away the back slashes) to run this part. Take note that the folder path in the " " should be where your unzipped files are. 
** This path will be specific to your computer
// cd "G:\Dropbox\Teaching\Housing Economics\Project"

** Opening dataset 
u land_registry_pollution.dta, clear

** Installing reghdfe - a statistical package that allows you to include fixed effects (area and/or time). ssc install allow us to install additional packages. The command capture: in front allow us avoid stopping despite facing errors.
capture: ssc install reghdfe
reghdfe, compile
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

** Running the analysis:
/*
Notes:
- reg is the command for running a simple ordinary least square regression.
- First variable lnprice is the dependent variable of interest. (your Y)
- Subsequent variables are housing characteristics that act as independent variables (your X's)
- Coef is the estimated beta. Null hypothesis is that the beta = 0. If we reject the null hypothesis, we conclude that there is a statistically significant relationship between the certain X variable and Y. Put differently, this particular housing characteristic i
- Option robust just correct the standard errors for heteroscedasticity.
- Note that the specifications I ran here is very parsimonious. Feel free to add in more variables in your analysis. If, for instance, you believe that some variables are affecting house prices non-linearly, you can consider adding the non-linear squared terms.
*/

eststo clear // this command clears your stored estimates. 

* 1. Simple Model: Looking at structural characteristics:
reg lnprice detached_dum semi_d_dum terrace_dum freehold newbuild, robust
est store reg1 // here we are storing the regression estimates, under name reg1. 

/*
Linear regression                               Number of obs     =    450,885     [Number of observations]
                                                F(5, 450879)      =   10097.02
                                                Prob > F          =     0.0000
                                                R-squared         =     0.1005	   [Variation of house prices explained by the model]
                                                Root MSE          =     .54228		
												
------------------------------------------------------------------------------
             |               Robust
     lnprice |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
detached_dum |   .6475392   .0078034    82.98   0.000     .6322447    .6628336     [Detached housing are, on average, selling at prices 65% more than Flats]
  semi_d_dum |   .1677273   .0069677    24.07   0.000     .1540708    .1813838
 terrace_dum |   .0494551    .006848     7.22   0.000     .0360333     .062877
    freehold |   .1373837   .0067959    20.22   0.000     .1240639    .1507034	   [Freehold are sold at 14% more than leasehold flats]
    newbuild |   .1323672   .0026836    49.32   0.000     .1271074    .1376269	   [Newbuilds are sold at 13% more than older flats]
       _cons |   12.45513   .0012742  9774.89   0.000     12.45263    12.45762
------------------------------------------------------------------------------

** Remember, it is always relative to the omitted group of interest, holding all other factors constant.

*/

* 2. Adding in Air Quality:
reg lnprice detached_dum semi_d_dum terrace_dum freehold newbuild pm10, robust
est store reg2 // here we are storing the regression estimates, under name reg2. 


/*
Linear regression                               Number of obs     =    450,885
                                                F(6, 450878)      =    8958.11
                                                Prob > F          =     0.0000
                                                R-squared         =     0.1042
                                                Root MSE          =     .54116

------------------------------------------------------------------------------
             |               Robust
     lnprice |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
detached_dum |   .6564444   .0077904    84.26   0.000     .6411755    .6717134
  semi_d_dum |   .1748146   .0069437    25.18   0.000     .1612052    .1884239
 terrace_dum |   .0508094     .00682     7.45   0.000     .0374424    .0641764
    freehold |   .1406117   .0067659    20.78   0.000     .1273508    .1538726
    newbuild |   .1374038   .0026838    51.20   0.000     .1321436    .1426639
        pm10 |   .0061303   .0001498    40.93   0.000     .0058367    .0064238     [1 unit increase in pm10 increases housing values by 0.6%???? This doesn't make sense?]
       _cons |   12.29461   .0039751  3092.87   0.000     12.28682     12.3024
------------------------------------------------------------------------------
*/

* 3. Let us now try to partial out time invariant unobservables with the inclusion of year and area (local authority) fixed effects. This is implemented with the reghdfe command using absorb. Absorb (year la) basically means include la (local authority fixed effects) and year fixed effects. You can change these variables to include fixed effects at a more granular spatial level. This is equivalent to adding a dummy variable for each area (For instance, in Singapore context, we can including an Ang Mo Kio, Jurong West, Bishan Dummy....etc) and year (1999, 2000,... etc). 

	* What exactly we are doing here:
// Area fixed effects control for time-invariant unobservables specific to a particular area. By controlling area fixed effects, we are now exploiting within area variation. In other words, by adding in a Jurong West dummy, we are exploiting the variation of crime/air quality within Jurong West Area! This is useful because we are comparing similar properties in the same area but with different exposure to the disamenity of interest.    
// Year fixed effects control for general changes in house prices across areas over time (recall how we plot the house price index).  


// You can start off with larger spatial fixed effects - at local authority levels. How many local authorities are there?

reghdfe lnprice detached_dum semi_d_dum terrace_dum freehold newbuild pm10 thamesriv_dist tube_distnear bus_distnear grossannualpay jobdensity hoursworked unemployment, absorb(year la_name) vce(robust)
est store reg3 // here we are storing the regression estimates, under name reg3. 


/*

HDFE Linear regression                            Number of obs   =    434,219
Absorbing 2 HDFE groups                           F(  13, 434162) =   15971.29
                                                  Prob > F        =     0.0000
                                                  R-squared       =     0.5399
                                                  Adj R-squared   =     0.5398
                                                  Within R-sq.    =     0.3545
                                                  Root MSE        =     0.3837

--------------------------------------------------------------------------------
               |               Robust
       lnprice |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
---------------+----------------------------------------------------------------
  detached_dum |   .8625499   .0062318   138.41   0.000     .8503357     .874764
    semi_d_dum |   .3691868   .0052474    70.36   0.000     .3589019    .3794716
   terrace_dum |   .1861882   .0050941    36.55   0.000     .1762038    .1961725
      freehold |   .2558086   .0050384    50.77   0.000     .2459335    .2656837
      newbuild |   .1807481   .0021708    83.26   0.000     .1764933    .1850029
          pm10 |   .0005997   .0001266     4.74   0.000     .0003517    .0008478 [1 unit increase in pm10 increases housing values by 0.06%???? This still doesn't make sense right?]
thamesriv_dist |  -8.91e-06   3.69e-07   -24.14   0.000    -9.63e-06   -8.18e-06
 tube_distnear |  -.0000571   5.52e-07  -103.38   0.000    -.0000581    -.000056 [How should we interpret this variable?]
  bus_distnear |   .0003116   6.00e-06    51.96   0.000     .0002999    .0003234
grossannualpay |  -3.93e-06   5.96e-07    -6.59   0.000    -5.10e-06   -2.76e-06
    jobdensity |   .5650288   .0159332    35.46   0.000     .5338002    .5962575
   hoursworked |    .006948    .002132     3.26   0.001     .0027693    .0111267
  unemployment |  -.0145686   .0006435   -22.64   0.000    -.0158298   -.0133074
         _cons |   11.91229   .0863015   138.03   0.000     11.74314    12.08144
--------------------------------------------------------------------------------

Absorbed degrees of freedom:
-----------------------------------------------------+
 Absorbed FE | Categories  - Redundant  = Num. Coefs |
-------------+---------------------------------------|
        year |        10           0          10     | [Tells you the number of year dummies and local authority fixed effects you control for in your analysis. In other words, there are a total of 35 Local Authorities in your sample]
     la_name |        35           1          34     |
-----------------------------------------------------+

*/


// You can then add in more granular spatial fixed effects. Lets now control at MSOA level....

reghdfe lnprice detached_dum semi_d_dum terrace_dum freehold newbuild pm10 thamesriv_dist tube_distnear bus_distnear grossannualpay jobdensity hoursworked unemployment, absorb(year msoa11) vce(robust)
est store reg4 // here we are storing the regression estimates, under name reg4. 


/*
HDFE Linear regression                            Number of obs   =    434,213
Absorbing 2 HDFE groups                           F(  13, 433414) =   19883.42
                                                  Prob > F        =     0.0000
                                                  R-squared       =     0.6739
                                                  Adj R-squared   =     0.6733
                                                  Within R-sq.    =     0.4016
                                                  Root MSE        =     0.3233

--------------------------------------------------------------------------------
               |               Robust
       lnprice |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
---------------+----------------------------------------------------------------
  detached_dum |   .6853205   .0054694   125.30   0.000     .6746006    .6960404
    semi_d_dum |   .3198862   .0046255    69.16   0.000     .3108204    .3289521
   terrace_dum |    .183947   .0045131    40.76   0.000     .1751014    .1927926
      freehold |   .3221132   .0044724    72.02   0.000     .3133475    .3308789
      newbuild |   .1849797   .0020674    89.48   0.000     .1809277    .1890317
          pm10 |  -.0018662   .0001614   -11.56   0.000    -.0021826   -.0015497 [1 unit increase in pm10 now reduces housing values by 0.18%. This make more sense now...]
thamesriv_dist |  -.0000171   1.54e-06   -11.11   0.000    -.0000201   -.0000141
 tube_distnear |   -.000019   1.77e-06   -10.70   0.000    -.0000225   -.0000155
  bus_distnear |   .0002279   5.34e-06    42.65   0.000     .0002175    .0002384
grossannualpay |   5.02e-06   5.12e-07     9.82   0.000     4.02e-06    6.02e-06
    jobdensity |   .5582578   .0152688    36.56   0.000     .5283315    .5881841
   hoursworked |   .0190496   .0018097    10.53   0.000     .0155027    .0225965
  unemployment |  -.0150842   .0005822   -25.91   0.000    -.0162253   -.0139431
         _cons |   11.23891   .0735705   152.76   0.000     11.09472    11.38311
--------------------------------------------------------------------------------

Absorbed degrees of freedom:
-----------------------------------------------------+
 Absorbed FE | Categories  - Redundant  = Num. Coefs |
-------------+---------------------------------------|
        year |        10           0          10     |
      msoa11 |       777           1         776     |
-----------------------------------------------------+


*/

// Recall you have been storing your regression estimates under reg1 to reg4. You can now export these regression results in excel table. Once you are done running your regressions, you can export it out using outreg2. Whenever you face any problems with any commands, you can always use the following command 

help outreg2 // note that you can do the same thing with any commands

outreg2 detached_dum semi_d_dum terrace_dum freehold newbuild pm10 thamesriv_dist tube_distnear bus_distnear grossannualpay jobdensity hoursworked unemployment [reg1 reg2 reg3 reg4] using results_pollution.xls, replace dec(5) seeout 

/*
** Notes
- The first list = your variable list
- The second list with [] is your estimate store list. Recall we save them as reg1 to reg4
- results.xls is your filename that stores all the results
- replace option allows you to override the existing file. Take note that you will need to close the results file in excel before you are able to overwrite the file.
- dec(5) means that you are saving your coefficients at 5 decimal places. You can easily make the adjustments.
- There are more options available to customize your outputs. Please use the help command for more information.
*/


// After you have decided on your final specification, you can rerun the regressions but this time round your focus will be on creating the hedonic price index, plotting on the time dummies (here year-quartely) that captures the variation of house prices over time. We will run the regressions and estimate the yearquarter dummies using i.yearquarter_num

eststo clear
cap:egen yearquarter_num = group(yearquarter) //allows you to change string variables to numerical variables for your regression. 
reghdfe lnprice detached_dum semi_d_dum terrace_dum freehold newbuild pm10 thamesriv_dist tube_distnear bus_distnear grossannualpay jobdensity hoursworked unemployment i.yearquarter_num, absorb(msoa11) vce(robust)
tab yearquarter if e(sample)==1
parmest, level(95) format(estimate min95 max95 %8.2f p %8.3f) saving(price_index.dta, replace) //parmest is a command that allows you to save your regression output as a stata data. You can then manipulate this data and plot them out as an index.

** Graphing the estimates: Stata is useful because you can construct visually attractive graphs from your data or your regression output. 
u price_index.dta, clear //opening the regression output

** Cleaning up the dataset, focusing on the time dummies
g keep = substr(parm,strpos(parm,"year")-1,1) //identifying the yearquarter_num observations
keep if keep=="." //keeping the relevant coefficients
drop keep
split parm, p(.)
replace estimate = (estimate+1)*100 // converting the estimates with 100 as the base period. Recall the base period is the reference group in which the dummy is ommitted. In this case, they are sales made in 2005Q1 (OR timeperiod 1)
destring parm1, force replace
replace parm1 = 1 if parm1==.
rename parm1 timeperiod

** graphing the estimates: 
	set scheme s1mono
		graph twoway (scatter estimate timeperiod, lcolor(black) msymbol(oh) mcolor(black) mlabel(estimate) mlabsize(tiny) mlabposition(12))(line estimate timeperiod, lcolor(black)), ///
		legend(off) ytitle("Price Index (Base = 2005Q1)") xtitle("Year-Quarter") ///
		xlabel(1 "2005Q1" 5 "2006Q1" 9 "2007Q1" 13 "2008Q1" 17 "2009Q1" 21 "2010Q1" 25 "2011Q1" 29 "2012Q1" 33 "2013Q1" 37 "2014Q1", labsize(small)) /// here, i am relabelling the x-axis from time period (which runs from 1 to 20+ to yearquarter variables)
		ylabel(100(10)150, format(%9.0g)) ///
		aspect(0.5) 
		graph export priceindex_pollution.png, as(png) replace

/*
** Notes
- In short, what we did here is that we extract the time dummies that we have estimated and try to plot them out graphically. It is definitely worthwhile to invest sometime understanding this code here
- Graph twoway allows us to plot a 2 way graph here: first we do a scatter plot of the estimates, then we join them using a linear
- The first set of brackets () is for the scatterplot. Here we try to plot them as dots, and label them. Second set is for the line plotting the line estimates. 
- Graph export allows you to save your graph as an image.
*/




************************************
************ Crime *****************
************************************

** In case you are facing problems reading the files, you can uncomment this (take away the back slashes) to run this part. Take note that the folder path in the " " should be where your unzipped files are. 
** This path will be specific to your computer
// cd "G:\Dropbox\Teaching\Housing Economics\Project"

** Opening dataset 
u land_registry_crime.dta, clear

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
}


** Running the analysis:
/*
Notes:
- reg is the command for running a simple ordinary least square regression.
- First variable lnprice is the dependent variable of interest. (your Y)
- Subsequent variables are housing characteristics that act as independent variables (your X's)
- Coef is the estimated beta. Null hypothesis is that the beta = 0. If we reject the null hypothesis, we conclude that there is a statistically significant relationship between the certain X variable and Y. Put differently, this particular housing characteristic i
- Option robust just correct the standard errors for heteroscedasticity 
- Note that the specifications I ran here is very parsimonious. Feel free to add in more variables in your analysis. If, for instance, you believe that some variables are affecting house prices non-linearly, you can consider adding the non-linear squared terms.
*/

eststo clear // this command clears your stored estimates. 

* 1. Simple Model: Looking at structural characteristics:
reg lnprice detached_dum semi_d_dum terrace_dum freehold newbuild, robust
est store reg1 // here we are storing the regression estimates, under name reg1. 

/*
Linear regression                               Number of obs     =    450,885     [Number of observations]
                                                F(5, 450879)      =   10097.02
                                                Prob > F          =     0.0000
                                                R-squared         =     0.1005	   [Variation of house prices explained by the model]
                                                Root MSE          =     .54228		
												
------------------------------------------------------------------------------
             |               Robust
     lnprice |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
detached_dum |   .6475392   .0078034    82.98   0.000     .6322447    .6628336     [Detached housing are, on average, selling at prices 65% more than Flats]
  semi_d_dum |   .1677273   .0069677    24.07   0.000     .1540708    .1813838
 terrace_dum |   .0494551    .006848     7.22   0.000     .0360333     .062877
    freehold |   .1373837   .0067959    20.22   0.000     .1240639    .1507034	   [Freehold are sold at 14% more than leasehold flats]
    newbuild |   .1323672   .0026836    49.32   0.000     .1271074    .1376269	   [Newbuilds are sold at 13% more than older flats]
       _cons |   12.45513   .0012742  9774.89   0.000     12.45263    12.45762
------------------------------------------------------------------------------

** Remember, it is always relative to the omitted group of interest, holding all other factors constant.
*/

* 2. Adding in Crime :
reg lnprice detached_dum semi_d_dum terrace_dum freehold newbuild log_allcrime, robust
est store reg2 // here we are storing the regression estimates, under name reg2. 

/*

Linear regression                               Number of obs     =    549,813
                                                F(6, 549806)      =    7116.29
                                                Prob > F          =     0.0000
                                                R-squared         =     0.0733
                                                Root MSE          =      .6151

------------------------------------------------------------------------------
             |               Robust
     lnprice |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
detached_dum |   .6110636     .00876    69.76   0.000     .5938942     .628233
  semi_d_dum |   .1469399   .0080047    18.36   0.000      .131251    .1626288
 terrace_dum |   .1106149   .0078462    14.10   0.000     .0952365    .1259932
    freehold |   .1170153   .0078223    14.96   0.000     .1016838    .1323468
    newbuild |    .063852   .0027967    22.83   0.000     .0583706    .0693335
log_allcrime |   .0140066   .0006373    21.98   0.000     .0127575    .0152556     [People paying to live near crime ridden neighbourhoods? Why?]
       _cons |    12.5745   .0030906  4068.59   0.000     12.56845    12.58056
------------------------------------------------------------------------------

*/


* 3. Let us now try to partial out time invariant unobservables with the inclusion of year and area (local authority) fixed effects. This is implemented with the reghdfe command using absorb. Absorb (year la) basically means include la (local authority fixed effects) and year fixed effects. You can change these variables to include fixed effects at a more granular spatial level. This is equivalent to adding a dummy variable for each area (For instance, in Singapore context, we can including an Ang Mo Kio, Jurong West, Bishan Dummy....etc) and year (1999, 2000,... etc). 

	* What exactly we are doing here:
// Area fixed effects control for time-invariant unobservables specific to a particular area. By controlling area fixed effects, we are now exploiting within area variation. In other words, by adding in a Jurong West dummy, we are exploiting the variation of crime/air quality within Jurong West Area! This is useful because we are comparing similar properties in the same area but with different exposure to the disamenity of interest.    
// Year fixed effects control for general changes in house prices across areas over time (recall how we plot the house price index).  


// You can start off with larger spatial fixed effects - at local authority levels. How many local authorities are there?

reghdfe lnprice detached_dum semi_d_dum terrace_dum freehold newbuild log_allcrime thamesriv_dist tube_distnear bus_distnear grossannualpay jobdensity hoursworked unemployment, absorb(year la_name) vce(robust)
est store reg3 // here we are storing the regression estimates, under name reg3. 


/*
HDFE Linear regression                            Number of obs   =    496,514
Absorbing 2 HDFE groups                           F(  13, 496464) =   18287.96
                                                  Prob > F        =     0.0000
                                                  R-squared       =     0.5544
                                                  Adj R-squared   =     0.5544
                                                  Within R-sq.    =     0.3529
                                                  Root MSE        =     0.4268

--------------------------------------------------------------------------------
               |               Robust
       lnprice |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
---------------+----------------------------------------------------------------
  detached_dum |   .8752119   .0069334   126.23   0.000     .8616227    .8888011
    semi_d_dum |   .4002149   .0061102    65.50   0.000     .3882392    .4121906
   terrace_dum |   .2116027   .0059617    35.49   0.000     .1999179    .2232874
      freehold |   .2967683    .005936    49.99   0.000     .2851338    .3084027
      newbuild |   .1794604   .0022525    79.67   0.000     .1750455    .1838752
  log_allcrime |  -.0387723   .0009835   -39.42   0.000    -.0406998   -.0368447 [1% increase in crime corresponds to a -0.038% decrease in housing values. This makes more sense]
thamesriv_dist |  -.0000308   4.01e-07   -76.76   0.000    -.0000316     -.00003
 tube_distnear |  -.0000375   4.87e-07   -76.85   0.000    -.0000384   -.0000365
  bus_distnear |   .0003067   6.51e-06    47.12   0.000      .000294    .0003195
grossannualpay |  -6.33e-06   6.69e-07    -9.46   0.000    -7.65e-06   -5.02e-06
    jobdensity |   .4638096   .0251203    18.46   0.000     .4145746    .5130446
   hoursworked |  -.0023079    .001935    -1.19   0.233    -.0061005    .0014847
  unemployment |  -.0000476   .0007455    -0.06   0.949    -.0015088    .0014137
         _cons |   12.73466   .0842146   151.22   0.000     12.56961    12.89972
--------------------------------------------------------------------------------

Absorbed degrees of freedom:
-----------------------------------------------------+
 Absorbed FE | Categories  - Redundant  = Num. Coefs |
-------------+---------------------------------------|
        year |         5           0           5     |
     la_name |        33           1          32     |
-----------------------------------------------------+
*/

// Adding in finer spatial fixed effects
reghdfe lnprice detached_dum semi_d_dum terrace_dum freehold newbuild log_allcrime thamesriv_dist tube_distnear bus_distnear grossannualpay jobdensity hoursworked unemployment, absorb(year msoa11) vce(robust)
est store reg4 // here we are storing the regression estimates, under name reg4. 

/*


HDFE Linear regression                            Number of obs   =    496,515
Absorbing 2 HDFE groups                           F(  13, 495515) =   24476.88
                                                  Prob > F        =     0.0000
                                                  R-squared       =     0.6947
                                                  Adj R-squared   =     0.6941
                                                  Within R-sq.    =     0.4148
                                                  Root MSE        =     0.3536

--------------------------------------------------------------------------------
               |               Robust
       lnprice |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
---------------+----------------------------------------------------------------
  detached_dum |   .7137413   .0060731   117.52   0.000     .7018382    .7256445
    semi_d_dum |     .37023   .0053868    68.73   0.000     .3596721    .3807879
   terrace_dum |   .2258393   .0052735    42.83   0.000     .2155034    .2361751
      freehold |   .3633321   .0052516    69.19   0.000     .3530393     .373625
      newbuild |   .1930816   .0021369    90.35   0.000     .1888932    .1972699
  log_allcrime |  -.0091277   .0010124    -9.02   0.000     -.011112   -.0071434 [What happens to the coefficients now?]
thamesriv_dist |  -.0000423   1.56e-06   -27.15   0.000    -.0000453   -.0000392
 tube_distnear |  -6.17e-06   1.69e-06    -3.66   0.000    -9.49e-06   -2.86e-06
  bus_distnear |   .0002944   5.68e-06    51.80   0.000     .0002833    .0003056
grossannualpay |  -4.89e-06   5.46e-07    -8.96   0.000    -5.96e-06   -3.82e-06
    jobdensity |    .473078   .0219987    21.50   0.000     .4299612    .5161948
   hoursworked |   .0041463   .0015183     2.73   0.006     .0011705    .0071221
  unemployment |  -.0017226   .0006274    -2.75   0.006    -.0029522   -.0004929
         _cons |   12.28042   .0670845   183.06   0.000     12.14894    12.41191
--------------------------------------------------------------------------------

Absorbed degrees of freedom:
-----------------------------------------------------+
 Absorbed FE | Categories  - Redundant  = Num. Coefs |
-------------+---------------------------------------|
        year |         5           0           5     |
      msoa11 |       983           1         982     |
-----------------------------------------------------+

*/

// Recall you have been storing your regression estimates under reg1 to reg4. You can now export these regression results in excel table. Once you are done running your regressions, you can export it out using outreg2. Whenever you face any problems with any commands, you can always use the following command 

help outreg2 // note that you can do the same thing with any commands

outreg2 detached_dum semi_d_dum terrace_dum freehold newbuild log_allcrime thamesriv_dist tube_distnear bus_distnear grossannualpay jobdensity hoursworked unemployment [reg1 reg2 reg3 reg4] using results_crime.xls, replace dec(5) seeout 

/*
** Notes
- The first list = your variable list
- The second list with [] is your estimate store list. Recall we save them as reg1 to reg4
- results.xls is your filename that stores all the results
- replace option allows you to override the existing file. Take note that you will need to close the results file in excel before you are able to overwrite the file.
- dec(5) means that you are saving your coefficients at 5 decimal places. You can easily make the adjustments.
- There are more options available to customize your outputs. Please use the help command for more information.
*/


// After you have decided on your final specification, you can rerun the regressions but this time round your focus will be on creating the hedonic price index, plotting on the time dummies (here year-quartely) that captures the variation of house prices over time. We will run the regressions and estimate the yearquarter dummies using i.yearquarter_num

eststo clear
cap:egen yearquarter_num = group(yearquarter) //allows you to change string variables to numerical variables for your regression. 
reghdfe lnprice detached_dum semi_d_dum terrace_dum freehold newbuild log_allcrime thamesriv_dist tube_distnear bus_distnear grossannualpay jobdensity hoursworked unemployment i.yearquarter_num, absorb(msoa11) vce(robust)
tab yearquarter if e(sample)==1
parmest, level(95) format(estimate min95 max95 %8.2f p %8.3f) saving(price_index.dta, replace) //parmest is a command that allows you to save your regression output as a stata data. You can then manipulate this data and plot them out as an index.

** Graphing the estimates: Stata is useful because you can construct visually attractive graphs from your data or your regression output. 
u price_index.dta, clear //opening the regression output

** Cleaning up the dataset, focusing on the time dummies
g keep = substr(parm,strpos(parm,"year")-1,1) //identifying the yearquarter_num observations
keep if keep=="." //keeping the relevant coefficients
drop keep
split parm, p(.)
replace estimate = (estimate+1)*100 // converting the estimates with 100 as the base period. Recall the base period is the reference group in which the dummy is ommitted. In this case, they are sales made in 2005Q1 (OR timeperiod 1)
destring parm1, force replace
replace parm1 = 1 if parm1==.
rename parm1 timeperiod

** graphing the estimates: 
	set scheme s1mono
		graph twoway (scatter estimate timeperiod, lcolor(black) msymbol(oh) mcolor(black) mlabel(estimate) mlabsize(tiny) mlabposition(12))(line estimate timeperiod, lcolor(black)), ///
		legend(off) ytitle("Price Index (Base = 2005Q1)") xtitle("Year-Quarter") ///
		xlabel(1 "2010Q1" 5 "2011Q1" 9 "2012Q1" 13 "2013Q1" 17 "2014Q1", labsize(small)) /// here, i am relabelling the x-axis from time period (which runs from 1 to 20+ to yearquarter variables)
		ylabel(100(10)150, format(%9.0g)) ///
		aspect(0.5) 
		graph export priceindex_crime.png, as(png) replace
		
		
	

