#----------------------------- Load Neccessary Packages ------------------------
library(tidyverse)
library(haven)
library(dplyr)
library(broom)
install.packages("fixest")
library(fixest)

# Load the .dta file. Dataframe will be displayed at "Environment" window, upper right of the screen
london_tube <- read_dta(file.choose())
summary(london_tube)

#------------------------------- Data Cleaning ---------------------------------
# We will drop "tube_distnear" which has been declared obsolete
london_tube <- select(london_tube,-"tube_distnear")

# Generate natural logarithm of price, add this as a new column. This adjusts for outliers
london_tube <- london_tube %>% mutate(log_price = log(price))
# Another command for the same logic is london_tube$log_price <- log(london_tube$price)

# For column age, replace Y as 1 and N as 0. Base dummy is "newbuild is 0"
london_tube <- london_tube %>% 
  mutate(age = str_replace_all(age, c("Y" = "1", "N" = "0"))) %>%
  mutate(age = as.numeric(age))

# Other dummy variables have been prepared, which are detached_dum, flat_dum, 
# semi_d_dum, terrace_dum, freehold, leasehold

#---------------------------------- Modeling ------------------------------------
# Simple model 1: assess only the structural characteristics of the house. 
model_1 <- lm(log_price ~  detached_dum + semi_d_dum + terrace_dum + leasehold 
               + age, data = london_tube)
print("--------------------------- Simple Model 1 ----------------------------")
#tidy(model_ols)
summary(model_1)

# Model 2: include all variables in Model 1, and adding on "station_km"
model_2 <- lm(log_price ~  detached_dum + semi_d_dum + terrace_dum + leasehold 
                + age + station_km, data = london_tube)
print("------------------------------- Model 2 -------------------------------")
#tidy(model_2)
summary(model_2)

# Model 3: Area fixed effects control & Year fixed effects control
# 1. for time-invariant unobservables specific to a particular area. 
# By controlling area fixed effects, we are now exploiting within area variation. 
# In other words, by adding in a Jurong West dummy, we are exploiting the variation of crime/air quality within Jurong West Area! 
# This is useful because we are comparing similar properties in the same area but with different exposure to the disamenity of interest.    
# 2. for general changes in house prices across areas over time (recall how we plot the house price index).

# Model 3a: control for year & large-scale area (lsoa)
model_3a <- feols(log_price ~  detached_dum + semi_d_dum + terrace_dum + leasehold 
                 + age + station_km + thamesriv_dist + dist_to_cbd
                 + bus_distnear + grossannualpay + hoursworked
                 + unemployment + jobdensity | postcode + lsoacode, 
                 cluster = ~lsoacode, collin.tol = 1e-100,
                 data = london_tube)
print("------------------------------- Model 3a ------------------------------")
summary(model_3a)

# Model 3b: control for year & granular area (msoa)
model_3b <- feols(log_price ~  detached_dum + semi_d_dum + terrace_dum + leasehold 
                 + age + station_km + thamesriv_dist + dist_to_cbd
                 + bus_distnear + grossannualpay + hoursworked
                 + unemployment + jobdensity | postcode + msoa11, 
                 cluster = ~msoa11, collin.tol = 1e-100,
                 data = london_tube)
print("------------------------------- Model 3b ------------------------------")
summary(model_3b)
