library(tidycensus)
library(tidyverse)
library(sf)
library(tigris)
library(rgeos)
library(sp)
#install.packages(sf)

options(tigris_use_cache = TRUE)


census_api_key("b4f929484bb795b703dd9623754054573943a66f")


listy <- zctas(starts_with = c("10","11"), state = "NY")

help(zctas)
ny1834 <- get_acs(state = "NY", geography = "zcta", variables = "B27010_050", geometry = T, year = 2016)
ny1834
#help(get_acs)

ny3564 <- get_acs(geography = "zcta", variables = "B27010_033", state = "NY", year = 2016)
ny3564
ny_age <- rbind(ny1834,ny3564)

ny_age.group_by(GEOID)

med_inc <- get_acs(geography = "zcta", variables = "B19013_001E", state = "NY", year = 2016)


race_white <- get_acs(geography = "zcta", variables = "B02001_002", state = "NY", year = 2016)



fam4 <- get_acs(geography = "zcta", variables = "B11016_005", state = "NY", year = 2016)

fam5 <- get_acs(geography = "zcta", variables = "B11016_006", state = "NY", year = 2016)

fam6 <- get_acs(geography = "zcta", variables = "B11016_007", state = "NY", year = 2016)

fam7m <- get_acs(geography = "zcta", variables = "B11016_008", state = "NY", year = 2016)



nonfam4 <- get_acs(geography = "zcta", variables = "B11016_013", state = "NY", year = 2016)

nonfam5 <- get_acs(geography = "zcta", variables = "B11016_014", state = "NY", year = 2016)

nonfam6 <- get_acs(geography = "zcta", variables = "B11016_015", state = "NY", year = 2016)

nonfam7m <- get_acs(geography = "zcta", variables = "B11016_016", state = "NY", year = 2016)



pub_trans <- get_acs(geography = "zcta", variables = "B08301_010", state = "NY", year = 2016)



eld6566 <- get_acs(geography = "zcta", variables = "B01001_020", state = "NY", year = 2016)

eld_6667 <- get_acs(geography = "zcta", variables = "B01001_021", state = "NY", year = 2016)

eld_6768 <- get_acs(geography = "zcta", variables = "B01001_022", state = "NY", year = 2016)

eld_6869 <- get_acs(geography = "zcta", variables = "B01001_023", state = "NY", year = 2016)

eld_6970 <- get_acs(geography = "zcta", variables = "B01001_024", state = "NY", year = 2016)

eld_70a <- get_acs(geography = "zcta", variables = "B01001_025", state = "NY", year = 2016)



f_eld_6566 <- get_acs(geography = "zcta", variables = "B01001_044", state = "NY", year = 2016)

f_eld_6667 <- get_acs(geography = "zcta", variables = "B01001_045", state = "NY", year = 2016)

f_eld_6768 <- get_acs(geography = "zcta", variables = "B01001_046", state = "NY", year = 2016)

f_eld_6869 <- get_acs(geography = "zcta", variables = "B01001_047", state = "NY", year = 2016)

f_eld_6970 <- get_acs(geography = "zcta", variables = "B01001_048", state = "NY", year = 2016)

f_eld_70a <- get_acs(geography = "zcta", variables = "B01001_049", state = "NY", year = 2016)



plot(ny1834["estimate"])



