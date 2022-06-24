#Replicating Figure 1 results
#####################################################################################################
library(tidyverse)
library(tidycensus)
library(tigris)
library(sf)

options(tigris_use_cache = TRUE)

#load key for census data





data_16 <- load_variables(2016, "acs5", cache = TRUE) 
data_16

#zipcode list
zippy <- read.csv("April_1_pos_tests.csv")
zippy <- zippy %>% mutate(GEOID = MODZCTA) %>% mutate(prop_positive = Positive/Total)
zippy <- zippy[ ,-c(1:3)]

#load the different variables 

#proportion of 18-64 year old population that is uninsured
df_uninsured <- get_acs(geography = "zcta",
                        variables = c(pop_18_to_34 = "B27010_033",
                                      pop_35_to_64 = "B27010_050",
                                      pop_total_18_to_34 = "B27010_018",
                                      pop_total_35_to_64 = "B27010_034"),
                        state = "NY",
                        year = 2016,
                        geometry = T, 
                        output = "wide") 
df_uninsured$GEOID <- as.numeric(df_uninsured$GEOID)
#doing join to get only certain zipcodes 
df_uninsured <- inner_join(df_uninsured,zippy, by="GEOID")
          
#create a column with proportion of uninsured people in the age group 18 to 64 over the total population of the
#age group 18 to 64
df_uninsured <- df_uninsured %>% mutate(pop_uninsured = (pop_18_to_34E + pop_35_to_64E)/(pop_total_18_to_34E + pop_total_35_to_64E))
median(df_uninsured$pop_uninsured)
quantile(df_uninsured$pop_uninsured, 0.25)
quantile(df_uninsured$pop_uninsured, 0.75)

#Result - median proportion of 18 to 64 year olds with no insurance
#13.6% 

#Result - R^2 value 
model_uninsured <- lm(prop_positive ~ pop_uninsured, data = df_uninsured)
summary(model_uninsured)
#Multiple R^2 = 33.95%, Adjusted R^2 = 33.57%

#map of uninsured values
ggplot(data = df_uninsured, aes(fill = pop_uninsured)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "YlOrRd", 
                       direction = 1) + 
  labs(title = "Proportion of 18-64 year olds who are uninsured")

#median household income
df_med_income <- get_acs(geography = "zcta",
              variables = c(med_income = "B19013_001E"),
              state = "NY",
              year = 2016,
              geometry = T, 
              output = "wide") 
df_med_income$GEOID <- as.numeric(df_med_income$GEOID)
df_med_income <- inner_join(df_med_income, zippy, by="GEOID")
df_med_income <- df_med_income %>% mutate(mill_med_income = med_income/1000000)


summary(df_med_income)
ggplot(data = df_med_income, aes(fill = mill_med_income)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "YlGn", 
                       direction = 1) + 
  labs(title = "Median income (in millions, 2016$)")

#median of median household income
#60,526

#R^2 median income
model_med_income <- lm(prop_positive ~ mill_med_income, data = df_med_income)
summary(model_med_income)
#Multiple R^2 = 29.04%,  Adjusted R^2 = 28.64%

#proportion of population that identifies as white                    
df_white_only <- get_acs(geography = "zcta",
                         variables = c(white_only = "B02001_002",
                                       pop_in_zipcode = "B01001_001"),
                         state = "NY",
                         year = 2016,
                         geometry = T, 
                         output = "wide")  
df_white_only$GEOID <- as.numeric(df_white_only$GEOID)
df_white_only <- inner_join(df_white_only, zippy, by="GEOID")
df_white_only <- df_white_only %>% mutate(perc_white_only = white_onlyE/pop_in_zipcodeE)

#results from model 
summary(df_white_only)
ggplot(data = df_white_only, aes(fill = perc_white_only)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "Purples", 
                       direction = 1) + 
  labs(title = "Proportion self-identifying as White")

#median of proportion of population that identifies as white
#48.4%

#R^2 white only
model_white <- lm(prop_positive ~ perc_white_only, data = df_white_only)
summary(model_white)
#Multiple R^2 = 33.52%,  Adjusted R^2 = 33.14%

#proportion of population living with more than 3 inhabitants
df_more_than_three <- get_acs(geography = "zcta",
                              variables = c(four_pop = "B11016_005",
                                            five_pop = "B11016_006",
                                            six_pop = "B11016_007",
                                            seven_or_more_pop = "B11016_008",
                                            non_four_pop = "B11016_013",
                                            non_five_pop = "B11016_014",
                                            non_six_pop = "B11016_015",
                                            non_seven_or_more_pop = "B11016_016",
                                            total = "B11016_001"),
                              state = "NY",
                              year = 2016,
                              geometry = T, 
                              output = "wide") 
