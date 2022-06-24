#script to load necessary dataframes for ses features
library(tidycensus)
#need to input a census api key to retrive the data for 2016
census_api_key("(insert-api-key-here)", install = TRUE)

data_16 <- load_variables(2016, "acs5", cache = TRUE) 
data_16

#first dataframe captures uninsured population in the age groups of 18-64 for each zipcode
df_uninsured <- get_acs(geography = "zcta",
                        variables = c(pop_18_to_34 = "B27010_033",
                                      pop_35_to_64 = "B27010_050",
                                      tot_18_to_34 = "B27010_018",
                                      tot_35_to_64 = "B27010_034"),
                        state = "NY",
                        year = 2016,
                        geometry = T, 
                        output = "wide") 

#second dataframe captures the median income data in each zipcode
med_inc <- get_acs(geography = "zcta", 
                   variables = c(income = "B19013_001E"), 
                   state = "NY", 
                   year = 2016,
                   geometry = T, 
                   output = "wide")

#third dataframe captures the amount of people that self-recognize themselves as white in each zipcode
race_white <- get_acs(geography = "zcta", 
                      variables = c(white = "B02001_002", 
                                    tot = "B01001_001"), 
                      state = "NY", 
                      year = 2016,
                      geometry = T, 
                      output = "wide")

#fourth dataframe captures the amount of households that consist of more than 3 people in each zipcode
house_size <- get_acs(geography = "zcta", 
                      variables = c(four = "B11016_005", 
                                    five = "B11016_006",
                                    six = "B11016_007",
                                    sev_more = "B11016_008",
                                    nfamfour = "B11016_013",
                                    nfamfive = "B11016_014",
                                    nfamsix = "B11016_015", 
                                    nfamsev_more = "B11016_016",
                                    total = "B11016_001"),
                      state = "NY", 
                      year = 2016,
                      geometry = T, 
                      output = "wide")

#fifth dataframe captures the amount of people that commute by bus in each zipcode
pub_trans <- get_acs(geography = "zcta", 
                     variables = c(bus = "B08301_011", 
                                   total = "B08301_001"), 
                     state = "NY", 
                     year = 2016, 
                     geometry = T, 
                     output = "wide")

#sixth datafram captures the population that is 65+ in each zipcode
elderly <- get_acs(geography = "zcta", 
                   variables = c(m65_66 = "B01001_020", 
                                 m66_67 = "B01001_021",
                                 m67_68 = "B01001_022", 
                                 m68_69 = "B01001_023", 
                                 m69_70 = "B01001_024", 
                                 m70a = "B01001_025",
                                 f65_66 = "B01001_044", 
                                 f66_67 = "B01001_045", 
                                 f67_68 = "B01001_046", 
                                 f68_69 = "B01001_047",
                                 f69_70 = "B01001_048", 
                                 f70a = "B01001_049", 
                                 total = "B01001_001"), 
                   state = "NY", 
                   year = 2016, 
                   geometry = T, 
                   output = "wide")

#saved data into a RData file
save(data = df_uninsured, med_inc, race_white, house_size, pub_trans, elderly, file = "census_2016_data.RData")
