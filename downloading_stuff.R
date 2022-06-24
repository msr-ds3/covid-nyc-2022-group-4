library(tidyverse)
library(tidycensus)
library(tigris)
#uncomment below and run it in case there's an error with tibbles
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

#grab the zip codes for NYC
# came from this link https://github.com/nychealth/coronavirus-data/blob/097cbd70aa00eb635b17b177bc4546b2fce21895/tests-by-zcta.csv
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

#make zip code numeric, to match type with the other one
df_uninsured$GEOID <- as.numeric(df_uninsured$GEOID)

#join to keep the NYC zip codes
df_uninsured <-  inner_join(df_uninsured, zippy, by="GEOID")



#get rid of extra columns from zippy
df_uninsured <- df_uninsured[, -c(11:13)]



#create a column with proportion
df_uninsured <- df_uninsured %>% mutate(pop_uninsured = (pop_18_to_34E + pop_35_to_64E)/(tot_18_to_34E + tot_35_to_64E))
summary(df_uninsured)



#graph it on the map of nyc
ggplot(data = df_uninsured, aes(fill = pop_uninsured)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "YlOrRd", 
                       direction = 1)

#make a linear model
uninsured_model <- lm(prop_COVID ~ pop_uninsured, data = df_uninsured)

#get summary
summary(uninsured_model)



#-------------now for median income

#get income data
med_inc <- get_acs(geography = "zcta", variables = c(income = "B19013_001E"), state = "NY", year = 2016,
                   geometry = T, 
                   output = "wide")


#make zip code numeric, to match type with the other one
med_inc$GEOID <- as.numeric(med_inc$GEOID)

#join to keep the NYC zip codes
med_inc <-  inner_join(med_inc, zippy, by="GEOID")

#get rid of extra columns
med_inc <- med_inc[, -c(5:7)]

#summary
summary(med_inc)

#make columns to take in millions
med_inc <- med_inc %>% mutate(income_mil = income/1000000)


#graph
ggplot(data = med_inc, aes(fill = income_mil)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "YlGn", 
                       direction = 1)

#linear model, then summarise
income_model <- lm(prop_COVID ~ income_mil, data = med_inc)

summary(income_model)



#---------------end of median income


#--------------beginning of race_white

#rinse and repeat
race_white <- get_acs(geography = "zcta", variables = c(white = "B02001_002", tot = "B01001_001"), state = "NY", year = 2016,
                      geometry = T, 
                      output = "wide")

race_white$GEOID <- as.numeric(race_white$GEOID)
race_white <-  inner_join(race_white, zippy, by="GEOID")

race_white <- race_white[, -c(7:9)]

#divide to get portion
race_white <- race_white %>% mutate(prop_white = whiteE / totE)


summary(race_white)

ggplot(data = race_white, aes(fill = prop_white)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "Purples", 
                       direction = 1)


race_model <- lm(prop_COVID ~ prop_white, data = race_white)

summary(race_model)


#-------------end of race_white

#---------------------------beginning of house_size

#same as the previous
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


bus_model <- lm(prop_COVID ~ prop_bus, data = pub_trans)

summary(bus_model)

#-----------------------------end of public transportation


#--------------------------------beginning of 65+

#this one we have to combine a lot, since they do it in male and female, in increments of a couple years
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

#merge everything for the linear model
full_merge <- inner_join(mergerd_table, second_merged, by="GEOID")


full_lm <- lm(prop_COVID.x.y ~ pop_uninsured + prop_white + prop_four_up + income_mil, data = full_merge)


#here are the confidence intervals and estimates
confint(full_lm)

summary(full_lm)




#-----------plot 2 --------------


load('/data/safegraph/safegraph.Rdata')


library(tidyverse)


zippy <- read.csv("April_1_pos_tests.csv")

zippy <- zippy %>% mutate(postal_code = MODZCTA)


#zippy$postal_code <- as.numeric(zippy$postal_code)
safegraph <- inner_join(safegraph, zippy, by="postal_code")


safegraph <- safegraph[, -c(7:9)]


#to get the baseline, grab february and grab median of average visits per day
baseline_df <- safegraph %>% filter(grepl("^2020-02-", date))


baseline_df <- baseline_df %>% group_by(postal_code) %>% summarize(base_med = median(avg_visits_per_day))



#join the median of that zip code to the main table
safegraph <- inner_join(safegraph, baseline_df, by= "postal_code") 

#get the difference from median
safegraph<- safegraph %>% mutate(change_base = (avg_visits_per_day - base_med) / base_med)

#make date into a factor for the graph
safegraph$date <- as.factor(safegraph$date)

#get rid of feb since it wasn't in the paper
safegraph <- safegraph %>% filter(grepl("^2020-03-", date) | grepl("^2020-04-", date))

#get median of all zips
dates_listy <- safegraph %>% group_by(date) %>% summarise(all_zip_med = median(change_base, na.rm=TRUE), 
                                                          all_zip_quant_low = quantile(change_base, .25 ,na.rm=TRUE),
                                                          all_zip_quant_high = quantile(change_base, .75 ,na.rm=TRUE))


#plot
ggplot() +
  geom_violin(data = safegraph, aes(x = change_base, y = date), color = "orange") +
  geom_pointrange(data = dates_listy, aes(x = all_zip_med, y = date, xmin = all_zip_quant_low, xmax = all_zip_quant_high), color = "red") +
  xlim(-1,2)


#---------end of plot 2

#------------table 2

#drop the geometry columns b/c you can't join, then join everything
df_uninsured <- st_drop_geometry(df_uninsured)
race_white <- st_drop_geometry(race_white)

mergerd_table <- inner_join(df_uninsured, race_white, by="GEOID")