df_more_than_three$GEOID <- as.numeric(df_more_than_three$GEOID)
df_more_than_three <- inner_join(df_more_than_three, zippy, by="GEOID")
#create a column with proportion
df_more_than_three <- df_more_than_three %>% mutate(perc_pop_more_than_3 = (four_popE + five_popE + six_popE + seven_or_more_popE +
                                                                         non_four_popE + non_five_popE + non_six_popE +
                                                                         non_seven_or_more_popE)/totalE)
summary(df_more_than_three)
ggplot(data = df_more_than_three, aes(fill = perc_pop_more_than_3)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "YlOrRd", 
                       direction = 1) + 
  labs(title = "Proportion in households of 4 or more")

#median of proportion of population with more than 3 inhabitants
#23.9%

#R^2 more than 3
model_more_than_3 <- lm(prop_positive ~ perc_pop_more_than_3, data = df_more_than_three)
summary(model_more_than_3)
#Multiple R^2 = 39.3%,  Adjusted R^2 = 38.95%

#proportion of population using public transportation
df_commute <- get_acs(geography = "zcta",
                      variables = c(commute = "B08301_011",
                                    total_transport = "B08301_001"),
                      state = "NY",
                      year = 2016,
                      geometry = T, 
                      output = "wide")
df_commute$GEOID <- as.numeric(df_commute$GEOID)
df_commute <- inner_join(df_commute, zippy, by="GEOID")
#create a column with proportion
df_commute <- df_commute %>% mutate(perc_commute = commuteE/total_transportE)

#Results from population commute 
summary(df_commute)
ggplot(data = df_commute, aes(fill = perc_commute)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "YlOrRd", 
                       direction = 1) + 
  labs(title = "Proportion of population that commutes by bus")

#median of proportion of population using public transportation
#9.6%

#R^2 commute
model_commute <- lm(prop_positive ~ perc_commute, data = df_commute)
summary(model_commute)
#Multiple R^2 = 12.72%,  Adjusted R^2 = 12.22%

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
                                    elderly_total = "B01001_001"),
                      state = "NY",
                      year = 2016,
                      geometry = T, 
                      output = "wide")
df_elderly$GEOID <- as.numeric(df_elderly$GEOID)
df_elderly <- inner_join(df_elderly, zippy, by="GEOID")
df_elderly <- df_elderly %>% mutate(perc_pop_elderly = (pop_elderly_65_mE + pop_elderly_67_mE + pop_elderly_70_mE + 
                                                          pop_elderly_75_mE +  pop_elderly_80_mE + pop_elderly_85_mE +
                                                          pop_elderly_65_fE + pop_elderly_67_fE + pop_elderly_70_fE +
                                                          pop_elderly_75_fE + pop_elderly_80_fE + pop_elderly_85_fE)/ elderly_totalE)
summary(df_elderly)
ggplot(data = df_elderly, aes(fill = perc_pop_elderly)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "YlOrRd", 
                       direction = 1) + 
  labs(title = "Proportion of population 65+ years of age")

#median of proportion of population that is elderly              
#12.4%









##All graphs together
plot1 <- ggplot(data = df_uninsured, aes(fill = pop_uninsured)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "YlOrRd", 
                       direction = 1) + 
  labs(title = "Proportion of 18-64 year olds who are uninsured")
plot2 <- ggplot(data = df_med_income, aes(fill = mill_med_income)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "YlGn", 
                       direction = 1) + 
  labs(title = "Median income (in millions, 2016$)")
plot3 <- ggplot(data = df_white_only, aes(fill = perc_white_only)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "Purples", 
                       direction = 1) + 
  labs(title = "Proportion self-identifying as White")
plot4 <- ggplot(data = df_more_than_three, aes(fill = perc_pop_more_than_3)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "YlOrRd", 
                       direction = 1) + 
  labs(title = "Proportion in households of 4 or more")
plot5 <- ggplot(data = df_commute, aes(fill = perc_commute)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "YlOrRd", 
                       direction = 1) + 
  labs(title = "Proportion of population that commutes by bus")
plot6  <- ggplot(data = df_elderly, aes(fill = perc_pop_elderly)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "YlOrRd", 
                       direction = 1) + 
  labs(title = "Proportion of population 65+ years of age")
library("ggpubr")
install.packages("ggpubr")
ggarrange(plot1, plot2, plot3, plot4, plot5, plot6, 
          ncol = 3, nrow = 2)

#######################################################################################################

#Replicating Table 1 
#######################################################################################################
#R^2 elderly
model_elderly <- lm(prop_positive ~ perc_pop_elderly, data = df_elderly)
summary(model_elderly)
#Multiple R^2 = 1.29%,  Adjusted R^2 = 0.72%

