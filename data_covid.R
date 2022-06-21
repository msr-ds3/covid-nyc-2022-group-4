library(tidyverse)
library(tidycensus)
library(tigris)

packageVersion("tibble")
packageVersion("sf")
packageVersion("vctrs")

options(tigris_use_cache = TRUE)

census_api_key("8964974e588c5cc1228d54499453cd8b41c8e1eb", install = TRUE)

data_16 <- load_variables(2016, "acs5", cache = TRUE) 
data_16

#load the different variables 

#proportion of 18-64 year old population that is uninsured
df_uninsured <- get_acs(geography = "zcta",
                        variables = c(pop_18_to_34 = "B27010_033",
                                      pop_35_to_64 = "B27010_050",
                                      pop_in_zipcode = "B01001_001"),
                        state = "NY",
                        #county = c("Queens","New York", "Kings", "Bronx", "Richmond"),
                        year = 2016,
                        #geometry = T, 
                        output = "wide") 
#create a column with proportion
df_uninsured <- df_uninsured %>% mutate(pop_uninsured = (pop_18_to_34E + pop_35_to_64E)/pop_in_zipcodeE)

#median

#median household income
df_med_income <- get_acs(geography = "zcta",
              variables = c(med_income = "B19013_001E"),
              state = "NY",
              year = 2016,
              #geometry = T, 
              output = "wide")            

#proportion of population that identifies as white                    
df_white_only <- get_acs(geography = "zcta",
                         variables = c(white_only = "B02001_002",
                                       pop_in_zipcode = "B01001_001"),
                         state = "NY",
                         county = "Queens County",                            
                         year = 2016,
                         #geometry = T, 
                         output = "wide")  
#create a column with proportion
df_white_only <- df_white_only %>% mutate(perc_white_only = white_onlyE/pop_in_zipcodeE)

#proportion of population living with more than 3 inhabitants
df_more_than_three <- get_acs(geography = "zcta",
                              variables = c(three_pop = "B11016_004",
                                            four_pop = "B11016_005",
                                            five_pop = "B11016_006",
                                            six_pop = "B11016_007",
                                            seven_or_more_pop = "B11016_008",
                                            non_three_pop = "B11016_012",
                                            non_four_pop = "B11016_013",
                                            non_five_pop = "B11016_014",
                                            non_six_pop = "B11016_015",
                                            non_seven_or_more_pop = "B11016_016",
                                            pop_in_zipcode = "B01001_001"),
                              state = "NY",
                              county = "Queens County",                            
                              year = 2016,
                              #geometry = T, 
                              output = "wide")  
#create a column with proportion
df_more_than_three <- df_more_than_three %>% mutate(perc_pop_more_than_3 = (three_popE + four_popE + five_popE + six_popE + seven_or_more_popE +
                                                                         non_three_popE + non_four_popE + non_five_popE + non_six_popE +
                                                                         non_seven_or_more_popE)/pop_in_zipcodeE)

#proportion of population using public transportation
df_commute <- get_acs(geography = "zcta",
                      variables = c(commute = "B08021_010",
                                    pop_in_zipcode = "B01001_001"),
                      state = "NY",
                      county = "Queens County",                            
                      year = 2016,
                      #geometry = T, 
                      output = "wide")
#create a column with proportion
df_commute <- df_commute %>% mutate(perc_commute = commuteE/pop_in_zipcodeE)

#proportion of population that is elderly
df_elderly <- get_acs(geography = "zcta",
                      variables = c(pop_elderly_65_m = "B01001_020",
                                    pop_elderly_67_m = "B01001_021",
                                    pop_elderly_70_m = "B01001_022",
                                    pop_elderly_75_m = "B01001_023",
                                    pop_elderly_80_m = "B01001_024",
                                    pop_elderly_85_m = "B01001_025",
                                    pop_elderly_65_f = "B01001_044",
                                    pop_elderly_67_f = "B01001_045",
                                    pop_elderly_70_f = "B01001_046",
                                    pop_elderly_75_f = "B01001_047",
                                    pop_elderly_80_f = "B01001_048",
                                    pop_elderly_85_f = "B01001_049",
                                    pop_in_zipcode = "B01001_001"),
                      state = "NY",
                      county = "Queens County",                            
                      year = 2016,
                      #geometry = T, 
                      output = "wide")
df_elderly <- df_elderly %>% mutate(perc_pop_elderly = (pop_elderly_65_mE + pop_elderly_67_mE + pop_elderly_70_mE + 
                                                          pop_elderly_75_mE + pop_elderly_80_mE + pop_elderly_85_mE + 
                                                          pop_elderly_65_fE + pop_elderly_67_fE + pop_elderly_70_fE + 
                                                          pop_elderly_75_fE + pop_elderly_80_fE + pop_elderly_85_fE)/pop_in_zipcodeE)
              

#create a dataframe with only the final proportions and values needed



#testing exercise from book
library(tidycensus)
library(tidyverse)
library(tigris)
library(sf)

us_median_age <- get_acs(
  geography = "state",
  variables = "B01002_001",
  year = 2019,
  survey = "acs1",
  geometry = TRUE,
  resolution = "20m"
)

plot(us_median_age$geometry)

ggplot(data = us_median_age, aes(fill = estimate)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "RdPu", 
                       direction = 1) + 
  labs(title = "  Median Age by State, 2019",
       caption = "Data source: 2019 1-year ACS, US Census Bureau",
       fill = "ACS estimate") + 
  theme_void()

library(tidycensus)
options(tigris_use_cache = TRUE)

dc_income <- get_acs(
  geography = "tract", 
  variables = "B19013_001",
  state = "DC", 
  year = 2020,
  geometry = TRUE
)

plot(dc_income["estimate"])