house_size <- st_drop_geometry(house_size)
med_inc <- st_drop_geometry(med_inc)

second_merged <- inner_join(house_size, med_inc, by="GEOID")

full_merge <- inner_join(mergerd_table, second_merged, by="GEOID")



elderly <- st_drop_geometry(elderly)

pub_trans <- st_drop_geometry(pub_trans)

third_merged <- inner_join(elderly, pub_trans, by = "GEOID")

six_merge <- inner_join(third_merged, full_merge, by="GEOID")





full_lm <- lm(prop_COVID.x.y ~ prop_eld + prop_bus + income_mil + prop_white + pop_uninsured + prop_four_up, data = six_merge)


#here are the confidence intervals and estimates -
confint(full_lm)

summary(full_lm)


#now with mobility
#first change postal code to GEOID

safegraph <- safegraph %>% rename(GEOID = postal_code)

safegraph <- safegraph %>% filter(grepl("2020-04-01", date))

library(tidyr)


seven_merge <- inner_join(six_merge, safegraph, by = "GEOID")

#drop nas and infs
seven_merge <- na.omit(seven_merge)
seven_merge <- seven_merge %>% filter(change_base != Inf)

seven_lm <- lm(prop_COVID.x.y ~ prop_eld + prop_bus + income_mil + prop_white + pop_uninsured + prop_four_up + change_base, data = seven_merge)


#table 2
confint(seven_lm)

summary(seven_lm)





#------------------end of table 2



#------------------beginning of extension question, all of NY


library(tidyverse)
library(tidycensus)
library(tigris)
#uncomment below and run it in case there's an error with tibbles
#install.packages("sf")
library(sf)


packageVersion("tibble")
packageVersion("sf")
packageVersion("vctrs")

options(tigris_use_cache = TRUE)


census_api_key("b4f929484bb795b703dd9623754054573943a66f", install = TRUE)




#uninsured
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

df_uninsured$GEOID <- as.factor(df_uninsured$GEOID)

df_uninsured <- df_uninsured %>% mutate(pop_uninsured = (pop_18_to_34E + pop_35_to_64E)/(tot_18_to_34E + tot_35_to_64E))


#income data
med_inc <- get_acs(geography = "zcta", variables = c(income = "B19013_001E"), state = "NY", year = 2016,
                   geometry = T, 
                   output = "wide")


med_inc$GEOID <- as.factor(med_inc$GEOID)
med_inc <- med_inc %>% mutate(income_mil = income/1000000)



#race white
race_white <- get_acs(geography = "zcta", variables = c(white = "B02001_002", tot = "B01001_001"), state = "NY", year = 2016,
                      geometry = T, 
                      output = "wide")

race_white$GEOID <- as.factor(race_white$GEOID)

race_white <- race_white %>% mutate(prop_white = whiteE / totE)


#house size
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


house_size$GEOID <- as.factor(house_size$GEOID)

house_size <- house_size %>% mutate(prop_four_up =  (fourE + fiveE + sixE + sev_moreE +
                                                       nfamfourE + nfamfiveE +nfamsixE + nfamsev_moreE) / totalE )



#busing
pub_trans <- get_acs(geography = "zcta", variables = c(bus = "B08301_011", total = "B08301_001"), 
                     state = "NY", year = 2016, geometry = T, output = "wide")

pub_trans$GEOID <- as.factor(pub_trans$GEOID)

pub_trans <- pub_trans %>% mutate(prop_bus = busE/totalE)



#elderly
elderly <- get_acs(geography = "zcta", variables = c(m65_66 = "B01001_020", m66_67 = "B01001_021",
                                                     m67_68 = "B01001_022", m68_69 = "B01001_023", m69_70 = "B01001_024", m70a = "B01001_025",
                                                     f65_66 = "B01001_044", f66_67 = "B01001_045", f67_68 = "B01001_046", f68_69 = "B01001_047",
                                                     f69_70 = "B01001_048", f70a = "B01001_049", total = "B01001_001"), state = "NY", year = 2016, geometry = T, output = "wide")


elderly$GEOID <- as.factor(elderly$GEOID)


elderly <- elderly %>% mutate(prop_eld =  (m65_66E + m66_67E + m67_68E + m68_69E + m69_70E+ m70aE +
                                             f65_66E + f66_67E + f67_68E + f68_69E + f69_70E+ f70aE)/totalE )




#drop the geometry columns b/c you can't join, then join everything
df_uninsured <- st_drop_geometry(df_uninsured)
race_white <- st_drop_geometry(race_white)

mergerd_table <- inner_join(df_uninsured, race_white, by="GEOID")


house_size <- st_drop_geometry(house_size)
med_inc <- st_drop_geometry(med_inc)

second_merged <- inner_join(house_size, med_inc, by="GEOID")

full_merge <- inner_join(mergerd_table, second_merged, by="GEOID")



elderly <- st_drop_geometry(elderly)

pub_trans <- st_drop_geometry(pub_trans)

third_merged <- inner_join(elderly, pub_trans, by = "GEOID")

six_merge <- inner_join(third_merged, full_merge, by="GEOID")


zippy2 <- read.csv("apr_1st_NY.csv")

zippy2$Zip_Code <- as.factor(zippy2$Zip_Code)

zippy2 <- zippy2 %>% mutate(GEOID = Zip_Code)




zippy2 <- zippy2 %>% mutate(prop_COVID = Positive_Cases/Total_Tests)



seven_merge <- inner_join(six_merge, zippy2, by = "GEOID")


full_lm <- lm(prop_COVID ~ prop_eld + prop_bus + income_mil + prop_white + pop_uninsured + prop_four_up, data = seven_merge)


#here are the confidence intervals and estimates -
confint(full_lm)

summary(full_lm)



#-------------------end of all of NY