#create a dataframe with only the final proportions and values needed for the regression table 1
#uninsured, white, more than 3, median income
#help from https://gis.stackexchange.com/questions/341103/error-message-when-joining-two-dataframes-with-sf-error-y-should-be-a-data-fra
df_uninsured <- st_drop_geometry(df_uninsured)
df_white_only <- st_drop_geometry(df_white_only)
df_more_than_three <- st_drop_geometry(df_more_than_three)
df_med_income <- st_drop_geometry(df_med_income)
merged_df1 <- inner_join(df_uninsured, df_white_only, by="GEOID")
merged_df2 <- inner_join(merged_df1, df_more_than_three, by="GEOID")
merged_df_final <- inner_join(merged_df2, df_med_income)

model_fit <- lm(prop_positive.x ~ mill_med_income + perc_white_only + pop_uninsured + perc_pop_more_than_3, 
                data = merged_df_final)

model_results <- summary(model_fit)
model_results
#Results
#Multiple R^2 = 0.55
#Adjusted R^2 = 0.54
#Estimate intercept = 0.46
#Estimate median income = -0.34
#Estimate white only = -0.09
#Estimate uninsured = 0.25
#Estimate more than 3 = 0.33
confint(model_fit, level=0.95)
#######################################################################################################

#Replicating Figure 2
#######################################################################################################
library(tidyverse)

load('/data/safegraph/safegraph.Rdata')

#zipcode data
zippy <- read.csv("April_1_pos_tests.csv")
zippy <- zippy %>% mutate(postal_code = MODZCTA) %>% mutate(prop_positive = Positive/Total)

#filter only february values
feb_df <- safegraph %>% filter(grepl("^2020-02-", date))

all_feb_data <- inner_join(zippy, feb_df, by = "postal_code")

#get median daily visits before the pandemic, V_z(hat)
all_feb_data <- all_feb_data %>% group_by(postal_code) %>%
  summarize(median_per_zipcode = median(avg_visits_per_day))

baseline_data <- inner_join(all_feb_data, safegraph,by="postal_code")

baseline_data <- baseline_data %>% mutate(prop_baseline_median = (avg_visits_per_day - median_per_zipcode)/(median_per_zipcode)) %>%
  filter(grepl("^2020-03-", date) | grepl("^2020-04-",date))

#data for graph
summary_data <- baseline_data %>% group_by(date) %>% filter(grepl("^2020-03-", date) | grepl("^2020-04-",date)) %>%
  summarize(median_per_date = median(prop_baseline_median, na.rm = TRUE),
            quantile_1 = quantile(prop_baseline_median, 0.25, na.rm = TRUE),
            quantile_3 = quantile(prop_baseline_median, 0.75, na.rm = TRUE))

#graph
ggplot() + 
  geom_violin(data = baseline_data, aes(x = prop_baseline_median, y = as.factor(date)), color = "orange") +
  geom_pointrange(data = summary_data, aes(xmin = quantile_1, xmax = quantile_3, x = median_per_date, y = as.factor(date)), color = "red") +
  xlim(-1,2) +
  xlab("Change in mobility relative to baseline") +
  ylab("Date")
#######################################################################################################

#Replicating Table 2
#######################################################################################################
#dropping geometry columns from data frames before merge since they cause problems when joining tables
df_uninsured <- st_drop_geometry(df_uninsured)
df_white_only <- st_drop_geometry(df_white_only)
df_more_than_three <- st_drop_geometry(df_more_than_three)
df_med_income <- st_drop_geometry(df_med_income)
df_commute <- st_drop_geometry(df_commute)
df_elderly <- st_drop_geometry(df_elderly)

#joining data files together to a new data frame to reproduce regression results
merge_df1 <- inner_join(df_uninsured, df_white_only, by="GEOID")
merge_df2 <- inner_join(merge_df1, df_more_than_three, by="GEOID")
merge_df3 <- inner_join(merge_df2, df_med_income, by="GEOID")
merge_df4 <- inner_join(merge_df3, df_commute, by="GEOID") 
merge_df5 <- inner_join(merge_df4, df_elderly, by="GEOID")

#regression model without mobility
model_fit2 <- lm(prop_positive.x ~ perc_pop_elderly + perc_commute + mill_med_income + perc_white_only + pop_uninsured + perc_pop_more_than_3, data = merge_df5)
summary(model_fit2)
confint(model_fit2,level=0.95)

baseline_data_summary <- baseline_data %>% filter(grepl("2020-04-01",date))

merge_df6 <- inner_join(merge_df5, baseline_data_summary, by="GEOID")
merge_df6 <- na.omit(merge_df6)
merge_df6 <- merge_df6 %>% filter(prop_baseline_median != Inf)

#regression model with only mobility
model_only_mobility <- lm(prop_positive.x ~ prop_baseline_median, data = merge_df6)
summary(model_only_mobility)
confint(model_only_mobility)

#regression model with mobility
model_fit_mobility <- lm(prop_positive.x ~ perc_pop_elderly + perc_commute + mill_med_income + perc_white_only + pop_uninsured + perc_pop_more_than_3 + prop_baseline_median, data = merge_df6)
summary(model_fit_mobility)
confint(model_fit_mobility,level=0.95)
#######################################################################################################
