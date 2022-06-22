library(tidyverse)
library(tidycensus)
library(tigris)

#install.packages("sf")
library(sf)


packageVersion("tibble")
packageVersion("sf")
packageVersion("vctrs")

options(tigris_use_cache = TRUE)


census_api_key("b4f929484bb795b703dd9623754054573943a66f", install = TRUE)


data_16 <- load_variables(2016, "acs5", cache = TRUE) 
data_16

#load the different variables 

zippy <- read.csv("April_1_pos_tests.csv")

zippy <- zippy %>% mutate(GEOID = MODZCTA)

zippy <- zippy %>% mutate(prop_COVID = Positive/Total)



#proportion of 18-64 year old population that is uninsured
df_uninsured <- get_acs(geography = "zcta",
                        variables = c(pop_18_to_34 = "B27010_033",
                                      pop_35_to_64 = "B27010_050",
                                      tot_18_to_34 = "B27010_018",
                                      tot_35_to_64 = "B27010_034"),
                        state = "NY",
                        #county = c("Queens","New York", "Kings", "Bronx", "Richmond"),
                        year = 2016,
                        geometry = T, 
                        output = "wide") 

df_uninsured$GEOID <- as.numeric(df_uninsured$GEOID)
df_uninsured <-  inner_join(df_uninsured, zippy, by="GEOID")

#get rid of extra columns
df_uninsured <- df_uninsured[, -c(11:13)]



#create a column with proportion
df_uninsured <- df_uninsured %>% mutate(pop_uninsured = (pop_18_to_34E + pop_35_to_64E)/(tot_18_to_34E + tot_35_to_64E))
summary(df_uninsured)

#median proportion of 18 to 64 year olds with no insurance
#

#graph
ggplot(data = df_uninsured, aes(fill = pop_uninsured)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "YlOrRd", 
                       direction = 1)


uninsured_model <- lm(prop_COVID ~ pop_uninsured, data = df_uninsured)

summary(uninsured_model)



#-------------now for median income
med_inc <- get_acs(geography = "zcta", variables = c(income = "B19013_001E"), state = "NY", year = 2016,
                   geometry = T, 
                   output = "wide")


med_inc$GEOID <- as.numeric(med_inc$GEOID)
med_inc <-  inner_join(med_inc, zippy, by="GEOID")

#get rid of extra columns
med_inc <- med_inc[, -c(5:7)]

summary(med_inc)

med_inc <- med_inc %>% mutate(income_mil = income/1000000)


#graph
ggplot(data = med_inc, aes(fill = income_mil)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "YlGn", 
                       direction = 1)

income_model <- lm(prop_COVID ~ income_mil, data = med_inc)

summary(income_model)



#---------------end of median income


#--------------beginning of race_white

race_white <- get_acs(geography = "zcta", variables = c(white = "B02001_002", tot = "B01001_001"), state = "NY", year = 2016,
                      geometry = T, 
                      output = "wide")

race_white$GEOID <- as.numeric(race_white$GEOID)
race_white <-  inner_join(race_white, zippy, by="GEOID")

race_white <- race_white[, -c(7:9)]

race_white <- race_white %>% mutate(prop_white = whiteE / totE)


summary(race_white)

ggplot(data = race_white, aes(fill = prop_white)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "Purples", 
                       direction = 1)


#r squared
race_model <- lm(prop_COVID ~ prop_white, data = race_white)

summary(race_model)


#-------------end of race_white

#---------------------------beginning of house_size

house_size <- get_acs(geography = "zcta", variables = c(four = "B11016_005", 
                                                  five = "B11016_006",
                                                  six = "B11016_007",
                                                  sev_more = "B11016_008",
                                                  nfamfour = "B11016_013",
                                                  nfamfive = "B11016_014",
                                                  nfamsix = "B11016_015", 
                                                  nfamsev_more = "B11016_016",
                                                  total = "B11016_001"),
                                                  state = "NY", year = 2016,
                                                  geometry = T, 
                                                  output = "wide")


house_size$GEOID <- as.numeric(house_size$GEOID)
house_size <-  inner_join(house_size, zippy, by="GEOID")

house_size <- house_size[, -c(21:23)]

#get proportions
house_size <- house_size %>% mutate(prop_four_up =  (fourE + fiveE + sixE + sev_moreE +
                                    nfamfourE + nfamfiveE +nfamsixE + nfamsev_moreE) / totalE )

summary(house_size)

ggplot(data = house_size, aes(fill = prop_four_up)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "YlOrRd", 
                       direction = 1)

#r squared
house_model <- lm(prop_COVID ~ prop_four_up, data = house_size)

summary(house_model)


#------------------------------- end of house size


#----------------------------beginning public transportation


pub_trans <- get_acs(geography = "zcta", variables = c(bus = "B08301_011", total = "B08301_001"), 
                     state = "NY", year = 2016, geometry = T, output = "wide")

pub_trans$GEOID <- as.numeric(pub_trans$GEOID)
pub_trans <-  inner_join(pub_trans, zippy, by="GEOID")

pub_trans <- pub_trans[, -c(7:9)]

pub_trans <- pub_trans %>% mutate(prop_bus = busE/totalE)


summary(pub_trans)

ggplot(data = pub_trans, aes(fill = prop_bus)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "YlOrRd", 
                       direction = 1)

#r squared
bus_model <- lm(prop_COVID ~ prop_bus, data = pub_trans)

summary(bus_model)

#-----------------------------end of public transportation


#--------------------------------beginning of 65+

elderly <- get_acs(geography = "zcta", variables = c(m65_66 = "B01001_020", m66_67 = "B01001_021",
                   m67_68 = "B01001_022", m68_69 = "B01001_023", m69_70 = "B01001_024", m70a = "B01001_025",
                   f65_66 = "B01001_044", f66_67 = "B01001_045", f67_68 = "B01001_046", f68_69 = "B01001_047",
                   f69_70 = "B01001_048", f70a = "B01001_049", total = "B01001_001"), state = "NY", year = 2016, geometry = T, output = "wide")


elderly$GEOID <- as.numeric(elderly$GEOID)
elderly <-  inner_join(elderly, zippy, by="GEOID")

elderly <- elderly[, -c(29:31)]

elderly <- elderly %>% mutate(prop_eld =  (m65_66E + m66_67E + m67_68E + m68_69E + m69_70E+ m70aE +
                                           f65_66E + f66_67E + f67_68E + f68_69E + f69_70E+ f70aE)/totalE )

summary(elderly)

ggplot(data = elderly, aes(fill = prop_eld)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "YlOrRd", 
                       direction = 1)

#r squared
elderly_model <- lm(prop_COVID ~ prop_eld, data = elderly)

summary(elderly_model)

#--------------------------------------end of 65+


#--------------------merge tables

#unisured, white, over3, income

df_uninsured <- st_drop_geometry(df_uninsured)
race_white <- st_drop_geometry(race_white)

mergerd_table <- inner_join(df_uninsured, race_white, by="GEOID")


house_size <- st_drop_geometry(house_size)
med_inc <- st_drop_geometry(med_inc)

second_merged <- inner_join(house_size, med_inc, by="GEOID")

full_merge <- inner_join(mergerd_table, second_merged, by="GEOID")


full_lm <- lm(prop_COVID.x.y ~ pop_uninsured + prop_white + prop_four_up + income_mil, data = full_merge)


#here are the confidence intervals and estimates ----- note use kable
confint(full_lm)

summary(full_lm)
