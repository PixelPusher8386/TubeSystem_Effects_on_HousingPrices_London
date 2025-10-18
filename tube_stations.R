# Load neccessary packages
library(haven)
library(dplyr)

# Load the .dta file. Dataframe will be displayed at "Environment" window, upper right of the screen
london_tube <- read_dta(file.choose())
summary(london_tube)

# We will drop "tube_distnear" which has been declared obsolete

london_tube <- select(london_tube,-"tube_distnear")
install.packages("RStata")
library(RStata)

# Generate natural logarithm of price, add this as a new column. This adjusts for outliers

# For column newbuild, replace Y as 1 and N as 0. replace with numeric dummy values

# robust will be used to correct the standard errors for heteroscedasticity.

# Simple model 1: assess only the structural characteristics of the house. These includes: property type, age (newbuild or not), type of hold

# Model 2: include all variables in Model 1, and adding on "station_km"

# Model 3: Area fixed effects control & Year fixed effects control
# 1. for time-invariant unobservables specific to a particular area. 
# By controlling area fixed effects, we are now exploiting within area variation. 
# In other words, by adding in a Jurong West dummy, we are exploiting the variation of crime/air quality within Jurong West Area! 
# This is useful because we are comparing similar properties in the same area but with different exposure to the disamenity of interest.    
# 2. for general changes in house prices across areas over time (recall how we plot the house price index).

# Model 3a: control for year & large-scale area (lsoa)

# Model 3b: control for year & granular area (msoa)