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
  geom_pointrange(data = summary_data, aes(xmin = quantile_1, xmax = quantile_3, x = median_per_date, y = as.factor(date)), color = "red") 

#table 2 values 

library(tidycensus)
load("ses_2016_data.RData")
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