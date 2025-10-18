Coursework for HE3027: Housing Economics (NTU, AY25/26)
TubeSystem_Effects_on_HousingPrices_London

This is my thought process to "divide and conquer" the dataset

1. Generate natural logarithm of price, add this as a new column. This adjusts for outliers.
2. Dummy variables references will be flat, freehold, newbuild
3. For column newbuild, replace Y as 1 and N as 0. replace with numeric dummy values
4. robust will be used to correct the standard errors for heteroscedasticity.
5. Simple model 1: assess only the structural characteristics of the house. These includes: property type, age (newbuild or not), type of hold
6. Model 2: include all variables in Model 1, and adding on "station_km"
7. Model 3: Area fixed effects control & Year fixed effects control
  a) for time-invariant unobservables specific to a particular area. 
By controlling area fixed effects, we are now exploiting within area variation. 
In other words, by adding in a Jurong West dummy, we are exploiting the variation of crime/air quality within Jurong West Area! 
This is useful because we are comparing similar properties in the same area but with different exposure to the disamenity of interest.    
  b) for general changes in house prices across areas over time (recall how we plot the house price index).
8. Model 3a: control for year & large-scale area (lsoa)
9. Model 3b: control for year & granular area (msoa)
10. Rerun to work out hedonic pricing model
11. Draw graphs to illustrate main observations
